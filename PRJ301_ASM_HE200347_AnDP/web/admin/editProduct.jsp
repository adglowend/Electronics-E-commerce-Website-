<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="dao.CategoryDAO"%>
<%@page import="dao.BrandDAO"%>
<%@page import="model.Product"%>
<%@page import="dao.ProductImageDAO"%>
<%@page import="model.ProductImage"%>
<%@page import="model.Category"%>
<%@page import="model.Brand"%>
<%@page import="model.User"%>
<%@page import="model.Role"%>

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

Product p = (Product) request.getAttribute("product");
String mainImage = (String) request.getAttribute("mainImage");
ArrayList<Category> categories = new CategoryDAO().getAllCategory();
ArrayList<Brand> brands = new BrandDAO().getAllBrand();

ProductImageDAO imageDao = new ProductImageDAO();
ArrayList<ProductImage> imageList = p != null ? imageDao.getImagesByProduct(p.getProductID()) : new ArrayList<>();
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Edit Product - Electro Store</title>
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
                    <div class="d-flex align-items-center">
                        <a href="<%=request.getContextPath()%>/admin/product" class="btn btn-outline-secondary me-3">
                            <i class="ti ti-arrow-left"></i>
                        </a>
                        <div>
                            <h1 class="fs-3 mb-1">Edit Product</h1>
                            <p class="text-secondary mb-0">Update product information</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-4 col-12">
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">Product Images</h5>
                        </div>
                        <div class="card-body">
                            <%
                            if (imageList == null || imageList.isEmpty()) {
                            %>
                            <div class="bg-light rounded p-5 text-center">
                                <i class="ti ti-photo fs-1 text-secondary"></i>
                                <p class="text-secondary mt-2 mb-0">No images yet</p>
                            </div>
                            <%
                            } else {
                            %>
                            <div class="row g-2">
                                <%
                                for (ProductImage img : imageList) {
                                    String badge = img.isIsMain() ? "<span class='badge bg-success position-absolute top-0 start-0 m-1'>Main</span>" : "";
                                %>
                                <div class="col-6 position-relative">
                                    <div class="border rounded overflow-hidden position-relative">
                                        <%=badge%>
                                        <img src="<%=img.getImageURL()%>" alt="" class="w-100" style="height: 110px; object-fit: cover;">
                                        <div class="d-flex border-top">
                                            <% if (!img.isIsMain()) { %>
                                            <form action="<%=request.getContextPath()%>/admin/product-image" method="post" class="flex-grow-1">
                                                <input type="hidden" name="action" value="setMain">
                                                <input type="hidden" name="imageID" value="<%=img.getImageID()%>">
                                                <input type="hidden" name="productID" value="<%=p.getProductID()%>">
                                                <button type="submit" class="btn btn-sm btn-outline-primary w-100 rounded-0" title="Set as main">
                                                    <i class="ti ti-star"></i>
                                                </button>
                                            </form>
                                            <% } else { %>
                                            <button type="button" class="btn btn-sm btn-success w-100 rounded-0" disabled>
                                                <i class="ti ti-star-filled"></i> Main
                                            </button>
                                            <% } %>
                                            <form action="<%=request.getContextPath()%>/admin/product-image" method="post" onsubmit="return confirm('Delete this image?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="imageID" value="<%=img.getImageID()%>">
                                                <input type="hidden" name="productID" value="<%=p.getProductID()%>">
                                                <button type="submit" class="btn btn-sm btn-outline-danger rounded-0" title="Delete">
                                                    <i class="ti ti-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                                <%
                                }
                                %>
                            </div>
                            <%
                            }
                            %>

                            <hr class="my-3">

                            <form action="<%=request.getContextPath()%>/admin/product-image" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="productID" value="<%=p.getProductID()%>">
                                <label class="form-label fw-bold">Add More Images</label>
                                <input type="file" class="form-control mb-2" name="imageFile" accept="image/*" multiple id="imageFileMulti">
                                <div id="multiPreview" class="d-flex flex-wrap gap-1 mb-2"></div>
                                <div class="form-check mb-2">
                                    <input class="form-check-input" type="checkbox" name="isMain" value="1" id="isMainCheck">
                                    <label class="form-check-label" for="isMainCheck">
                                        Set first uploaded as main image
                                    </label>
                                </div>
                                <button type="submit" class="btn btn-primary btn-sm w-100">
                                    <i class="ti ti-upload me-1"></i> Upload Images
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8 col-12">
                    <div class="card">
                        <div class="card-body p-4">
                            <form action="<%=request.getContextPath()%>/admin/product" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="edit">
                                <input type="hidden" name="productID" value="<%=p.getProductID()%>">

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Product Name <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" name="productName" value="<%=p.getProductName() != null ? p.getProductName() : ""%>" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Category <span class="text-danger">*</span></label>
                                        <select class="form-select" name="categoryID" required>
                                            <%
                                            if (categories != null) {
                                                for (Category c : categories) {
                                                    String sel = p.getCategoryID() == c.getCategoryID() ? "selected" : "";
                                            %>
                                            <option value="<%=c.getCategoryID()%>" <%=sel%>><%=c.getCategoryName()%></option>
                                            <%
                                                }
                                            }
                                            %>
                                        </select>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Brand <span class="text-danger">*</span></label>
                                        <select class="form-select" name="brandID" required>
                                            <%
                                            if (brands != null) {
                                                for (Brand b : brands) {
                                                    String sel = p.getBrandID() == b.getBrandID() ? "selected" : "";
                                            %>
                                            <option value="<%=b.getBrandID()%>" <%=sel%>><%=b.getBrandName()%></option>
                                            <%
                                                }
                                            }
                                            %>
                                        </select>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Price (VND) <span class="text-danger">*</span></label>
                                        <input type="number" step="0.01" class="form-control" name="price" value="<%=p.getPrice()%>" required>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Quantity <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" name="quantity" value="<%=p.getQuantity()%>" required>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Image URL (optional)</label>
                                        <input type="text" class="form-control" name="newImageURL" placeholder="https://example.com/image.jpg">
                                        <small class="text-secondary">Or manage images in the gallery panel</small>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea class="form-control" name="description" rows="4"><%=p.getDescription() != null ? p.getDescription() : ""%></textarea>
                                </div>

                                <div class="mb-4">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="status" value="true" id="statusCheck" <%=p.isStatus() ? "checked" : ""%>>
                                        <label class="form-check-label" for="statusCheck">
                                            Active (product will be visible)
                                        </label>
                                    </div>
                                </div>

                                <div class="d-flex gap-2">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="ti ti-device-floppy me-2"></i> Update Product
                                    </button>
                                    <a href="<%=request.getContextPath()%>/admin/product" class="btn btn-outline-secondary">Cancel</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <script>
        document.getElementById('imageFileMulti')?.addEventListener('change', function () {
            var preview = document.getElementById('multiPreview');
            preview.innerHTML = '';
            if (this.files) {
                Array.from(this.files).forEach(function (file) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var img = document.createElement('img');
                        img.src = e.target.result;
                        img.style.width = '60px';
                        img.style.height = '60px';
                        img.style.objectFit = 'cover';
                        img.className = 'rounded border';
                        preview.appendChild(img);
                    };
                    reader.readAsDataURL(file);
                });
            }
        });
    </script>
</body>
</html>
