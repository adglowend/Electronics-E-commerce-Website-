package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import model.Cart;
import utils.DBContext;

public class CartDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public CartDAO() {
        conn = DBContext.getConnection();
    }

    public Cart getCartByUser(int userID) {
        String sql = "SELECT * FROM Cart WHERE UserID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userID);
            rs = ps.executeQuery();
            if (rs.next()) {
                Cart c = new Cart();
                c.setCartID(rs.getInt("CartID"));
                c.setUserID(rs.getInt("UserID"));
                Timestamp t = rs.getTimestamp("CreatedAt");
                if (t != null) {
                    c.setCreatedAt(new java.util.Date(t.getTime()));
                }
                return c;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getOrCreateCart(int userID) {
        Cart existing = getCartByUser(userID);
        if (existing != null) {
            return existing.getCartID();
        }
        String sql = "INSERT INTO Cart(UserID) VALUES(?)";
        try {
            ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setInt(1, userID);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}