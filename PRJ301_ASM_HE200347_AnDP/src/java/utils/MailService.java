package utils;

import java.util.Properties;
import java.util.Calendar;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

/**
 * Gửi email qua Gmail SMTP. Dùng mật khẩu ứng dụng đã cấu hình trong MailConfig.
 *
 * Yêu cầu thư viện: jakarta.mail-2.0.x (đã có sẵn trong NetBeans
 * default Java EE API; nếu lỗi import thì add mail.jar + activation.jar).
 */
public final class MailService {

    private MailService() {
        // utility class
    }

    /**
     * Gửi email HTML đơn giản.
     *
     * @param to       email người nhận
     * @param subject  tiêu đề
     * @param htmlBody nội dung HTML
     * @return true nếu gửi thành công
     */
    public static boolean sendHtml(String to, String subject, String htmlBody) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", MailConfig.HOST);
        props.put("mail.smtp.port", String.valueOf(MailConfig.PORT));
        props.put("mail.smtp.ssl.trust", MailConfig.HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(MailConfig.USERNAME, MailConfig.APP_PASSWORD);
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(MailConfig.FROM_EMAIL, MailConfig.FROM_NAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            return true;
        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Gửi mail kích hoạt tài khoản cho người dùng mới đăng ký.
     * Template hiện đại: gradient header, hero với icon, CTA nổi, responsive.
     */
    public static boolean sendActivationMail(String to, String fullName, String activationLink) {
        String subject = "[Electro Shop] Xác nhận tài khoản của bạn";
        String html = buildActivationHtml(fullName, activationLink);
        return sendHtml(to, subject, html);
    }

    /**
     * Gửi mail đặt lại mật khẩu.
     */
    public static boolean sendResetPasswordMail(String to, String fullName, String resetLink) {
        String subject = "[Electro Shop] Đặt lại mật khẩu";
        String html = buildResetPasswordHtml(fullName, resetLink);
        return sendHtml(to, subject, html);
    }

    /* =====================================================================
     * Template kích hoạt tài khoản
     * Inline CSS 100% để tương thích Gmail / Outlook / Apple Mail.
     * ===================================================================== */
    private static String buildActivationHtml(String fullName, String link) {
        String name      = escape(fullName);
        String safeLink  = escape(link);
        int    year      = Calendar.getInstance().get(Calendar.YEAR);

        StringBuilder b = new StringBuilder(4096);

        // Preheader (preview text khi chưa mở mail)
        b.append("<div style='display:none;max-height:0;overflow:hidden;mso-hide:all;font-size:1px;line-height:1px;color:transparent'>")
         .append("Ch\u00E0o m\u1EEBng \u0111\u1EBFn v\u1EDBi Electro Shop! Vui l\u00F2ng k\u00EDch ho\u1EA1t t\u00E0i kho\u1EA3n c\u1EE7a b\u1EA1n.")
         .append("&#8203;&#847;&#847;&#847;&#847;&#847;&#847;&#847;&#847;&#847;&#847;")
         .append("</div>");

        // Outer wrapper
        b.append("<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>")
         .append("<html xmlns='http://www.w3.org/1999/xhtml' lang='vi'>")
         .append("<head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>")
         .append("<meta name='viewport' content='width=device-width, initial-scale=1.0'/>")
         .append("<meta name='x-apple-disable-message-reformatting'/>")
         .append("<title>K\u00EDch ho\u1EA1t t\u00E0i kho\u1EA3n</title></head>")
         .append("<body style='margin:0;padding:0;background-color:#f4f5f7;-webkit-text-size-adjust:100%;font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,sans-serif'>");

        // Preheader spacer
        b.append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='background-color:#f4f5f7'>")
         .append("<tr><td style='height:32px;line-height:32px;font-size:0'>&nbsp;</td></tr></table>");

        // Container
        b.append("<table role='presentation' align='center' width='100%' cellpadding='0' cellspacing='0' border='0' style='max-width:600px;margin:0 auto;background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(15,23,42,0.06)'>");

        // ===== HEADER với gradient + logo =====
        b.append("<tr><td style='background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 50%,#3b82f6 100%);padding:0'>")
         .append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0'><tr>")
         .append("<td style='padding:28px 32px 24px 32px'>")
         .append("<table role='presentation' cellpadding='0' cellspacing='0' border='0'><tr>")
         .append("<td style='width:44px;height:44px;background:linear-gradient(135deg,#f59e0b,#ef4444);border-radius:12px;text-align:center;vertical-align:middle'>")
         .append("<span style='color:#ffffff;font-size:22px;font-weight:800;line-height:44px;display:inline-block'>E</span>")
         .append("</td>")
         .append("<td style='padding-left:12px;vertical-align:middle'>")
         .append("<span style='color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.3px'>Electro Shop</span><br/>")
         .append("<span style='color:#cbd5e1;font-size:12px;letter-spacing:0.5px;text-transform:uppercase'>Laptop &amp; Ph\u1EE5 ki\u1EC7n ch\u00EDnh h\u00E3ng</span>")
         .append("</td></tr></table>")
         .append("</td></tr></table>")
         .append("</td></tr>");

        // ===== HERO banner =====
        b.append("<tr><td style='background:linear-gradient(135deg,#f97316 0%,#ef4444 100%);padding:48px 32px;text-align:center'>")
         .append("<div style='display:inline-block;width:80px;height:80px;background:rgba(255,255,255,0.18);border-radius:50%;text-align:center;line-height:80px;margin-bottom:16px'>")
         .append("<span style='font-size:42px;line-height:80px;display:inline-block;color:#ffffff'>&#9993;</span>")
         .append("</div>")
         .append("<h1 style='margin:0;color:#ffffff;font-size:28px;font-weight:800;letter-spacing:-0.4px'>X\u00E1c nh\u1EADn t\u00E0i kho\u1EA3n</h1>")
         .append("<p style='margin:8px 0 0 0;color:#fed7aa;font-size:15px'>Ch\u1EC9 m\u1ED9t b\u01B0\u1EDBc n\u1EEFa \u0111\u1EC3 ho\u00E0n t\u1EA5t</p>")
         .append("</td></tr>");

        // ===== BODY content =====
        b.append("<tr><td style='padding:40px 40px 16px 40px;color:#1f2937;font-size:16px;line-height:1.7'>")
         .append("<p style='margin:0 0 16px 0;font-size:17px'>Ch\u00E0o <strong>").append(name).append("</strong>,</p>")
         .append("<p style='margin:0 0 16px 0'>")
         .append("C\u1EA3m \u01A1n b\u1EA1n \u0111\u00E3 \u0111\u0103ng k\u00FD t\u00E0i kho\u1EA3n t\u1EA1i <strong style='color:#ef4444'>Electro Shop</strong>. ")
         .append("\u0110\u1EC3 b\u1EAFt \u0111\u1EA7u mua s\u1EAFm v\u00E0 s\u1EED d\u1EE5ng \u0111\u1EA7y \u0111\u1EE7 c\u00E1c t\u00EDnh n\u0103ng, vui l\u00F2ng k\u00EDch ho\u1EA1t t\u00E0i kho\u1EA3n b\u1EB1ng c\u00E1ch nh\u1EA5n n\u00FAt b\u00EAn d\u01B0\u1EDBi:")
         .append("</p>")

         // CTA button
         .append("<table role='presentation' align='center' cellpadding='0' cellspacing='0' border='0' style='margin:32px auto'>")
         .append("<tr><td style='border-radius:12px;background:linear-gradient(135deg,#f97316 0%,#ef4444 100%);box-shadow:0 8px 20px rgba(239,68,68,0.35)'>")
         .append("<a href='").append(safeLink).append("' target='_blank' ")
         .append("style='display:inline-block;padding:16px 40px;color:#ffffff;text-decoration:none;font-weight:700;font-size:16px;letter-spacing:0.3px;border-radius:12px'>")
         .append("&#10003;&nbsp;&nbsp;K\u00EDch ho\u1EA1t t\u00E0i kho\u1EA3n")
         .append("</a>")
         .append("</td></tr></table>")

         // Info box
         .append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='margin:24px 0;background-color:#fff7ed;border-left:4px solid #f59e0b;border-radius:8px'>")
         .append("<tr><td style='padding:16px 20px;color:#92400e;font-size:14px;line-height:1.6'>")
         .append("<strong>&#9888; L\u01B0u \u00FD:</strong> Li\u00EAn k\u1EBFt n\u00E0y c\u00F3 hi\u1EC7u l\u1EF1c v\u0129nh vi\u1EC5n cho t\u1EDBi khi b\u1EA1n y\u00EAu c\u1EA7u g\u1EEDi l\u1EA1i. ")
         .append("V\u00EC l\u00FD do b\u1EA3o m\u1EADt, vui l\u00F2ng kh\u00F4ng chia s\u1EBB li\u00EAn k\u1EBFt n\u00E0y v\u1EDBi b\u1EA5t k\u00EC ai.")
         .append("</td></tr></table>")

         // Fallback link
         .append("<p style='margin:24px 0 8px 0;color:#6b7280;font-size:13px'>")
         .append("N\u1EBFu n\u00FAt kh\u00F4ng ho\u1EA1t \u0111\u1ED9ng, h\u00E3y sao ch\u00E9p li\u00EAn k\u1EBFt sau v\u00E0o tr\u00ECnh duy\u1EC7t:")
         .append("</p>")
         .append("<p style='margin:0;padding:12px 14px;background-color:#f1f5f9;border-radius:8px;word-break:break-all;font-family:SFMono-Regular,Consolas,monospace;font-size:12px;color:#475569'>")
         .append(safeLink)
         .append("</p>")
         .append("</td></tr>");

        // ===== Feature row (3 cột) =====
        b.append("<tr><td style='padding:8px 32px 32px 32px'>")
         .append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0'><tr>")
         .append("<td style='width:33.33%;text-align:center;padding:8px'>")
         .append("<div style='font-size:24px'>&#128722;</div>")
         .append("<div style='font-size:13px;color:#475569;font-weight:600;margin-top:6px'>Mi\u1EC5n ph\u00ED v\u1EADn chuy\u1EC3n</div>")
         .append("</td>")
         .append("<td style='width:33.33%;text-align:center;padding:8px;border-left:1px solid #e5e7eb;border-right:1px solid #e5e7eb'>")
         .append("<div style='font-size:24px'>&#128274;</div>")
         .append("<div style='font-size:13px;color:#475569;font-weight:600;margin-top:6px'>Thanh to\u00E1n an to\u00E0n</div>")
         .append("</td>")
         .append("<td style='width:33.33%;text-align:center;padding:8px'>")
         .append("<div style='font-size:24px'>&#127873;</div>")
         .append("<div style='font-size:13px;color:#475569;font-weight:600;margin-top:6px'>Nhi\u1EC1u \u01B0u \u0111\u00E3i</div>")
         .append("</td>")
         .append("</tr></table>")
         .append("</td></tr>");

        // ===== FOOTER =====
        b.append("<tr><td style='background-color:#0f172a;padding:28px 32px'>")
         .append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0'><tr>")
         .append("<td style='color:#cbd5e1;font-size:13px;line-height:1.7'>")
         .append("<div style='color:#ffffff;font-weight:700;margin-bottom:6px'>Electro Shop</div>")
         .append("Email n\u00E0y \u0111\u01B0\u1EE3c g\u1EEDi t\u1EF1 \u0111\u1ED9ng. N\u1EBFu b\u1EA1n kh\u00F4ng th\u1EF1c hi\u1EC7n \u0111\u0103ng k\u00FD, vui l\u00F2ng b\u1ECF qua.")
         .append("<br/>Li\u00EAn h\u1EC7: <a href='mailto:").append(MailConfig.USERNAME).append("' style='color:#fbbf24;text-decoration:none'>")
         .append(MailConfig.USERNAME).append("</a>")
         .append("</td>")
         .append("<td style='text-align:right;vertical-align:top'>")
         .append("<span style='display:inline-block;width:32px;height:32px;background:linear-gradient(135deg,#3b82f6,#06b6d4);border-radius:50%;text-align:center;line-height:32px;margin-left:6px'>")
         .append("<a href='#' style='color:#ffffff;text-decoration:none;font-weight:700'>f</a>")
         .append("</span>")
         .append("<span style='display:inline-block;width:32px;height:32px;background:linear-gradient(135deg,#ec4899,#f43f5e);border-radius:50%;text-align:center;line-height:32px;margin-left:6px'>")
         .append("<a href='#' style='color:#ffffff;text-decoration:none;font-weight:700'>IG</a>")
         .append("</span>")
         .append("</td>")
         .append("</tr></table>")
         .append("<div style='margin-top:18px;padding-top:18px;border-top:1px solid #1e293b;color:#64748b;font-size:11px;line-height:1.6'>")
         .append("&copy; ").append(year).append(" Electro Shop. All rights reserved.<br/>")
         .append("B\u1EA1n nh\u1EADn \u0111\u01B0\u1EE3c email n\u00E0y v\u00EC \u0111\u00E3 \u0111\u0103ng k\u00FD t\u00E0i kho\u1EA3n tr\u00EAn website c\u1EE7a ch\u00FAng t\u00F4i.")
         .append("</div>")
         .append("</td></tr>");

        b.append("</table>"); // close container

        // Bottom spacer
        b.append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='background-color:#f4f5f7'>")
         .append("<tr><td style='height:32px;line-height:32px;font-size:0'>&nbsp;</td></tr></table>");

        b.append("</body></html>");

        return b.toString();
    }

    /* =====================================================================
     * Template đặt lại mật khẩu
     * ===================================================================== */
    private static String buildResetPasswordHtml(String fullName, String link) {
        String name     = escape(fullName);
        String safeLink = escape(link);
        int    year     = Calendar.getInstance().get(Calendar.YEAR);

        StringBuilder b = new StringBuilder(4096);

        b.append("<div style='display:none;max-height:0;overflow:hidden;mso-hide:all;font-size:1px;line-height:1px;color:transparent'>")
         .append("B\u1EA1n nh\u1EADn \u0111\u01B0\u1EE3c email n\u00E0y v\u00EC \u0111\u00E3 y\u00EAu c\u1EA7u \u0111\u1EB7t l\u1EA1i m\u1EADt kh\u1EA9u t\u1EA1i Electro Shop.")
         .append("&#8203;&#847;&#847;&#847;&#847;&#847;&#847;&#847;&#847;&#847;&#847;")
         .append("</div>");

        b.append("<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>")
         .append("<html xmlns='http://www.w3.org/1999/xhtml' lang='vi'>")
         .append("<head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>")
         .append("<meta name='viewport' content='width=device-width, initial-scale=1.0'/>")
         .append("<title>\u0110\u1EB7t l\u1EA1i m\u1EADt kh\u1EA9u</title></head>")
         .append("<body style='margin:0;padding:0;background-color:#f4f5f7;-webkit-text-size-adjust:100%;font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Helvetica,Arial,sans-serif'>");

        b.append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='background-color:#f4f5f7'>")
         .append("<tr><td style='height:32px;line-height:32px;font-size:0'>&nbsp;</td></tr></table>");

        b.append("<table role='presentation' align='center' width='100%' cellpadding='0' cellspacing='0' border='0' style='max-width:600px;margin:0 auto;background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(15,23,42,0.06)'>");

        // HEADER
        b.append("<tr><td style='background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 50%,#3b82f6 100%);padding:0'>")
         .append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0'><tr>")
         .append("<td style='padding:28px 32px 24px 32px'>")
         .append("<table role='presentation' cellpadding='0' cellspacing='0' border='0'><tr>")
         .append("<td style='width:44px;height:44px;background:linear-gradient(135deg,#f59e0b,#ef4444);border-radius:12px;text-align:center;vertical-align:middle'>")
         .append("<span style='color:#ffffff;font-size:22px;font-weight:800;line-height:44px;display:inline-block'>E</span>")
         .append("</td>")
         .append("<td style='padding-left:12px;vertical-align:middle'>")
         .append("<span style='color:#ffffff;font-size:20px;font-weight:700;letter-spacing:0.3px'>Electro Shop</span><br/>")
         .append("<span style='color:#cbd5e1;font-size:12px;letter-spacing:0.5px;text-transform:uppercase'>Laptop &amp; Ph\u1EE5 ki\u1EC7n ch\u00EDnh h\u00E3ng</span>")
         .append("</td></tr></table>")
         .append("</td></tr></table>")
         .append("</td></tr>");

        // HERO
        b.append("<tr><td style='background:linear-gradient(135deg,#f97316 0%,#ef4444 100%);padding:48px 32px;text-align:center'>")
         .append("<div style='display:inline-block;width:80px;height:80px;background:rgba(255,255,255,0.18);border-radius:50%;text-align:center;line-height:80px;margin-bottom:16px'>")
         .append("<span style='font-size:42px;line-height:80px;display:inline-block;color:#ffffff'>&#128273;</span>")
         .append("</div>")
         .append("<h1 style='margin:0;color:#ffffff;font-size:28px;font-weight:800;letter-spacing:-0.4px'>\u0110\u1EB7t l\u1EA1i m\u1EADt kh\u1EA9u</h1>")
         .append("<p style='margin:8px 0 0 0;color:#fed7aa;font-size:15px'>Ch\u00FAng t\u00F4i \u0111\u00E3 nh\u1EADn y\u00EAu c\u1EA7u \u0111\u1EB7t l\u1EA1i m\u1EADt kh\u1EA9u c\u1EE7a b\u1EA1n</p>")
         .append("</td></tr>");

        // BODY
        b.append("<tr><td style='padding:40px 40px 16px 40px;color:#1f2937;font-size:16px;line-height:1.7'>")
         .append("<p style='margin:0 0 16px 0;font-size:17px'>Ch\u00E0o <strong>").append(name).append("</strong>,</p>")
         .append("<p style='margin:0 0 16px 0'>")
         .append("Ch\u00FAng t\u00F4i nh\u1EADn \u0111\u01B0\u1EE3c y\u00EAu c\u1EA7u \u0111\u1EB7t l\u1EA1i m\u1EADt kh\u1EA9u cho t\u00E0i kho\u1EA3n <strong style='color:#ef4444'>Electro Shop</strong> c\u1EE7a b\u1EA1n. ")
         .append("Vui l\u00F2ng nh\u1EA5n n\u00FAt b\u00EAn d\u01B0\u1EDBi \u0111\u1EC3 t\u1EA1o m\u1EADt kh\u1EA9u m\u1EDBi. Li\u00EAn k\u1EBFt s\u1EBD h\u1EBFt h\u1EA1n sau khi b\u1EA1n s\u1EED d\u1EE5ng xong.")
         .append("</p>")

         .append("<table role='presentation' align='center' cellpadding='0' cellspacing='0' border='0' style='margin:32px auto'>")
         .append("<tr><td style='border-radius:12px;background:linear-gradient(135deg,#f97316 0%,#ef4444 100%);box-shadow:0 8px 20px rgba(239,68,68,0.35)'>")
         .append("<a href='").append(safeLink).append("' target='_blank' ")
         .append("style='display:inline-block;padding:16px 40px;color:#ffffff;text-decoration:none;font-weight:700;font-size:16px;letter-spacing:0.3px;border-radius:12px'>")
         .append("&#128274;&nbsp;&nbsp;\u0110\u1EB7t l\u1EA1i m\u1EADt kh\u1EA9u")
         .append("</a>")
         .append("</td></tr></table>")

         .append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='margin:24px 0;background-color:#fff7ed;border-left:4px solid #f59e0b;border-radius:8px'>")
         .append("<tr><td style='padding:16px 20px;color:#92400e;font-size:14px;line-height:1.6'>")
         .append("<strong>&#9888; L\u01B0u \u00FD:</strong> N\u1EBFu b\u1EA1n kh\u00F4ng y\u00EAu c\u1EA7u \u0111\u1EB7t l\u1EA1i m\u1EADt kh\u1EA9u, vui l\u00F2ng b\u1ECF qua email n\u00E0y. ")
         .append("T\u00E0i kho\u1EA3n c\u1EE7a b\u1EA1n v\u1EABn an to\u00E0n v\u00E0 kh\u00F4ng c\u1EA7n thay \u0111\u1ED5i g\u00EC.")
         .append("</td></tr></table>")

         .append("<p style='margin:24px 0 8px 0;color:#6b7280;font-size:13px'>")
         .append("N\u1EBFu n\u00FAt kh\u00F4ng ho\u1EA1t \u0111\u1ED9ng, h\u00E3y sao ch\u00E9p li\u00EAn k\u1EBFt sau v\u00E0o tr\u00ECnh duy\u1EC7t:")
         .append("</p>")
         .append("<p style='margin:0;padding:12px 14px;background-color:#f1f5f9;border-radius:8px;word-break:break-all;font-family:SFMono-Regular,Consolas,monospace;font-size:12px;color:#475569'>")
         .append(safeLink)
         .append("</p>")
         .append("</td></tr>");

        // FOOTER
        b.append("<tr><td style='background-color:#0f172a;padding:28px 32px'>")
         .append("<div style='color:#ffffff;font-weight:700;margin-bottom:6px'>Electro Shop</div>")
         .append("<div style='color:#cbd5e1;font-size:13px;line-height:1.7'>")
         .append("Email n\u00E0y \u0111\u01B0\u1EE3c g\u1EEDi t\u1EF1 \u0111\u1ED9ng. Vui l\u00F2ng kh\u00F4ng tr\u1EA3 l\u1EDDi.")
         .append("<br/>Li\u00EAn h\u1EC7: <a href='mailto:").append(MailConfig.USERNAME).append("' style='color:#fbbf24;text-decoration:none'>")
         .append(MailConfig.USERNAME).append("</a>")
         .append("</div>")
         .append("<div style='margin-top:18px;padding-top:18px;border-top:1px solid #1e293b;color:#64748b;font-size:11px;line-height:1.6'>")
         .append("&copy; ").append(year).append(" Electro Shop. All rights reserved.")
         .append("</div>")
         .append("</td></tr>");

        b.append("</table>");

        b.append("<table role='presentation' width='100%' cellpadding='0' cellspacing='0' border='0' style='background-color:#f4f5f7'>")
         .append("<tr><td style='height:32px;line-height:32px;font-size:0'>&nbsp;</td></tr></table>");

        b.append("</body></html>");

        return b.toString();
    }

    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}