package controller;

import dao.ProductImageDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.ProductImage;
import model.User;
import model.Role;
import model.Product;
import dao.ProductDAO;
import java.io.IOException;
import java.io.File;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.util.UUID;

@WebServlet("/admin/product-image")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 10 * 1024 * 1024,
    maxRequestSize = 50 * 1024 * 1024
)
public class ProductImageServlet extends HttpServlet {

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

        part.write(uploadPath + File.separator + fileName);
        return request.getContextPath() + "/assets/imgProduct/" + fileName;
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        Role role = (Role) session.getAttribute("role");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        String roleName = role != null ? role.getRoleName() : "";
        if (!"Admin".equalsIgnoreCase(roleName) && user.getRoleID() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) {
            return;
        }

        String action = request.getParameter("action");
        ProductImageDAO imageDao = new ProductImageDAO();
        ProductDAO productDao = new ProductDAO();

        if ("add".equals(action)) {
            String productIdStr = request.getParameter("productID");
            if (productIdStr != null && !productIdStr.isEmpty()) {
                try {
                    int productID = Integer.parseInt(productIdStr);
                    String mainImageFlag = request.getParameter("isMain");

                    java.util.Collection<Part> parts = null;
                    try {
                        parts = request.getParts();
                    } catch (Exception ignored) {}

                    int order = imageDao.getImagesByProduct(productID).size() + 1;

                    if (parts != null) {
                        for (Part part : parts) {
                            if ("imageFile".equals(part.getName()) && part.getSize() > 0) {
                                String savedURL = saveImage(part, request);
                                if (savedURL != null) {
                                    ProductImage img = new ProductImage();
                                    img.setProductID(productID);
                                    img.setImageURL(savedURL);
                                    img.setIsMain("1".equals(mainImageFlag));
                                    img.setDisplayOrder(order++);
                                    if (img.isIsMain()) {
                                        imageDao.unsetAllMain(productID);
                                    }
                                    imageDao.insertImage(img);
                                }
                            }
                        }
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        } else if ("setMain".equals(action)) {
            String imageIdStr = request.getParameter("imageID");
            String productIdStr = request.getParameter("productID");
            if (imageIdStr != null && productIdStr != null) {
                try {
                    int imageID = Integer.parseInt(imageIdStr);
                    int productID = Integer.parseInt(productIdStr);
                    imageDao.unsetAllMain(productID);
                    imageDao.setMainImage(imageID);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        } else if ("delete".equals(action)) {
            String imageIdStr = request.getParameter("imageID");
            String productIdStr = request.getParameter("productID");
            if (imageIdStr != null && productIdStr != null) {
                try {
                    int imageID = Integer.parseInt(imageIdStr);
                    int productID = Integer.parseInt(productIdStr);
                    ProductImage img = null;
                    java.util.ArrayList<ProductImage> list = imageDao.getImagesByProduct(productID);
                    for (ProductImage i : list) {
                        if (i.getImageID() == imageID) {
                            img = i;
                            break;
                        }
                    }
                    imageDao.deleteImage(imageID);
                    // If deleted the main one, promote next one
                    if (img != null && img.isIsMain()) {
                        java.util.ArrayList<ProductImage> remaining = imageDao.getImagesByProduct(productID);
                        if (!remaining.isEmpty()) {
                            imageDao.setMainImage(remaining.get(0).getImageID());
                        }
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        }

        String referer = request.getHeader("referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/product");
        }
    }
}