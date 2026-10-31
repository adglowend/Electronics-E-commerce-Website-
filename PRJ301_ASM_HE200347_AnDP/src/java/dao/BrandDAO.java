package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.Brand;
import utils.DBContext;

public class BrandDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public BrandDAO() {
        conn = DBContext.getConnection();
    }

    private Brand map(ResultSet rs) throws Exception {
        Brand b = new Brand();
        b.setBrandID(rs.getInt("BrandID"));
        b.setBrandName(rs.getString("BrandName"));
        b.setCountry(rs.getString("Country"));
        b.setStatus(rs.getBoolean("Status"));
        return b;
    }

    public ArrayList<Brand> getAllBrand() {
        ArrayList<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM Brand";
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

    public ArrayList<Brand> searchBrands(String keyword) {
        ArrayList<Brand> list = new ArrayList<>();
        String sql = "SELECT * FROM Brand WHERE BrandName LIKE ? OR Country LIKE ?";
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

    public void insertBrand(Brand b) {
        String sql = "INSERT INTO Brand(BrandName, Country, Status) VALUES(?,?,?)";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, b.getBrandName());
            ps.setString(2, b.getCountry());
            ps.setBoolean(3, b.isStatus());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Brand getBrandById(int id) {
        String sql = "SELECT * FROM Brand WHERE BrandID=?";
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

    public void updateBrand(Brand b) {
        String sql = "UPDATE Brand SET BrandName=?, Country=?, Status=? WHERE BrandID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, b.getBrandName());
            ps.setString(2, b.getCountry());
            ps.setBoolean(3, b.isStatus());
            ps.setInt(4, b.getBrandID());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteBrand(int id) {
        String sql = "DELETE FROM Brand WHERE BrandID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}