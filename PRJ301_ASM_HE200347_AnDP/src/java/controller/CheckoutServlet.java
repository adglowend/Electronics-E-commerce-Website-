package controller;

import dao.CartDAO;
import dao.CartItemDAO;
import dao.OrderDAO;
import dao.PaymentDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import model.CartItem;
import model.Order;
import model.OrderDetail;
import model.Payment;
import model.User;

@WebServlet("/customer/checkout")
public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer cartID = (Integer) session.getAttribute("cartID");
        if (cartID == null) {
            cartID = new CartDAO().getOrCreateCart(user.getUserID());
            session.setAttribute("cartID", cartID);
        }

        ArrayList<CartItem> cart = new CartItemDAO().getCartItems(cartID);
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/cart");
            return;
        }

        double total = 0;
        for (CartItem item : cart) {
            total += item.getTotal();
        }
        long totalLong = (long) total;

        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null) paymentMethod = "COD";

        // ===== Tạo Order (status Pending) + OrderDetails ngay từ đầu =====
        // Dù chọn COD hay VNPay, Order đều phải được lưu vào DB ngay từ đầu
        // (tránh phụ thuộc session, đồng thời có thể tra cứu lại khi cần).
        Order order = new Order();
        order.setUserID(user.getUserID());
        order.setTotalAmount(total);
        order.setStatus("Pending");

        int orderID = new OrderDAO().insertOrder(order);
        if (orderID == 0) {
            request.setAttribute("error", "Không thể tạo đơn hàng. Vui lòng thử lại!");
            request.getRequestDispatcher("/customer/cart.jsp").forward(request, response);
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        for (CartItem item : cart) {
            OrderDetail od = new OrderDetail();
            od.setOrderID(orderID);
            od.setProductID(item.getProductID());
            od.setQuantity(item.getQuantity());
            od.setPrice(item.getProduct().getPrice());
            orderDAO.insertOrderDetail(od);
        }

        if ("VNPay".equalsIgnoreCase(paymentMethod)) {
            // ===== VNPay flow =====
            // Schema Payment.Method chỉ chấp nhận 'Cash' | 'COD' (CHECK constraint).
            // Vì về bản chất VNPay chỉ là cổng thanh toán thay tiền mặt, ta ghi method = "COD",
            // còn phân biệt đã thanh toán online hay chưa thông qua PaymentStatus.
            //   - Trước thanh toán: method=COD, status=Pending (chờ user trả tiền online)
            //   - Sau thanh toán:  method=COD, status=Paid   (đã nhận tiền qua VNPay)
            // Thông tin VNPay (mã GD, ngân hàng, payDate) lưu trên URL return.jsp,
            // không cần thêm cột DB.
            Payment payment = new Payment();
            payment.setOrderID(orderID);
            payment.setMethod(Payment.METHOD_COD);
            payment.setPaymentStatus(Payment.STATUS_PENDING);
            payment.setPaymentDate(null);
            new PaymentDAO().insertPayment(payment);

            session.setAttribute("vnpayCartID", cartID);

            response.sendRedirect(request.getContextPath()
                    + "/vnpay/pay?orderId=" + orderID + "&amount=" + totalLong);
            return;
        }

        // ===== COD flow =====
        Payment payment = new Payment();
        payment.setOrderID(orderID);
        payment.setMethod(Payment.METHOD_COD);
        payment.setPaymentStatus(Payment.STATUS_PENDING);
        payment.setPaymentDate(null);
        new PaymentDAO().insertPayment(payment);

        // COD: chuyển Order thành Confirmed luôn, clear cart
        orderDAO.updateStatus(orderID, "Confirmed");
        // Trừ tồn kho Product theo số lượng đã mua
        orderDAO.decreaseStockFromOrder(orderID);

        new CartItemDAO().clearCart(cartID);
        session.removeAttribute("cart");

        request.setAttribute("message", "Order placed successfully! (COD)");
        request.setAttribute("orderID", orderID);
        request.getRequestDispatcher("/customer/success.jsp").forward(request, response);
    }
}