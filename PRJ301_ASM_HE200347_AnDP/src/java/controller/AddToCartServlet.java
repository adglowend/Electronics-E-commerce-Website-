package controller;

import dao.CartDAO;
import dao.CartItemDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.CartItem;
import model.Product;
import model.User;

@WebServlet("/customer/addCart")
public class AddToCartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int productID = Integer.parseInt(request.getParameter("id"));
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Product p = new ProductDAO().getProductById(productID);
        if (p == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        int cartID = new CartDAO().getOrCreateCart(user.getUserID());
        session.setAttribute("cartID", cartID);

        CartItem existing = new CartItemDAO().findItem(cartID, productID);
        int currentQty = existing != null ? existing.getQuantity() : 0;
        int stock = p.getQuantity();

        if (currentQty + 1 > stock) {
            session.setAttribute("error", "Cannot add: only " + stock + " item(s) in stock.");
        } else {
            new CartItemDAO().addItem(cartID, productID, 1);
            session.setAttribute("success", "Added to cart successfully.");
        }
        session.setAttribute("cart", new CartItemDAO().getCartItems(cartID));

        response.sendRedirect(request.getContextPath() + "/customer/cart");
    }
}