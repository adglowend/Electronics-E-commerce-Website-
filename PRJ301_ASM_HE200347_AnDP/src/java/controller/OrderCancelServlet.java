package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet("/customer/orders/cancel")
public class OrderCancelServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idRaw = request.getParameter("id");
        int orderID = 0;
        try {
            orderID = Integer.parseInt(idRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        OrderDAO dao = new OrderDAO();
        boolean ok = dao.cancelOrder(orderID, user.getUserID());

        session.setAttribute(ok ? "flash_ok" : "flash_err",
                             ok ? "Đã huỷ đơn hàng #" + orderID
                                : "Không thể huỷ đơn #" + orderID + " (chỉ huỷ được đơn Pending của bạn).");
        response.sendRedirect(request.getContextPath() + "/customer/orders");
    }
}