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
import utils.MailService;
import utils.TokenUtil;

/**
 * Gửi lại email kích hoạt. POST { email }.
 * Nếu email tồn tại và chưa active thì cấp token mới, gửi mail, lưu DB.
 * Không tiết lộ email có tồn tại hay không (tránh enumeration).
 */
@WebServlet(name = "ResendActivationServlet", urlPatterns = {"/resend-activation"})
public class ResendActivationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("email");
        HttpSession session = request.getSession();

        // Always return the same message to avoid email enumeration
        String okMsg = "Nếu email tồn tại và chưa được kích hoạt, "
                     + "chúng tôi đã gửi lại liên kết kích hoạt. Vui lòng kiểm tra hộp thư.";

        if (email == null || email.trim().isEmpty()) {
            session.setAttribute("error", "Vui lòng nhập email để nhận lại liên kết kích hoạt.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        UserDAO dao = new UserDAO();
        User u = dao.findByEmail(email.trim());

        if (u != null && !u.isStatus()) {
            String token = TokenUtil.generate();
            dao.updateActivationToken(u.getUserID(), token);

            String link = request.getRequestURL().toString()
                    .replace(request.getServletPath(), "")
                    + request.getContextPath() + "/activate?token=" + token;

            MailService.sendActivationMail(u.getEmail(), u.getFullName(), link);
        }

        session.setAttribute("success", okMsg);
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
