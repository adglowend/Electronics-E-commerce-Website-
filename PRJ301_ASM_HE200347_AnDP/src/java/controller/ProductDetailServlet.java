package controller;

import dao.ProductDAO;
import dao.ProductImageDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import model.Product;
import model.ProductImage;

@WebServlet("/customer/detail")
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        ProductDAO pdao = new ProductDAO();
        ProductImageDAO imgDao = new ProductImageDAO();

        Product p = pdao.getProductById(id);
        String mainImage = pdao.getMainImage(id);
        ArrayList<ProductImage> images = imgDao.getImagesByProduct(id);

        request.setAttribute("product", p);
        request.setAttribute("mainImage", mainImage);
        request.setAttribute("images", images);

        request.getRequestDispatcher("/customer/detail.jsp").forward(request, response);
    }
}