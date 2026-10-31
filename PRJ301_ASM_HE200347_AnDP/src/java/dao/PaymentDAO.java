package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import model.Payment;
import utils.DBContext;

public class PaymentDAO {

    private final Connection conn;
    private PreparedStatement ps;
    private ResultSet rs;

    public PaymentDAO() {
        conn = DBContext.getConnection();
    }

    public void insertPayment(Payment p) {
        String sql = "INSERT INTO Payment(OrderID, Method, PaymentStatus, PaymentDate) VALUES(?,?,?,?)";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, p.getOrderID());
            ps.setString(2, p.getMethod());
            ps.setString(3, p.getPaymentStatus());
            if (p.getPaymentDate() != null) {
                ps.setTimestamp(4, new Timestamp(p.getPaymentDate().getTime()));
            } else {
                ps.setNull(4, java.sql.Types.TIMESTAMP);
            }
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public ArrayList<Payment> getPaymentsByOrder(int orderID) {
        ArrayList<Payment> list = new ArrayList<>();
        String sql = "SELECT * FROM Payment WHERE OrderID=?";
        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderID);
            rs = ps.executeQuery();
            while (rs.next()) {
                Payment p = new Payment();
                p.setPaymentID(rs.getInt("PaymentID"));
                p.setOrderID(rs.getInt("OrderID"));
                p.setMethod(rs.getString("Method"));
                p.setPaymentStatus(rs.getString("PaymentStatus"));
                Timestamp t = rs.getTimestamp("PaymentDate");
                if (t != null) {
                    p.setPaymentDate(new java.util.Date(t.getTime()));
                }
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}