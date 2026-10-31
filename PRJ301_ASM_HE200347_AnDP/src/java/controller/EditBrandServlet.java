package controller;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Brand;

@WebServlet("/admin/editBrand")
public class EditBrandServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        BrandDAO dao = new BrandDAO();
        request.setAttribute("b", dao.getBrandById(id));
        request.getRequestDispatcher("/admin/editBrand.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Brand b = new Brand();
        b.setBrandID(Integer.parseInt(request.getParameter("id")));
        b.setBrandName(request.getParameter("name"));
        b.setCountry(request.getParameter("country"));
        b.setStatus(request.getParameter("status") != null);

        BrandDAO dao = new BrandDAO();
        dao.updateBrand(b);

        response.sendRedirect(request.getContextPath() + "/admin/brand");
    }
}