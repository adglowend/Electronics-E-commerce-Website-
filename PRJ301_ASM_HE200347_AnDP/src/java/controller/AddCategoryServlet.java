package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Category;

@WebServlet("/admin/addCategory")
public class AddCategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/addCategory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Category c = new Category();
        c.setCategoryName(request.getParameter("name"));
        c.setDescription(request.getParameter("description"));
        c.setStatus(request.getParameter("status") != null);

        CategoryDAO dao = new CategoryDAO();
        dao.insertCategory(c);

        response.sendRedirect(request.getContextPath() + "/admin/category");
    }
}