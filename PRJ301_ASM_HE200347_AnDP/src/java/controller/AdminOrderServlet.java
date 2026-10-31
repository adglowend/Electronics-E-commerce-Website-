package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.User;
import model.Role;
import java.io.IOException;
import java.text.NumberFormat;
import java.util.Locale;

@WebServlet("/admin/orders")
public class AdminOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        Role role = (Role) session.getAttribute("role");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleName = role != null ? role.getRoleName() : "";
        if (!"Admin".equalsIgnoreCase(roleName) && user.getRoleID() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        OrderDAO dao = new OrderDAO();

        if ("detail".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    Order o = dao.getOrderByID(id);
                    request.setAttribute("order", o);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            request.getRequestDispatcher("/admin/orderDetail.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    Order o = dao.getOrderByID(id);
                    request.setAttribute("order", o);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            request.getRequestDispatcher("/admin/updateOrder.jsp").forward(request, response);
            return;
        }

        // Default: list orders with optional search
        String keyword = request.getParameter("search");
        if (keyword != null && !keyword.trim().isEmpty()) {
            request.setAttribute("list", dao.searchOrders(keyword.trim()));
            request.setAttribute("keyword", keyword.trim());
        } else {
            request.setAttribute("list", dao.getAllOrder());
        }
        request.getRequestDispatcher("/admin/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        Role role = (Role) session.getAttribute("role");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleName = role != null ? role.getRoleName() : "";
        if (!"Admin".equalsIgnoreCase(roleName) && user.getRoleID() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        OrderDAO dao = new OrderDAO();

        if ("update".equals(action)) {
            String idStr = request.getParameter("id");
            String newStatus = request.getParameter("status");

            if (idStr != null && !idStr.isEmpty() && newStatus != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    dao.updateStatus(id, newStatus);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders");
    }
}
