package model;

import java.util.Date;

/**
 *
 * @author Trung Hieu
 */
public class Cart {

    private int cartID;
    private int userID;
    private Date createdAt;

    public Cart() {
    }

    public Cart(int cartID, int userID, Date createdAt) {
        this.cartID = cartID;
        this.userID = userID;
        this.createdAt = createdAt;
    }

    public int getCartID() {
        return cartID;
    }

    public void setCartID(int cartID) {
        this.cartID = cartID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}