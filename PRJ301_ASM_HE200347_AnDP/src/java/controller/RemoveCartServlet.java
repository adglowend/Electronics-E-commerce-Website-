package controller;

import dao.CartItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/customer/removeCart")
public class RemoveCartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int cartItemID = Integer.parseInt(request.getParameter("cartItemID"));
        new CartItemDAO().deleteItem(cartItemID);

        HttpSession session = request.getSession();
        Integer cartID = (Integer) session.getAttribute("cartID");
        if (cartID != null) {
            session.setAttribute("cart", new CartItemDAO().getCartItems(cartID));
        }

        response.sendRedirect(request.getContextPath() + "/customer/cart");
    }
}