<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.*"%>
<%@page import="dao.ProductDAO"%>
<%@page import="model.Order"%>
<%@page import="model.OrderDetail"%>
<%@page import="model.Product"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    request.setAttribute("pageTitle", "Order Detail - Electro");
    request.setAttribute("active", "orders");
    Order order = (Order) request.getAttribute("order");
    ArrayList<OrderDetail> details = (ArrayList<OrderDetail>) request.getAttribute("details");
    boolean canCancel = Boolean.TRUE.equals(request.getAttribute("canCancel"));

    String ctx = request.getContextPath();

    if (order == null) {
        response.sendRedirect(ctx + "/customer/orders");
        return;
    }

    String st = order.getStatus() == null ? "" : order.getStatus().toLowerCase();
    String cls = "status-pending";
    if (st.contains("confirm"))        cls = "status-confirmed";
    else if (st.contains("ship") || st.contains("deliver")) cls = "status-shipping";
    else if (st.contains("complet") || st.contains("done")) cls = "status-completed";
    else if (st.contains("cancel") || st.contains("reject")) cls = "status-cancelled";

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    ProductDAO productDAO = new ProductDAO();
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/orders.css">
<link rel="stylesheet" href="<%=ctx%>/assets/css/vnpay.css">

<section class="container py-5">
    <div class="d-flex align-items-center mb-3 gap-2">
        <a href="<%=ctx%>/customer/orders" class="btn btn-sm btn-outline-secondary rounded-pill">
            <i class="fa fa-arrow-left me-1"></i> Quay lại
        </a>
        <h4 class="mb-0"><i class="fa fa-file-invoice me-2 text-primary"></i>Chi tiết đơn hàng</h4>
        <div class="ms-auto d-flex gap-2">
            <a href="<%=ctx%>/customer/orders/export/pdf?id=<%= order.getOrderID() %>"
               class="btn btn-sm btn-danger rounded-pill">
                <i class="fa fa-file-pdf me-1"></i> Export PDF
            </a>
        </div>
    </div>

    <div class="bill-box">
        <div class="bill-head">
            <div>
                <h4 class="mb-0">HÓA ĐƠN</h4>
                <small class="text-muted">Electro - Laptop &amp; Computer Store</small>
            </div>
            <div class="text-end">
                <strong>Mã đơn:</strong> #<%= order.getOrderID() %><br>
                <small class="text-muted">
                    <%= order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "" %>
                </small>
                <div class="mt-1">
                    <span class="status-badge <%=cls%>"><%= order.getStatus() %></span>
                </div>
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
                Map<Integer, Product> productCache = new HashMap<>();
                Map<Integer, String>  imageCache   = new HashMap<>();

                if (details != null) {
                    for (OrderDetail od : details) {
                        int qty    = od.getQuantity();
                        double price = od.getPrice();
                        double line = qty * price;
                        int productID = od.getProductID();

                        String productName = "(Sản phẩm không tồn tại)";
                        Product cached = productCache.get(productID);
                        if (cached == null) {
                            cached = productDAO.getProductById(productID);
                            if (cached != null) productCache.put(productID, cached);
                        }
                        if (cached != null && cached.getProductName() != null) {
                            productName = cached.getProductName();
                        }

                        String imageURL = imageCache.get(productID);
                        if (imageURL == null) {
                            imageURL = productDAO.getMainImage(productID);
                            imageCache.put(productID, imageURL != null ? imageURL : "");
                        }
                        if (imageURL.isEmpty()) {
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
                            <img src="<%= imageURL %>" alt="<%= productName %>"
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
                    <td class="text-end text-danger">
                        <strong><%= String.format("%,d", (long) order.getTotalAmount()) %> VND</strong>
                    </td>
                </tr>
            </tfoot>
        </table>
    </div>

    <% if (canCancel) { %>
        <div class="bill-box mt-3 d-flex align-items-center justify-content-between flex-wrap gap-2"
             style="border-style:dashed; background:#fff8f8;">
            <div>
                <i class="fa fa-info-circle text-warning me-1"></i>
                Đơn đang ở trạng thái <strong>Pending</strong>. Bạn có thể huỷ trước khi được xử lý.
            </div>
            <form action="<%=ctx%>/customer/orders/cancel" method="post"
                  onsubmit="return confirm('Huỷ đơn #<%= order.getOrderID() %>? Hành động này không thể hoàn tác.');">
                <input type="hidden" name="id" value="<%= order.getOrderID() %>">
                <button type="submit" class="btn btn-danger rounded-pill px-4">
                    <i class="fa fa-times me-1"></i>Huỷ đơn hàng
                </button>
            </form>
        </div>
    <% } else { %>
        <div class="bill-box mt-3 text-muted">
            <i class="fa fa-lock me-1"></i>
            Đơn đã ở trạng thái <strong><%= order.getStatus() %></strong>, không thể huỷ.
        </div>
    <% } %>
</section>

<%@include file="../common/customerFooter.jsp" %>