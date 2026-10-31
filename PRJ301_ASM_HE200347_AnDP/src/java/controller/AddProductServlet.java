package controller;

import dao.ProductDAO;
import dao.ProductImageDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Product;
import model.ProductImage;

@WebServlet("/admin/addProduct")
public class AddProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/addProduct.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Product p = new Product();
        p.setCategoryID(Integer.parseInt(request.getParameter("categoryID")));
        p.setBrandID(Integer.parseInt(request.getParameter("brandID")));
        p.setProductName(request.getParameter("productName"));
        p.setPrice(Double.parseDouble(request.getParameter("price")));
        p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
        p.setDescription(request.getParameter("description"));
        p.setStatus(request.getParameter("status") != null);

        ProductDAO dao = new ProductDAO();
        int newID = dao.insertProduct(p);

        String imageURL = request.getParameter("imageURL");
        if (newID > 0 && imageURL != null && !imageURL.trim().isEmpty()) {
            ProductImage img = new ProductImage();
            img.setProductID(newID);
            img.setImageURL(imageURL.trim());
            img.setIsMain(true);
            img.setDisplayOrder(1);
            new ProductImageDAO().insertImage(img);
        }

        response.sendRedirect(request.getContextPath() + "/admin/product");
    }
}