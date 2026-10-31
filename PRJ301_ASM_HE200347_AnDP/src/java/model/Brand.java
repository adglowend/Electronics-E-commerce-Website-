package model;

/**
 *
 * @author Trung Hieu
 */
public class Brand {

    private int brandID;
    private String brandName;
    private String country;
    private boolean status;

    public Brand() {
    }

    public Brand(int brandID, String brandName, String country, boolean status) {
        this.brandID = brandID;
        this.brandName = brandName;
        this.country = country;
        this.status = status;
    }

    public int getBrandID() {
        return brandID;
    }

    public void setBrandID(int brandID) {
        this.brandID = brandID;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public boolean isStatus() {
        return status;
    }

    public void setStatus(boolean status) {
        this.status = status;
    }
}