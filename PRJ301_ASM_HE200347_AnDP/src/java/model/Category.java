package model;

/**
 *
 * @author Trung Hieu
 */
public class Category {

    private int categoryID;
    private String categoryName;
    private String description;
    private boolean status;

    public Category() {
    }

    public Category(int categoryID, String categoryName, String description, boolean status) {
        this.categoryID = categoryID;
        this.categoryName = categoryName;
        this.description = description;
        this.status = status;
    }

    public int getCategoryID() {
        return categoryID;
    }

    public void setCategoryID(int categoryID) {
        this.categoryID = categoryID;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
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
}