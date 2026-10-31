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

@WebServlet("/admin/editProduct")
public class EditProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        ProductDAO dao = new ProductDAO();
        Product p = dao.getProductById(id);

        ProductImageDAO imgDAO = new ProductImageDAO();
        request.setAttribute("product", p);
        request.setAttribute("images", imgDAO.getImagesByProduct(id));
        request.setAttribute("mainImage", dao.getMainImage(id));

        request.getRequestDispatcher("/admin/editProduct.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Product p = new Product();
        p.setProductID(Integer.parseInt(request.getParameter("productID")));
        p.setCategoryID(Integer.parseInt(request.getParameter("categoryID")));
        p.setBrandID(Integer.parseInt(request.getParameter("brandID")));
        p.setProductName(request.getParameter("productName"));
        p.setPrice(Double.parseDouble(request.getParameter("price")));
        p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
        p.setDescription(request.getParameter("description"));
        p.setStatus(request.getParameter("status") != null);

        ProductDAO dao = new ProductDAO();
        dao.updateProduct(p);

        String addImageURL = request.getParameter("newImageURL");
        if (addImageURL != null && !addImageURL.trim().isEmpty()) {
            ProductImage img = new ProductImage();
            img.setProductID(p.getProductID());
            img.setImageURL(addImageURL.trim());
            img.setIsMain(false);
            img.setDisplayOrder(99);
            new ProductImageDAO().insertImage(img);
        }

        response.sendRedirect(request.getContextPath() + "/admin/product");
    }
}