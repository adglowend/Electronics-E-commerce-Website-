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

@WebServlet("/customer/orders")
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        User user = (User) session.getAttribute("account");

        if (user == null) {

            response.sendRedirect(request.getContextPath() + "/login");

            return;

        }

        OrderDAO dao = new OrderDAO();

        request.setAttribute("list",
                dao.getOrderByUser(user.getUserID()));

        request.getRequestDispatcher("/customer/orders.jsp")
                .forward(request, response);

    }

}