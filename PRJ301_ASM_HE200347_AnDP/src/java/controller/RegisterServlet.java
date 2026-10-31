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

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    // RFC-lite email regex
    private static final Pattern EMAIL = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    // 10 digits, must start with 0
    private static final Pattern PHONE = Pattern.compile("^0[0-9]{9}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("common/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = trim(request.getParameter("fullName"));
        String email    = trim(request.getParameter("email"));
        String phone    = trim(request.getParameter("phone"));
        String address  = trim(request.getParameter("address"));
        String password = request.getParameter("password");
        String confirm  = request.getParameter("confirmPassword");
        String agree    = request.getParameter("agree");

        String error = validateRegistration(
                fullName, email, phone, address, password, confirm, agree);

        if (error != null) {
            request.setAttribute("error", error);
            keepInput(request, fullName, email, phone, address);
            request.getRequestDispatcher("common/register.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        // Email exists
        if (dao.findByEmail(email) != null) {
            request.setAttribute("error", "Email đã được sử dụng. Vui lòng chọn email khác.");
            keepInput(request, fullName, email, phone, address);
            request.getRequestDispatcher("common/register.jsp").forward(request, response);
            return;
        }

        // Create user — default status = false (inactive), must activate via email
        User u = new User();
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPhone(phone);
        u.setAddress(address);
        u.setPasswordHash(password); // plain, matches LoginServlet
        u.setRoleID(2);              // Customer
        u.setStatus(false);          // chưa kích hoạt
        u.setActivationToken(TokenUtil.generate());

        try {
            dao.insertUserWithToken(u);
        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Đăng ký thất bại. Vui lòng thử lại sau.");
            keepInput(request, fullName, email, phone, address);
            request.getRequestDispatcher("common/register.jsp").forward(request, response);
            return;
        }

        // Build activation link — must be absolute so user can click from email.
        // request.getRequestURL() includes context path already, so just append the activate path + token.
        String base = request.getRequestURL().toString();
        int slashIdx = base.lastIndexOf('/');
        String link = base.substring(0, slashIdx + 1) + "activate?token=" + u.getActivationToken();

        boolean sent = MailService.sendActivationMail(email, fullName, link);

        HttpSession session = request.getSession();
        if (sent) {
            session.setAttribute("success",
                    "Đăng ký thành công! Vui lòng kiểm tra email " + email
                  + " và nhấn vào liên kết kích hoạt để đăng nhập.");
        } else {
            session.setAttribute("success",
                    "Đăng ký thành công! Tuy nhiên không gửi được email kích hoạt. "
                  + "Vui lòng dùng chức năng \"Gửi lại email kích hoạt\" ở trang đăng nhập.");
            // vẫn lưu token để có thể gửi lại
        }
        session.setAttribute("loginEmail", email);
        response.sendRedirect(request.getContextPath() + "/login");
    }

    // ---- helpers ----

    private static String validateRegistration(String fullName, String email,
                                              String phone, String address,
                                              String password, String confirm,
                                              String agree) {
        if (isBlank(fullName) || isBlank(email) || isBlank(password)
                || isBlank(phone) || isBlank(address)) {
            return "Vui lòng điền đầy đủ tất cả các trường.";
        }
        if (fullName.length() < 2) {
            return "Họ và tên phải có ít nhất 2 ký tự.";
        }
        if (!EMAIL.matcher(email).matches()) {
            return "Email không đúng định dạng (ví dụ: name@example.com).";
        }
        if (!PHONE.matcher(phone).matches()) {
            return "Số điện thoại phải đúng 10 chữ số và bắt đầu bằng số 0.";
        }
        String pwdError = validatePassword(password);
        if (pwdError != null) {
            return pwdError;
        }
        if (!password.equals(confirm)) {
            return "Mật khẩu xác nhận không khớp.";
        }
        if (agree == null) {
            return "Bạn cần đồng ý với điều khoản để đăng ký.";
        }
        return null;
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }

    /**
     * Password must have at least 8 characters and contain:
     * - 1 uppercase letter
     * - 1 lowercase letter
     * - 1 digit
     * - 1 special character (!@#$%^&*...)
     *
     * @return null if valid, otherwise the error message.
     */
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

    private static void keepInput(HttpServletRequest req,
                                  String fullName, String email, String phone, String address) {
        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);
        req.setAttribute("phone", phone);
        req.setAttribute("address", address);
    }
}
