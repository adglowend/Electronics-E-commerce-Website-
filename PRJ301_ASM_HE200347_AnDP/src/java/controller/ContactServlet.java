package controller;

import java.io.IOException;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.MailService;
import utils.MailConfig;

/**
 * Contact form handler:
 *   GET  /contact         -> show contact page
 *   POST /contact        -> validate fields, send mail to store owner, send auto-reply to user
 */
@WebServlet(name = "ContactServlet", urlPatterns = {"/contact"})
public class ContactServlet extends HttpServlet {

    private static final Pattern EMAIL = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/contact.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String name    = req.getParameter("name");
        String email   = req.getParameter("email");
        String subject = req.getParameter("subject");
        String message = req.getParameter("message");

        // ── Preserve form values on error ──
        req.setAttribute("name",    name);
        req.setAttribute("email",   email);
        req.setAttribute("subject", subject);
        req.setAttribute("message", message);

        // ── Validate ──
        if (name == null || name.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập họ tên của bạn.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }

        if (email == null || !EMAIL.matcher(email.trim()).matches()) {
            req.setAttribute("error", "Email không đúng định dạng.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }
        email = email.trim();

        if (subject == null || subject.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng chọn chủ đề.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }

        if (message == null || message.trim().isEmpty() || message.trim().length() < 10) {
            req.setAttribute("error", "Tin nhắn phải có ít nhất 10 ký tự.");
            req.getRequestDispatcher("/contact.jsp").forward(req, resp);
            return;
        }

        name    = name.trim();
        subject = subject.trim();
        message = message.trim();

        // ── Send mail to store owner ──
        boolean sentToOwner = sendToOwner(name, email, subject, message, req);

        // ── Send auto-reply to customer ──
        sendAutoReply(email, name);

        // ── Success ──
        req.setAttribute("success",
                "Cảm ơn bạn đã liên hệ! Chúng tôi đã nhận được tin nhắn và sẽ phản hồi trong thời gian sớm nhất.");
        req.getRequestDispatcher("/contact.jsp").forward(req, resp);
    }

    /* ──────────────────────────────────────────────────────────────
     * Build & send email to the store owner (thieuducdung254@gmail.com)
     * ────────────────────────────────────────────────────────────── */
    private boolean sendToOwner(String senderName, String senderEmail,
                                String subject, String body, HttpServletRequest req) {
        String storeEmail = MailConfig.USERNAME;

        String html = buildOwnerEmail(senderName, senderEmail, subject, body, req);

        return MailService.sendHtml(storeEmail,
                "[Electro Shop] Contact: " + subject + " - from " + senderName,
                html);
    }

    private String buildOwnerEmail(String senderName, String senderEmail,
                                   String subject, String body, HttpServletRequest req) {
        int year = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
        String safeBody = escapeHtml(body);

        StringBuilder b = new StringBuilder(4096);
        b.append("<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' "
                + "'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>");
        b.append("<html xmlns='http://www.w3.org/1999/xhtml' lang='vi'>");
        b.append("<head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>");
        b.append("<meta name='viewport' content='width=device-width, initial-scale=1.0'/>");
        b.append("<title>Contact Form</title></head>");
        b.append("<body style='margin:0;padding:0;background-color:#f4f5f7;"
                + "font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif'>");

        // Top spacer
        b.append("<table width='100%' cellpadding='0' cellspacing='0' border='0' "
                + "style='background-color:#f4f5f7'><tr><td style='height:32px'>&nbsp;</td></tr></table>");

        // Container
        b.append("<table align='center' width='100%' cellpadding='0' cellspacing='0' border='0' "
                + "style='max-width:600px;margin:0 auto;background-color:#ffffff;"
                + "border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(15,23,42,0.08)'>");

        // Header
        b.append("<tr><td style='background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 50%,#3b82f6 100%);padding:28px 32px'>");
        b.append("<table cellpadding='0' cellspacing='0' border='0'><tr>");
        b.append("<td style='width:44px;height:44px;background:linear-gradient(135deg,#f59e0b,#ef4444);"
                + "border-radius:12px;text-align:center;vertical-align:middle'>");
        b.append("<span style='color:#ffffff;font-size:22px;font-weight:800;"
                + "line-height:44px;display:inline-block'>E</span>");
        b.append("</td>");
        b.append("<td style='padding-left:12px;vertical-align:middle'>");
        b.append("<span style='color:#ffffff;font-size:20px;font-weight:700'>Electro Shop</span><br/>");
        b.append("<span style='color:#cbd5e1;font-size:12px;text-transform:uppercase'>New Contact Message</span>");
        b.append("</td></tr></table>");
        b.append("</td></tr>");

        // Hero
        b.append("<tr><td style='background:linear-gradient(135deg,#f97316 0%,#ef4444 100%);"
                + "padding:40px 32px;text-align:center'>");
        b.append("<h1 style='margin:0;color:#ffffff;font-size:26px;font-weight:800'>");
        b.append("B&#7841;n c&#243; tin nh&#7855;n li&#234;n h&#7879; má»›i</h1>");
        b.append("</td></tr>");

        // Body
        b.append("<tr><td style='padding:40px 40px 16px 40px;color:#1f2937;font-size:16px;line-height:1.7'>");
        b.append("<table width='100%' cellpadding='12' cellspacing='0' border='0' "
                + "style='background-color:#f8fafc;border-radius:12px;border:1px solid #e5e7eb'>");
        b.append("<tr><td style='font-weight:700;width:120px;color:#6b7280;font-size:13px;text-transform:uppercase'>");
        b.append("H&#7885; t&#234;n</td>");
        b.append("<td style='font-weight:600;color:#111827'>").append(escapeHtml(senderName)).append("</td></tr>");
        b.append("<tr style='background-color:#f1f5f9'><td style='font-weight:700;color:#6b7280;font-size:13px;text-transform:uppercase'>");
        b.append("Email</td>");
        b.append("<td><a href='mailto:").append(escapeHtml(senderEmail)).append("' style='color:#2563eb'>")
                .append(escapeHtml(senderEmail)).append("</a></td></tr>");
        b.append("<tr><td style='font-weight:700;color:#6b7280;font-size:13px;text-transform:uppercase'>");
        b.append("Ch&#7911; &#273;&#7873;</td>");
        b.append("<td style='font-weight:600;color:#111827'>").append(escapeHtml(subject)).append("</td></tr>");
        b.append("</table>");

        b.append("<h3 style='margin:28px 0 12px 0;font-size:15px;color:#374151'>N&#7897;i dung tin nh&#7855;n:</h3>");
        b.append("<div style='padding:16px 20px;background-color:#fffbeb;"
                + "border-left:4px solid #f59e0b;border-radius:0 8px 8px 0;"
                + "font-size:15px;line-height:1.8;white-space:pre-wrap'>");
        b.append(safeBody);
        b.append("</div>");

        b.append("</td></tr>");

        // Footer
        b.append("<tr><td style='background-color:#0f172a;padding:24px 32px'>");
        b.append("<div style='color:#cbd5e1;font-size:13px;line-height:1.7'>");
        b.append("Email này được gửi tự động từ form liên hệ trên website Electro Shop.<br/>");
        b.append("Thời gian nhận: ").append(java.time.LocalDateTime.now().toString()).append("<br/>");
        b.append("IP người gửi: ").append(req.getRemoteAddr());
        b.append("</div>");
        b.append("<div style='margin-top:16px;padding-top:16px;border-top:1px solid #1e293b;"
                + "color:#64748b;font-size:11px'>");
        b.append("&copy; ").append(year).append(" Electro Shop. All rights reserved.");
        b.append("</div>");
        b.append("</td></tr>");

        b.append("</table>");
        b.append("<table width='100%' cellpadding='0' cellspacing='0' border='0' "
                + "style='background-color:#f4f5f7'><tr><td style='height:32px'>&nbsp;</td></tr></table>");
        b.append("</body></html>");

        return b.toString();
    }

    /* ──────────────────────────────────────────────────────────────
     * Build & send auto-reply email to the customer
     * ────────────────────────────────────────────────────────────── */
    private void sendAutoReply(String toEmail, String toName) {
        String html = buildAutoReplyHtml(toName);
        MailService.sendHtml(toEmail, "[Electro Shop] Chúng tôi đã nhận được liên hệ của bạn", html);
    }

    private String buildAutoReplyHtml(String name) {
        int year = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
        String safeName = escapeHtml(name);

        StringBuilder b = new StringBuilder(4096);
        b.append("<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' "
                + "'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>");
        b.append("<html xmlns='http://www.w3.org/1999/xhtml' lang='vi'>");
        b.append("<head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>");
        b.append("<meta name='viewport' content='width=device-width, initial-scale=1.0'/>");
        b.append("<title>Electro Shop - Contact Confirmation</title></head>");
        b.append("<body style='margin:0;padding:0;background-color:#f4f5f7;"
                + "font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif'>");

        b.append("<table width='100%' cellpadding='0' cellspacing='0' border='0' "
                + "style='background-color:#f4f5f7'><tr><td style='height:32px'>&nbsp;</td></tr></table>");

        b.append("<table align='center' width='100%' cellpadding='0' cellspacing='0' border='0' "
                + "style='max-width:600px;margin:0 auto;background-color:#ffffff;"
                + "border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(15,23,42,0.08)'>");

        // Header
        b.append("<tr><td style='background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 50%,#3b82f6 100%);padding:28px 32px'>");
        b.append("<table cellpadding='0' cellspacing='0' border='0'><tr>");
        b.append("<td style='width:44px;height:44px;background:linear-gradient(135deg,#f59e0b,#ef4444);"
                + "border-radius:12px;text-align:center;vertical-align:middle'>");
        b.append("<span style='color:#ffffff;font-size:22px;font-weight:800;"
                + "line-height:44px;display:inline-block'>E</span>");
        b.append("</td>");
        b.append("<td style='padding-left:12px;vertical-align:middle'>");
        b.append("<span style='color:#ffffff;font-size:20px;font-weight:700'>Electro Shop</span><br/>");
        b.append("<span style='color:#cbd5e1;font-size:12px;text-transform:uppercase'>Laptop &amp; Computer Store</span>");
        b.append("</td></tr></table>");
        b.append("</td></tr>");

        // Hero
        b.append("<tr><td style='background:linear-gradient(135deg,#f97316 0%,#ef4444 100%);"
                + "padding:48px 32px;text-align:center'>");
        b.append("<div style='display:inline-block;width:80px;height:80px;background:rgba(255,255,255,0.18);"
                + "border-radius:50%;text-align:center;line-height:80px;margin-bottom:16px'>");
        b.append("<span style='font-size:42px;line-height:80px;display:inline-block;color:#ffffff'>&#10003;</span>");
        b.append("</div>");
        b.append("<h1 style='margin:0;color:#ffffff;font-size:28px;font-weight:800'>Ch&#250;ng t&#244;i &#273;&#227; nh&#7853;n &#273;&#432;&#7907;c tin nh&#7855;n c&#7911;a b&#7841;n</h1>");
        b.append("<p style='margin:8px 0 0 0;color:#fed7aa;font-size:15px'>C&#7843;m &#417;n b&#7841;n &#273;&#227; li&#234;n h&#7879; v&#7899;i Electro Shop!</p>");
        b.append("</td></tr>");

        // Body
        b.append("<tr><td style='padding:40px 40px 16px 40px;color:#1f2937;font-size:16px;line-height:1.7'>");
        b.append("<p style='margin:0 0 16px 0;font-size:17px'>");
        b.append("Xin chào <strong>").append(safeName).append("</strong>,</p>");
        b.append("<p style='margin:0 0 16px 0'>");
        b.append("C&#7843;m &#417;n b&#7841;n &#273;&#227; li&#234;n h&#7879; v&#7899;i <strong style='color:#ef4444'>Electro Shop</strong>. ");
        b.append("Ch&#250;ng t&#244;i &#273;&#227; nh&#7853;n &#273;&#432;&#7907;c tin nh&#7855;n c&#7911;a b&#7841;n v&#224; s&#7869; ph&#7843;n h&#7891;i trong th&#7901;i gian s&#7899;m nh&#7845;t c&#243; th&#7875;. ");
        b.append("Th&#244;ng th&#432;&#7901;ng ch&#250;ng t&#244;i s&#7869; ph&#7843;n h&#7891;i trong v&#242;ng <strong>24 gi&#7901;</strong>.</p>");

        // Info box
        b.append("<table width='100%' cellpadding='0' cellspacing='0' border='0' style='margin:24px 0;"
                + "background-color:#f0fdf4;border-left:4px solid #22c55e;border-radius:0 8px 8px 0'>");
        b.append("<tr><td style='padding:16px 20px;color:#166534;font-size:14px;line-height:1.6'>");
        b.append("<strong>&#10003; B&#7841;n &#273;&#227; l&#224;m &#273;&#250;ng!</strong><br/>");
        b.append("Tin nh&#7855;n c&#7911;a b&#7841;n &#273;&#227; &#273;&#432;&#7907;c ghi nh&#7853;n. Ch&#250;ng t&#244;i s&#7869; ph&#7843;n h&#7891;i qua email s&#7899;m nh&#7845;t.");
        b.append("</td></tr></table>");

        b.append("<p style='margin:0 0 16px 0'>Trong th&#7901;i gian ch&#7901; ph&#7843;n h&#7891;i, b&#7841;n c&#243; th&#7875;:</p>");
        b.append("<ul style='margin:0 0 16px 0;padding-left:20px'>");
        b.append("<li>Xem <a href='").append(MailConfig.USERNAME).append("' style='color:#2563eb'>s&#7843;n ph&#7849;m</a> c&#7911;a ch&#250;ng t&#244;i</li>");
        b.append("<li>Theo d&#245;i <a href='#' style='color:#2563eb'>&#273;&#417;n h&#224;ng</a> c&#7911;a b&#7841;n</li>");
        b.append("<li>Ki&#7875;m tra ch&#432;&#417;ng tr&#236;nh khuy&#7871;n m&#227;i hi&#7879;n c&#243;</li>");
        b.append("</ul>");

        b.append("</td></tr>");

        // Footer
        b.append("<tr><td style='background-color:#0f172a;padding:28px 32px'>");
        b.append("<div style='color:#ffffff;font-weight:700;margin-bottom:6px'>Electro Shop</div>");
        b.append("<div style='color:#cbd5e1;font-size:13px;line-height:1.7'>");
        b.append("Email n&#224;y &#273;&#432;&#7907;c g&#7917;i t&#7921; &#273;&#7897;ng. Vui l&#242;ng kh&#244;ng tr&#7843; l&#7901;i email n&#224;y.<br/>");
        b.append("Li&#234;n h&#7879;: <a href='mailto:").append(MailConfig.USERNAME).append("' style='color:#fbbf24;text-decoration:none'>")
                .append(MailConfig.USERNAME).append("</a>");
        b.append("</div>");
        b.append("<div style='margin-top:18px;padding-top:18px;border-top:1px solid #1e293b;"
                + "color:#64748b;font-size:11px;line-height:1.6'>");
        b.append("&copy; ").append(year).append(" Electro Shop. All rights reserved.");
        b.append("</div>");
        b.append("</td></tr>");

        b.append("</table>");
        b.append("<table width='100%' cellpadding='0' cellspacing='0' border='0' "
                + "style='background-color:#f4f5f7'><tr><td style='height:32px'>&nbsp;</td></tr></table>");
        b.append("</body></html>");

        return b.toString();
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                 .replace("<", "&lt;")
                 .replace(">", "&gt;")
                 .replace("\"", "&quot;")
                 .replace("'", "&#39;");
    }
}
