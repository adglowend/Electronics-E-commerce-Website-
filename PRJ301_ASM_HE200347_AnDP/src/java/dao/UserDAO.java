package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import model.Role;
import model.User;
import utils.DBContext;

public class UserDAO {

    private Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public UserDAO() {
        conn = DBContext.getConnection();
    }

    private User mapUser(ResultSet rs) throws Exception {
        User u = new User();
        u.setUserID(rs.getInt("UserID"));
        u.setFullName(rs.getString("FullName"));
        u.setEmail(rs.getString("Email"));
        u.setPasswordHash(rs.getString("PasswordHash"));
        u.setPhone(rs.getString("Phone"));
        u.setAddress(rs.getString("Address"));
        u.setRoleID(rs.getInt("RoleID"));
        u.setStatus(rs.getBoolean("Status"));

        Timestamp created = rs.getTimestamp("CreatedAt");
        if (created != null) {
            u.setCreatedAt(new java.util.Date(created.getTime()));
        }
        Timestamp updated = rs.getTimestamp("UpdatedAt");
        if (updated != null) {
            u.setUpdatedAt(new java.util.Date(updated.getTime()));
        }
        try {
            u.setActivationToken(rs.getString("ActivationToken"));
        } catch (java.sql.SQLException ignore) {
            // column may not exist yet on legacy DB
        }
        return u;
    }

    public User login(String email, String passwordHash) {
        String sql = "SELECT * FROM Users WHERE Email = ? AND PasswordHash = ? AND Status = 1";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Role getRoleByID(int roleID) {
        String sql = "SELECT * FROM Role WHERE RoleID = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roleID);
            rs = ps.executeQuery();
            if (rs.next()) {
                Role r = new Role();
                r.setRoleID(rs.getInt("RoleID"));
                r.setRoleName(rs.getString("RoleName"));
                r.setDescription(rs.getString("Description"));
                r.setStatus(rs.getBoolean("Status"));
                return r;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public ArrayList<Role> getAllRole() {
        ArrayList<Role> list = new ArrayList<>();
        String sql = "SELECT * FROM Role";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Role r = new Role();
                r.setRoleID(rs.getInt("RoleID"));
                r.setRoleName(rs.getString("RoleName"));
                r.setDescription(rs.getString("Description"));
                r.setStatus(rs.getBoolean("Status"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getRoleIDByName(String roleName) {
        if (roleName == null) return 0;
        String sql = "SELECT RoleID FROM Role WHERE RoleName = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, roleName);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("RoleID");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public ArrayList<User> getAllUser() {
        ArrayList<User> list = new ArrayList<>();
        String sql = "SELECT * FROM Users";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<User> searchUsers(String keyword) {
        ArrayList<User> list = new ArrayList<>();
        String sql = "SELECT * FROM Users WHERE FullName LIKE ? OR Email LIKE ? OR Phone LIKE ?";
        try {
            ps = conn.prepareStatement(sql);
            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public User getUserById(int id) {
        String sql = "SELECT * FROM Users WHERE UserID = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM Users WHERE Email = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void insertUser(User u) {
        String sql = "INSERT INTO Users(FullName, Email, PasswordHash, Phone, Address, RoleID, Status) VALUES(?,?,?,?,?,?,?)";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPasswordHash());
            ps.setString(4, u.getPhone());
            ps.setString(5, u.getAddress());
            ps.setInt(6, u.getRoleID());
            ps.setBoolean(7, u.isStatus());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateUser(User u) {
        String sql = "UPDATE Users SET FullName=?, Email=?, PasswordHash=?, Phone=?, Address=?, RoleID=?, Status=?, UpdatedAt=GETDATE() WHERE UserID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPasswordHash());
            ps.setString(4, u.getPhone());
            ps.setString(5, u.getAddress());
            ps.setInt(6, u.getRoleID());
            ps.setBoolean(7, u.isStatus());
            ps.setInt(8, u.getUserID());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteUser(int id) {
        String sql = "DELETE FROM Users WHERE UserID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateProfile(User u) {
        String sql = "UPDATE Users SET FullName=?, Phone=?, Address=?, UpdatedAt=GETDATE() WHERE UserID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getPhone());
            ps.setString(3, u.getAddress());
            ps.setInt(4, u.getUserID());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void changePassword(int userID, String passwordHash) {
        String sql = "UPDATE Users SET PasswordHash=?, UpdatedAt=GETDATE() WHERE UserID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, passwordHash);
            ps.setInt(2, userID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Insert user bao gồm cột ActivationToken (dùng khi đăng ký kèm email kích hoạt).
     * Status mặc định = false (chưa kích hoạt) — servlet tự quyết định.
     */
    public boolean insertUserWithToken(User u) {
        String sql = "INSERT INTO Users(FullName, Email, PasswordHash, Phone, Address, RoleID, Status, ActivationToken) VALUES(?,?,?,?,?,?,?,?)";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPasswordHash());
            ps.setString(4, u.getPhone());
            ps.setString(5, u.getAddress());
            ps.setInt(6, u.getRoleID());
            ps.setBoolean(7, u.isStatus());
            ps.setString(8, u.getActivationToken());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public User findByActivationToken(String token) {
        if (token == null || token.isEmpty()) return null;
        String sql = "SELECT * FROM Users WHERE ActivationToken = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean activateByToken(String token) {
        String sql = "UPDATE Users SET Status = 1, ActivationToken = NULL, UpdatedAt = GETDATE() WHERE ActivationToken = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateActivationToken(int userID, String token) {
        String sql = "UPDATE Users SET ActivationToken = ?, UpdatedAt = GETDATE() WHERE UserID = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, token);
            ps.setInt(2, userID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Đặt lại mật khẩu qua token: cập nhật password mới và xóa token để không dùng lại được.
     */
    public boolean changePasswordAndClearToken(int userID, String newPasswordHash) {
        String sql = "UPDATE Users SET PasswordHash = ?, ActivationToken = NULL, UpdatedAt = GETDATE() WHERE UserID = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, newPasswordHash);
            ps.setInt(2, userID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int getCountAllUsers() {
        String sql = "SELECT COUNT(*) FROM Users";
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

    public int getCountActiveUsers() {
        String sql = "SELECT COUNT(*) FROM Users WHERE Status = 1";
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

    public int getCountUsersByRole(int roleID) {
        String sql = "SELECT COUNT(*) FROM Users WHERE RoleID = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, roleID);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
}