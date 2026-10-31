package controller;

import dao.CartItemDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import model.CartItem;
import model.Product;

@WebServlet("/customer/updateCart")
public class UpdateCartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int cartItemID = Integer.parseInt(request.getParameter("cartItemID"));

        int delta = 0;
        try {
            String d = request.getParameter("delta");
            if (d != null && !d.isEmpty()) delta = Integer.parseInt(d);
        } catch (NumberFormatException ignored) {}

        int quantity;
        if (delta != 0) {
            int current = findQuantity(request, cartItemID);
            quantity = current + delta;
        } else {
            quantity = Integer.parseInt(request.getParameter("quantity"));
        }
        if (quantity < 1) quantity = 1;

        HttpSession session = request.getSession();
        CartItem target = findCartItem(request, cartItemID);
        int stock = 0;
        if (target != null) {
            Product p = new ProductDAO().getProductById(target.getProductID());
            if (p != null) stock = p.getQuantity();
        }
        if (quantity > stock) {
            quantity = Math.max(stock, 1);
            session.setAttribute("error", "Quantity cannot exceed available stock (" + stock + ").");
        }

        new CartItemDAO().updateQuantity(cartItemID, quantity);

        Integer cartID = (Integer) session.getAttribute("cartID");
        if (cartID != null) {
            session.setAttribute("cart", new CartItemDAO().getCartItems(cartID));
        } else {
            ArrayList<CartItem> cart = (ArrayList<CartItem>) session.getAttribute("cart");
            if (cart != null) {
                for (CartItem ci : cart) {
                    if (ci.getCartItemID() == cartItemID) {
                        ci.setQuantity(quantity);
                        break;
                    }
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/customer/cart");
    }

    private int findQuantity(HttpServletRequest request, int cartItemID) {
        CartItem ci = findCartItem(request, cartItemID);
        return ci != null ? ci.getQuantity() : 1;
    }

    private CartItem findCartItem(HttpServletRequest request, int cartItemID) {
        HttpSession session = request.getSession();
        Integer cartID = (Integer) session.getAttribute("cartID");
        if (cartID != null) {
            for (CartItem ci : new CartItemDAO().getCartItems(cartID)) {
                if (ci.getCartItemID() == cartItemID) return ci;
            }
        } else {
            ArrayList<CartItem> cart = (ArrayList<CartItem>) session.getAttribute("cart");
            if (cart != null) {
                for (CartItem ci : cart) {
                    if (ci.getCartItemID() == cartItemID) return ci;
                }
            }
        }
        return null;
    }
}
