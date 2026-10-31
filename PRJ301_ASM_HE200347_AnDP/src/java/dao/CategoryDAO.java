package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.Category;
import utils.DBContext;

public class CategoryDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public CategoryDAO() {
        conn = DBContext.getConnection();
    }

    private Category map(ResultSet rs) throws Exception {
        Category c = new Category();
        c.setCategoryID(rs.getInt("CategoryID"));
        c.setCategoryName(rs.getString("CategoryName"));
        c.setDescription(rs.getString("Description"));
        c.setStatus(rs.getBoolean("Status"));
        return c;
    }

    public ArrayList<Category> getAllCategory() {
        ArrayList<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Category";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<Category> searchCategories(String keyword) {
        ArrayList<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM Category WHERE CategoryName LIKE ? OR Description LIKE ?";
        try {
            ps = conn.prepareStatement(sql);
            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insertCategory(Category c) {
        String sql = "INSERT INTO Category(CategoryName, Description, Status) VALUES(?,?,?)";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, c.getCategoryName());
            ps.setString(2, c.getDescription());
            ps.setBoolean(3, c.isStatus());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Category getCategoryById(int id) {
        String sql = "SELECT * FROM Category WHERE CategoryID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void updateCategory(Category c) {
        String sql = "UPDATE Category SET CategoryName=?, Description=?, Status=? WHERE CategoryID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, c.getCategoryName());
            ps.setString(2, c.getDescription());
            ps.setBoolean(3, c.isStatus());
            ps.setInt(4, c.getCategoryID());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteCategory(int id) {
        String sql = "DELETE FROM Category WHERE CategoryID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}