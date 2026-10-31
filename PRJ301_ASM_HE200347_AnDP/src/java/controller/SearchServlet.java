package controller;

import dao.CategoryDAO;
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
import model.Category;
import model.Product;

@WebServlet("/customer/search")
public class SearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        }
        keyword = keyword.trim();

        CategoryDAO catDao = new CategoryDAO();
        ProductDAO productDao = new ProductDAO();

        ArrayList<Product> list = productDao.searchProduct(keyword);
        ArrayList<Category> categories = catDao.getAllCategory();

        Map<Integer, String> mainImages = new HashMap<>();
        for (Product p : list) {
            mainImages.put(p.getProductID(), productDao.getMainImage(p.getProductID()));
        }

        request.setAttribute("categories", categories);
        request.setAttribute("list", list);
        request.setAttribute("mainImages", mainImages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("pageTitle",
                (keyword.isEmpty() ? "Search" : "Search: " + keyword) + " - Electro");

        request.getRequestDispatcher("/customer/search.jsp").forward(request, response);
    }
}