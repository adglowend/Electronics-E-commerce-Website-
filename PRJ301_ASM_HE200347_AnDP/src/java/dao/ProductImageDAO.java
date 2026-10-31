package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import model.ProductImage;
import utils.DBContext;

public class ProductImageDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public ProductImageDAO() {
        conn = DBContext.getConnection();
    }

    public ArrayList<ProductImage> getImagesByProduct(int productID) {
        ArrayList<ProductImage> list = new ArrayList<>();
        String sql = "SELECT * FROM ProductImage WHERE ProductID=? ORDER BY IsMain DESC, DisplayOrder ASC";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productID);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insertImage(ProductImage img) {
        String sql = "INSERT INTO ProductImage(ProductID, ImageURL, IsMain, DisplayOrder) VALUES(?,?,?,?)";
        try {
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, img.getProductID());
            ps.setString(2, img.getImageURL());
            ps.setBoolean(3, img.isIsMain());
            ps.setInt(4, img.getDisplayOrder());
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

    public void deleteImage(int imageID) {
        String sql = "DELETE FROM ProductImage WHERE ImageID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, imageID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void unsetAllMain(int productID) {
        String sql = "UPDATE ProductImage SET IsMain=0 WHERE ProductID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void setMainImage(int imageID) {
        String sql = "UPDATE ProductImage SET IsMain=1 WHERE ImageID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, imageID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String getMainImage(int productID) {
        String sql = "SELECT TOP 1 ImageURL FROM ProductImage WHERE ProductID=? AND IsMain=1";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, productID);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("ImageURL");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private ProductImage map(ResultSet rs) throws Exception {
        ProductImage img = new ProductImage();
        img.setImageID(rs.getInt("ImageID"));
        img.setProductID(rs.getInt("ProductID"));
        img.setImageURL(rs.getString("ImageURL"));
        img.setIsMain(rs.getBoolean("IsMain"));
        img.setDisplayOrder(rs.getInt("DisplayOrder"));
        Timestamp c = rs.getTimestamp("CreatedAt");
        if (c != null) {
            img.setCreatedAt(new java.util.Date(c.getTime()));
        }
        return img;
    }
}