<%@page contentType="text/html;charset=UTF-8"%>
<%@page import="model.Order"%>
<%@page import="model.User"%>
<%@page import="model.Role"%>
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
String current = order != null ? order.getStatus() : "Pending";
String[] statuses = {"Pending", "Confirmed", "Processing", "Shipped", "Completed", "Cancelled"};
Locale locale = new Locale("vi", "VN");
NumberFormat nf = NumberFormat.getInstance(locale);
SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm", locale);
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Update Order - Electro Store</title>
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
                    <div class="d-flex align-items-center">
                        <a href="<%=request.getContextPath()%>/admin/orders" class="btn btn-outline-secondary me-3">
                            <i class="ti ti-arrow-left"></i>
                        </a>
                        <div>
                            <h1 class="fs-3 mb-1">Update Order Status</h1>
                            <p class="text-secondary mb-0">Order #<%=order != null ? order.getOrderID() : ""%></p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6 col-12">
                    <div class="card">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">Order Information</h5>
                        </div>
                        <div class="card-body">
                            <table class="table table-borderless mb-0">
                                <tr>
                                    <td class="text-secondary" style="width: 150px;">Order ID:</td>
                                    <td><strong>#<%=order != null ? order.getOrderID() : ""%></strong></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Customer ID:</td>
                                    <td>#<%=order != null ? order.getUserID() : ""%></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Order Date:</td>
                                    <td><%=order != null && order.getOrderDate() != null ? sdf.format(order.getOrderDate()) : "N/A"%></td>
                                </tr>
                                <tr>
                                    <td class="text-secondary">Total Amount:</td>
                                    <td><strong><%=order != null ? nf.format(order.getTotalAmount()) : 0%> VND</strong></td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div class="card mt-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">Update Status</h5>
                        </div>
                        <div class="card-body">
                            <form action="<%=request.getContextPath()%>/admin/orders" method="post">
                                <input type="hidden" name="action" value="update">
                                <input type="hidden" name="id" value="<%=order != null ? order.getOrderID() : 0%>">

                                <div class="mb-4">
                                    <label class="form-label">Order Status</label>
                                    <select class="form-select" name="status">
                                        <%
                                        for (String s : statuses) {
                                            String sel = s.equals(current) ? "selected" : "";
                                            String badgeClass = "";
                                            if ("Completed".equals(s)) badgeClass = "text-success";
                                            else if ("Processing".equals(s) || "Shipped".equals(s)) badgeClass = "text-primary";
                                            else if ("Pending".equals(s)) badgeClass = "text-warning";
                                            else if ("Cancelled".equals(s)) badgeClass = "text-danger";
                                            else badgeClass = "text-secondary";
                                        %>
                                        <option value="<%=s%>" <%=sel%>><%=s%></option>
                                        <%
                                        }
                                        %>
                                    </select>
                                </div>

                                <div class="d-flex gap-2">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="ti ti-check me-2"></i> Update Status
                                    </button>
                                    <a href="<%=request.getContextPath()%>/admin/orders" class="btn btn-outline-secondary">Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
