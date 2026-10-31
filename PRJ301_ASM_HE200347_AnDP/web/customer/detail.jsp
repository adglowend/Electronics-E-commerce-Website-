<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.Product"%>
<%@page import="model.ProductImage"%>
<%@page import="model.Brand"%>
<%@page import="dao.BrandDAO"%>
<%
    request.setAttribute("pageTitle", "Product Detail - Electro");
    request.setAttribute("active", "shop");
    Product p = (Product) request.getAttribute("product");
    String mainImage = (String) request.getAttribute("mainImage");
    ArrayList<ProductImage> images = (ArrayList<ProductImage>) request.getAttribute("images");
    String ctx = request.getContextPath();
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
    String brandName = null;
    String brandCountry = null;
    if (p != null) {
        try {
            BrandDAO bdao = new BrandDAO();
            Brand brand = bdao.getBrandById(p.getBrandID());
            if (brand != null) {
                brandName = brand.getBrandName();
                brandCountry = brand.getCountry();
            }
        } catch (Exception e) {
            // brand lookup is optional
        }
    }
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/detail.css">

<section class="container py-5">
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<%=ctx%>/home">Home</a></li>
            <li class="breadcrumb-item active">Product Detail</li>
        </ol>
    </nav>

    <div class="detail-card">
        <div class="row">
            <div class="col-md-6">
                <%
                if (mainImage != null && !mainImage.isEmpty()) {
                %>
                    <img src="<%=mainImage%>" class="img-fluid rounded mb-3" id="mainImg">
                <%
                } else {
                %>
                    <div class="no-image-box">No Image</div>
                <% } %>

                <% if (images != null) {
                    for (ProductImage img : images) {
                        if (!img.isIsMain()) {
                %>
                            <img src="<%=img.getImageURL()%>" class="thumb me-2 mb-2"
                                 onclick="document.getElementById('mainImg').src='<%=img.getImageURL()%>'">
                <%
                        }
                    }
                } %>
            </div>
            <div class="col-md-6">
                <h2 class="mb-3"><%=p.getProductName()%></h2>
                <%
                if (brandName != null) {
                %>
                    <p class="mb-2">
                        <span class="badge bg-light text-dark border me-1">
                            <i class="fa fa-tag me-1 text-primary"></i>Brand
                        </span>
                        <strong><%=brandName%></strong>
                        <% if (brandCountry != null && !brandCountry.isEmpty()) { %>
                            <small class="text-muted">(<%=brandCountry%>)</small>
                        <% } %>
                    </p>
                <%
                }
                %>
                <p class="price"><%= nf.format(p.getPrice()) %> VND</p>
                <hr>
                <p><strong>Quantity in stock:</strong> <%=p.getQuantity()%></p>
                <p><strong>Description:</strong> <%=p.getDescription()%></p>
                <p>
                    <strong>Status:</strong>
                    <% if (p.isStatus() && p.getQuantity() > 0) { %>
                        <span class="badge bg-success">In Stock</span>
                    <% } else { %>
                        <span class="badge bg-secondary">Out of Stock</span>
                    <% } %>
                </p>
                <div class="mt-4">
                    <a href="<%=ctx%>/customer/addCart?id=<%=p.getProductID()%>"
                       class="btn btn-primary rounded-pill px-4">
                        <i class="fa fa-cart-plus me-1"></i>Add To Cart
                    </a>
                    <a href="<%=ctx%>/home" class="btn btn-outline-secondary rounded-pill px-4">
                        <i class="fa fa-arrow-left me-1"></i>Back
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<%@include file="../common/customerFooter.jsp" %>
