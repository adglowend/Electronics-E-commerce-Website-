<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="model.Order"%>
<%@page import="model.OrderDetail"%>
<%@page import="model.Product"%>
<%@page import="model.User"%>
<%@page import="model.Role"%>
<%@page import="dao.OrderDAO"%>
<%@page import="dao.ProductDAO"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.text.SimpleDateFormat"%>

<%
User admin = (User) session.getAttribute("account");
Role adminRole = (Role) session.getAttribute("role");

if (admin == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

String roleName = adminRole != null ? adminRole.getRoleName() : "";
if (!"Admin".equalsIgnoreCase(roleName) && admin.getRoleID() != 1) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

Order order = (Order) request.getAttribute("order");
OrderDAO orderDAO = new OrderDAO();
ProductDAO productDAO = new ProductDAO();
ArrayList<OrderDetail> details = null;
if (order != null) {
    details = orderDAO.getOrderDetails(order.getOrderID());
}

Locale locale = new Locale("vi", "VN");
NumberFormat nf = NumberFormat.getInstance(locale);
SimpleDateFormat sdf = new SimpleDateFormat("dd MMMM yyyy HH:mm", locale);

String statusClass = "bg-secondary-subtle text-secondary border-secondary";
if (order != null && "Completed".equalsIgnoreCase(order.getStatus())) {
    statusClass = "bg-success-subtle text-success border-success";
} else if (order != null && ("Processing".equalsIgnoreCase(order.getStatus()) || "Shipped".equalsIgnoreCase(order.getStatus()))) {
    statusClass = "bg-primary-subtle text-primary border-primary";
} else if (order != null && "Pending".equalsIgnoreCase(order.getStatus())) {
    statusClass = "bg-warning-subtle text-warning border-warning";
} else if (order != null && "Cancelled".equalsIgnoreCase(order.getStatus())) {
    statusClass = "bg-danger-subtle text-danger border-danger";
}
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Order Detail - Electro Store</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="apple-touch-icon" sizes="180x180" href="<%=request.getContextPath()%>/admin/assets/images/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="<%=request.getContextPath()%>/admin/assets/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="<%=request.getContextPath()%>/admin/assets/images/favicon-16x16.png">
    <link rel="manifest" href="<%=request.getContextPath()%>/admin/assets/site.webmanifest">
    <script type="module" src="<%=request.getContextPath()%>/admin/assets/js/main.js"></script>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/admin/assets/css/main.css">
</head>

<body>
    <div id="overlay" class="overlay"></div>

    <!-- TOPBAR -->
    <nav id="topbar" class="navbar bg-white border-bottom fixed-top topbar px-3">
        <button id="toggleBtn" class="d-none d-lg-inline-flex btn btn-light btn-icon btn-sm">
            <i class="ti ti-layout-sidebar-left-expand"></i>
        </button>
        <button id="mobileBtn" class="btn btn-light btn-icon btn-sm d-lg-none me-2">
            <i class="ti ti-layout-sidebar-left-expand"></i>
        </button>
        <div>
            <ul class="list-unstyled d-flex align-items-center mb-0 gap-1">
                <li class="ms-3 dropdown">
                    <a href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <img src="<%=request.getContextPath()%>/admin/assets/images/avatar/avatar-1.jpg" alt="" class="avatar avatar-sm rounded-circle">
                    </a>
                    <div class="dropdown-menu dropdown-menu-end p-0" style="min-width: 200px;">
                        <div>
                            <div class="d-flex gap-3 align-items-center border-dashed border-bottom px-3 py-3">
                                <img src="<%=request.getContextPath()%>/admin/assets/images/avatar/avatar-1.jpg" alt="" class="avatar avatar-md rounded-circle">
                                <div>
                                    <h4 class="mb-0 small"><%=admin.getFullName() != null ? admin.getFullName() : "Admin"%></h4>
                                    <p class="mb-0 small"><%=admin.getEmail() != null ? admin.getEmail() : ""%></p>
                                </div>
                            </div>
                            <div class="p-3 d-flex flex-column gap-1 small lh-lg">
                                <a href="<%=request.getContextPath()%>/logout" class="text-danger">
                                    <i class="ti ti-logout me-1"></i> Logout
                                </a>
                            </div>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </nav>

    <!-- SIDEBAR -->
    <aside id="sidebar" class="sidebar">
        <div class="logo-area">
            <a href="<%=request.getContextPath()%>/admin/dashboard" class="d-inline-flex">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                    <path d="M12 2L2 7L12 12L22 7L12 2Z" fill="%23657E92"/>
                    <path d="M2 17L12 22L22 17" stroke="%23302C4D" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M2 12L12 17L22 12" stroke="%23302C4D" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <span class="logo-text ms-2 fw-bold">Electro Store</span>
            </a>
        </div>
        <ul class="nav flex-column">
            <li class="px-4 py-2"><small class="nav-text">Main</small></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/dashboard"><i class="ti ti-home"></i><span class="nav-text">Dashboard</span></a></li>
            <li><a class="nav-link active" href="<%=request.getContextPath()%>/admin/orders"><i class="ti ti-shopping-cart"></i><span class="nav-text">Orders</span></a></li>
            <li class="px-4 py-2"><small class="nav-text">Management</small></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/user"><i class="ti ti-users"></i><span class="nav-text">Users</span></a></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/category"><i class="ti ti-category"></i><span class="nav-text">Categories</span></a></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/brand"><i class="ti ti-tag"></i><span class="nav-text">Brands</span></a></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/product"><i class="ti ti-box"></i><span class="nav-text">Products</span></a></li>
            <li class="px-4 pt-4 pb-2"><small class="nav-text">Account</small></li>
            <li><a class="nav-link text-danger" href="<%=request.getContextPath()%>/logout"><i class="ti ti-logout"></i><span class="nav-text">Logout</span></a></li>
        </ul>
    </aside>

    <!-- MAIN CONTENT -->
    <main id="content" class="content py-10">
        <div class="container-fluid">
            <div class="row mb-4">
                <div class="col-12">
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center">
                            <a href="<%=request.getContextPath()%>/admin/orders" class="btn btn-outline-secondary me-3">
                                <i class="ti ti-arrow-left"></i>
                            </a>
                            <div>
                                <h1 class="fs-3 mb-1">Order #<%=order != null ? order.getOrderID() : ""%></h1>
                                <p class="text-secondary mb-0">
                                    <% if (order != null && order.getOrderDate() != null) { %>
                                    Placed on <%=sdf.format(order.getOrderDate())%>
                                    <% } %>
                                </p>
                            </div>
                        </div>
                        <% if (order != null) { %>
                        <span class="badge <%=statusClass%> border fs-6"><%=order.getStatus()%></span>
                        <% } %>
                    </div>
                </div>
            </div>

            <% if (order == null) { %>
            <div class="alert alert-danger">Order not found.</div>
            <% } else { %>

            <div class="row g-3">
                <!-- Customer Info -->
                <div class="col-lg-4 col-12">
                    <div class="card">
                        <div class="card-header bg-white">
                            <h5 class="mb-0"><i class="ti ti-user me-2"></i>Customer Information</h5>
                        </div>
                        <div class="card-body">
                            <table class="table table-borderless mb-0">
                                <tr>
                                    <td class="text-secondary" style="width: 120px;">Name:</td>
                                    <td><strong><%=order.getCustomerName() != null ? order.getCustomerName() : "N/A"%></strong></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Customer ID:</td>
                                    <td>#<%=order.getUserID()%></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Email:</td>
                                    <td><%=order.getCustomerEmail() != null ? order.getCustomerEmail() : "N/A"%></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Phone:</td>
                                    <td><%=order.getCustomerPhone() != null && !order.getCustomerPhone().isEmpty() ? order.getCustomerPhone() : "N/A"%></td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div class="card mt-3">
                        <div class="card-header bg-white">
                            <h5 class="mb-0"><i class="ti ti-truck me-2"></i>Update Status</h5>
                        </div>
                        <div class="card-body">
                            <form action="<%=request.getContextPath()%>/admin/orders" method="post">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%=order.getOrderID()%>">
                                
                                <div class="mb-3">
                                    <select class="form-select" name="status">
                                        <% 
                                        String[] statuses = {"Pending", "Confirmed", "Processing", "Shipped", "Completed", "Cancelled"};
                                        for (String s : statuses) {
                                            String sel = s.equals(order.getStatus()) ? "selected" : "";
                                        %>
                                        <option value="<%=s%>" <%=sel%>><%=s%></option>
                                        <% } %>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="ti ti-check me-2"></i> Update Status
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Order Items -->
                <div class="col-lg-8 col-12">
                    <div class="card">
                        <div class="card-header bg-white">
                            <h5 class="mb-0"><i class="ti ti-shopping-cart me-2"></i>Order Items</h5>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table mb-0 align-middle">
                                    <thead class="table-light border-light">
                                        <tr>
                                            <th style="width: 80px;">Image</th>
                                            <th>Product</th>
                                            <th>Price</th>
                                            <th style="width: 100px;">Quantity</th>
                                            <th class="text-end">Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                        if (details != null && !details.isEmpty()) {
                                            double total = 0;
                                            for (OrderDetail od : details) {
                                                Product p = productDAO.getProductById(od.getProductID());
                                                String productName = p != null ? p.getProductName() : "Product #" + od.getProductID();
                                                String mainImage = p != null ? productDAO.getMainImage(p.getProductID()) : null;
                                                double subtotal = od.getPrice() * od.getQuantity();
                                                total += subtotal;
                                        %>
                                        <tr>
                                            <td>
                                                <% if (mainImage != null && !mainImage.isEmpty()) { %>
                                                <img src="<%=mainImage%>" alt="<%=productName%>" class="rounded" style="width: 60px; height: 60px; object-fit: cover;">
                                                <% } else { %>
                                                <div class="bg-light rounded d-flex align-items-center justify-content-center" style="width: 60px; height: 60px;">
                                                    <i class="ti ti-image text-secondary"></i>
                                                </div>
                                                <% } %>
                                            </td>
                                            <td>
                                                <strong><%=productName%></strong>
                                                <% if (p != null) { %>
                                                <br><small class="text-secondary">#<%=p.getProductID()%></small>
                                                <% } %>
                                            </td>
                                            <td><%=nf.format(od.getPrice())%> VND</td>
                                            <td><span class="badge bg-light text-dark border"><%=od.getQuantity()%></span></td>
                                            <td class="text-end"><strong><%=nf.format(subtotal)%></strong> VND</td>
                                        </tr>
                                        <% } %>
                                        <tr class="border-top">
                                            <td colspan="4" class="text-end"><strong>Total:</strong></td>
                                            <td class="text-end">
                                                <h4 class="mb-0 text-primary"><%=nf.format(order.getTotalAmount())%> VND</h4>
                                            </td>
                                        </tr>
                                        <% } else { %>
                                        <tr>
                                            <td colspan="5" class="text-center text-secondary py-4">No items in this order</td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <% } %>
        </div>
    </main>
</body>
</html>
