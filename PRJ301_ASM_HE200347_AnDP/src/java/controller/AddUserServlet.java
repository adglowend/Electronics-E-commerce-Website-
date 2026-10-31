package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet("/admin/addUser")
public class AddUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/addUser.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UserDAO dao = new UserDAO();

        User u = new User();
        u.setFullName(request.getParameter("fullName"));
        u.setEmail(request.getParameter("email"));
        u.setPasswordHash(request.getParameter("password"));
        u.setPhone(request.getParameter("phone"));
        u.setAddress(request.getParameter("address"));
        u.setRoleID(dao.getRoleIDByName(request.getParameter("role")));
        u.setStatus(request.getParameter("status") != null);

        dao.insertUser(u);

        response.sendRedirect(request.getContextPath() + "/admin/user");
    }
}