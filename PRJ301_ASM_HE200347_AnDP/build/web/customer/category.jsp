<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="model.Category"%>
<%@page import="model.Product"%>
<%@page import="model.Brand"%>
<%@page import="dao.BrandDAO"%>
<%@page import="model.Brand"%>
<%@page import="dao.BrandDAO"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    if (request.getAttribute("pageTitle") == null) {
        request.setAttribute("pageTitle", "Category - Electro");
    }

    List<Category> categories = (List<Category>) request.getAttribute("categories");
    Category current = (Category) request.getAttribute("currentCategory");
    List<Product> list = (List<Product>) request.getAttribute("list");
    Map<Integer, String> mainImages = (Map<Integer, String>) request.getAttribute("mainImages");
    if (mainImages == null) mainImages = new java.util.HashMap<>();
    if (list == null) list = new java.util.ArrayList<>();
    if (categories == null) categories = new java.util.ArrayList<>();

    // ===== Pagination (read attributes set by FilterCategoryServlet) =====
    Integer _currentPage = (Integer) request.getAttribute("currentPage");
    Integer _totalPages  = (Integer) request.getAttribute("totalPages");
    Integer _totalItems  = (Integer) request.getAttribute("totalItems");
    Integer _pageSize    = (Integer) request.getAttribute("pageSize");
    Integer _startIndex  = (Integer) request.getAttribute("startIndex");
    Integer _endIndex    = (Integer) request.getAttribute("endIndex");
    String  _baseUrl     = (String)  request.getAttribute("baseUrl");
    String  _extraParams = (String)  request.getAttribute("extraParams");
    if (_currentPage == null) _currentPage = 1;
    if (_totalPages  == null) _totalPages  = 1;
    if (_totalItems  == null) _totalItems  = list.size();
    if (_pageSize    == null) _pageSize    = 15;
    if (_startIndex  == null) _startIndex  = 0;
    if (_endIndex    == null) _endIndex    = list.size();
    if (_baseUrl     == null) _baseUrl     = request.getContextPath() + "/customer/category";
    if (_extraParams == null) _extraParams = "";

    java.util.List<Brand> allBrands = new java.util.ArrayList<>();
    try {
        allBrands = new BrandDAO().getAllBrand();
    } catch (Exception e) {
        // brand list optional
    }

    String ctx = request.getContextPath();
    if (request.getAttribute("active") == null && current != null) {
        request.setAttribute("active", current.getCategoryName().toLowerCase());
    }
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/category.css">

<!-- Hero band removed -->

<!-- Category filter chips removed: navbar already has DB-driven categories -->

<!-- Product grid -->
<section class="py-5" style="background:#f8f9fa;">
    <div class="container">
        <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap">
            <h2 class="fw-bold m-0">
                <%= current != null ? current.getCategoryName() : "Products" %>
                <span class="text-muted fs-6">(<span id="visibleCount"><%= list.size() %></span> items)</span>
            </h2>
        </div>

        <div class="cat-layout">
            <aside class="filter-sidebar">
                <div class="filter-group">
                    <h6><i class="fa fa-tag me-1"></i>Brand</h6>
                    <%
                    if (allBrands != null && !allBrands.isEmpty()) {
                        for (Brand b : allBrands) {
                            int bid = b.getBrandID();
                            String bname = b.getBrandName();
                            if (bname == null) bname = "Brand " + bid;
                    %>
                            <div class="form-check">
                                <input class="form-check-input filter-brand" type="checkbox" value="<%= bid %>" id="brand_<%= bid %>">
                                <label class="form-check-label" for="brand_<%= bid %>"><%= bname %></label>
                            </div>
                    <%
                        }
                    } else {
                    %>
                        <small class="text-muted">No brands available.</small>
                    <% } %>
                </div>

                <div class="filter-group">
                    <h6><i class="fa fa-money-bill me-1"></i>Price Range</h6>
                    <div class="form-check">
                        <input class="form-check-input filter-price" type="radio" name="priceRange" id="priceAll" value="all" checked>
                        <label class="form-check-label" for="priceAll">All prices</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input filter-price" type="radio" name="priceRange" id="price1" value="0-5000000">
                        <label class="form-check-label" for="price1">Under 5.000.000</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input filter-price" type="radio" name="priceRange" id="price2" value="5000000-10000000">
                        <label class="form-check-label" for="price2">5 - 10 trieu</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input filter-price" type="radio" name="priceRange" id="price3" value="10000000-20000000">
                        <label class="form-check-label" for="price3">10 - 20 trieu</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input filter-price" type="radio" name="priceRange" id="price4" value="20000000-999999999">
                        <label class="form-check-label" for="price4">Tren 20 trieu</label>
                    </div>
                    <div class="mt-2 price-inputs">
                        <input type="number" class="form-control form-control-sm" id="minPrice" placeholder="Min">
                        <input type="number" class="form-control form-control-sm" id="maxPrice" placeholder="Max">
                    </div>
                </div>

                <div class="filter-group">
                    <h6><i class="fa fa-cubes me-1"></i>Availability</h6>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="inStockOnly">
                        <label class="form-check-label" for="inStockOnly">In stock only</label>
                    </div>
                </div>

                <div class="d-flex gap-2 mt-3">
                    <button class="btn btn-apply btn-sm w-50" id="applyFilter">
                        <i class="fa fa-filter me-1"></i>Apply
                    </button>
                    <button class="btn btn-reset btn-sm w-50" id="resetFilter">
                        <i class="fa fa-undo me-1"></i>Reset
                    </button>
                </div>
            </aside>

            <div>
        <%
        if (list.isEmpty()) {
        %>
            <div class="empty-cat">
                <i class="fa fa-box-open"></i>
                <h4 class="mt-3">No products in this category</h4>
                <p class="text-muted">Please check back later or browse other categories.</p>
                <a href="<%=ctx%>/home" class="btn btn-primary rounded-pill px-4 mt-2">
                    <i class="fa fa-home me-1"></i>Back to Home
                </a>
            </div>
        <%
        } else {
        %>
            <div class="row g-4 cat-grid" id="catGrid">
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
                    <div class="col-6 col-md-4 col-lg-6 col-xl-4 product-col"
                         data-brand-id="<%=p.getBrandID()%>"
                         data-price="<%=price%>"
                         data-discount="<%= (oldPrice > 0) ? "1" : "0" %>"
                         data-stock="<%= inStock ? "1" : "0" %>">
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

            <!-- Pagination Info + Controls -->
            <div class="d-flex flex-nowrap justify-content-between align-items-center mt-5 gap-3">
                <div class="text-muted small text-nowrap">
                    Hiển thị <strong><%= _startIndex + 1 %>–<%= _endIndex %></strong> / <strong><%= _totalItems %></strong> sản phẩm
                    (trang <strong><%= _currentPage %></strong>/<strong><%= _totalPages %></strong>)
                </div>
                <%
                if (_totalPages > 1) {
                    int window = 2;
                    int from = Math.max(1, _currentPage - window);
                    int to   = Math.min(_totalPages, _currentPage + window);
                %>
                <nav aria-label="Category pagination">
                    <ul class="pagination mb-0">
                        <!-- Previous -->
                        <li class="page-item <%= _currentPage == 1 ? "disabled" : "" %>">
                            <a class="page-link"
                               href="<%= _currentPage == 1 ? "#" : _baseUrl + "?page=" + (_currentPage - 1) + _extraParams %>"
                               aria-label="Previous">
                                <span aria-hidden="true">&laquo;</span>
                            </a>
                        </li>

                        <!-- First + ellipsis -->
                        <%
                        if (from > 1) {
                        %>
                            <li class="page-item">
                                <a class="page-link" href="<%= _baseUrl + "?page=1" + _extraParams %>">1</a>
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
                        for (int pg = from; pg <= to; pg++) {
                        %>
                            <li class="page-item <%= pg == _currentPage ? "active" : "" %>">
                                <%
                                if (pg == _currentPage) {
                                %>
                                    <span class="page-link"><%= pg %></span>
                                <%
                                } else {
                                %>
                                    <a class="page-link" href="<%= _baseUrl + "?page=" + pg + _extraParams %>"><%= pg %></a>
                                <%
                                }
                                %>
                            </li>
                        <%
                        }

                        // Last + ellipsis
                        if (to < _totalPages) {
                            if (to < _totalPages - 1) {
                        %>
                                <li class="page-item disabled"><span class="page-link">…</span></li>
                        <%
                            }
                        %>
                            <li class="page-item">
                                <a class="page-link" href="<%= _baseUrl + "?page=" + _totalPages + _extraParams %>"><%= _totalPages %></a>
                            </li>
                        <%
                        }
                        %>

                        <!-- Next -->
                        <li class="page-item <%= _currentPage == _totalPages ? "disabled" : "" %>">
                            <a class="page-link"
                               href="<%= _currentPage == _totalPages ? "#" : _baseUrl + "?page=" + (_currentPage + 1) + _extraParams %>"
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

            <div id="emptyFilter" class="empty-cat mt-4" style="display:none;">
                <i class="fa fa-search"></i>
                <h4 class="mt-3">No products match your filters</h4>
                <p class="text-muted">Try adjusting your selection.</p>
            </div>
        <%
        } // end else
        %>
            </div>
        </div>
    </div>
</section>

<script>
(function () {
    var grid = document.getElementById('catGrid');
    if (!grid) return;
    var emptyBox = document.getElementById('emptyFilter');
    var visibleCount = document.getElementById('visibleCount');

    function applyFilters() {
        var selectedBrands = Array.prototype.slice.call(document.querySelectorAll('.filter-brand:checked'))
            .map(function (cb) { return cb.value; });
        var priceRadio = document.querySelector('.filter-price:checked');
        var priceRange = priceRadio ? priceRadio.value : 'all';
        var minP = parseFloat(document.getElementById('minPrice').value);
        var maxP = parseFloat(document.getElementById('maxPrice').value);
        var inStockOnly = document.getElementById('inStockOnly').checked;
        var lo = 0, hi = Number.POSITIVE_INFINITY;
        if (priceRange && priceRange !== 'all') {
            var parts = priceRange.split('-');
            lo = parseFloat(parts[0]); hi = parseFloat(parts[1]);
        }
        if (!isNaN(minP)) lo = Math.max(lo, minP);
        if (!isNaN(maxP)) hi = Math.min(hi, maxP);

        var cards = grid.querySelectorAll('.product-col');
        var visible = 0;
        cards.forEach(function (card) {
            var bid = card.getAttribute('data-brand-id');
            var price = parseFloat(card.getAttribute('data-price'));
            var stock = card.getAttribute('data-stock') === '1';
            var show = true;
            if (selectedBrands.length > 0 && selectedBrands.indexOf(bid) === -1) show = false;
            if (show && (price < lo || price > hi)) show = false;
            if (show && inStockOnly && !stock) show = false;
            card.style.display = show ? '' : 'none';
            if (show) visible++;
        });
        if (visibleCount) visibleCount.textContent = visible;
        if (emptyBox) emptyBox.style.display = visible === 0 ? '' : 'none';
    }

    var applyBtn = document.getElementById('applyFilter');
    if (applyBtn) applyBtn.addEventListener('click', applyFilters);
    var resetBtn = document.getElementById('resetFilter');
    if (resetBtn) resetBtn.addEventListener('click', function () {
        document.querySelectorAll('.filter-brand').forEach(function (cb) { cb.checked = false; });
        var allPrice = document.getElementById('priceAll');
        if (allPrice) allPrice.checked = true;
        document.getElementById('minPrice').value = '';
        document.getElementById('maxPrice').value = '';
        document.getElementById('inStockOnly').checked = false;
        applyFilters();
    });
})();
</script>

<%@include file="../common/customerFooter.jsp" %>
