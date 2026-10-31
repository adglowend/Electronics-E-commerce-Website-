package controller;

import dao.BrandDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/deleteBrand")
public class DeleteBrandServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        BrandDAO dao = new BrandDAO();

        dao.deleteBrand(id);

        response.sendRedirect(request.getContextPath()+"/admin/brand");

    }

}