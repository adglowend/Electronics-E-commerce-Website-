package model;

import java.util.Date;

/**
 *
 * @author Trung Hieu
 */
public class ProductImage {

    private int imageID;
    private int productID;
    private String imageURL;
    private boolean isMain;
    private int displayOrder;
    private Date createdAt;

    public ProductImage() {
    }

    public ProductImage(int imageID, int productID, String imageURL,
                        boolean isMain, int displayOrder, Date createdAt) {
        this.imageID = imageID;
        this.productID = productID;
        this.imageURL = imageURL;
        this.isMain = isMain;
        this.displayOrder = displayOrder;
        this.createdAt = createdAt;
    }

    public int getImageID() {
        return imageID;
    }

    public void setImageID(int imageID) {
        this.imageID = imageID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public boolean isIsMain() {
        return isMain;
    }

    public void setIsMain(boolean isMain) {
        this.isMain = isMain;
    }

    public int getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(int displayOrder) {
        this.displayOrder = displayOrder;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}