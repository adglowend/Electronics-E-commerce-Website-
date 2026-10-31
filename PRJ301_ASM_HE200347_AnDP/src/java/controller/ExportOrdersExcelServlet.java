package controller;

import dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.User;
import model.Role;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Locale;

@WebServlet("/admin/orders/export")
public class ExportOrdersExcelServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        Role role = (Role) session.getAttribute("role");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleName = role != null ? role.getRoleName() : "";
        if (!"Admin".equalsIgnoreCase(roleName) && user.getRoleID() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String keyword = request.getParameter("search");
        OrderDAO dao = new OrderDAO();
        ArrayList<Order> list;
        if (keyword != null && !keyword.trim().isEmpty()) {
            list = dao.searchOrders(keyword.trim());
        } else {
            list = dao.getAllOrder();
        }

        Locale locale = new Locale("vi", "VN");
        NumberFormat nf = NumberFormat.getInstance(locale);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm", locale);

        String filename = "orders_" + new SimpleDateFormat("yyyyMMdd_HHmmss", locale).format(new java.util.Date()) + ".csv";

        response.setContentType("text/csv; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        PrintWriter out = response.getWriter();

        // UTF-8 BOM so Excel recognizes encoding and displays Vietnamese correctly
        out.write('\ufeff');

        // Title + metadata rows
        out.println("DANH SÁCH ĐƠN HÀNG");
        if (keyword != null && !keyword.trim().isEmpty()) {
            out.println("Từ khóa," + csv(keyword));
        }
        out.println("Ngày xuất," + sdf.format(new java.util.Date()));
        out.println();

        // Header
        out.println("Order ID,Customer,Email,Phone,Order Date,Total (VND),Status");

        double grandTotal = 0;
        for (Order o : list) {
            String name = o.getCustomerName() != null ? o.getCustomerName() : "N/A";
            String email = o.getCustomerEmail() != null ? o.getCustomerEmail() : "";
            String phone = o.getCustomerPhone() != null && !o.getCustomerPhone().isEmpty() ? o.getCustomerPhone() : "";
            String dateStr = o.getOrderDate() != null ? sdf.format(o.getOrderDate()) : "";
            String status = o.getStatus() != null ? o.getStatus() : "";
            double total = o.getTotalAmount();
            grandTotal += total;

            out.println(csv("#" + o.getOrderID())
                    + "," + csv(name)
                    + "," + csv(email)
                    + "," + csv(phone)
                    + "," + csv(dateStr)
                    + "," + csv(nf.format(total))
                    + "," + csv(status));
        }

        out.println();
        out.println("Tổng cộng," + list.size() + " đơn,," + "," + "," + csv(nf.format(grandTotal)) + ",");

        out.flush();
    }

    private String csv(String s) {
        if (s == null) return "";
        boolean needsQuote = s.contains(",") || s.contains("\"") || s.contains("\n") || s.contains("\r");
        String escaped = s.replace("\"", "\"\"");
        return needsQuote ? "\"" + escaped + "\"" : escaped;
    }
}
