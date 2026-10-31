package controller;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Brand;
import model.User;
import model.Role;
import java.io.IOException;

@WebServlet("/admin/brand")
public class BrandServlet extends HttpServlet {

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
        BrandDAO dao = new BrandDAO();

        if ("add".equals(action)) {
            request.getRequestDispatcher("/admin/addBrand.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    Brand b = dao.getBrandById(id);
                    request.setAttribute("b", b);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            request.getRequestDispatcher("/admin/editBrand.jsp").forward(request, response);
            return;
        }

        if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    dao.deleteBrand(id);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/brand");
            return;
        }

        // Default: list brands with optional search
        String keyword = request.getParameter("search");
        if (keyword != null && !keyword.trim().isEmpty()) {
            request.setAttribute("list", dao.searchBrands(keyword.trim()));
            request.setAttribute("keyword", keyword.trim());
        } else {
            request.setAttribute("list", dao.getAllBrand());
        }
        request.getRequestDispatcher("/admin/brand.jsp").forward(request, response);
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
        BrandDAO dao = new BrandDAO();

        if ("add".equals(action)) {
            Brand b = new Brand();
            b.setBrandName(request.getParameter("name"));
            b.setCountry(request.getParameter("country"));
            b.setStatus(request.getParameter("status") != null);
            dao.insertBrand(b);
            response.sendRedirect(request.getContextPath() + "/admin/brand");
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/brand");
                return;
            }

            try {
                int id = Integer.parseInt(idStr);
                Brand b = dao.getBrandById(id);
                if (b != null) {
                    b.setBrandName(request.getParameter("name"));
                    b.setCountry(request.getParameter("country"));
                    b.setStatus(request.getParameter("status") != null);
                    dao.updateBrand(b);
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/admin/brand");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/brand");
    }
}
