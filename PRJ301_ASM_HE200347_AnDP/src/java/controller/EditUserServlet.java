package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Role;
import model.User;

@WebServlet("/admin/editUser")
public class EditUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        UserDAO dao = new UserDAO();
        User u = dao.getUserById(id);

        Role currentRole = u != null ? dao.getRoleByID(u.getRoleID()) : null;

        request.setAttribute("user", u);
        request.setAttribute("currentRoleName", currentRole != null ? currentRole.getRoleName() : "");

        request.getRequestDispatcher("/admin/editUser.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        UserDAO dao = new UserDAO();

        User u = new User();
        u.setUserID(Integer.parseInt(request.getParameter("id")));
        u.setFullName(request.getParameter("fullName"));
        u.setEmail(request.getParameter("email"));
        u.setPasswordHash(request.getParameter("password"));
        u.setPhone(request.getParameter("phone"));
        u.setAddress(request.getParameter("address"));
        u.setRoleID(dao.getRoleIDByName(request.getParameter("role")));
        u.setStatus(request.getParameter("status") != null);

        dao.updateUser(u);

        response.sendRedirect(request.getContextPath() + "/admin/user");
    }
}