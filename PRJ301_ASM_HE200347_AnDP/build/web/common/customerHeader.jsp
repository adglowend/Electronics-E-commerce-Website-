<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@page import="model.User"%>
<%@page import="model.Role"%>
<%
    User account = (User) session.getAttribute("account");
    Role role = (Role) session.getAttribute("role");
    boolean isLoggedIn = (account != null);
    boolean isAdmin = (role != null && "Admin".equalsIgnoreCase(role.getRoleName()))
            || (account != null && account.getRoleID() == 1);

    // "active" param: home | cart | checkout | profile | orders | (anything else)
    String active = (String) request.getAttribute("active");
    if (active == null) active = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Electro" %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/header.css">
</head>
<body>

<!-- Topbar -->
<div class="container-fluid px-5 d-none d-lg-block topbar">
    <div class="row align-items-center topbar-row">
        <div class="col-lg-4 small text-muted">
            <i class="fa fa-phone-alt me-1 text-primary"></i>Hotline:
            <a href="tel:+841234567890" class="text-muted text-decoration-none ms-1 fw-semibold">(+84) 123 456 789</a>
        </div>
        <div class="col-lg-4 text-center small text-muted">
            <i class="fa fa-bolt me-1 text-primary"></i>Electro - Laptop &amp; Computer Store
        </div>
        <div class="col-lg-4 text-end small text-muted">
            <% if (isLoggedIn) { %>
                <span class="me-3">
                    <i class="fa fa-user me-1 text-primary"></i><%= account.getFullName() %>
                    <% if (isAdmin) { %><span class="badge bg-danger ms-1">Admin</span><% } %>
                </span>
                <a href="<%=request.getContextPath()%>/logout" class="text-muted text-decoration-none me-3">
                    <i class="fas fa-sign-out-alt me-1"></i>Logout
                </a>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/login" class="text-muted text-decoration-none me-3">
                    <i class="fa fa-sign-in-alt me-1"></i>Login
                </a>
            <% } %>
        </div>
    </div>
</div>

<!-- Brand bar -->
<div class="container-fluid px-3 px-lg-5 brand-bar">
    <div class="row gx-0 align-items-center">
        <div class="col-lg-3 col-md-3 col-12 text-center text-lg-start mb-3 mb-lg-0">
            <a href="<%=request.getContextPath()%>/home" class="text-decoration-none">
                <h2 class="brand-logo">
                    <i class="fas fa-shopping-bag"></i> Electro
                </h2>
            </a>
        </div>
        <div class="col-lg-6 col-md-6 col-12 mb-3 mb-lg-0">
            <form action="<%=request.getContextPath()%>/customer/search" method="get" class="d-flex">
                <input type="text" name="keyword" class="form-control rounded-pill"
                       placeholder="Search products...">
                <button class="btn btn-primary rounded-pill ms-2" type="submit">
                    <i class="fas fa-search"></i>
                </button>
            </form>
        </div>
        <div class="col-lg-3 col-md-3 col-12 text-center text-lg-end">
            <div class="brand-actions">
            <% if (isLoggedIn) { %>
                <a href="<%=request.getContextPath()%>/customer/cart" class="text-dark text-decoration-none">
                    <i class="fas fa-shopping-cart fa-lg"></i>
                    <span>Cart</span>
                </a>
                <a href="<%=request.getContextPath()%>/customer/profile" class="text-dark text-decoration-none">
                    <i class="fas fa-user fa-lg"></i>
                    <span>Profile</span>
                </a>
                <a href="<%=request.getContextPath()%>/customer/orders" class="text-dark text-decoration-none">
                    <i class="fas fa-box fa-lg"></i>
                    <span>My Orders</span>
                </a>
                <a href="<%=request.getContextPath()%>/contact" class="text-dark text-decoration-none">
                    <i class="fas fa-headset fa-lg"></i>
                    <span>Contact</span>
                </a>
                <% if (isAdmin) { %>
                <a href="<%=request.getContextPath()%>/admin/dashboard.jsp" class="text-decoration-none">
                    <i class="fas fa-cog fa-lg" style="color:#f39c12;"></i>
                    <span class="fw-bold" style="color:#f39c12;">Admin</span>
                </a>
                <% } %>
            <% } else { %>
                <a href="<%=request.getContextPath()%>/contact" class="text-dark text-decoration-none">
                    <i class="fas fa-headset fa-lg"></i>
                    <span>Contact</span>
                </a>
                <a href="<%=request.getContextPath()%>/login" class="btn btn-primary rounded-pill px-4">
                    <i class="fa fa-sign-in-alt me-1"></i>Login
                </a>
            <% } %>
            </div>
        </div>
    </div>
</div>

<!-- Navbar -->
<%
java.util.ArrayList<model.Category> navCategories = new java.util.ArrayList<>();
try {
    dao.CategoryDAO cdao = new dao.CategoryDAO();
    navCategories = cdao.getAllCategory();
} catch (Exception ex) {
    // ignore — fallback to empty list
}
Object navActiveAttr = request.getAttribute("active");
String navActive = navActiveAttr == null ? "" : ((String) navActiveAttr).toLowerCase();
boolean homeActive = navActive.isEmpty() || "home".equalsIgnoreCase(navActive);
%>
<div class="container-fluid nav-bar p-0">
    <div class="row gx-0 align-items-center nav-bar-shell">
        <div class="col-12">
            <nav class="navbar navbar-expand-lg py-0 ecom-navbar">
                <a href="${pageContext.request.contextPath}/home" class="navbar-brand d-block d-lg-none ms-3">
                    <h1 class="display-6 fw-bold m-0 brand-logo-mobile"><i class="fas fa-laptop me-2"></i>Electro</h1>
                </a>
                <button class="navbar-toggler me-3 border-0 ecom-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse">
                    <span class="fa fa-bars fa-1x"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarCollapse">
                    <ul class="navbar-nav mx-auto py-0">
                        <li class="nav-item">
                            <a href="${pageContext.request.contextPath}/home" class="nav-link px-4 py-3 fw-semibold <%= homeActive ? "active" : "" %>">
                                Home
                            </a>
                        </li>
                        <%
                        for (model.Category c : navCategories) {
                            if (c == null || !c.isStatus()) continue;
                            String cname = c.getCategoryName() == null ? "" : c.getCategoryName();
                            boolean isActive = navActive.equals(cname.toLowerCase());
                        %>
                        <li class="nav-item">
                            <a href="${pageContext.request.contextPath}/customer/category?id=<%= c.getCategoryID() %>"
                               class="nav-link px-4 py-3 fw-medium <%= isActive ? "active" : "" %>">
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

<div class="page-wrap">
