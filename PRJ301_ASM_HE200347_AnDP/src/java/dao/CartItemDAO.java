package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.CartItem;
import model.Product;
import utils.DBContext;

public class CartItemDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public CartItemDAO() {
        conn = DBContext.getConnection();
    }

    public ArrayList<CartItem> getCartItems(int cartID) {
        ArrayList<CartItem> list = new ArrayList<>();
        String sql = "SELECT ci.CartItemID, ci.CartID, ci.ProductID, ci.Quantity, "
                   + "p.ProductName, p.Price, p.Status AS ProductStatus, p.Quantity AS StockQuantity "
                   + "FROM CartItem ci JOIN Product p ON ci.ProductID = p.ProductID "
                   + "WHERE ci.CartID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, cartID);
            rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setProductID(rs.getInt("ProductID"));
                p.setProductName(rs.getString("ProductName"));
                p.setPrice(rs.getDouble("Price"));
                p.setQuantity(rs.getInt("StockQuantity"));
                p.setStatus(rs.getBoolean("ProductStatus"));

                CartItem ci = new CartItem();
                ci.setCartItemID(rs.getInt("CartItemID"));
                ci.setCartID(rs.getInt("CartID"));
                ci.setProductID(rs.getInt("ProductID"));
                ci.setQuantity(rs.getInt("Quantity"));
                ci.setProduct(p);
                list.add(ci);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public CartItem findItem(int cartID, int productID) {
        String sql = "SELECT * FROM CartItem WHERE CartID=? AND ProductID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, cartID);
            ps.setInt(2, productID);
            rs = ps.executeQuery();
            if (rs.next()) {
                CartItem ci = new CartItem();
                ci.setCartItemID(rs.getInt("CartItemID"));
                ci.setCartID(rs.getInt("CartID"));
                ci.setProductID(rs.getInt("ProductID"));
                ci.setQuantity(rs.getInt("Quantity"));
                return ci;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void addItem(int cartID, int productID, int quantity) {
        CartItem existing = findItem(cartID, productID);
        if (existing != null) {
            updateQuantity(existing.getCartItemID(), existing.getQuantity() + quantity);
            return;
        }
        String sql = "INSERT INTO CartItem(CartID, ProductID, Quantity) VALUES(?,?,?)";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, cartID);
            ps.setInt(2, productID);
            ps.setInt(3, quantity);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateQuantity(int cartItemID, int quantity) {
        if (quantity <= 0) {
            deleteItem(cartItemID);
            return;
        }
        String sql = "UPDATE CartItem SET Quantity=? WHERE CartItemID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, quantity);
            ps.setInt(2, cartItemID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteItem(int cartItemID) {
        String sql = "DELETE FROM CartItem WHERE CartItemID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, cartItemID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void clearCart(int cartID) {
        String sql = "DELETE FROM CartItem WHERE CartID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, cartID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}