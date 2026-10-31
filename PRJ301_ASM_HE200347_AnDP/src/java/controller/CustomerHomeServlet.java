package controller;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import model.Product;

@WebServlet("/customer/home")
public class CustomerHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductDAO dao = new ProductDAO();
        ArrayList<Product> list = dao.getAllProduct();

        Map<Integer, String> mainImages = new HashMap<>();
        for (Product p : list) {
            mainImages.put(p.getProductID(), dao.getMainImage(p.getProductID()));
        }

        request.setAttribute("list", list);
        request.setAttribute("mainImages", mainImages);
        request.setAttribute("active", "home");

        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}