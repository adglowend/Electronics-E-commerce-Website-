<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="dao.ProductDAO"%>
<%@page import="dao.CategoryDAO"%>
<%@page import="dao.BrandDAO"%>
<%@page import="model.Product"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="model.User"%>
<%@page import="model.Role"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>

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

ArrayList<Product> list = (ArrayList<Product>) request.getAttribute("list");
String keyword = (String) request.getAttribute("keyword");
Locale locale = new Locale("vi", "VN");
NumberFormat nf = NumberFormat.getInstance(locale);

// Get category and brand names for mapping
Map<Integer, String> categoryNames = new HashMap<>();
Map<Integer, String> brandNames = new HashMap<>();
Map<Integer, String> mainImages = new HashMap<>();

CategoryDAO categoryDAO = new CategoryDAO();
BrandDAO brandDAO = new BrandDAO();
ProductDAO productDAO = new ProductDAO();

ArrayList<Category> categories = categoryDAO.getAllCategory();
if (categories != null) {
    for (Category c : categories) {
        categoryNames.put(c.getCategoryID(), c.getCategoryName());
    }
}

ArrayList<Brand> brands = brandDAO.getAllBrand();
if (brands != null) {
    for (Brand b : brands) {
        brandNames.put(b.getBrandID(), b.getBrandName());
    }
}

if (list != null) {
    for (Product p : list) {
        mainImages.put(p.getProductID(), productDAO.getMainImage(p.getProductID()));
    }
}
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Product Management - Electro Store</title>
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
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/orders"><i class="ti ti-shopping-cart"></i><span class="nav-text">Orders</span></a></li>
            <li class="px-4 py-2"><small class="nav-text">Management</small></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/user"><i class="ti ti-users"></i><span class="nav-text">Users</span></a></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/category"><i class="ti ti-category"></i><span class="nav-text">Categories</span></a></li>
            <li><a class="nav-link" href="<%=request.getContextPath()%>/admin/brand"><i class="ti ti-tag"></i><span class="nav-text">Brands</span></a></li>
            <li><a class="nav-link active" href="<%=request.getContextPath()%>/admin/product"><i class="ti ti-box"></i><span class="nav-text">Products</span></a></li>
            <li class="px-4 pt-4 pb-2"><small class="nav-text">Account</small></li>
            <li><a class="nav-link text-danger" href="<%=request.getContextPath()%>/logout"><i class="ti ti-logout"></i><span class="nav-text">Logout</span></a></li>
        </ul>
    </aside>

    <!-- MAIN CONTENT -->
    <main id="content" class="content py-10">
        <div class="container-fluid">
            <div class="row mb-4">
                <div class="col-12">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h1 class="fs-3 mb-1">Product Management</h1>
                            <p class="text-secondary mb-0">Manage store products</p>
                        </div>
                        <a href="<%=request.getContextPath()%>/admin/product?action=add" class="btn btn-primary">
                            <i class="ti ti-plus me-2"></i> Add Product
                        </a>
                    </div>
                </div>
            </div>

            <div class="row mb-3">
                <div class="col-12">
                    <form action="<%=request.getContextPath()%>/admin/product" method="get" class="d-flex gap-2 align-items-center">
                        <div class="input-group" style="max-width: 450px;">
                            <span class="input-group-text bg-white border-end-0">
                                <i class="ti ti-search text-secondary"></i>
                            </span>
                            <input type="text" name="search" class="form-control border-start-0" placeholder="Search by name or description..." value="<%=keyword != null ? keyword : ""%>">
                            <% if (keyword != null && !keyword.isEmpty()) { %>
                            <a href="<%=request.getContextPath()%>/admin/product" class="btn btn-outline-secondary" title="Clear">
                                <i class="ti ti-x"></i>
                            </a>
                            <% } %>
                        </div>
                        <button type="submit" class="btn btn-primary">
                            <i class="ti ti-search me-1"></i> Search
                        </button>
                    </form>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table mb-0 text-nowrap table-hover">
                                    <thead class="table-light border-light">
                                        <tr>
                                            <th>Image</th>
                                            <th>Product Name</th>
                                            <th>Category</th>
                                            <th>Brand</th>
                                            <th>Price</th>
                                            <th>Stock</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                        if (list == null || list.isEmpty()) {
                                        %>
                                        <tr>
                                            <td colspan="8" class="text-center text-secondary py-4">
                                                <% if (keyword != null && !keyword.isEmpty()) { %>
                                                No products found for "<strong><%=keyword%></strong>"
                                                <% } else { %>
                                                No products found
                                                <% } %>
                                            </td>
                                        </tr>
                                        <%
                                        } else {
                                            for (Product p : list) {
                                                String catName = categoryNames.getOrDefault(p.getCategoryID(), "N/A");
                                                String brandName = brandNames.getOrDefault(p.getBrandID(), "N/A");
                                                String img = mainImages.get(p.getProductID());
                                                String statusClass = p.isStatus() ? "bg-success-subtle text-success border-success" : "bg-secondary-subtle text-secondary border-secondary";
                                                String stockClass = p.getQuantity() <= 10 ? "text-danger fw-bold" : "";
                                        %>
                                        <tr>
                                            <td>
                                                <% if (img != null && !img.isEmpty()) { %>
                                                <img src="<%=img%>" alt="" class="avatar avatar-md rounded" style="object-fit: cover;">
                                                <% } else { %>
                                                <div class="avatar avatar-md bg-secondary rounded"><i class="ti ti-image"></i></div>
                                                <% } %>
                                            </td>
                                            <td><strong><%=p.getProductName() != null ? p.getProductName() : "N/A"%></strong></td>
                                            <td><span class="badge bg-light text-dark border"><%=catName%></span></td>
                                            <td><span class="badge bg-light text-dark border"><%=brandName%></span></td>
                                            <td><strong><%=nf.format(p.getPrice())%></strong> VND</td>
                                            <td class="<%=stockClass%>"><%=p.getQuantity()%></td>
                                            <td><span class="badge <%=statusClass%> border"><%=p.isStatus() ? "Active" : "Inactive"%></span></td>
                                            <td>
                                                <a href="<%=request.getContextPath()%>/admin/product?action=edit&id=<%=p.getProductID()%>" class="btn btn-sm btn-outline-primary">
                                                    <i class="ti ti-edit"></i>
                                                </a>
                                                <a href="<%=request.getContextPath()%>/admin/product?action=delete&id=<%=p.getProductID()%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this product?')">
                                                    <i class="ti ti-trash"></i>
                                                </a>
                                            </td>
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
</body>
</html>
