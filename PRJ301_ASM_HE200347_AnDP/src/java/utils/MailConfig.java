package utils;

/**
 * Cấu hình email chung cho toàn bộ hệ thống.
 * Đổi tài khoản / app-password ở đây là đổi ở mọi servlet dùng mail.
 *
 * Lưu ý: không commit mật khẩu ứng dụng lên git public.
 * Với Gmail, cần tạo "App Password" trong cài đặt bảo mật tài khoản Google.
 */
public final class MailConfig {

    public static final String HOST     = "smtp.gmail.com";
    public static final int    PORT     = 587;

    // Tài khoản gửi (from)
    public static final String USERNAME = "thieuducdung254@gmail.com";

    // App password do người dùng cung cấp
    public static final String APP_PASSWORD = "cjck finy xram tbfe";

    public static final String FROM_NAME  = "Electro Shop";
    public static final String FROM_EMAIL = USERNAME;

    private MailConfig() {
        // utility class
    }
}
