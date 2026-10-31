<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="model.Product"%>
<%@page import="model.User"%>
<%@page import="model.Role"%>
<%@page import="model.Category"%>
<%@page import="dao.ProductDAO"%>
<%@page import="dao.CategoryDAO"%>

<%
User account = (User) session.getAttribute("account");
Role role = (Role) session.getAttribute("role");

ArrayList<Product> list = (ArrayList<Product>) request.getAttribute("list");
Map<Integer, String> mainImages = (Map<Integer, String>) request.getAttribute("mainImages");

if (list == null || mainImages == null) {
    ProductDAO pdao = new ProductDAO();
    if (list == null) {
        list = pdao.getAllProduct();
    }
    if (mainImages == null) {
        mainImages = new HashMap<>();
        for (Product p : list) {
            mainImages.put(p.getProductID(), pdao.getMainImage(p.getProductID()));
        }
    }
}

// Sort by createdAt desc (newest first); nulls go last
list.sort((a, b) -> {
    Date ca = a.getCreatedAt();
    Date cb = b.getCreatedAt();
    if (ca == null && cb == null) return 0;
    if (ca == null) return 1;
    if (cb == null) return -1;
    return cb.compareTo(ca);
});

// ===== Pagination =====
int pageSize = 8;
int currentPage = 1;
try {
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        currentPage = Math.max(1, Integer.parseInt(pageParam));
    }
} catch (NumberFormatException ignored) {}

int totalItems = list.size();
int totalPages = (int) Math.ceil((double) totalItems / pageSize);
if (totalPages == 0) totalPages = 1;
if (currentPage > totalPages) currentPage = totalPages;

int startIndex = (currentPage - 1) * pageSize;
int endIndex = Math.min(startIndex + pageSize, totalItems);
ArrayList<Product> pagedList = new ArrayList<>(
        list.subList(startIndex, endIndex));

// Xây baseUrl giữ lại các query param khác (vd ?category=1) khi chuyển trang
String baseUrl = request.getContextPath() + request.getServletPath();
String extraParams = "";
java.util.Enumeration<String> paramNames = request.getParameterNames();
java.util.List<String> keepParams = new java.util.ArrayList<>();
while (paramNames.hasMoreElements()) {
    String p = paramNames.nextElement();
    if (!"page".equals(p)) {
        keepParams.add(p + "=" + java.net.URLEncoder.encode(
                request.getParameter(p) == null ? "" : request.getParameter(p),
                "UTF-8"));
    }
}
if (!keepParams.isEmpty()) {
    extraParams = "&" + String.join("&", keepParams);
}

ArrayList<Category> categories = new ArrayList<>();
try {
    CategoryDAO cdao = new CategoryDAO();
    categories = cdao.getAllCategory();
} catch (Exception e) {
    // fallback static categories
}

boolean isLoggedIn = (account != null);
boolean isAdmin = (role != null && "Admin".equalsIgnoreCase(role.getRoleName()))
        || (account != null && account.getRoleID() == 1);
%>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <title>Electro - Laptop &amp; Computer Store</title>
        <meta content="width=device-width, initial-scale=1.0" name="viewport">
        <meta content="Electro - Laptop, Computer, Mouse, Keyboard, Monitor Store" name="keywords">
        <meta content="Your trusted store for laptops, computers and accessories in Vietnam" name="description">

        <!-- Google Web Fonts -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">

        <!-- Icon Font Stylesheet -->
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css"/>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

        <!-- Libraries Stylesheet -->
        <link href="lib/animate/animate.min.css" rel="stylesheet">
        <link href="lib/owlcarousel/assets/owl.carousel.min.css" rel="stylesheet">

        <!-- Customized Bootstrap Stylesheet -->
        <link href="assets/css/bootstrap.min.css" rel="stylesheet">

        <!-- Template Stylesheet -->
        <link href="assets/css/style.css" rel="stylesheet">

        <!-- Homepage Custom Styles -->
        <link href="assets/css/home.css" rel="stylesheet">
    </head>

    <body>

        <!-- Spinner Start -->
        <div id="spinner" class="show bg-white position-fixed translate-middle w-100 vh-100 top-50 start-50 d-flex align-items-center justify-content-center">
            <div class="spinner-border text-primary" style="width: 3rem; height: 3rem;" role="status">
                <span class="sr-only">Loading...</span>
            </div>
        </div>
        <!-- Spinner End -->


        <!-- Topbar Start -->
        <div class="container-fluid px-5 d-none d-lg-block topbar" style="border-bottom: 1px solid #dee2e6; background: #fafbfc;">
            <div class="row gx-0 align-items-center" style="height: 45px;">
                <div class="col-lg-4 text-center text-lg-start">
                    <small class="text-muted">
                        <i class="fa fa-phone-alt me-1 text-primary"></i>Hotline:
                    </small>
                    <a href="tel:+841234567890" class="text-muted ms-1 fw-semibold">(+84) 123 456 789</a>
                </div>
                <div class="col-lg-4 text-center">
                    <small class="text-muted">
                        <i class="fa fa-bolt me-1 text-primary"></i>Electro - Laptop &amp; Computer Store
                    </small>
                </div>
                <div class="col-lg-4 text-center text-lg-end">
                    <div class="d-inline-flex align-items-center" style="height: 45px;">
                        <%
                        if (isLoggedIn) {
                        %>
                            <span class="text-muted me-3">
                                <i class="fa fa-user me-2 text-primary"></i><%= account.getFullName() %>
                                <% if (isAdmin) { %> <span class="badge bg-danger ms-1">Admin</span><% } %>
                            </span>
                            <a href="${pageContext.request.contextPath}/logout" class="text-muted me-3">
                                <i class="fas fa-sign-out-alt me-1"></i>Logout
                            </a>
                        <%
                        } else {
                        %>
                            <a href="${pageContext.request.contextPath}/login" class="text-muted me-3">
                                <i class="fa fa-sign-in-alt me-1"></i>Login
                            </a>
                        <%
                        }
                        %>
                    </div>
                </div>
            </div>
        </div>
        <!-- Topbar End -->


        <!-- Logo & Search Start -->
        <div class="container-fluid px-5 py-3 d-none d-lg-block">
            <div class="row gx-0 align-items-center text-center">
                <div class="col-md-4 text-center text-lg-start">
                    <a href="${pageContext.request.contextPath}/home" class="navbar-brand p-0">
                        <h1 class="display-5 text-primary m-0"><i class="fas fa-laptop text-secondary me-2"></i>Electro</h1>
                    </a>
                </div>
                <div class="col-md-4 text-center">
                    <form action="${pageContext.request.contextPath}/customer/search" method="get">
                        <div class="d-flex border rounded-pill overflow-hidden">
                            <input class="form-control border-0 rounded-pill px-3 py-2 w-100" type="text" name="keyword" placeholder="Search products...">
                            <button type="submit" class="btn rounded-pill px-4 btn-search-orange">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </form>
                </div>
                <div class="col-md-4 text-center text-lg-end">
                    <div class="d-inline-flex align-items-center">
                        <% if (isLoggedIn) { %>
                            <a href="${pageContext.request.contextPath}/customer/cart" class="text-muted d-flex align-items-center justify-content-center me-3">
                                <span class="rounded-circle btn-md-square border"><i class="fas fa-shopping-cart"></i></span>
                                <span class="text-dark ms-2">Cart</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/profile" class="text-muted d-flex align-items-center justify-content-center me-3">
                                <span class="rounded-circle btn-md-square border"><i class="fas fa-user"></i></span>
                                <span class="text-dark ms-2">Profile</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/customer/orders" class="text-muted d-flex align-items-center justify-content-center me-3">
                                <span class="rounded-circle btn-md-square border"><i class="fas fa-box"></i></span>
                                <span class="text-dark ms-2">My Orders</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/contact" class="text-muted d-flex align-items-center justify-content-center me-3">
                                <span class="rounded-circle btn-md-square border"><i class="fas fa-headset"></i></span>
                                <span class="text-dark ms-2">Contact</span>
                            </a>
                            <% if (isAdmin) { %>
                            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="text-muted d-flex align-items-center justify-content-center">
                                <span class="rounded-circle btn-md-square border" style="border-color:#f39c12 !important;"><i class="fas fa-cog" style="color:#f39c12;"></i></span>
                                <span class="ms-2 fw-bold" style="color:#f39c12;">Admin</span>
                            </a>
                            <% } %>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/contact" class="text-muted d-flex align-items-center justify-content-center me-3">
                                <span class="rounded-circle btn-md-square border"><i class="fas fa-headset"></i></span>
                                <span class="text-dark ms-2">Contact</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary rounded-pill px-4">
                                <i class="fa fa-sign-in-alt me-1"></i>Login
                            </a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <!-- Logo & Search End -->


        <!-- Navbar Start -->
        <div class="container-fluid nav-bar p-0">
            <div class="row gx-0 align-items-center" style="background:#fff; box-shadow: 0 2px 12px rgba(230,126,34,.15);">
                <!-- Navigation Links -->
                <div class="col-12">
                    <nav class="navbar navbar-expand-lg py-0" style="background:transparent;">
                        <a href="${pageContext.request.contextPath}/home" class="navbar-brand d-block d-lg-none ms-3">
                            <h1 class="display-6 fw-bold m-0" style="color:#e65100;"><i class="fas fa-laptop me-2"></i>Electro</h1>
                        </a>
                        <button class="navbar-toggler me-3 border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse" style="color:#e65100;">
                            <span class="fa fa-bars fa-1x"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="navbarCollapse">
                            <ul class="navbar-nav mx-auto py-0">
                                <%
                                boolean homeActive = (request.getAttribute("active") == null)
                                        || "home".equalsIgnoreCase((String) request.getAttribute("active"));
                                %>
                                <li class="nav-item">
                                    <a href="${pageContext.request.contextPath}/home" class="nav-link px-4 py-3 fw-semibold <%= homeActive ? "active" : "" %>"
                                       style="color:<%= homeActive ? "#e65100" : "#555" %>; border-bottom:3px solid <%= homeActive ? "#e65100" : "transparent" %>;">
                                        Home
                                    </a>
                                </li>
                                <%
                                Object activeAttr = request.getAttribute("active");
                                String activeKey = activeAttr == null ? "" : ((String) activeAttr).toLowerCase();
                                for (Category c : categories) {
                                    if (c == null || !c.isStatus()) continue;
                                    String cname = c.getCategoryName() == null ? "" : c.getCategoryName();
                                    boolean isActive = activeKey.equals(cname.toLowerCase());
                                %>
                                <li class="nav-item">
                                    <a href="${pageContext.request.contextPath}/customer/category?id=<%= c.getCategoryID() %>"
                                       class="nav-link px-4 py-3 fw-medium <%= isActive ? "active" : "" %>"
                                       style="color:<%= isActive ? "#e65100" : "#555" %>; border-bottom:3px solid <%= isActive ? "#e65100" : "transparent" %>;">
                                        <%= cname %>
                                    </a>
                                </li>
                                <%
                                }
                                %>
                            </ul>
                        </div>
                    </nav>
                </div>
            </div>
        </div>
        <!-- Navbar End -->


        <!-- Hero Carousel Start -->
        <div class="container-fluid carousel bg-light px-0">
            <div class="row g-0">
                <div class="col-12">
                    <div id="headerCarousel" class="carousel slide" data-bs-ride="carousel" data-bs-interval="5000">
                        <div class="carousel-indicators">
                            <button type="button" data-bs-target="#headerCarousel" data-bs-slide-to="0" class="active"></button>
                            <button type="button" data-bs-target="#headerCarousel" data-bs-slide-to="1"></button>
                            <button type="button" data-bs-target="#headerCarousel" data-bs-slide-to="2"></button>
                        </div>
                        <div class="carousel-inner">
                            <div class="carousel-item active" style="height: 460px;">
                                <div class="d-flex align-items-center justify-content-center"
                                     style="background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); height: 100%;">
                                    <div class="text-center text-white px-5">
                                        <span class="badge mb-3 px-3 py-2 fw-bold" style="background:rgba(255,255,255,.12); color:#4facfe; backdrop-filter:blur(4px); border:1px solid rgba(79,172,254,.25);">MEGA SALE 2026</span>
                                        <h1 class="display-3 fw-bold mb-3">Save Up To $400</h1>
                                        <p class="fs-4 mb-4 opacity-75">On Selected Laptops &amp; Desktop Computers</p>
                                        <a href="${pageContext.request.contextPath}/customer/category?id=1"
                                           class="btn btn-light rounded-pill px-5 py-2 fw-bold shadow-sm">
                                            Shop Now <i class="fas fa-arrow-right ms-2"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="carousel-item" style="height: 460px;">
                                <div class="d-flex align-items-center justify-content-center"
                                     style="background: linear-gradient(135deg, #212529 0%, #495057 100%); height: 100%;">
                                    <div class="text-center text-white px-5">
                                        <span class="badge bg-warning text-dark mb-3 px-3 py-2 fw-bold">NEW ARRIVALS</span>
                                        <h1 class="display-3 fw-bold mb-3">Latest 2026 Models</h1>
                                        <p class="fs-4 mb-4 opacity-75">High Quality Computer Accessories</p>
                                        <a href="${pageContext.request.contextPath}/home"
                                           class="btn btn-dark rounded-pill px-5 py-2 fw-bold shadow-sm">
                                            Explore <i class="fas fa-arrow-right ms-2"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="carousel-item" style="height: 460px;">
                                <div class="d-flex align-items-center justify-content-center"
                                     style="background: linear-gradient(135deg, #0d3b66 0%, #186355 50%, #1e5f5a 100%); height: 100%;">
                                    <div class="text-center text-white px-5">
                                        <span class="badge bg-light text-success mb-3 px-3 py-2 fw-bold">FREE SHIPPING</span>
                                        <h1 class="display-3 fw-bold mb-3">Orders Over $100</h1>
                                        <p class="fs-4 mb-4 opacity-75">Fast delivery across Vietnam</p>
                                        <a href="${pageContext.request.contextPath}/home"
                                           class="btn btn-outline-light rounded-pill px-5 py-2 fw-bold shadow-sm">
                                            Browse All <i class="fas fa-arrow-right ms-2"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <button class="carousel-control-prev" type="button" data-bs-target="#headerCarousel" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Previous</span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#headerCarousel" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">Next</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
        <!-- Hero Carousel End -->


        <!-- Services Start -->
        <div class="container-fluid py-4" style="background: #f8f9fa;">
            <div class="container">
                <div class="row g-0">
                    <div class="col-6 col-md-4 col-lg-2 border-end text-center py-3 service-item">
                        <i class="fa fa-truck fa-2x text-primary mb-2"></i>
                        <h6 class="mb-1 fw-bold">Free Shipping</h6>
                        <small class="text-muted">Orders over $100</small>
                    </div>
                    <div class="col-6 col-md-4 col-lg-2 border-end text-center py-3 service-item">
                        <i class="fa fa-undo fa-2x text-primary mb-2"></i>
                        <h6 class="mb-1 fw-bold">Free Return</h6>
                        <small class="text-muted">30 days return</small>
                    </div>
                    <div class="col-6 col-md-4 col-lg-2 border-end text-center py-3 service-item">
                        <i class="fa fa-lock fa-2x text-primary mb-2"></i>
                        <h6 class="mb-1 fw-bold">Secure Payment</h6>
                        <small class="text-muted">100% secure</small>
                    </div>
                    <div class="col-6 col-md-4 col-lg-2 border-end text-center py-3 service-item">
                        <i class="fa fa-headset fa-2x text-primary mb-2"></i>
                        <h6 class="mb-1 fw-bold">24/7 Support</h6>
                        <small class="text-muted">Dedicated support</small>
                    </div>
                    <div class="col-6 col-md-4 col-lg-2 border-end text-center py-3 service-item">
                        <i class="fa fa-gift fa-2x text-primary mb-2"></i>
                        <h6 class="mb-1 fw-bold">Gift Cards</h6>
                        <small class="text-muted">Over $50</small>
                    </div>
                    <div class="col-6 col-md-4 col-lg-2 text-center py-3 service-item">
                        <i class="fa fa-star fa-2x text-primary mb-2"></i>
                        <h6 class="mb-1 fw-bold">Top Quality</h6>
                        <small class="text-muted">Guaranteed</small>
                    </div>
                </div>
            </div>
        </div>
        <!-- Services End -->


        <!-- Products Offer Start -->
        <div class="container-fluid bg-light py-5">
            <div class="container">
                <div class="row g-4">
                    <div class="col-lg-6">
                        <a href="${pageContext.request.contextPath}/customer/category?id=1" class="d-flex align-items-center justify-content-between border bg-white rounded p-4 text-decoration-none">
                            <div>
                                <p class="text-muted mb-3">Find The Best Laptop for You!</p>
                                <h3 class="text-primary fw-bold">Gaming Laptop</h3>
                                <h1 class="display-3 text-secondary mb-0">40% <span class="text-primary fw-normal" style="font-size:1.5rem;">Off</span></h1>
                            </div>
                            <i class="fas fa-laptop fa-5x text-primary opacity-25"></i>
                        </a>
                    </div>
                    <div class="col-lg-6">
                        <a href="${pageContext.request.contextPath}/customer/category?id=3" class="d-flex align-items-center justify-content-between border bg-white rounded p-4 text-decoration-none">
                            <div>
                                <p class="text-muted mb-3">New Collection 2026</p>
                                <h3 class="text-primary fw-bold">Smart Keyboard</h3>
                                <h1 class="display-3 text-secondary mb-0">25% <span class="text-primary fw-normal" style="font-size:1.5rem;">Off</span></h1>
                            </div>
                            <i class="fas fa-keyboard fa-5x text-primary opacity-25"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <!-- Products Offer End -->


        <!-- Our Products Start -->
        <div class="container-fluid product py-5">
            <div class="container py-5">
                <div class="tab-class">
                    <div class="row g-4 mb-4">
                        <div class="col-lg-4 text-start">
                            <h1 class="fw-bold section-title d-inline-block">Our Products</h1>
                        </div>
                        <div class="col-lg-8 text-end">
                            <ul class="nav nav-pills d-inline-flex text-center mb-0 flex-wrap">
                                <li class="nav-item mb-2">
                                    <a class="d-flex mx-2 py-2 bg-light rounded-pill active" data-bs-toggle="pill" href="#tab-1">
                                        <span class="text-dark" style="width: 130px;">All Products</span>
                                    </a>
                                </li>
                                <%
                                if (categories.isEmpty()) {
                                %>
                                    <li class="nav-item mb-2">
                                        <a class="d-flex mx-2 py-2 bg-light rounded-pill" href="${pageContext.request.contextPath}/customer/category?id=1">
                                            <span class="text-dark" style="width: 130px;">Laptop</span>
                                        </a>
                                    </li>
                                    <li class="nav-item mb-2">
                                        <a class="d-flex mx-2 py-2 bg-light rounded-pill" href="${pageContext.request.contextPath}/customer/category?id=2">
                                            <span class="text-dark" style="width: 130px;">Mouse</span>
                                        </a>
                                    </li>
                                <%
                                } else {
                                    for (Category c : categories) {
                                %>
                                    <li class="nav-item mb-2">
                                        <a class="d-flex mx-2 py-2 bg-light rounded-pill" href="${pageContext.request.contextPath}/customer/category?id=<%=c.getCategoryID()%>">
                                            <span class="text-dark" style="width: 130px;"><%=c.getCategoryName()%></span>
                                        </a>
                                    </li>
                                <%
                                    }
                                }
                                %>
                            </ul>
                        </div>
                    </div>

                    <div class="tab-content">
                        <div id="tab-1" class="tab-pane fade show p-0 active">
                            <%
                            if (pagedList.isEmpty()) {
                            %>
                                <div class="alert alert-info text-center py-5">
                                    <i class="fa fa-search fa-3x mb-3 d-block text-muted"></i>
                                    <h5>No Products Found</h5>
                                    <p class="text-muted">Try searching with a different keyword.</p>
                                </div>
                            <%
                            } else {
                            %>
                                <div class="row g-4">
                                    <%
                                    int col = 0;
                                    for (Product p : pagedList) {
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

                                                <!-- Hinh anh san pham -->
                                                <div class="product-card-img" style="height:260px; overflow:hidden; background:#f1f3f5; position:relative;">
                                                    <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>" class="d-block h-100 w-100">
                                                        <%
                                                        if (img != null && !img.trim().isEmpty()) {
                                                        %>
                                                            <img src="<%=img%>" class="img-fluid w-100 h-100" style="object-fit:cover; transition:transform .4s;" alt="<%=p.getProductName()%>">
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

                                                    <!-- Badge goc trai tren -->
                                                    <span class="product-badge <%=badgeClass%>"><%= badgeText %></span>

                                                    <!-- Nut Quick View goc phai tren -->
                                                    <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>"
                                                       class="product-card-qv btn btn-light btn-sm rounded-circle shadow"
                                                       title="View Detail" style="z-index:5;">
                                                        <i class="fa fa-eye"></i>
                                                    </a>

                                                    <!-- Nut Add to Cart giua hinh -->
                                                    <div class="product-card-add" style="z-index:5;">
                                                        <%
                                                        if (inStock) {
                                                        %>
                                                            <a href="${pageContext.request.contextPath}/customer/addCart?id=<%=p.getProductID()%>"
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

                                                <!-- Thong tin san pham -->
                                                <div class="product-card-info p-3">
                                                    <p class="mb-1" style="font-size:0.75rem; color:#888; text-transform:uppercase; letter-spacing:.5px;">
                                                        <%=p.getDescription() != null ? p.getDescription() : "Electronics"%>
                                                    </p>
                                                    <h5 class="mb-2 fw-bold" style="font-size:0.95rem; line-height:1.3; color:#333;">
                                                        <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>" class="text-decoration-none text-dark">
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

                                <!-- Pagination Info + Controls -->
                                <div class="d-flex flex-nowrap justify-content-between align-items-center mt-5 gap-3">
                                    <div class="text-muted small text-nowrap">
                                        Hiển thị <strong><%= startIndex + 1 %>–<%= endIndex %></strong> / <strong><%= totalItems %></strong> sản phẩm
                                        (trang <strong><%= currentPage %></strong>/<strong><%= totalPages %></strong>)
                                    </div>
                                    <%
                                    if (totalPages > 1) {
                                        int window = 2; // số trang hiển thị mỗi bên currentPage
                                        int from = Math.max(1, currentPage - window);
                                        int to   = Math.min(totalPages, currentPage + window);
                                    %>
                                    <nav aria-label="Product pagination">
                                        <ul class="pagination mb-0">
                                            <!-- Previous -->
                                            <li class="page-item <%= currentPage == 1 ? "disabled" : "" %>">
                                                <a class="page-link"
                                                   href="<%= currentPage == 1 ? "#" : baseUrl + "?page=" + (currentPage - 1) + extraParams %>"
                                                   aria-label="Previous">
                                                    <span aria-hidden="true">&laquo;</span>
                                                </a>
                                            </li>

                                            <!-- First + ellipsis -->
                                            <%
                                            if (from > 1) {
                                            %>
                                                <li class="page-item">
                                                    <a class="page-link" href="<%= baseUrl + "?page=1" + extraParams %>">1</a>
                                                </li>
                                                <%
                                                if (from > 2) {
                                                %>
                                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                                <%
                                                }
                                            %>

                                            <%
                                            }

                                            // Page numbers
                                            for (int p = from; p <= to; p++) {
                                            %>
                                                <li class="page-item <%= p == currentPage ? "active" : "" %>">
                                                    <%
                                                    if (p == currentPage) {
                                                    %>
                                                        <span class="page-link"><%= p %></span>
                                                    <%
                                                    } else {
                                                    %>
                                                        <a class="page-link" href="<%= baseUrl + "?page=" + p + extraParams %>"><%= p %></a>
                                                    <%
                                                    }
                                                    %>
                                                </li>
                                            <%
                                            }

                                            // Last + ellipsis
                                            if (to < totalPages) {
                                                if (to < totalPages - 1) {
                                            %>
                                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                            <%
                                                }
                                            %>
                                                <li class="page-item">
                                                    <a class="page-link" href="<%= baseUrl + "?page=" + totalPages + extraParams %>"><%= totalPages %></a>
                                                </li>
                                            <%
                                            }
                                            %>

                                            <!-- Next -->
                                            <li class="page-item <%= currentPage == totalPages ? "disabled" : "" %>">
                                                <a class="page-link"
                                                   href="<%= currentPage == totalPages ? "#" : baseUrl + "?page=" + (currentPage + 1) + extraParams %>"
                                                   aria-label="Next">
                                                    <span aria-hidden="true">&raquo;</span>
                                                </a>
                                            </li>
                                        </ul>
                                    </nav>
                                    <%
                                    } // end if totalPages > 1
                                    %>
                                </div>
                            <%
                            } // end else
                            %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Our Products End -->


        <!-- Product Banner Start -->
        <div class="container-fluid py-5">
            <div class="container">
                <div class="row g-4">
                    <div class="col-lg-6">
                        <a href="${pageContext.request.contextPath}/customer/category?id=4" class="text-decoration-none">
                            <div class="rounded position-relative overflow-hidden" style="background: linear-gradient(135deg, #1a1a2e, #16213e, #0f3460); min-height:280px;">
                                <img src="img/product-banner.jpg" class="img-fluid w-100 rounded" alt="Monitor Sale"
                                     onerror="this.style.display='none'"
                                     style="min-height:280px; object-fit:cover; opacity:0.35;">
                                <div class="banner-overlay position-absolute top-0 start-0 w-100 h-100 d-flex flex-column justify-content-center rounded p-4" style="background: rgba(15,52,96,0.82);">
                                    <h3 class="display-5 text-white fw-bold">Monitor <br><span class="fw-normal">Essentials</span></h3>
                                    <p class="fs-4 text-white opacity-75">From $299.99</p>
                                    <span class="btn btn-light rounded-pill align-self-start py-2 px-4 fw-bold">Shop Now</span>
                                </div>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-6">
                        <a href="${pageContext.request.contextPath}/customer/category?id=2" class="text-decoration-none">
                            <div class="rounded position-relative overflow-hidden" style="background: linear-gradient(135deg, #2d1b00, #5c3d00, #8b6914); min-height:280px;">
                                <img src="img/product-banner-2.jpg" class="img-fluid w-100 rounded" alt="Accessories Sale"
                                     onerror="this.style.display='none'"
                                     style="min-height:280px; object-fit:cover; opacity:0.35;">
                                <div class="banner-overlay-2 position-absolute top-0 start-0 w-100 h-100 d-flex flex-column justify-content-center rounded p-4" style="background: rgba(50,30,0,0.7);">
                                    <h2 class="display-2 text-white fw-bold">SALE</h2>
                                    <h4 class="display-5 text-white mb-4">Get Up To 50% Off</h4>
                                    <span class="btn btn-outline-light rounded-pill align-self-center py-2 px-4 fw-bold">Shop Now</span>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <!-- Product Banner End -->


        <!-- Product List Start -->
        <div class="container-fluid products productList overflow-hidden" style="background: #fff;">
            <div class="container products-mini py-5">
                <div class="mx-auto text-center mb-5" style="max-width: 900px;">
                    <h1 class="mb-0 display-4 fw-bold section-title d-inline-block">New Arrivals</h1>
                </div>
                <%
                if (!list.isEmpty()) {
                    int count = 0;
                    java.util.List<Product> arrivals = new java.util.ArrayList<>();
                    for (Product p : list) {
                        if (count >= 4) break;
                        arrivals.add(p);
                        count++;
                    }
                    // Render in rows of 4
                    for (int row = 0; row < arrivals.size(); row += 4) {
                %>
                    <div class="row g-4 mb-4">
                        <%
                        for (int i = row; i < Math.min(row + 4, arrivals.size()); i++) {
                            Product p = arrivals.get(i);
                            String img = mainImages.get(p.getProductID());
                            boolean inStock = p.getQuantity() > 0 && p.isStatus();
                            double price = p.getPrice();
                            double oldPrice = price * 1.2;
                        %>
                            <div class="col-md-6 col-lg-3">
                                <div class="mini-product-item products-mini-item border rounded bg-white h-100">
                                    <div class="products-mini-img border-bottom text-center" style="height: 140px; overflow:hidden;">
                                        <%
                                        if (img != null && !img.trim().isEmpty()) {
                                        %>
                                            <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>">
                                                <img src="<%=img%>" class="img-fluid" style="height:100%; width:100%; object-fit:cover;" alt="<%=p.getProductName()%>">
                                            </a>
                                        <%
                                        } else {
                                        %>
                                            <div class="w-100 h-100 d-flex align-items-center justify-content-center bg-light">
                                                <i class="fa fa-image fa-2x text-muted"></i>
                                            </div>
                                        <%
                                        }
                                        %>
                                    </div>
                                    <div class="p-3">
                                        <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>" class="d-block small text-muted text-uppercase mb-1 text-decoration-none">
                                            <%=p.getDescription() != null ? p.getDescription() : "Electronics"%>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>" class="d-block h6 fw-bold text-dark mb-2 text-decoration-none" style="font-size:0.9rem; line-height:1.4; min-height:2.8em; overflow:hidden; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical;">
                                            <%=p.getProductName()%>
                                        </a>
                                        <div class="mb-2">
                                            <span class="text-danger fw-bold"><%=String.format("%,.0f", price).replace(",", ".")%> VND</span>
                                            <del class="text-muted ms-1" style="font-size:0.8rem;"><%=String.format("%,.0f", oldPrice).replace(",", ".")%></del>
                                        </div>
                                        <div class="mb-2" style="font-size:0.75rem;">
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
                                        <%
                                        if (inStock) {
                                        %>
                                            <a href="${pageContext.request.contextPath}/customer/addCart?id=<%=p.getProductID()%>"
                                               class="btn btn-dark btn-sm rounded-pill py-1 px-3 w-100">
                                                <i class="fas fa-shopping-cart me-1"></i>Add
                                            </a>
                                        <%
                                        } else {
                                        %>
                                            <button class="btn btn-secondary btn-sm rounded-pill py-1 px-3 w-100" disabled>
                                                <i class="fa fa-ban me-1"></i>Out
                                            </button>
                                        <%
                                        }
                                        %>
                                    </div>
                                </div>
                            </div>
                        <%
                        } // end inner for
                        %>
                    </div>
                <%
                    } // end outer for
                }
                %>
            </div>
        </div>
        <!-- Product List End -->


        <!-- Bestseller Products Start -->
        <div class="container-fluid products pb-5" style="background: #f8f9fa;">
            <div class="container products-mini py-5">
                <div class="mx-auto text-center mb-5" style="max-width: 700px;">
                    <h1 class="mb-0 display-4 fw-bold section-title d-inline-block">Bestseller Products</h1>
                    <p class="text-muted mt-3">Top-rated products chosen by thousands of customers across Vietnam.</p>
                </div>
                <%
                if (!list.isEmpty()) {
                    int startIdx = Math.min(4, list.size());
                    java.util.List<Product> bestsellers = list.subList(0, startIdx);
                    for (int row = 0; row < bestsellers.size(); row += 4) {
                %>
                    <div class="row g-4 mb-4">
                        <%
                        for (int i = row; i < Math.min(row + 4, bestsellers.size()); i++) {
                            Product p = bestsellers.get(i);
                            String img = mainImages.get(p.getProductID());
                            boolean inStock = p.getQuantity() > 0 && p.isStatus();
                            double price = p.getPrice();
                            double oldPrice = price * 1.15;
                            int rating = 4 + ((p.getProductID() * 3) % 2);
                        %>
                            <div class="col-md-6 col-lg-3">
                                <div class="mini-product-item products-mini-item border rounded bg-white h-100">
                                    <div class="products-mini-img border-bottom text-center" style="height: 140px; overflow:hidden;">
                                        <%
                                        if (img != null && !img.trim().isEmpty()) {
                                        %>
                                            <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>">
                                                <img src="<%=img%>" class="img-fluid" style="height:100%; width:100%; object-fit:cover;" alt="<%=p.getProductName()%>">
                                            </a>
                                        <%
                                        } else {
                                        %>
                                            <div class="w-100 h-100 d-flex align-items-center justify-content-center bg-light">
                                                <i class="fa fa-image fa-2x text-muted"></i>
                                            </div>
                                        <%
                                        }
                                        %>
                                    </div>
                                    <div class="p-3">
                                        <div class="mb-2">
                                            <%
                                            for (int s = 0; s < 5; s++) {
                                                if (s < rating) {
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
                                        </div>
                                        <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>" class="d-block small text-muted text-uppercase mb-1 text-decoration-none">
                                            <%=p.getDescription() != null ? p.getDescription() : "Electronics"%>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/customer/detail?id=<%=p.getProductID()%>" class="d-block fw-bold text-dark mb-2 text-decoration-none" style="font-size:0.9rem; line-height:1.4; min-height:2.8em; overflow:hidden; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical;">
                                            <%=p.getProductName()%>
                                        </a>
                                        <div class="mb-2">
                                            <span class="text-danger fw-bold"><%=String.format("%,.0f", price).replace(",", ".")%> VND</span>
                                            <del class="text-muted ms-1" style="font-size:0.8rem;"><%=String.format("%,.0f", oldPrice).replace(",", ".")%></del>
                                        </div>
                                        <div class="mb-2" style="font-size:0.75rem;">
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
                                        <%
                                        if (inStock) {
                                        %>
                                            <a href="${pageContext.request.contextPath}/customer/addCart?id=<%=p.getProductID()%>"
                                               class="btn btn-dark btn-sm rounded-pill py-1 px-3 w-100">
                                                <i class="fas fa-shopping-cart me-1"></i>Add
                                            </a>
                                        <%
                                        } else {
                                        %>
                                            <button class="btn btn-secondary btn-sm rounded-pill py-1 px-3 w-100" disabled>
                                                <i class="fa fa-ban me-1"></i>Out
                                            </button>
                                        <%
                                        }
                                        %>
                                    </div>
                                </div>
                            </div>
                        <%
                        } // end inner for
                        %>
                    </div>
                <%
                    } // end outer for
                }
                %>
            </div>
        </div>
        <!-- Bestseller Products End -->


        <!-- Shop By Category Start -->
        <div class="container-fluid py-5" style="background: #f8f9fa;">
            <div class="container">
                <div class="mx-auto text-center mb-5">
                    <h1 class="fw-bold section-title d-inline-block">Shop By Category</h1>
                </div>
                <div class="row g-4 text-center">
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/customer/category?id=1" class="category-icon-item d-block text-decoration-none">
                            <div class="bg-white rounded shadow-sm py-4 px-3">
                                <i class="fas fa-laptop fa-3x text-primary mb-3"></i>
                                <h5 class="text-dark mb-1">Laptop</h5>
                                <small class="text-muted">Laptops &amp; Notebooks</small>
                            </div>
                        </a>
                    </div>
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/customer/category?id=2" class="category-icon-item d-block text-decoration-none">
                            <div class="bg-white rounded shadow-sm py-4 px-3">
                                <i class="fas fa-mouse fa-3x text-primary mb-3"></i>
                                <h5 class="text-dark mb-1">Mouse</h5>
                                <small class="text-muted">Wireless &amp; Gaming</small>
                            </div>
                        </a>
                    </div>
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/customer/category?id=3" class="category-icon-item d-block text-decoration-none">
                            <div class="bg-white rounded shadow-sm py-4 px-3">
                                <i class="fas fa-keyboard fa-3x text-primary mb-3"></i>
                                <h5 class="text-dark mb-1">Keyboard</h5>
                                <small class="text-muted">Mechanical &amp; Smart</small>
                            </div>
                        </a>
                    </div>
                    <div class="col-6 col-md-3">
                        <a href="${pageContext.request.contextPath}/customer/category?id=4" class="category-icon-item d-block text-decoration-none">
                            <div class="bg-white rounded shadow-sm py-4 px-3">
                                <i class="fas fa-desktop fa-3x text-primary mb-3"></i>
                                <h5 class="text-dark mb-1">Monitor</h5>
                                <small class="text-muted">Displays &amp; Screens</small>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <!-- Shop By Category End -->


        <!-- Features Banner Start -->
        <div class="container-fluid py-5" style="background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);">
            <div class="container">
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="d-flex align-items-center justify-content-between bg-white rounded p-4 h-100 shadow-sm" style="border-left: 5px solid #ffc107;">
                            <div>
                                <span class="badge bg-warning text-dark mb-2">HOT DEAL</span>
                                <p class="text-muted mb-1 small">Find The Best Laptop</p>
                                <h3 class="text-primary fw-bold mb-1">Gaming Laptop</h3>
                                <h1 class="display-4 text-secondary mb-0">40% <span class="text-primary fw-normal" style="font-size:1.5rem;">Off</span></h1>
                            </div>
                            <i class="fas fa-laptop fa-5x text-primary opacity-25"></i>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="d-flex align-items-center justify-content-between bg-white rounded p-4 h-100 shadow-sm" style="border-left: 5px solid #0d6efd;">
                            <div>
                                <span class="badge mb-2" style="background:rgba(13,110,253,.15); color:#0d6efd;">NEW</span>
                                <p class="text-muted mb-1 small">New Collection 2026</p>
                                <h3 class="text-primary fw-bold mb-1">Smart Keyboard</h3>
                                <h1 class="display-4 text-secondary mb-0">25% <span class="text-primary fw-normal" style="font-size:1.5rem;">Off</span></h1>
                            </div>
                            <i class="fas fa-keyboard fa-5x text-primary opacity-25"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Features Banner End -->


        <!-- Testimonial Start -->
        <div class="container-fluid py-5">
            <div class="container py-5">
                <div class="mx-auto text-center mb-5" style="max-width: 600px;">
                    <h1 class="fw-bold section-title d-inline-block">Testimonials</h1>
                </div>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="testimonial-item bg-white border rounded p-4 h-100 shadow-sm">
                            <div class="d-flex align-items-center mb-3">
                                <img src="img/avatar.jpg" class="rounded-circle me-3" style="width:50px;height:50px;object-fit:cover;" alt="Customer"
                                     onerror="this.style.display='none'">
                                <div class="rounded-circle d-flex align-items-center justify-content-center me-3" style="width:50px;height:50px; background:#0d6efd;">
                                    <i class="fas fa-user text-white"></i>
                                </div>
                                <div>
                                    <h5 class="mb-0 fw-bold">Nguyen Van A</h5>
                                    <small class="text-muted">Ho Chi Minh City</small>
                                </div>
                            </div>
                            <div class="mb-3">
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                            </div>
                            <p class="text-muted mb-0">
                                <i class="fas fa-quote-left text-primary me-2"></i>
                                Great product quality and fast delivery. I bought a gaming laptop and it works perfectly. Highly recommended!
                                <i class="fas fa-quote-right text-primary ms-2"></i>
                            </p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="testimonial-item bg-white border rounded p-4 h-100 shadow-sm">
                            <div class="d-flex align-items-center mb-3">
                                <div class="bg-success rounded-circle d-flex align-items-center justify-content-center me-3" style="width:50px;height:50px;">
                                    <i class="fas fa-user text-white"></i>
                                </div>
                                <div>
                                    <h5 class="mb-0 fw-bold">Tran Thi B</h5>
                                    <small class="text-muted">Hanoi</small>
                                </div>
                            </div>
                            <div class="mb-3">
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                            </div>
                            <p class="text-muted mb-0">
                                <i class="fas fa-quote-left text-primary me-2"></i>
                                Excellent customer service and competitive prices. The mechanical keyboard I ordered arrived in perfect condition.
                                <i class="fas fa-quote-right text-primary ms-2"></i>
                            </p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="testimonial-item bg-white border rounded p-4 h-100 shadow-sm">
                            <div class="d-flex align-items-center mb-3">
                                <div class="bg-info rounded-circle d-flex align-items-center justify-content-center me-3" style="width:50px;height:50px;">
                                    <i class="fas fa-user text-white"></i>
                                </div>
                                <div>
                                    <h5 class="mb-0 fw-bold">Le Van C</h5>
                                    <small class="text-muted">Da Nang</small>
                                </div>
                            </div>
                            <div class="mb-3">
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="fas fa-star text-warning"></i>
                                <i class="far fa-star text-warning"></i>
                            </div>
                            <p class="text-muted mb-0">
                                <i class="fas fa-quote-left text-primary me-2"></i>
                                Wide selection of computer accessories. The 24-month warranty gives me peace of mind. Will buy again!
                                <i class="fas fa-quote-right text-primary ms-2"></i>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Testimonial End -->


        <!-- Footer Start -->
        <div class="container-fluid footer py-5" style="background: #212529;">
            <div class="container py-4">
                <div class="row g-4">
                    <div class="col-md-6 col-lg-3">
                        <div>
                            <h3 class="text-primary mb-3"><i class="fas fa-laptop me-2"></i>Electro</h3>
                            <p class="text-muted small mb-3">
                                Your trusted store for laptops, computers, and accessories.
                                High quality products with competitive prices.
                            </p>
                            <div class="d-flex gap-2">
                                <a href="#" class="btn btn-outline-primary btn-sm rounded-circle">
                                    <i class="fab fa-facebook-f"></i>
                                </a>
                                <a href="#" class="btn btn-outline-primary btn-sm rounded-circle">
                                    <i class="fab fa-twitter"></i>
                                </a>
                                <a href="#" class="btn btn-outline-primary btn-sm rounded-circle">
                                    <i class="fab fa-instagram"></i>
                                </a>
                                <a href="#" class="btn btn-outline-primary btn-sm rounded-circle">
                                    <i class="fab fa-youtube"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <h4 class="text-white mb-3">Contact Us</h4>
                        <p class="text-muted small mb-2">
                            <i class="fa fa-map-marker-alt me-2 text-primary"></i>123 Le Loi, District 1, HCM City
                        </p>
                        <p class="text-muted small mb-2">
                            <i class="fa fa-envelope me-2 text-primary"></i>support@electro.vn
                        </p>
                        <p class="text-muted small mb-0">
                            <i class="fa fa-phone me-2 text-primary"></i>(+84) 123 456 789
                        </p>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <h4 class="text-white mb-3">Quick Links</h4>
                        <a href="${pageContext.request.contextPath}/home" class="d-block text-muted small mb-2 text-decoration-none">
                            <i class="fa fa-angle-right me-2 text-primary"></i>Home
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/category?id=1" class="d-block text-muted small mb-2 text-decoration-none">
                            <i class="fa fa-angle-right me-2 text-primary"></i>Laptop
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/category?id=3" class="d-block text-muted small mb-2 text-decoration-none">
                            <i class="fa fa-angle-right me-2 text-primary"></i>Keyboard
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/orders" class="d-block text-muted small mb-2 text-decoration-none">
                            <i class="fa fa-angle-right me-2 text-primary"></i>My Orders
                        </a>
                        <%
                        if (isAdmin) {
                        %>
                            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="d-block text-warning small mb-2 text-decoration-none">
                                <i class="fa fa-cog me-2"></i>Admin Panel
                            </a>
                        <%
                        }
                        %>
                    </div>
                    <div class="col-md-6 col-lg-3">
                        <h4 class="text-white mb-3">Newsletter</h4>
                        <p class="text-muted small mb-3">Get the latest deals and updates.</p>
                        <form action="#" method="post" class="d-flex mb-3">
                            <input type="email" class="form-control rounded-start-pill border-end-0" placeholder="Your email" required>
                            <button class="btn btn-primary rounded-end-pill px-3" type="submit">
                                <i class="fa fa-paper-plane"></i>
                            </button>
                        </form>
                        <small class="text-muted d-block">
                            <i class="fa fa-shield-alt me-1 text-success"></i>We respect your privacy.
                        </small>
                    </div>
                </div>
            </div>
        </div>
        <!-- Footer End -->


        <!-- Copyright Start -->
        <div class="container-fluid copyright py-3" style="background: #1a1a1a;">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-6 text-center text-md-start">
                        <span class="text-white small">
                            &copy; 2026 <a href="#" class="text-primary">Electro</a>. All rights reserved.
                        </span>
                    </div>
                    <div class="col-md-6 text-center text-md-end">
                        <span class="text-muted small">Designed for ComputerStore Project</span>
                    </div>
                </div>
            </div>
        </div>
        <!-- Copyright End -->


        <!-- Back to Top -->
        <a href="#" class="btn btn-primary btn-lg-square back-to-top">
            <i class="fa fa-arrow-up"></i>
        </a>


        <!-- JavaScript -->
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="lib/easing/easing.min.js"></script>
        <script src="lib/waypoints/waypoints.min.js"></script>
        <script src="lib/owlcarousel/owl.carousel.min.js"></script>
        <script src="lib/counterup/counterup.min.js"></script>
        <script src="js/main.js"></script>

        <script>
            // Quick view hover effect for product cards
            document.querySelectorAll('.product-item').forEach(function(item) {
                item.addEventListener('mouseenter', function() {
                    var details = this.querySelector('.product-details');
                    if (details) {
                        details.style.opacity = '1';
                        details.style.right = '10px';
                    }
                });
                item.addEventListener('mouseleave', function() {
                    var details = this.querySelector('.product-details');
                    if (details) {
                        details.style.opacity = '0';
                        details.style.right = '-40px';
                    }
                });
            });

            // Initialize WOW.js if available
            if (typeof WOW !== 'undefined') {
                new WOW().init();
            }
        </script>

    </body>
</html>
