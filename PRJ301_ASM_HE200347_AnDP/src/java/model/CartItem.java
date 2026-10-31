package model;

/**
 *
 * @author Trung Hieu
 */
public class CartItem {

    private int cartItemID;
    private int cartID;
    private int productID;
    private int quantity;
    private Product product;

    public CartItem() {
    }

    public CartItem(int cartItemID, int cartID, int productID, int quantity) {
        this.cartItemID = cartItemID;
        this.cartID = cartID;
        this.productID = productID;
        this.quantity = quantity;
    }

    public CartItem(int cartItemID, int cartID, Product product, int quantity) {
        this.cartItemID = cartItemID;
        this.cartID = cartID;
        this.product = product;
        this.productID = product.getProductID();
        this.quantity = quantity;
    }

    public int getCartItemID() {
        return cartItemID;
    }

    public void setCartItemID(int cartItemID) {
        this.cartItemID = cartItemID;
    }

    public int getCartID() {
        return cartID;
    }

    public void setCartID(int cartID) {
        this.cartID = cartID;
    }

    public int getProductID() {
        return productID;
    }

    public void setProductID(int productID) {
        this.productID = productID;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
        if (product != null) {
            this.productID = product.getProductID();
        }
    }

    public double getTotal() {
        if (product == null) {
            return 0;
        }
        return product.getPrice() * quantity;
    }
}