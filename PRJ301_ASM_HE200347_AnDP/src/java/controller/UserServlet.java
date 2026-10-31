package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Role;
import model.User;
import java.io.IOException;

@WebServlet("/admin/user")
public class UserServlet extends HttpServlet {

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
        UserDAO dao = new UserDAO();

        if ("add".equals(action)) {
            request.getRequestDispatcher("/admin/addUser.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    User u = dao.getUserById(id);
                    if (u != null) {
                        Role r = dao.getRoleByID(u.getRoleID());
                        request.setAttribute("user", u);
                        request.setAttribute("currentRoleName", r != null ? r.getRoleName() : "");
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            request.getRequestDispatcher("/admin/editUser.jsp").forward(request, response);
            return;
        }

        if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    dao.deleteUser(id);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/user");
            return;
        }

        // Default: list users with optional search
        String keyword = request.getParameter("search");
        if (keyword != null && !keyword.trim().isEmpty()) {
            request.setAttribute("list", dao.searchUsers(keyword.trim()));
            request.setAttribute("keyword", keyword.trim());
        } else {
            request.setAttribute("list", dao.getAllUser());
        }
        request.getRequestDispatcher("/admin/user.jsp").forward(request, response);
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
        UserDAO dao = new UserDAO();

        if ("add".equals(action)) {
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
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/user");
                return;
            }

            try {
                int id = Integer.parseInt(idStr);
                User existingUser = dao.getUserById(id);
                if (existingUser != null) {
                    existingUser.setFullName(request.getParameter("fullName"));
                    existingUser.setEmail(request.getParameter("email"));
                    existingUser.setPasswordHash(request.getParameter("password"));
                    existingUser.setPhone(request.getParameter("phone"));
                    existingUser.setAddress(request.getParameter("address"));
                    existingUser.setRoleID(dao.getRoleIDByName(request.getParameter("role")));
                    existingUser.setStatus(request.getParameter("status") != null);

                    dao.updateUser(existingUser);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/admin/user");
            return;
        }

        // Default redirect
        response.sendRedirect(request.getContextPath() + "/admin/user");
    }
}
