package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebServlet("/admin/updateOrder")
public class UpdateOrderServlet extends HttpServlet {

    private static final List<String> ALLOWED = Arrays.asList(
            "Pending", "Confirmed", "Shipping", "Completed", "Cancelled"
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        OrderDAO dao = new OrderDAO();
        request.setAttribute("order", dao.getAllOrder().stream()
                .filter(o -> o.getOrderID() == id).findFirst().orElse(null));
        request.getRequestDispatcher("/admin/updateOrder.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String status = request.getParameter("status");

        if (status != null && ALLOWED.contains(status)) {
            new OrderDAO().updateStatus(id, status);
        } else {
            request.getSession().setAttribute("error", "Trạng thái không hợp lệ!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders");
    }
}