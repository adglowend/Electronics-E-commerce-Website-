package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.UserDAO;
import model.User;

@WebServlet(name = "ActivateServlet", urlPatterns = {"/activate"})
public class ActivateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String token = request.getParameter("token");
        String status = "error";
        String message = "Liên kết kích hoạt không hợp lệ hoặc đã được sử dụng.";

        if (token != null && !token.isEmpty()) {
            UserDAO dao = new UserDAO();
            User u = dao.findByActivationToken(token);

            if (u != null) {
                if (u.isStatus()) {
                    status = "ok";
                    message = "Tài khoản đã được kích hoạt trước đó. Bạn có thể đăng nhập.";
                } else if (dao.activateByToken(token)) {
                    status = "ok";
                    message = "Kích hoạt tài khoản thành công! Bạn có thể đăng nhập ngay bây giờ.";
                } else {
                    message = "Không thể kích hoạt tài khoản. Vui lòng thử lại sau.";
                }
            }
        }

        HttpSession session = request.getSession();
        if ("ok".equals(status)) {
            session.setAttribute("success", message);
        } else {
            session.setAttribute("error", message);
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
