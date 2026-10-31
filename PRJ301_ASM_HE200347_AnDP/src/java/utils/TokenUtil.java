package utils;

import java.security.SecureRandom;
import java.util.Base64;

/**
 * Sinh token ngẫu nhiên dùng cho việc kích hoạt tài khoản, reset mật khẩu, ...
 */
public final class TokenUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final int BYTE_LENGTH = 32; // 256-bit

    private TokenUtil() {
    }

    /** Trả về chuỗi URL-safe, khoảng 43 ký tự, dùng làm activation token. */
    public static String generate() {
        byte[] bytes = new byte[BYTE_LENGTH];
        RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
