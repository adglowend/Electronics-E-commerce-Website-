package controller;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Brand;

@WebServlet("/admin/addBrand")
public class AddBrandServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/addBrand.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Brand b = new Brand();
        b.setBrandName(request.getParameter("name"));
        b.setCountry(request.getParameter("country"));
        b.setStatus(request.getParameter("status") != null);

        BrandDAO dao = new BrandDAO();
        dao.insertBrand(b);

        response.sendRedirect(request.getContextPath() + "/admin/brand");
    }
}