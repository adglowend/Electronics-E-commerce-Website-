<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.Category"%>
<%@page import="model.Product"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    if (request.getAttribute("pageTitle") == null) {
        request.setAttribute("pageTitle", "Search - Electro");
    }

    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> list = (List<Product>) request.getAttribute("list");
    Map<Integer, String> mainImages = (Map<Integer, String>) request.getAttribute("mainImages");
    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) keyword = "";

    if (mainImages == null) mainImages = new java.util.HashMap<>();
    if (list == null) list = new java.util.ArrayList<>();
    if (categories == null) categories = new java.util.ArrayList<>();

    String ctx = request.getContextPath();
    if (request.getAttribute("active") == null) {
        request.setAttribute("active", "search");
    }
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/search.css">

<!-- Hero band removed -->

<!-- Category chips removed: navbar already has DB-driven categories -->

<!-- Result grid -->
<section class="py-5" style="background:#f8f9fa;">
    <div class="container">
        <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap">
            <h2 class="fw-bold m-0">
                <% if (keyword.isEmpty()) { %>
                    Browse all products
                <% } else { %>
                    Search results
                <% } %>
                <span class="text-muted fs-6">(<%= list.size() %> items)</span>
            </h2>
        </div>

        <%
        if (list.isEmpty()) {
        %>
            <div class="empty-search">
                <i class="fa fa-search"></i>
                <%
                if (keyword.isEmpty()) {
                %>
                    <h4 class="mt-3">Start searching</h4>
                    <p class="text-muted">Enter a product name in the search box above to find what you need.</p>
                <%
                } else {
                %>
                    <h4 class="mt-3">No products found for "<%= keyword %>"</h4>
                    <p class="text-muted">Try a different keyword or browse the categories above.</p>
                <%
                }
                %>
                <a href="<%=ctx%>/home" class="btn btn-primary rounded-pill px-4 mt-2">
                    <i class="fa fa-home me-1"></i>Back to Home
                </a>
            </div>
        <%
        } else {
        %>
            <div class="row g-4 cat-grid">
                <%
                int col = 0;
                for (Product p : list) {
                    col++;
                    String img = mainImages.get(p.getProductID());
                    boolean inStock = p.getQuantity() > 0 && p.isStatus();
                    double price = p.getPrice();
                    double oldPrice = (col % 4 == 0) ? price * 1.25 : 0;
                    int rating = 3 + ((p.getProductID() * 7) % 3);
                    int reviewCount = 5 + ((p.getProductID() * 11) % 95);
                    String badgeClass = "badge-new";
                    String badgeText = "New";
                    if (col % 5 == 0) { badgeClass = "badge-hot"; badgeText = "Hot"; }
                    else if (col % 4 == 0) { badgeClass = "badge-sale"; badgeText = "-25%"; }
                    else if (inStock) { badgeClass = "badge-stock"; badgeText = "In Stock"; }
                %>
                    <div class="col-6 col-md-4 col-lg-3">
                        <div class="product-card-wrap rounded overflow-hidden shadow-sm h-100">

                            <div class="product-card-img" style="height:260px; background:#f1f3f5; position:relative;">
                                <a href="<%=ctx%>/customer/detail?id=<%=p.getProductID()%>" class="d-block h-100 w-100">
                                    <%
                                    if (img != null && !img.trim().isEmpty()) {
                                    %>
                                        <img src="<%=img%>" class="img-fluid w-100 h-100" style="object-fit:cover;" alt="<%=p.getProductName()%>">
                                    <%
                                    } else {
                                    %>
                                        <div class="w-100 h-100 d-flex align-items-center justify-content-center">
                                            <i class="fa fa-image fa-4x text-muted"></i>
                                        </div>
                                    <%
                                    }
                                    %>
                                </a>
                                <span class="product-badge <%=badgeClass%>"><%= badgeText %></span>
                                <a href="<%=ctx%>/customer/detail?id=<%=p.getProductID()%>"
                                   class="product-card-qv btn btn-light btn-sm rounded-circle shadow"
                                   title="View Detail" style="z-index:5;">
                                    <i class="fa fa-eye"></i>
                                </a>
                                <div class="product-card-add" style="z-index:5;">
                                    <%
                                    if (inStock) {
                                    %>
                                        <a href="<%=ctx%>/customer/addCart?id=<%=p.getProductID()%>"
                                           class="btn btn-dark rounded-pill px-3 py-2 shadow fw-bold d-inline-block">
                                            <i class="fas fa-shopping-cart me-1"></i>Add to Cart
                                        </a>
                                    <%
                                    } else {
                                    %>
                                        <button class="btn btn-secondary rounded-pill px-3 py-2 shadow fw-bold" disabled>
                                            <i class="fa fa-ban me-1"></i>Out of Stock
                                        </button>
                                    <%
                                    }
                                    %>
                                </div>
                            </div>

                            <div class="product-card-info p-3">
                                <p class="mb-1" style="font-size:0.75rem; color:#888; text-transform:uppercase; letter-spacing:.5px;">
                                    <%=p.getDescription() != null ? p.getDescription() : "Electronics"%>
                                </p>
                                <h5 class="mb-2 fw-bold" style="font-size:0.95rem; line-height:1.3; color:#333;">
                                    <a href="<%=ctx%>/customer/detail?id=<%=p.getProductID()%>" class="text-decoration-none text-dark">
                                        <%=p.getProductName()%>
                                    </a>
                                </h5>
                                <div class="d-flex align-items-center mb-2">
                                    <%
                                    for (int i = 0; i < 5; i++) {
                                        if (i < rating) {
                                    %>
                                            <i class="fas fa-star text-warning" style="font-size:0.7rem;"></i>
                                    <%
                                        } else {
                                    %>
                                            <i class="far fa-star text-muted" style="font-size:0.7rem;"></i>
                                    <%
                                        }
                                    }
                                    %>
                                    <small class="text-muted ms-1" style="font-size:0.7rem;">(<%= reviewCount %>)</small>
                                </div>
                                <div class="d-flex align-items-center flex-wrap gap-1">
                                    <span class="fw-bold" style="font-size:1rem; color:#0d6efd;"><%=String.format("%,.0f", price).replace(",", ".")%> VND</span>
                                    <%
                                    if (oldPrice > 0) {
                                    %>
                                        <del class="text-muted" style="font-size:0.8rem;"><%=String.format("%,.0f", oldPrice).replace(",", ".")%></del>
                                    <%
                                    }
                                    %>
                                </div>
                                <div class="mt-2" style="font-size:0.75rem;">
                                    <%
                                    if (p.getQuantity() > 0 && p.isStatus()) {
                                        String stockClass = p.getQuantity() <= 5 ? "text-danger fw-semibold" : "text-success";
                                    %>
                                        <i class="fa fa-cubes me-1 <%= stockClass %>"></i>
                                        <span class="<%= stockClass %>">
                                            <%= p.getQuantity() %> in stock
                                            <% if (p.getQuantity() <= 5) { %>
                                                <span class="badge bg-danger ms-1" style="font-size:0.65rem;">Low</span>
                                            <% } %>
                                        </span>
                                    <%
                                    } else {
                                    %>
                                        <i class="fa fa-times-circle me-1 text-muted"></i>
                                        <span class="text-muted">Out of stock</span>
                                    <%
                                    }
                                    %>
                                </div>
                            </div>
                        </div>
                    </div>
                <%
                } // end for
                %>
            </div>
        <%
        } // end else
        %>
    </div>
</section>

<%@include file="../common/customerFooter.jsp" %>
