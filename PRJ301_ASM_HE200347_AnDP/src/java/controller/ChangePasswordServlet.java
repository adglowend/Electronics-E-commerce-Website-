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

@WebServlet("/customer/changePassword")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/customer/changePassword.jsp")
                .forward(request, response);

    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        User user = (User) session.getAttribute("account");

        String oldPassword = request.getParameter("oldPassword");

        String newPassword = request.getParameter("newPassword");

        String confirmPassword = request.getParameter("confirmPassword");

        if (!user.getPasswordHash().equals(oldPassword)) {

            request.setAttribute("error", "Old password is incorrect!");

            request.getRequestDispatcher("/customer/changePassword.jsp")
                    .forward(request, response);

            return;

        }

        if (!newPassword.equals(confirmPassword)) {

            request.setAttribute("error", "Confirm password does not match!");

            request.getRequestDispatcher("/customer/changePassword.jsp")
                    .forward(request, response);

            return;

        }

        UserDAO dao = new UserDAO();

        dao.changePassword(user.getUserID(), newPassword);

        user.setPasswordHash(newPassword);

        session.setAttribute("account", user);

        request.setAttribute("message", "Change password successfully!");

        request.getRequestDispatcher("/customer/changePassword.jsp")
                .forward(request, response);

    }

}