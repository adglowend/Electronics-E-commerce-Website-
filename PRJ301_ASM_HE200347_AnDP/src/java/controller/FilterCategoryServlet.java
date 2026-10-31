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

@WebServlet("/customer/category")
public class FilterCategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idRaw = request.getParameter("id");
        int id = 0;
        try {
            id = Integer.parseInt(idRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        CategoryDAO catDao = new CategoryDAO();
        ProductDAO productDao = new ProductDAO();

        Category current = catDao.getCategoryById(id);
        if (current == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        ArrayList<Category> categories = catDao.getAllCategory();

        // ===== Pagination =====
        int pageSize = 15;
        int currentPage = 1;
        try {
            String p = request.getParameter("page");
            if (p != null && !p.trim().isEmpty()) {
                currentPage = Math.max(1, Integer.parseInt(p.trim()));
            }
        } catch (NumberFormatException ignore) {}

        int totalItems = productDao.countProductByCategory(id);
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        if (totalPages < 1) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        ArrayList<Product> list = productDao.getProductByCategoryPaged(id, currentPage, pageSize);
        int startIndex = (currentPage - 1) * pageSize;
        int endIndex   = Math.min(startIndex + list.size(), totalItems);

        Map<Integer, String> mainImages = new HashMap<>();
        for (Product p2 : list) {
            mainImages.put(p2.getProductID(), productDao.getMainImage(p2.getProductID()));
        }

        request.setAttribute("categories", categories);
        request.setAttribute("currentCategory", current);
        request.setAttribute("list", list);
        request.setAttribute("mainImages", mainImages);
        request.setAttribute("active", current.getCategoryName().toLowerCase());
        request.setAttribute("pageTitle", current.getCategoryName() + " - Electro");

        // Pagination attributes for JSP
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("startIndex", startIndex);
        request.setAttribute("endIndex", endIndex);
        request.setAttribute("baseUrl", request.getContextPath() + "/customer/category");
        request.setAttribute("extraParams", "&id=" + id);

        request.getRequestDispatcher("/customer/category.jsp").forward(request, response);
    }
}