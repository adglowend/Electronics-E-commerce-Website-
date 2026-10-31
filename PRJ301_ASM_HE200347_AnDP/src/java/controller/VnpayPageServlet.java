package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Forward tới JSP tương ứng trong /web/vnpay.
 *   /vnpay/pay     -> /vnpay/pay.jsp
 *   /vnpay/return  -> /vnpay/return.jsp
 *
 * Giúp URL thân thiện hơn (không cần .jsp).
 */
@WebServlet(urlPatterns = {"/vnpay/pay", "/vnpay/return"})
public class VnpayPageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath(); // "/vnpay/pay" hoặc "/vnpay/return"
        String jsp  = path + ".jsp";
        request.getRequestDispatcher(jsp).forward(request, response);
    }
}