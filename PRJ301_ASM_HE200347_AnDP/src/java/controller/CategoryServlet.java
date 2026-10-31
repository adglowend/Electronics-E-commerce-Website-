package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;
import model.User;
import model.Role;
import java.io.IOException;

@WebServlet("/admin/category")
public class CategoryServlet extends HttpServlet {

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
        CategoryDAO dao = new CategoryDAO();

        if ("add".equals(action)) {
            request.getRequestDispatcher("/admin/addCategory.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    Category c = dao.getCategoryById(id);
                    request.setAttribute("c", c);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            request.getRequestDispatcher("/admin/editCategory.jsp").forward(request, response);
            return;
        }

        if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    dao.deleteCategory(id);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/category");
            return;
        }

        // Default: list categories with optional search
        String keyword = request.getParameter("search");
        if (keyword != null && !keyword.trim().isEmpty()) {
            request.setAttribute("list", dao.searchCategories(keyword.trim()));
            request.setAttribute("keyword", keyword.trim());
        } else {
            request.setAttribute("list", dao.getAllCategory());
        }
        request.getRequestDispatcher("/admin/category.jsp").forward(request, response);
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
        CategoryDAO dao = new CategoryDAO();

        if ("add".equals(action)) {
            Category c = new Category();
            c.setCategoryName(request.getParameter("name"));
            c.setDescription(request.getParameter("description"));
            c.setStatus(request.getParameter("status") != null);
            dao.insertCategory(c);
            response.sendRedirect(request.getContextPath() + "/admin/category");
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/category");
                return;
            }

            try {
                int id = Integer.parseInt(idStr);
                Category c = dao.getCategoryById(id);
                if (c != null) {
                    c.setCategoryName(request.getParameter("name"));
                    c.setDescription(request.getParameter("description"));
                    c.setStatus(request.getParameter("status") != null);
                    dao.updateCategory(c);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/admin/category");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/category");
    }
}
