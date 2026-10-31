package model;

import java.util.Date;

/**
 *
 * @author Trung Hieu
 */
public class Payment {

    public static final String METHOD_CASH = "Cash";
    public static final String METHOD_COD = "COD";

    public static final String STATUS_PENDING = "Pending";
    public static final String STATUS_PAID = "Paid";
    public static final String STATUS_CANCELLED = "Cancelled";

    private int paymentID;
    private int orderID;
    private String method;
    private String paymentStatus;
    private Date paymentDate;

    public Payment() {
    }

    public Payment(int paymentID, int orderID, String method,
                   String paymentStatus, Date paymentDate) {
        this.paymentID = paymentID;
        this.orderID = orderID;
        this.method = method;
        this.paymentStatus = paymentStatus;
        this.paymentDate = paymentDate;
    }

    public int getPaymentID() {
        return paymentID;
    }

    public void setPaymentID(int paymentID) {
        this.paymentID = paymentID;
    }

    public int getOrderID() {
        return orderID;
    }

    public void setOrderID(int orderID) {
        this.orderID = orderID;
    }

    public String getMethod() {
        return method;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public Date getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Date paymentDate) {
        this.paymentDate = paymentDate;
    }
}