<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Role"%>
<%@page import="model.User"%>
<%@page import="model.Order"%>
<%@page import="model.OrderDetail"%>
<%@page import="dao.UserDAO"%>
<%@page import="dao.OrderDAO"%>
<%@page import="dao.ProductDAO"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Calendar"%>

<%
User user = (User) session.getAttribute("account");
Role role = (Role) session.getAttribute("role");

if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

String roleName = role != null ? role.getRoleName() : "";
if (!"Admin".equalsIgnoreCase(roleName) && user.getRoleID() != 1) {
    response.sendRedirect(request.getContextPath() + "/login");
    return;
}

Locale locale = new Locale("vi", "VN");
NumberFormat nf = NumberFormat.getInstance(locale);
SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy", locale);

// Get real stats from DB
UserDAO userDAO = new UserDAO();
OrderDAO orderDAO = new OrderDAO();
ProductDAO productDAO = new ProductDAO();

int totalUsers = userDAO.getCountAllUsers();
int totalOrders = orderDAO.getCountAllOrders();
int totalProducts = productDAO.getCountAllProducts();
double totalRevenue = orderDAO.getTotalRevenue();
int pendingOrders = orderDAO.getCountOrdersByStatus("Pending");

// Get order stats by status for pie chart
int completedOrders = orderDAO.getCountByStatus("Completed");
int processingOrders = orderDAO.getCountByStatus("Processing");
int cancelledOrders = orderDAO.getCountByStatus("Cancelled");

// Get monthly revenue for current year
int currentYear = Calendar.getInstance().get(Calendar.YEAR);
double[] monthlyRevenue = orderDAO.getMonthlyRevenue(currentYear);

// ===== Reports & Statistics =====
// Top 5 sản phẩm bán chạy
String[][] topProducts = orderDAO.getTopSellingProducts(5);
// Inventory report (top 10 sản phẩm tồn kho nhiều nhất)
String[][] inventoryReport = productDAO.getInventoryReport(10);
// Top 5 VIP Customers theo tổng chi tiêu
String[][] vipCustomers = orderDAO.getTopVipCustomers(5);

// Build JSON arrays for ApexCharts
StringBuilder topProductNames = new StringBuilder("[");
StringBuilder topProductValues = new StringBuilder("[");
for (int i = 0; i < topProducts.length; i++) {
    String n = topProducts[i][0] != null ? topProducts[i][0].replace("\"", "\\\"") : "";
    topProductNames.append("\"").append(n).append("\"");
    topProductValues.append(topProducts[i][1]);
    if (i < topProducts.length - 1) {
        topProductNames.append(",");
        topProductValues.append(",");
    }
}
topProductNames.append("]");
topProductValues.append("]");

StringBuilder inventoryNames = new StringBuilder("[");
StringBuilder inventoryValues = new StringBuilder("[");
for (int i = 0; i < inventoryReport.length; i++) {
    String n = inventoryReport[i][0] != null ? inventoryReport[i][0].replace("\"", "\\\"") : "";
    inventoryNames.append("\"").append(n).append("\"");
    inventoryValues.append(inventoryReport[i][1]);
    if (i < inventoryReport.length - 1) {
        inventoryNames.append(",");
        inventoryValues.append(",");
    }
}
inventoryNames.append("]");
inventoryValues.append("]");

StringBuilder vipNames = new StringBuilder("[");
StringBuilder vipValues = new StringBuilder("[");
for (int i = 0; i < vipCustomers.length; i++) {
    String n = vipCustomers[i][0] != null ? vipCustomers[i][0].replace("\"", "\\\"") : "";
    vipNames.append("\"").append(n).append("\"");
    vipValues.append(Math.round(Double.parseDouble(vipCustomers[i][1])));
    if (i < vipCustomers.length - 1) {
        vipNames.append(",");
        vipValues.append(",");
    }
}
vipNames.append("]");
vipValues.append("]");

// Get recent orders
ArrayList<Order> recentOrders = orderDAO.getAllOrder();
int orderCount = recentOrders.size();
if (orderCount > 5) {
    recentOrders = new ArrayList<>(recentOrders.subList(0, 5));
}

// Format monthly data for JS
StringBuilder monthlyData = new StringBuilder("[");
for (int i = 0; i < 12; i++) {
    monthlyData.append(Math.round(monthlyRevenue[i]));
    if (i < 11) monthlyData.append(",");
}
monthlyData.append("]");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - Electro Store</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="apple-touch-icon" sizes="180x180" href="<%=request.getContextPath()%>/admin/assets/images/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="<%=request.getContextPath()%>/admin/assets/images/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="<%=request.getContextPath()%>/admin/assets/images/favicon-16x16.png">
    <link rel="manifest" href="<%=request.getContextPath()%>/admin/assets/site.webmanifest">
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
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
                <li>
                    <a class="position-relative btn-icon btn-sm btn-light btn rounded-circle" data-bs-toggle="dropdown"
                        aria-expanded="false" href="#" role="button">
                        <i class="ti ti-bell"></i>
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger mt-2 ms-n2"><%=pendingOrders%></span>
                    </a>
                    <div class="dropdown-menu dropdown-menu-end dropdown-menu-md p-0">
                        <ul class="list-unstyled p-0 m-0">
                            <li class="p-3 border-bottom">
                                <div class="d-flex gap-3">
                                    <img src="<%=request.getContextPath()%>/admin/assets/images/avatar/avatar-1.jpg" alt="" class="avatar avatar-sm rounded-circle">
                                    <div class="flex-grow-1 small">
                                        <p class="mb-0">Pending orders</p>
                                        <p class="mb-1"><%=pendingOrders%> orders waiting for processing</p>
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </div>
                </li>
                <li class="ms-3 dropdown">
                    <a href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <img src="<%=request.getContextPath()%>/admin/assets/images/avatar/avatar-1.jpg" alt="" class="avatar avatar-sm rounded-circle">
                    </a>
                    <div class="dropdown-menu dropdown-menu-end p-0" style="min-width: 200px;">
                        <div>
                            <div class="d-flex gap-3 align-items-center border-dashed border-bottom px-3 py-3">
                                <img src="<%=request.getContextPath()%>/admin/assets/images/avatar/avatar-1.jpg" alt="" class="avatar avatar-md rounded-circle">
                                <div>
                                    <h4 class="mb-0 small"><%=user.getFullName() != null ? user.getFullName() : "Admin"%></h4>
                                    <p class="mb-0 small"><%=user.getEmail() != null ? user.getEmail() : ""%></p>
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
            <li><a class="nav-link active" href="<%=request.getContextPath()%>/admin/dashboard"><i class="ti ti-home"></i><span class="nav-text">Dashboard</span></a></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/orders"><i class="ti ti-shopping-cart"></i><span class="nav-text">Orders</span></a></li>
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
            <div class="row">
                <div class="col-12">
                    <div class="mb-6">
                        <h1 class="fs-3 mb-1">Dashboard</h1>
                        <p class="text-secondary">Welcome back, <strong><%=user.getFullName() != null ? user.getFullName() : "Admin"%></strong>!</p>
                    </div>
                </div>
            </div>

            <!-- Stat Cards -->
            <div class="row g-3 mb-3">
                <div class="col-lg-3 col-12">
                    <div class="card p-4 bg-primary bg-opacity-10 border border-primary border-opacity-25 rounded-2">
                        <div class="d-flex gap-3">
                            <div class="icon-shape icon-md bg-primary text-white rounded-2">
                                <i class="ti ti-users fs-4"></i>
                            </div>
                            <div>
                                <h2 class="mb-3 fs-6">Total Users</h2>
                                <h3 class="fw-bold mb-0"><%=nf.format(totalUsers)%></h3>
                                <p class="text-primary mb-0 small"><%=userDAO.getCountActiveUsers()%> active</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-12">
                    <div class="card p-4 bg-success bg-opacity-10 border border-success border-opacity-25 rounded-2">
                        <div class="d-flex gap-3">
                            <div class="icon-shape icon-md bg-success text-white rounded-2">
                                <i class="ti ti-shopping-cart fs-4"></i>
                            </div>
                            <div>
                                <h2 class="mb-3 fs-6">Total Orders</h2>
                                <h3 class="fw-bold mb-0"><%=nf.format(totalOrders)%></h3>
                                <p class="text-success mb-0 small"><%=pendingOrders%> pending</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-12">
                    <div class="card p-4 bg-info bg-opacity-10 border border-info border-opacity-25 rounded-2">
                        <div class="d-flex gap-3">
                            <div class="icon-shape icon-md bg-info text-white rounded-2">
                                <i class="ti ti-box fs-4"></i>
                            </div>
                            <div>
                                <h2 class="mb-3 fs-6">Products</h2>
                                <h3 class="fw-bold mb-0"><%=nf.format(totalProducts)%></h3>
                                <p class="text-info mb-0 small"><%=productDAO.getCountActiveProducts()%> active</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-12">
                    <div class="card p-4 bg-warning bg-opacity-10 border border-warning border-opacity-25 rounded-2">
                        <div class="d-flex gap-3">
                            <div class="icon-shape icon-md bg-warning text-white rounded-2">
                                <i class="ti ti-currency-dollar fs-4"></i>
                            </div>
                            <div>
                                <h2 class="mb-3 fs-6">Revenue</h2>
                                <h3 class="fw-bold mb-0"><%=nf.format(totalRevenue)%></h3>
                                <p class="text-warning mb-0 small">VND</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row g-3 mb-3">
                <!-- Revenue Chart -->
                <div class="col-lg-8 col-12">
                    <div class="card">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center px-4 py-3">
                            <h4 class="mb-0 h5">Revenue Overview <%=currentYear%></h4>
                        </div>
                        <div class="card-body">
                            <div id="revenueChart"></div>
                        </div>
                    </div>
                </div>

                <!-- Order Status Pie Chart -->
                <div class="col-lg-4 col-12">
                    <div class="card">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center px-4 py-3">
                            <h4 class="mb-0 h5">Order Status</h4>
                        </div>
                        <div class="card-body">
                            <div id="orderStatusChart"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Reports & Statistics Row -->
            <div class="row g-3 mb-3">
                <!-- Top Selling Products -->
                <div class="col-lg-6 col-12">
                    <div class="card">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center px-4 py-3">
                            <h4 class="mb-0 h5">Top-Selling Products</h4>
                            <small class="text-secondary">Top 5</small>
                        </div>
                        <div class="card-body">
                            <div id="topProductsChart"></div>
                        </div>
                    </div>
                </div>

                <!-- Inventory Report -->
                <div class="col-lg-6 col-12">
                    <div class="card">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center px-4 py-3">
                            <h4 class="mb-0 h5">Inventory Report</h4>
                            <small class="text-secondary">Top 10 in stock</small>
                        </div>
                        <div class="card-body">
                            <div id="inventoryChart"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- VIP Customers Row -->
            <div class="row g-3 mb-3">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center px-4 py-3">
                            <h4 class="mb-0 h5">VIP Customers</h4>
                            <small class="text-secondary">Top 5 by total spending</small>
                        </div>
                        <div class="card-body">
                            <div id="vipCustomersChart"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Orders -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center px-4 py-3">
                            <h4 class="mb-0 h5">Recent Orders</h4>
                            <a href="<%=request.getContextPath()%>/admin/orders" class="small text-primary text-decoration-underline">View All</a>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table mb-0 text-nowrap table-hover">
                                    <thead class="table-light border-light">
                                        <tr>
                                            <th>Order ID</th>
                                            <th>Customer ID</th>
                                            <th>Date</th>
                                            <th>Total</th>
                                            <th>Status</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                        if (recentOrders.isEmpty()) {
                                        %>
                                        <tr>
                                            <td colspan="6" class="text-center text-secondary py-4">No orders found</td>
                                        </tr>
                                        <%
                                        } else {
                                            for (Order o : recentOrders) {
                                                String statusClass = "bg-secondary-subtle text-secondary border-secondary";
                                                if ("Completed".equalsIgnoreCase(o.getStatus())) {
                                                    statusClass = "bg-success-subtle text-success border-success";
                                                } else if ("Processing".equalsIgnoreCase(o.getStatus()) || "Shipped".equalsIgnoreCase(o.getStatus())) {
                                                    statusClass = "bg-primary-subtle text-primary border-primary";
                                                } else if ("Pending".equalsIgnoreCase(o.getStatus())) {
                                                    statusClass = "bg-warning-subtle text-warning border-warning";
                                                } else if ("Cancelled".equalsIgnoreCase(o.getStatus())) {
                                                    statusClass = "bg-danger-subtle text-danger border-danger";
                                                }
                                                String orderDateStr = o.getOrderDate() != null ? sdf.format(o.getOrderDate()) : "N/A";
                                        %>
                                        <tr>
                                            <td>#<%=o.getOrderID()%></td>
                                            <td>
                                                <div><strong><%=o.getCustomerName() != null ? o.getCustomerName() : "N/A"%></strong></div>
                                                <small class="text-secondary">#<%=o.getUserID()%></small>
                                            </td>
                                            <td><%=orderDateStr%></td>
                                            <td><%=nf.format(o.getTotalAmount())%> VND</td>
                                            <td><span class="badge <%=statusClass%> border"><%=o.getStatus() != null ? o.getStatus() : "Unknown"%></span></td>
                                            <td><a href="<%=request.getContextPath()%>/admin/orders?action=detail&id=<%=o.getOrderID()%>" class="btn btn-sm btn-outline-primary">View</a></td>
                                        </tr>
                                        <%
                                            }
                                        }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Chart Scripts -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Monthly Revenue Bar Chart
            var revenueOptions = {
                series: [{
                    name: 'Revenue',
                    data: <%=monthlyData%>
                }],
                colors: ['#E66239'],
                chart: {
                    type: 'bar',
                    height: 350,
                    toolbar: { show: false }
                },
                plotOptions: {
                    bar: {
                        horizontal: false,
                        columnWidth: '60%',
                        borderRadius: 4,
                        borderRadiusApplication: 'end'
                    }
                },
                dataLabels: { enabled: false },
                xaxis: {
                    categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    axisBorder: { show: false },
                    axisTicks: { show: false }
                },
                yaxis: {
                    labels: {
                        formatter: function(val) {
                            if (val >= 1000000) return (val / 1000000).toFixed(1) + 'M';
                            if (val >= 1000) return (val / 1000).toFixed(0) + 'K';
                            return val;
                        }
                    }
                },
                fill: { opacity: 1 },
                tooltip: {
                    y: {
                        formatter: function(val) {
                            return new Intl.NumberFormat('vi-VN').format(val) + ' VND';
                        }
                    }
                }
            };
            var revenueChart = new ApexCharts(document.querySelector("#revenueChart"), revenueOptions);
            revenueChart.render();

            // Order Status Donut Chart
            var statusOptions = {
                series: [<%=completedOrders%>, <%=processingOrders%>, <%=pendingOrders%>, <%=cancelledOrders%>],
                colors: ['#198754', '#0d6efd', '#ffc107', '#dc3545'],
                chart: {
                    type: 'donut',
                    height: 350
                },
                labels: ['Completed', 'Processing', 'Pending', 'Cancelled'],
                plotOptions: {
                    pie: {
                        donut: {
                            size: '70%',
                            labels: {
                                show: true,
                                name: { show: true },
                                value: {
                                    show: true,
                                    formatter: function(val) { return val; }
                                },
                                total: {
                                    show: true,
                                    label: 'Total Orders',
                                    formatter: function(w) { return w.globals.seriesTotals.reduce((a, b) => a + b, 0); }
                                }
                            }
                        }
                    }
                },
                dataLabels: { enabled: false },
                legend: {
                    position: 'bottom'
                },
                responsive: [{
                    breakpoint: 480,
                    options: {
                        chart: { height: 300 },
                        legend: { position: 'bottom' }
                    }
                }]
            };
            var statusChart = new ApexCharts(document.querySelector("#orderStatusChart"), statusOptions);
            statusChart.render();

            // ===== Top-Selling Products (Horizontal Bar) =====
            var topProductsOptions = {
                series: [{
                    name: 'Sold',
                    data: <%=topProductValues%>
                }],
                colors: ['#0d6efd'],
                chart: {
                    type: 'bar',
                    height: 320,
                    toolbar: { show: false }
                },
                plotOptions: {
                    bar: {
                        horizontal: true,
                        borderRadius: 4,
                        barHeight: '60%',
                        distributed: false
                    }
                },
                dataLabels: {
                    enabled: true,
                    textAnchor: 'start',
                    offsetX: 0,
                    style: { fontSize: '12px', colors: ['#fff'] }
                },
                xaxis: {
                    categories: <%=topProductNames%>,
                    labels: {
                        style: { fontSize: '11px' }
                    }
                },
                yaxis: {
                    labels: {
                        style: { fontSize: '11px' },
                        maxWidth: 180
                    }
                },
                grid: { borderColor: '#e9ecef' },
                legend: { show: false },
                tooltip: {
                    y: { formatter: function(val) { return val + ' sản phẩm'; } }
                },
                noData: { text: 'Chưa có dữ liệu bán hàng' }
            };
            var topProductsChart = new ApexCharts(document.querySelector("#topProductsChart"), topProductsOptions);
            topProductsChart.render();

            // ===== Inventory Report (Horizontal Bar) =====
            var inventoryOptions = {
                series: [{
                    name: 'In Stock',
                    data: <%=inventoryValues%>
                }],
                colors: ['#198754'],
                chart: {
                    type: 'bar',
                    height: 380,
                    toolbar: { show: false }
                },
                plotOptions: {
                    bar: {
                        horizontal: true,
                        borderRadius: 4,
                        barHeight: '70%',
                        distributed: false
                    }
                },
                dataLabels: {
                    enabled: true,
                    textAnchor: 'start',
                    offsetX: 0,
                    style: { fontSize: '11px', colors: ['#fff'] }
                },
                xaxis: {
                    categories: <%=inventoryNames%>,
                    labels: { style: { fontSize: '10px' } }
                },
                yaxis: {
                    labels: { style: { fontSize: '10px' }, maxWidth: 160 }
                },
                grid: { borderColor: '#e9ecef' },
                legend: { show: false },
                tooltip: {
                    y: { formatter: function(val) { return val + ' sản phẩm'; } }
                },
                noData: { text: 'Chưa có sản phẩm' }
            };
            var inventoryChart = new ApexCharts(document.querySelector("#inventoryChart"), inventoryOptions);
            inventoryChart.render();

            // ===== VIP Customers (Bar + formatter tiền VND) =====
            var vipOptions = {
                series: [{
                    name: 'Total Spent',
                    data: <%=vipValues%>
                }],
                colors: ['#dc3545'],
                chart: {
                    type: 'bar',
                    height: 320,
                    toolbar: { show: false }
                },
                plotOptions: {
                    bar: {
                        horizontal: true,
                        borderRadius: 4,
                        barHeight: '60%',
                        distributed: false
                    }
                },
                dataLabels: {
                    enabled: true,
                    textAnchor: 'start',
                    offsetX: 0,
                    formatter: function(val) {
                        if (val >= 1000000) return (val / 1000000).toFixed(1) + 'M';
                        if (val >= 1000) return (val / 1000).toFixed(0) + 'K';
                        return val;
                    },
                    style: { fontSize: '12px', colors: ['#fff'] }
                },
                xaxis: {
                    categories: <%=vipNames%>,
                    labels: {
                        formatter: function(val) {
                            if (val >= 1000000) return (val / 1000000).toFixed(1) + 'M';
                            if (val >= 1000) return (val / 1000).toFixed(0) + 'K';
                            return val;
                        },
                        style: { fontSize: '11px' }
                    }
                },
                yaxis: {
                    labels: { style: { fontSize: '11px' }, maxWidth: 180 }
                },
                grid: { borderColor: '#e9ecef' },
                legend: { show: false },
                tooltip: {
                    y: {
                        formatter: function(val) {
                            return new Intl.NumberFormat('vi-VN').format(val) + ' VND';
                        }
                    }
                },
                noData: { text: 'Chưa có khách hàng' }
            };
            var vipChart = new ApexCharts(document.querySelector("#vipCustomersChart"), vipOptions);
            vipChart.render();
        });
    </script>
</body>
</html>
