package model;

import java.util.Date;

/**
 *
 * @author Trung Hieu
 */
public class Product {

    private int productID;
    private int categoryID;
    private int brandID;
    private String productName;
    private double price;
    private int quantity;
    private String description;
    private boolean status;
    private Date createdAt;
    private Date updatedAt;

    public Product() {
    }

    public Product(int productID, int categoryID, int brandID,
                   String productName, double price,
                   int quantity, String description,
                   boolean status, Date createdAt, Date updatedAt) {

        this.productID = productID;
        this.categoryID = categoryID;
        this.brandID = brandID;
        this.productName = productName;
        this.price = price;
        this.quantity = quantity;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public int getCategoryID() {
        return categoryID;
    }

    public void setCategoryID(int categoryID) {
        this.categoryID = categoryID;
    }

    public int getBrandID() {
        return brandID;
    }

    public void setBrandID(int brandID) {
        this.brandID = brandID;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
}