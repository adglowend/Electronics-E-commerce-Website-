<%@page import="java.net.URLEncoder"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="dao.CartDAO"%>
<%@page import="dao.CartItemDAO"%>
<%@page import="dao.OrderDAO"%>
<%@page import="dao.PaymentDAO"%>
<%@page import="dao.ProductDAO"%>
<%@page import="model.CartItem"%>
<%@page import="model.Order"%>
<%@page import="model.OrderDetail"%>
<%@page import="model.Payment"%>
<%@page import="model.Product"%>
<%@page import="utils.DBContext"%>
<%@page import="utils.VnpayConfig"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>

<%
    String ctx = request.getContextPath();

    // Debug log (tạm thời)
    try {
        String logLine = "[VNPAY-RETURN] hit, TxnRef="
                       + request.getParameter("vnp_TxnRef")
                       + ", RspCode=" + request.getParameter("vnp_ResponseCode")
                       + ", TxnStatus=" + request.getParameter("vnp_TransactionStatus")
                       + "\n";
        java.nio.file.Files.write(
            java.nio.file.Paths.get(System.getProperty("catalina.base"), "logs", "vnpay-return.log"),
            logLine.getBytes(StandardCharsets.UTF_8),
            java.nio.file.StandardOpenOption.CREATE,
            java.nio.file.StandardOpenOption.APPEND);
    } catch (Exception ignored) {}

    // ==== Bước 1: Build lại map field từ query string VNPay gửi về ====
    Map<String, String> fields = new HashMap<>();
    for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
        String fieldNameRaw = params.nextElement();
        String fieldName    = URLEncoder.encode(fieldNameRaw, StandardCharsets.US_ASCII.toString());
        String fieldValue   = URLEncoder.encode(request.getParameter(fieldNameRaw), StandardCharsets.US_ASCII.toString());
        if (fieldValue != null && fieldValue.length() > 0) {
            fields.put(fieldName, fieldValue);
        }
    }

    String vnp_SecureHash = request.getParameter("vnp_SecureHash");
    if (fields.containsKey("vnp_SecureHashType")) {
        fields.remove("vnp_SecureHashType");
    }
    if (fields.containsKey("vnp_SecureHash")) {
        fields.remove("vnp_SecureHash");
    }
    String signValue = VnpayConfig.hashAllFields(fields);

    // ==== Bước 2: Xác minh chữ ký ====
    boolean signatureValid  = signValue.equals(vnp_SecureHash);
    String  responseCode    = request.getParameter("vnp_ResponseCode");
    String  transactionCode = request.getParameter("vnp_TransactionStatus");
    String  orderIDStr      = request.getParameter("vnp_TxnRef");  // = OrderID
    String  amountStr       = request.getParameter("vnp_Amount");
    String  orderInfo       = request.getParameter("vnp_OrderInfo");
    String  bankCode        = request.getParameter("vnp_BankCode");
    String  payDate         = request.getParameter("vnp_PayDate");
    String  transactionNo   = request.getParameter("vnp_TransactionNo");

    boolean paymentSuccess = signatureValid
                          && "00".equals(responseCode)
                          && "00".equals(transactionCode);

    int orderID = 0;
    long totalAmount = 0;
    ArrayList<OrderDetail> orderDetails = null;
    Order order = null;
    String failReason = "";

    try {
        if (orderIDStr != null && !orderIDStr.isEmpty()) {
            orderID = Integer.parseInt(orderIDStr);
        }
    } catch (NumberFormatException ex) {
        failReason = "Mã đơn hàng không hợp lệ.";
    }

    if (orderID > 0) {
        // Tra DB lấy thông tin Order (không phụ thuộc session)
        order = new OrderDAO().getOrderByID(orderID);
        if (order == null) {
            failReason = "Không tìm thấy đơn hàng trong hệ thống.";
        } else {
            totalAmount = (long) order.getTotalAmount();
            orderDetails = new OrderDAO().getOrderDetails(orderID);
        }
    }

    if (paymentSuccess && order != null) {
        // ==== Bước 3: Thanh toán thành công → UPDATE DB ====
        try {
            // 1) Update Order.Status = "Confirmed"
            new OrderDAO().updateStatus(orderID, "Confirmed");

            // 1b) Trừ tồn kho Product theo số lượng đã mua
            new OrderDAO().decreaseStockFromOrder(orderID);

            // 2) Update Payment: status = Paid, ngày = now
            // Method giữ nguyên "COD" vì CHECK constraint của DB chỉ cho phép 'Cash' | 'COD'.
            // Việc đã thanh toán online được phân biệt qua PaymentStatus = 'Paid'.
            java.sql.Connection conn = utils.DBContext.getConnection();
            java.sql.PreparedStatement ps = conn.prepareStatement(
                "UPDATE Payment SET PaymentStatus=?, PaymentDate=? WHERE OrderID=?");
            ps.setString(1, Payment.STATUS_PAID);
            ps.setTimestamp(2, new java.sql.Timestamp(System.currentTimeMillis()));
            ps.setInt(3, orderID);
            ps.executeUpdate();
            ps.close();
            conn.close();

            // 3) Clear cart nếu user vẫn còn session
            Integer cartID = (Integer) session.getAttribute("vnpayCartID");
            if (cartID != null) {
                new CartItemDAO().clearCart(cartID);
                session.removeAttribute("cart");
            }
            session.removeAttribute("vnpayCartID");
        } catch (Exception ex) {
            ex.printStackTrace();
            failReason = "Lỗi khi cập nhật đơn hàng: " + ex.getMessage();
            paymentSuccess = false;
        }
    } else if (order != null && !"Pending".equals(order.getStatus())) {
        // Order đã được xử lý rồi (idempotent), không sửa nữa
    } else if (order != null && !paymentSuccess) {
        // Thanh toán thất bại → xoá Order Pending mồ côi (tránh rác DB)
        try {
            new OrderDAO().deleteOrder(orderID);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Kết quả thanh toán - Electro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/header.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/vnpay.css">
</head>
<body>

<%@include file="../common/customerHeader.jsp" %>

<div class="vnpay-wrap">
    <div class="container">
        <div class="vnpay-card mx-auto" style="max-width:780px; flex-direction:column;">
            <div class="vnpay-form-side" style="width:100%;">

                <% if (paymentSuccess && order != null) { %>
                    <div class="text-center">
                        <i class="fa fa-check-circle text-success" style="font-size:5rem;"></i>
                        <h2 class="mt-3 text-success">Thanh toán thành công!</h2>
                        <p class="text-muted">Đơn hàng của bạn đã được xác nhận và lưu vào hệ thống.</p>
                    </div>

                    <div class="bill-box mt-4">
                        <div class="bill-head">
                            <div>
                                <h4 class="mb-0">HÓA ĐƠN</h4>
                                <small class="text-muted">Electro - Laptop &amp; Computer Store</small>
                            </div>
                            <div class="text-end">
                                <strong>Mã đơn:</strong> #<%= orderID %><br>
                                <small class="text-muted">
                                    <%= order.getOrderDate() != null
                                        ? new SimpleDateFormat("dd/MM/yyyy HH:mm").format(order.getOrderDate())
                                        : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %>
                                </small>
                            </div>
                        </div>

                        <table class="table bill-table mt-3 mb-0">
                            <thead>
                                <tr>
                                    <th>Sản phẩm</th>
                                    <th class="text-center" style="width:80px;">SL</th>
                                    <th class="text-end" style="width:140px;">Đơn giá</th>
                                    <th class="text-end" style="width:140px;">Thành tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                // Cache tra cứu product để khỏi gọi DB lặp cho cùng ProductID
                                Map<Integer, Product> productCache = new HashMap<>();
                                Map<Integer, String>   imageCache   = new HashMap<>();
                                ProductDAO productDAO = new ProductDAO();

                                if (orderDetails != null) {
                                    for (OrderDetail od : orderDetails) {
                                        int qty    = od.getQuantity();
                                        double price = od.getPrice();
                                        double line = qty * price;
                                        int productID = od.getProductID();

                                        // Lấy thông tin Product (name) — cache theo productID
                                        String productName = "(Sản phẩm không tồn tại)";
                                        Product cached = productCache.get(productID);
                                        if (cached == null) {
                                            cached = productDAO.getProductById(productID);
                                            if (cached != null) {
                                                productCache.put(productID, cached);
                                            }
                                        }
                                        if (cached != null && cached.getProductName() != null) {
                                            productName = cached.getProductName();
                                        }

                                        // Lấy ảnh đại diện (IsMain) — cache theo productID
                                        String imageURL = imageCache.get(productID);
                                        if (imageURL == null) {
                                            imageURL = productDAO.getMainImage(productID);
                                            imageCache.put(productID, imageURL != null ? imageURL : "");
                                        }
                                        if (imageURL.isEmpty()) {
                                            // Placeholder SVG inline — không cần file vật lý
                                            imageURL = "data:image/svg+xml;utf8,"
                                                     + "<svg xmlns='http://www.w3.org/2000/svg' width='56' height='56'>"
                                                     + "<rect width='100%' height='100%' fill='%23f1f3f5'/>"
                                                     + "<text x='50%25' y='50%25' dominant-baseline='middle' "
                                                     + "text-anchor='middle' font-family='Arial' font-size='10' fill='%236c757d'>"
                                                     + "No image</text></svg>";
                                        }
                            %>
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="<%= imageURL %>"
                                                 alt="<%= productName %>"
                                                 class="bill-product-img"
                                                 onerror="this.onerror=null;this.src='data:image/svg+xml;utf8,&lt;svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2256%22 height=%2256%22&gt;&lt;rect width=%22100%25%22 height=%22100%25%22 fill=%22%23f1f3f5%22/&gt;&lt;/svg&gt;';">
                                            <div>
                                                <div class="bill-product-name"><%= productName %></div>
                                                <small class="text-muted">Mã SP: #<%= productID %></small>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-center"><%= qty %></td>
                                    <td class="text-end"><%= String.format("%,d", (long) price) %></td>
                                    <td class="text-end"><%= String.format("%,d", (long) line) %></td>
                                </tr>
                            <%
                                    }
                                }
                            %>
                            </tbody>
                            <tfoot>
                                <tr class="bill-total">
                                    <td colspan="3" class="text-end"><strong>Tổng cộng:</strong></td>
                                    <td class="text-end text-danger"><strong><%= String.format("%,d", totalAmount) %> VND</strong></td>
                                </tr>
                            </tfoot>
                        </table>

                        <div class="bill-meta mt-3">
                            <div><strong>Phương thức:</strong> <span class="badge bg-primary">VNPay</span></div>
                            <div><strong>Ngân hàng:</strong> <%= bankCode != null ? bankCode : "" %></div>
                            <div><strong>Mã GD VNPay:</strong> <%= transactionNo != null ? transactionNo : "" %></div>
                            <div><strong>Thời gian TT:</strong> <%= payDate != null ? payDate : "" %></div>
                        </div>
                    </div>

                    <div class="d-flex gap-2 mt-4 flex-wrap">
                        <a href="<%=ctx%>/customer/orders" class="btn btn-vnpay flex-fill">
                            <i class="fa fa-list me-1"></i>Xem đơn hàng
                        </a>
                        <a href="<%=ctx%>/home" class="btn vnpay-back-btn flex-fill">
                            <i class="fa fa-home me-1"></i>Trang chủ
                        </a>
                    </div>

                <% } else { %>
                    <div class="text-center">
                        <i class="fa fa-times-circle text-danger" style="font-size:5rem;"></i>
                        <h2 class="mt-3 text-danger">Thanh toán không thành công</h2>
                        <p class="text-muted">
                            <% if (!signatureValid) { %>
                                Sai chữ ký (checksum không hợp lệ). Đơn hàng không được lưu.
                            <% } else if (!failReason.isEmpty()) { %>
                                <%= failReason %>
                            <% } else { %>
                                Giao dịch bị huỷ hoặc thất bại. Đơn hàng đã được huỷ trong hệ thống.
                            <% } %>
                        </p>
                    </div>

                    <div class="d-flex gap-2 mt-3 flex-wrap">
                        <a href="<%=ctx%>/customer/cart" class="btn btn-vnpay flex-fill">
                            <i class="fa fa-shopping-cart me-1"></i>Về giỏ hàng
                        </a>
                        <a href="<%=ctx%>/home" class="btn vnpay-back-btn flex-fill">
                            <i class="fa fa-home me-1"></i>Trang chủ
                        </a>
                    </div>
                <% } %>

            </div>
        </div>
    </div>
</div>

<%@include file="../common/customerFooter.jsp" %>

</body>
</html>