package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import model.Product;
import utils.DBContext;

public class ProductDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public ProductDAO() {
        conn = DBContext.getConnection();
    }

    private Product mapProduct(ResultSet rs) throws Exception {
        Product p = new Product();
        p.setProductID(rs.getInt("ProductID"));
        p.setCategoryID(rs.getInt("CategoryID"));
        p.setBrandID(rs.getInt("BrandID"));
        p.setProductName(rs.getString("ProductName"));
        p.setPrice(rs.getDouble("Price"));
        p.setQuantity(rs.getInt("Quantity"));
        p.setDescription(rs.getString("Description"));
        p.setStatus(rs.getBoolean("Status"));
        Timestamp created = rs.getTimestamp("CreatedAt");
        if (created != null) {
            p.setCreatedAt(new java.util.Date(created.getTime()));
        }
        Timestamp updated = rs.getTimestamp("UpdatedAt");
        if (updated != null) {
            p.setUpdatedAt(new java.util.Date(updated.getTime()));
        }
        return p;
    }

    public ArrayList<Product> getAllProduct() {
        ArrayList<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<Product> searchProducts(String keyword) {
        ArrayList<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product WHERE ProductName LIKE ? OR Description LIKE ?";
        try {
            ps = conn.prepareStatement(sql);
            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insertProduct(Product p) {
        String sql = "INSERT INTO Product(CategoryID, BrandID, ProductName, Price, Quantity, Description, Status) "
                   + "VALUES(?,?,?,?,?,?,?)";
        try {
            ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, p.getCategoryID());
            ps.setInt(2, p.getBrandID());
            ps.setString(3, p.getProductName());
            ps.setDouble(4, p.getPrice());
            ps.setInt(5, p.getQuantity());
            ps.setString(6, p.getDescription());
            ps.setBoolean(7, p.isStatus());
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

    public Product getProductById(int id) {
        String sql = "SELECT * FROM Product WHERE ProductID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapProduct(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void updateProduct(Product p) {
        String sql = "UPDATE Product SET CategoryID=?, BrandID=?, ProductName=?, "
                   + "Price=?, Quantity=?, Description=?, Status=?, UpdatedAt=GETDATE() "
                   + "WHERE ProductID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, p.getCategoryID());
            ps.setInt(2, p.getBrandID());
            ps.setString(3, p.getProductName());
            ps.setDouble(4, p.getPrice());
            ps.setInt(5, p.getQuantity());
            ps.setString(6, p.getDescription());
            ps.setBoolean(7, p.isStatus());
            ps.setInt(8, p.getProductID());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteProduct(int id) {
        String sql = "DELETE FROM Product WHERE ProductID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public ArrayList<Product> searchProduct(String keyword) {
        ArrayList<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product WHERE ProductName LIKE ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + keyword + "%");
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<Product> getProductByCategory(int categoryID) {
        ArrayList<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product WHERE CategoryID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, categoryID);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProductByCategory(int categoryID) {
        String sql = "SELECT COUNT(*) FROM Product WHERE CategoryID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, categoryID);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Trang sản phẩm theo category (page bắt đầu từ 1).
     * SQL Server: OFFSET ? ROWS FETCH NEXT ? ROWS ONLY.
     */
    public ArrayList<Product> getProductByCategoryPaged(int categoryID, int page, int pageSize) {
        ArrayList<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM Product WHERE CategoryID=? "
                   + "ORDER BY ProductID DESC "
                   + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try {
            ps = conn.prepareStatement(sql);
            int offset = (page - 1) * pageSize;
            ps.setInt(1, categoryID);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lookup ảnh đại diện của product: ưu tiên IsMain = 1, nếu không có thì
     * lấy ảnh đầu tiên theo DisplayOrder.
     */
    public String getMainImage(int productID) {
        String sql = "SELECT TOP 1 ImageURL FROM ProductImage "
                   + "WHERE ProductID=? "
                   + "ORDER BY IsMain DESC, DisplayOrder ASC";
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

    public int getCountAllProducts() {
        String sql = "SELECT COUNT(*) FROM Product";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getCountActiveProducts() {
        String sql = "SELECT COUNT(*) FROM Product WHERE Status = 1";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getCountLowStockProducts(int threshold) {
        String sql = "SELECT COUNT(*) FROM Product WHERE Quantity <= ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, threshold);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Inventory report: tổng Quantity cho mỗi Product (top N theo Quantity giảm dần).
     * Trả về mảng [N][2]: [0]=ProductName, [1]=StockQuantity (int).
     */
    public String[][] getInventoryReport(int topN) {
        String sql = "SELECT TOP (?) ProductName, Quantity "
                   + "FROM Product WHERE Status = 1 "
                   + "ORDER BY Quantity DESC";
        java.util.ArrayList<String[]> list = new java.util.ArrayList<>();
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, topN);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{ rs.getString("ProductName"), String.valueOf(rs.getInt("Quantity")) });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.toArray(new String[0][]);
    }
}