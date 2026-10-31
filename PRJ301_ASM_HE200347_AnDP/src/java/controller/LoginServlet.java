package controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import dao.UserDAO;
import model.Role;
import model.User;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("common/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO dao = new UserDAO();

        // Tài khoản chưa kích hoạt: không cho đăng nhập, báo + gợi ý gửi lại mail
        User existing = dao.findByEmail(email);
        if (existing != null && !existing.isStatus()
                && existing.getPasswordHash() != null
                && existing.getPasswordHash().equals(password)) {
            request.setAttribute("error",
                    "Tài khoản chưa được kích hoạt. Vui lòng kiểm tra email hoặc nhấn \"Gửi lại email kích hoạt\" bên dưới.");
            request.setAttribute("loginEmail", email);
            request.getRequestDispatcher("common/login.jsp").forward(request, response);
            return;
        }

        User user = dao.login(email, password);

        if (user != null) {
            Role role = dao.getRoleByID(user.getRoleID());

            HttpSession session = request.getSession();
            session.setAttribute("account", user);
            session.setAttribute("role", role);

            if (role != null && "Admin".equalsIgnoreCase(role.getRoleName())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }
        } else {
            request.setAttribute("error", "Sai email hoặc mật khẩu!");
            request.setAttribute("loginEmail", email);
            request.getRequestDispatcher("common/login.jsp").forward(request, response);
        }
    }
}
