package controller;

import dao.ProductDAO;
import dao.CategoryDAO;
import dao.BrandDAO;
import dao.ProductImageDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.Product;
import model.ProductImage;
import model.User;
import model.Role;
import java.io.IOException;
import java.io.File;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.UUID;

@WebServlet("/admin/product")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        Role role = (Role) session.getAttribute("role");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleName = role != null ? role.getRoleName() : "";
        if (!"Admin".equalsIgnoreCase(roleName) && user.getRoleID() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        ProductDAO dao = new ProductDAO();

        if ("add".equals(action)) {
            request.getRequestDispatcher("/admin/addProduct.jsp").forward(request, response);
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    Product p = dao.getProductById(id);
                    if (p != null) {
                        String mainImage = dao.getMainImage(id);
                        request.setAttribute("product", p);
                        request.setAttribute("mainImage", mainImage);
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            request.getRequestDispatcher("/admin/editProduct.jsp").forward(request, response);
            return;
        }

        if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    int id = Integer.parseInt(idStr);
                    dao.deleteProduct(id);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/product");
            return;
        }

        // Default: list products with optional search
        String keyword = request.getParameter("search");
        if (keyword != null && !keyword.trim().isEmpty()) {
            request.setAttribute("list", dao.searchProducts(keyword.trim()));
            request.setAttribute("keyword", keyword.trim());
        } else {
            request.setAttribute("list", dao.getAllProduct());
        }
        request.getRequestDispatcher("/admin/product.jsp").forward(request, response);
    }

    private String saveImage(Part part, HttpServletRequest request) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }
        String originalName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String ext = "";
        int dot = originalName.lastIndexOf('.');
        if (dot > 0) {
            ext = originalName.substring(dot);
        }
        String fileName = UUID.randomUUID().toString() + ext;

        String uploadPath = request.getServletContext().getRealPath("/assets/imgProduct");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fullPath = uploadPath + File.separator + fileName;
        part.write(fullPath);

        return request.getContextPath() + "/assets/imgProduct/" + fileName;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        Role role = (Role) session.getAttribute("role");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleName = role != null ? role.getRoleName() : "";
        if (!"Admin".equalsIgnoreCase(roleName) && user.getRoleID() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        ProductDAO dao = new ProductDAO();
        ProductImageDAO imageDao = new ProductImageDAO();

        if ("add".equals(action)) {
            Product p = new Product();
            p.setProductName(request.getParameter("productName"));
            p.setCategoryID(Integer.parseInt(request.getParameter("categoryID")));
            p.setBrandID(Integer.parseInt(request.getParameter("brandID")));
            p.setPrice(Double.parseDouble(request.getParameter("price")));
            p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
            p.setDescription(request.getParameter("description"));
            p.setStatus(request.getParameter("status") != null);

            int productId = dao.insertProduct(p);

            // Handle multiple uploaded files
            java.util.Collection<Part> parts = null;
            try {
                parts = request.getParts();
            } catch (Exception ignored) {}

            int order = 1;
            boolean mainAssigned = false;
            if (parts != null) {
                for (Part part : parts) {
                    if ("imageFile".equals(part.getName()) && part.getSize() > 0) {
                        String savedURL = saveImage(part, request);
                        if (savedURL != null) {
                            ProductImage img = new ProductImage();
                            img.setProductID(productId);
                            img.setImageURL(savedURL);
                            img.setIsMain(!mainAssigned);
                            img.setDisplayOrder(order++);
                            imageDao.insertImage(img);
                            mainAssigned = true;
                        }
                    }
                }
            }

            // Fallback to URL if no file uploaded
            if (!mainAssigned) {
                String imageURL = request.getParameter("imageURL");
                if (imageURL != null && !imageURL.trim().isEmpty()) {
                    ProductImage img = new ProductImage();
                    img.setProductID(productId);
                    img.setImageURL(imageURL);
                    img.setIsMain(true);
                    img.setDisplayOrder(1);
                    imageDao.insertImage(img);
                }
            }

            response.sendRedirect(request.getContextPath() + "/admin/product");
            return;
        }

        if ("edit".equals(action)) {
            String idStr = request.getParameter("productID");
            if (idStr == null || idStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/product");
                return;
            }

            try {
                int id = Integer.parseInt(idStr);
                Product p = dao.getProductById(id);
                if (p != null) {
                    p.setProductName(request.getParameter("productName"));
                    p.setCategoryID(Integer.parseInt(request.getParameter("categoryID")));
                    p.setBrandID(Integer.parseInt(request.getParameter("brandID")));
                    p.setPrice(Double.parseDouble(request.getParameter("price")));
                    p.setQuantity(Integer.parseInt(request.getParameter("quantity")));
                    p.setDescription(request.getParameter("description"));
                    p.setStatus(request.getParameter("status") != null);

                    dao.updateProduct(p);

                    // Insert new image: priority to uploaded file, then URL
                    Part imagePart = null;
                    try {
                        imagePart = request.getPart("imageFile");
                    } catch (Exception ignored) {}
                    String savedImageURL = saveImage(imagePart, request);

                    String newImageURL = savedImageURL != null ? savedImageURL : request.getParameter("newImageURL");
                    if (newImageURL != null && !newImageURL.trim().isEmpty()) {
                        ProductImage img = new ProductImage();
                        img.setProductID(id);
                        img.setImageURL(newImageURL);
                        img.setIsMain(true);
                        img.setDisplayOrder(1);
                        imageDao.insertImage(img);
                    }
                }
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/admin/product");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/product");
    }
}
