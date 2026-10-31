package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet("/customer/profile")
public class ProfileServlet extends HttpServlet {

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

        request.setAttribute("user", user);

        request.getRequestDispatcher("/customer/profile.jsp")
                .forward(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        User user = (User) session.getAttribute("account");

        user.setFullName(request.getParameter("fullname"));

        user.setPhone(request.getParameter("phone"));

        user.setAddress(request.getParameter("address"));

        UserDAO dao = new UserDAO();

        dao.updateProfile(user);

        session.setAttribute("account", user);

        response.sendRedirect(request.getContextPath() + "/customer/profile");

    }

}