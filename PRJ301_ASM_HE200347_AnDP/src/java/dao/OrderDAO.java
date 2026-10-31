package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import model.Order;
import model.OrderDetail;
import utils.DBContext;

public class OrderDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public OrderDAO() {
        conn = DBContext.getConnection();
    }

    private Order mapOrder(ResultSet rs) throws Exception {
        Order o = new Order();
        o.setOrderID(rs.getInt("OrderID"));
        o.setUserID(rs.getInt("UserID"));
        Timestamp t = rs.getTimestamp("OrderDate");
        if (t != null) {
            o.setOrderDate(new java.util.Date(t.getTime()));
        }
        o.setTotalAmount(rs.getDouble("TotalAmount"));
        o.setStatus(rs.getString("Status"));
        // Customer info from JOIN
        o.setCustomerName(rs.getString("FullName"));
        o.setCustomerEmail(rs.getString("Email"));
        o.setCustomerPhone(rs.getString("Phone"));
        return o;
    }

    public int insertOrder(Order o) {
        String sql = "INSERT INTO Orders(UserID, TotalAmount, Status) VALUES(?,?,?)";
        try {
            ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setInt(1, o.getUserID());
            ps.setDouble(2, o.getTotalAmount());
            ps.setString(3, o.getStatus());
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

    public void insertOrderDetail(OrderDetail od) {
        String sql = "INSERT INTO OrderDetail(OrderID, ProductID, Quantity, Price) VALUES(?,?,?,?)";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, od.getOrderID());
            ps.setInt(2, od.getProductID());
            ps.setInt(3, od.getQuantity());
            ps.setDouble(4, od.getPrice());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public ArrayList<OrderDetail> getOrderDetails(int orderID) {
        ArrayList<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM OrderDetail WHERE OrderID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderID);
            rs = ps.executeQuery();
            while (rs.next()) {
                OrderDetail od = new OrderDetail();
                od.setOrderDetailID(rs.getInt("OrderDetailID"));
                od.setOrderID(rs.getInt("OrderID"));
                od.setProductID(rs.getInt("ProductID"));
                od.setQuantity(rs.getInt("Quantity"));
                od.setPrice(rs.getDouble("Price"));
                list.add(od);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<Order> getOrderByUser(int userID) {
        ArrayList<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.FullName, u.Email, u.Phone "
                   + "FROM Orders o LEFT JOIN Users u ON o.UserID = u.UserID "
                   + "WHERE o.UserID=? ORDER BY o.OrderDate DESC";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userID);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<Order> getAllOrder() {
        ArrayList<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.FullName, u.Email, u.Phone "
                   + "FROM Orders o LEFT JOIN Users u ON o.UserID = u.UserID "
                   + "ORDER BY o.OrderDate DESC";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public ArrayList<Order> searchOrders(String keyword) {
        ArrayList<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, u.FullName, u.Email, u.Phone "
                   + "FROM Orders o LEFT JOIN Users u ON o.UserID = u.UserID "
                   + "WHERE u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? "
                   + "ORDER BY o.OrderDate DESC";
        try {
            ps = conn.prepareStatement(sql);
            String kw = "%" + keyword + "%";
            ps.setString(1, kw);
            ps.setString(2, kw);
            ps.setString(3, kw);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Order getOrderByID(int orderID) {
        String sql = "SELECT o.*, u.FullName, u.Email, u.Phone "
                   + "FROM Orders o LEFT JOIN Users u ON o.UserID = u.UserID "
                   + "WHERE o.OrderID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderID);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapOrder(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void updateStatus(int orderID, String status) {
        String sql = "UPDATE Orders SET Status=? WHERE OrderID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, orderID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Trừ tồn kho Product theo OrderDetail của đơn hàng.
     * Dùng đơn giản: lặp qua từng OrderDetail, UPDATE Product SET Quantity = Quantity - ?
     * với điều kiện Quantity >= ? để tránh trừ âm.
     * Trả về true nếu tất cả cập nhật thành công.
     */
    public boolean decreaseStockFromOrder(int orderID) {
        String selectSql = "SELECT ProductID, Quantity FROM OrderDetail WHERE OrderID=?";
        String updateSql = "UPDATE Product SET Quantity = Quantity - ?, UpdatedAt = GETDATE() "
                         + "WHERE ProductID = ? AND Quantity >= ?";
        try {
            ps = conn.prepareStatement(selectSql);
            ps.setInt(1, orderID);
            rs = ps.executeQuery();
            ArrayList<int[]> items = new ArrayList<>();
            while (rs.next()) {
                items.add(new int[]{ rs.getInt("ProductID"), rs.getInt("Quantity") });
            }
            rs.close();
            ps.close();

            boolean allOk = true;
            for (int[] item : items) {
                PreparedStatement ups = conn.prepareStatement(updateSql);
                ups.setInt(1, item[1]);
                ups.setInt(2, item[0]);
                ups.setInt(3, item[1]);
                int rows = ups.executeUpdate();
                if (rows == 0) {
                    // Không đủ hàng — đánh dấu thất bại nhưng tiếp tục các sp khác
                    allOk = false;
                }
                ups.close();
            }
            return allOk;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Customer huỷ đơn hàng. Chỉ cho phép khi đơn ở trạng thái "Pending"
     * và đúng chủ sở hữu (tránh IDOR). Trả về true nếu UPDATE thành công.
     */
    public boolean cancelOrder(int orderID, int userID) {
        String sql = "UPDATE Orders SET Status='Cancelled' "
                   + "WHERE OrderID=? AND UserID=? AND Status='Pending'";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderID);
            ps.setInt(2, userID);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void deleteOrder(int orderID) {
        try {
            // Xoá OrderDetail trước (FK)
            ps = conn.prepareStatement("DELETE FROM OrderDetail WHERE OrderID=?");
            ps.setInt(1, orderID);
            ps.executeUpdate();
            // Xoá Payment (nếu có)
            ps = conn.prepareStatement("DELETE FROM Payment WHERE OrderID=?");
            ps.setInt(1, orderID);
            ps.executeUpdate();
            // Xoá Order
            ps = conn.prepareStatement("DELETE FROM Orders WHERE OrderID=?");
            ps.setInt(1, orderID);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int getCountAllOrders() {
        String sql = "SELECT COUNT(*) FROM Orders";
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

    public double getTotalRevenue() {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders WHERE Status != 'Cancelled'";
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getCountOrdersByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE Status = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
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
     * Lấy doanh thu theo tháng trong năm hiện tại (12 tháng)
     * Trả về mảng double[12] cho Jan-Dec
     */
    public double[] getMonthlyRevenue(int year) {
        double[] monthly = new double[12];
        String sql = "SELECT MONTH(OrderDate) as Month, ISNULL(SUM(TotalAmount), 0) as Revenue "
                   + "FROM Orders WHERE YEAR(OrderDate) = ? AND Status != 'Cancelled' "
                   + "GROUP BY MONTH(OrderDate) ORDER BY Month";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, year);
            rs = ps.executeQuery();
            while (rs.next()) {
                int month = rs.getInt("Month");
                monthly[month - 1] = rs.getDouble("Revenue");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return monthly;
    }

    /**
     * Lấy số đơn hàng theo từng trạng thái
     */
    public int getCountByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE Status = ?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
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
     * Top N sản phẩm bán chạy (theo tổng Quantity đã bán trong các đơn không bị huỷ).
     * Trả về mảng 2 chiều [N][2]: [0]=ProductName, [1]=TotalSold (int).
     */
    public String[][] getTopSellingProducts(int topN) {
        String sql = "SELECT TOP (?) p.ProductName, SUM(od.Quantity) AS TotalSold "
                   + "FROM OrderDetail od "
                   + "JOIN Orders o  ON od.OrderID = o.OrderID "
                   + "JOIN Product p ON od.ProductID = p.ProductID "
                   + "WHERE o.Status <> 'Cancelled' "
                   + "GROUP BY p.ProductName "
                   + "ORDER BY TotalSold DESC";
        java.util.ArrayList<String[]> list = new java.util.ArrayList<>();
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, topN);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{ rs.getString("ProductName"), String.valueOf(rs.getInt("TotalSold")) });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.toArray(new String[0][]);
    }

    /**
     * Top N VIP Customers theo tổng chi tiêu (chỉ tính đơn không bị huỷ).
     * Trả về mảng [N][2]: [0]=FullName, [1]=TotalSpent (double, format tiền).
     */
    public String[][] getTopVipCustomers(int topN) {
        String sql = "SELECT TOP (?) u.FullName, SUM(o.TotalAmount) AS TotalSpent "
                   + "FROM Orders o JOIN Users u ON o.UserID = u.UserID "
                   + "WHERE o.Status <> 'Cancelled' "
                   + "GROUP BY u.UserID, u.FullName "
                   + "ORDER BY TotalSpent DESC";
        java.util.ArrayList<String[]> list = new java.util.ArrayList<>();
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, topN);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new String[]{ rs.getString("FullName"), String.valueOf(rs.getDouble("TotalSpent")) });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list.toArray(new String[0][]);
    }
}