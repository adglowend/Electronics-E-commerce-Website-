<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.CartItem"%>
<%
    request.setAttribute("pageTitle", "Shopping Cart - Electro");
    request.setAttribute("active", "cart");

    ArrayList<CartItem> rawCart = (ArrayList<CartItem>) session.getAttribute("cart");
    if (rawCart == null) {
        rawCart = new ArrayList<>();
    }
    ArrayList<CartItem> cart = new ArrayList<>();
    for (CartItem ci : rawCart) {
        if (ci != null && ci.getProduct() != null) {
            cart.add(ci);
        }
    }
    double total = 0;
    for (CartItem ci : cart) {
        total += ci.getTotal();
    }
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
    String ctx = request.getContextPath();
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/cart.css">

<!-- Product grid -->

<!-- Alerts -->
<div class="container py-3">
    <%
    if (session.getAttribute("error") != null) {
    %>
        <div class="alert alert-danger alert-dismissible fade show">
            <%= session.getAttribute("error") %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <%
        session.removeAttribute("error");
    }
    if (session.getAttribute("success") != null) {
    %>
        <div class="alert alert-success alert-dismissible fade show">
            <%= session.getAttribute("success") %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <%
        session.removeAttribute("success");
    }
    %>
</div>

<!-- Cart Content -->
<section class="container pb-5">

    <% if (cart.isEmpty()) { %>
        <div class="empty-cart">
            <i class="fa fa-shopping-cart mb-3 d-block"></i>
            <h3 class="mb-3">Your cart is empty</h3>
            <p class="text-muted">Looks like you haven't added anything to your cart yet.</p>
            <a href="<%=ctx%>/home" class="btn btn-dark rounded-pill px-4 py-2">
                <i class="fa fa-arrow-left me-2"></i>Continue Shopping
            </a>
        </div>
    <% } else { %>

        <div class="table-responsive">
            <table class="table cart-table align-middle bg-white">
                <thead>
                    <tr>
                        <th>Product</th>
                        <th>Price</th>
                        <th>Quantity</th>
                        <th>Total</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                for (CartItem item : cart) {
                    int lineTotal = (int) Math.round(item.getTotal());
                %>
                    <tr>
                        <td>
                            <strong><%= item.getProduct().getProductName() %></strong><br>
                            <small class="text-muted">ID: <%= item.getProductID() %></small>
                        </td>
                        <td><%= nf.format(item.getProduct().getPrice()) %> VND</td>
                        <td>
                            <form action="<%=ctx%>/customer/updateCart" method="post"
                                  class="d-flex align-items-center gap-2">
                                <input type="hidden" name="cartItemID" value="<%= item.getCartItemID() %>">
                                <div class="qty-box">
                                    <button type="submit" name="delta" value="-1" title="Decrease">&#8722;</button>
                                    <input type="number" name="quantity" min="1"
                                           value="<%= item.getQuantity() %>">
                                    <button type="submit" name="delta" value="1" title="Increase">+</button>
                                </div>
                                <button type="submit" name="delta" value="0" class="btn btn-sm btn-warning">
                                    Update
                                </button>
                            </form>
                        </td>
                        <td class="line-total"><%= nf.format(lineTotal) %> VND</td>
                        <td class="text-center">
                            <a href="<%=ctx%>/customer/removeCart?cartItemID=<%= item.getCartItemID() %>"
                               class="btn btn-sm btn-danger"
                               onclick="return confirm('Remove this item?')">
                                <i class="fa fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <div class="row justify-content-end mt-4">
            <div class="col-md-6 col-lg-5 col-xl-4">
                <div class="total-box">
                    <h4 class="mb-3">Cart Total</h4>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Subtotal:</span>
                        <strong><%= nf.format(total) %> VND</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Shipping:</span>
                        <span class="text-success">Free</span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between mb-3">
                        <strong>Total:</strong>
                        <strong class="text-danger fs-5"><%= nf.format(total) %> VND</strong>
                    </div>
                    <a href="<%=ctx%>/home" class="btn btn-outline-secondary w-100 rounded-pill py-2 mt-2">
                        Continue Shopping
                    </a>
                </div>

                <form action="<%=ctx%>/customer/checkout" method="get" class="payment-method-box mt-3">
                    <h6 class="mb-2"><i class="fa fa-credit-card me-1"></i>Phương thức thanh toán</h6>
                    <label class="payment-opt">
                        <input type="radio" name="paymentMethod" value="COD" checked>
                        <span><i class="fa fa-money-bill-wave me-1"></i>Thanh toán khi nhận hàng (COD)</span>
                    </label>
                    <label class="payment-opt">
                        <input type="radio" name="paymentMethod" value="VNPay">
                        <span><i class="fa fa-shield-alt me-1"></i>Thanh toán qua VNPay (QR / ATM / Visa)</span>
                    </label>
                    <button type="submit" class="btn btn-dark w-100 rounded-pill py-2 mt-2">
                        <i class="fa fa-check me-1"></i>Đặt hàng
                    </button>
                </form>
            </div>
        </div>

    <% } %>

<%@include file="../common/customerFooter.jsp" %>
