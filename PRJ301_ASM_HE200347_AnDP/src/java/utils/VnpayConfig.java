package utils;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Cấu hình và tiện ích VNPay.
 * Refactored từ com.vnpay.common.Config để phù hợp với cấu trúc package của project.
 *
 * Lưu ý: Hai thông số quan trọng cần cấu hình trước khi chạy:
 *   - vnp_TmnCode   : Mã website (Terminal) VNPay cấp
 *   - secretKey     : Chuỗi bí mật VNPay cấp
 *   - vnp_ReturnPath : path return sau khi thanh toán (tương đối, ghép với request để ra URL tuyệt đối)
 */
public class VnpayConfig {

    public static String vnp_PayUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    // vnp_ReturnUrl giờ là PATH tương đối (bắt đầu bằng "/"). Khi build URL thanh toán,
    // VnpayServlet sẽ ghép với scheme + host + port + contextPath từ request thực tế,
    // tránh phải hardcode context path (vd /demo hay /ComputerStore).
    public static String vnp_ReturnPath = "/vnpay/return";
    public static String vnp_TmnCode = "20VZCLAD";
    public static String secretKey = "DH9NB2N2U0KN9UX1M1COZDZ0871PO855";
    public static String vnp_ApiUrl = "https://sandbox.vnpayment.vn/merchant_webapi/api/transaction";

    /**
     * Build URL return tuyệt đối từ request hiện tại + path tương đối trong config.
     * Ví dụ: request = localhost:8080/ComputerStore, path = /vnpay/return
     *        → http://localhost:8080/ComputerStore/vnpay/return
     */
    public static String buildReturnUrl(jakarta.servlet.http.HttpServletRequest request) {
        String scheme = request.getScheme();             // http / https
        String serverName = request.getServerName();     // localhost
        int serverPort = request.getServerPort();        // 8080
        String ctx = request.getContextPath();           // /ComputerStore hoặc /demo

        // Port mặc định (80/443) thì không ghi, các port khác thì ghi kèm
        boolean defaultPort =
                ("http".equalsIgnoreCase(scheme)  && serverPort == 80) ||
                ("https".equalsIgnoreCase(scheme) && serverPort == 443);

        StringBuilder sb = new StringBuilder();
        sb.append(scheme).append("://").append(serverName);
        if (!defaultPort) {
            sb.append(":").append(serverPort);
        }
        sb.append(ctx).append(vnp_ReturnPath);
        return sb.toString();
    }

    public static String md5(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest(message.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder(2 * hash.length);
            for (byte b : hash) {
                sb.append(String.format("%02x", b & 0xff));
            }
            digest = sb.toString();
        } catch (UnsupportedEncodingException ex) {
            digest = "";
        } catch (NoSuchAlgorithmException ex) {
            digest = "";
        }
        return digest;
    }

    public static String Sha256(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(message.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder(2 * hash.length);
            for (byte b : hash) {
                sb.append(String.format("%02x", b & 0xff));
            }
            digest = sb.toString();
        } catch (UnsupportedEncodingException ex) {
            digest = "";
        } catch (NoSuchAlgorithmException ex) {
            digest = "";
        }
        return digest;
    }

    /**
     * Băm tất cả các field (đã sort theo key) bằng HMAC-SHA512 với secretKey.
     * Dùng để tạo chữ ký khi tạo URL thanh toán và để xác minh checksum khi VNPay trả về.
     */
    @SuppressWarnings({"rawtypes", "unchecked"})
    public static String hashAllFields(Map fields) {
        List fieldNames = new ArrayList(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder sb = new StringBuilder();
        Iterator itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = (String) itr.next();
            String fieldValue = (String) fields.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                sb.append(fieldName);
                sb.append("=");
                sb.append(fieldValue);
            }
            if (itr.hasNext()) {
                sb.append("&");
            }
        }
        return hmacSHA512(secretKey, sb.toString());
    }

    public static String hmacSHA512(final String key, final String data) {
        try {
            if (key == null || data == null) {
                throw new NullPointerException();
            }
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes();
            final SecretKeySpec secretKeySpec = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKeySpec);
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = hmac512.doFinal(dataBytes);
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            return "";
        }
    }

    public static String getIpAddress(HttpServletRequest request) {
        String ipAdress;
        try {
            ipAdress = request.getHeader("X-FORWARDED-FOR");
            if (ipAdress == null) {
                ipAdress = request.getRemoteAddr();
            }
        } catch (Exception e) {
            ipAdress = "Invalid IP:" + e.getMessage();
        }
        return ipAdress;
    }

    public static String getRandomNumber(int len) {
        Random rnd = new Random();
        String chars = "0123456789";
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }
}