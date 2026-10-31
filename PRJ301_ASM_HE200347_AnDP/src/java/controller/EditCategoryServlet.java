package controller;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Category;

@WebServlet("/admin/editCategory")
public class EditCategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        CategoryDAO dao = new CategoryDAO();
        request.setAttribute("c", dao.getCategoryById(id));
        request.getRequestDispatcher("/admin/editCategory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Category c = new Category();
        c.setCategoryID(Integer.parseInt(request.getParameter("id")));
        c.setCategoryName(request.getParameter("name"));
        c.setDescription(request.getParameter("description"));
        c.setStatus(request.getParameter("status") != null);

        CategoryDAO dao = new CategoryDAO();
        dao.updateCategory(c);

        response.sendRedirect(request.getContextPath() + "/admin/category");
    }
}