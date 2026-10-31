package controller;

import dao.CartDAO;
import dao.CartItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import model.CartItem;
import model.User;

@WebServlet("/customer/cart")
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");

        if (user != null) {
            CartDAO cartDAO = new CartDAO();
            int cartID = cartDAO.getOrCreateCart(user.getUserID());
            session.setAttribute("cartID", cartID);
            session.setAttribute("cart", new CartItemDAO().getCartItems(cartID));
        }

        request.getRequestDispatcher("/customer/cart.jsp").forward(request, response);
    }
}