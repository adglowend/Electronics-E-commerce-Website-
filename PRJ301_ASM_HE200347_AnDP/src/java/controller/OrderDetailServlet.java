package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import model.Order;
import model.OrderDetail;
import model.User;

@WebServlet("/customer/orders/detail")
public class OrderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
        Order order = dao.getOrderByID(orderID);

        // Bảo mật: chỉ chính chủ mới xem được
        if (order == null || order.getUserID() != user.getUserID()) {
            response.sendRedirect(request.getContextPath() + "/customer/orders");
            return;
        }

        ArrayList<OrderDetail> details = dao.getOrderDetails(orderID);
        request.setAttribute("order", order);
        request.setAttribute("details", details);
        request.setAttribute("canCancel", "Pending".equalsIgnoreCase(order.getStatus()));

        request.getRequestDispatcher("/customer/order-detail.jsp").forward(request, response);
    }
}