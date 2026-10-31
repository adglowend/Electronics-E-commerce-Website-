package controller;

import java.io.IOException;
import java.util.regex.Pattern;
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
 * Quy trình đặt lại mật khẩu:
 *   1) GET  /forgot              -> hiển thị form nhập email
 *   2) POST /forgot              -> sinh token, gửi mail chứa link /reset?token=...
 *   3) GET  /reset?token=xxxxx   -> kiểm tra token, hiển thị form đổi mật khẩu
 *   4) POST /reset?token=xxxxx   -> cập nhật mật khẩu mới
 */
@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/forgot", "/reset"})
public class ResetPasswordServlet extends HttpServlet {

    private static final Pattern EMAIL = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    // ========================= /forgot =========================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("common/forgot.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String email = req.getParameter("email");
        if (email == null || !EMAIL.matcher(email.trim()).matches()) {
            req.setAttribute("error", "Email không đúng định dạng.");
            req.getRequestDispatcher("common/forgot.jsp").forward(req, resp);
            return;
        }
        email = email.trim();

        UserDAO dao = new UserDAO();
        User u = dao.findByEmail(email);

        // Luôn trả thông báo giống nhau để tránh lộ email có tồn tại hay không
        String okMsg = "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi liên kết đặt lại mật khẩu. "
                     + "Vui lòng kiểm tra hộp thư (kể cả thư mục Spam).";

        if (u != null) {
            // Tạo token mới, ghi đè token cũ (kể cả activation token)
            String token = TokenUtil.generate();
            dao.updateActivationToken(u.getUserID(), token);

            String base = req.getRequestURL().toString();
            int slashIdx = base.lastIndexOf('/');
            String link = base.substring(0, slashIdx + 1) + "reset?token=" + token;

            MailService.sendResetPasswordMail(u.getEmail(), u.getFullName(), link);
        }

        req.setAttribute("success", okMsg);
        req.getRequestDispatcher("common/forgot.jsp").forward(req, resp);
    }

    // ========================= /reset =========================

    private void showResetForm(HttpServletRequest req, HttpServletResponse resp, String token)
            throws ServletException, IOException {
        UserDAO dao = new UserDAO();
        User u = dao.findByActivationToken(token);
        if (u == null) {
            req.getSession().setAttribute("error",
                    "Liên kết đặt lại không hợp lệ hoặc đã được sử dụng.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        req.setAttribute("token", token);
        req.setAttribute("email", u.getEmail());
        req.getRequestDispatcher("common/reset.jsp").forward(req, resp);
    }

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/reset".equals(path)) {
            String token = req.getParameter("token");
            HttpSession session = req.getSession();
            if (token == null || token.isEmpty()) {
                session.setAttribute("error", "Thiếu mã đặt lại mật khẩu.");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            if ("POST".equalsIgnoreCase(req.getMethod())) {
                doReset(req, resp, token);
            } else {
                showResetForm(req, resp, token);
            }
            return;
        }
        // /forgot
        if ("POST".equalsIgnoreCase(req.getMethod())) {
            doPost(req, resp);
        } else {
            doGet(req, resp);
        }
    }

    private void doReset(HttpServletRequest req, HttpServletResponse resp, String token)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String newPwd = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");

        String pwdError = validatePassword(newPwd);
        if (pwdError != null) {
            req.setAttribute("error", pwdError);
            req.setAttribute("token", token);
            req.getRequestDispatcher("common/reset.jsp").forward(req, resp);
            return;
        }
        if (newPwd == null || !newPwd.equals(confirm)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            req.setAttribute("token", token);
            req.getRequestDispatcher("common/reset.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        User u = dao.findByActivationToken(token);
        if (u == null) {
            req.getSession().setAttribute("error",
                    "Liên kết đặt lại không hợp lệ hoặc đã hết hạn.");
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        boolean ok = dao.changePasswordAndClearToken(u.getUserID(), newPwd);
        if (!ok) {
            req.setAttribute("error", "Đặt lại mật khẩu thất bại. Vui lòng thử lại.");
            req.setAttribute("token", token);
            req.getRequestDispatcher("common/reset.jsp").forward(req, resp);
            return;
        }

        req.getSession().setAttribute("success",
                "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập với mật khẩu mới.");
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    // ========================= helpers =========================

    private static String validatePassword(String pwd) {
        if (pwd == null || pwd.length() < 8) {
            return "Mật khẩu phải có ít nhất 8 ký tự.";
        }
        if (!pwd.matches(".*[A-Z].*")) {
            return "Mật khẩu phải có ít nhất 1 chữ HOA.";
        }
        if (!pwd.matches(".*[a-z].*")) {
            return "Mật khẩu phải có ít nhất 1 chữ thường.";
        }
        if (!pwd.matches(".*[0-9].*")) {
            return "Mật khẩu phải có ít nhất 1 chữ số.";
        }
        if (!pwd.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>/?`~].*")) {
            return "Mật khẩu phải có ít nhất 1 ký tự đặc biệt (ví dụ: !@#$%^&*).";
        }
        return null;
    }
}
