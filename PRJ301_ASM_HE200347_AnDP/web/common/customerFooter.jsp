<%@page contentType="text/html;charset=UTF-8" language="java"%>
        </div>
</section>

</div>

<footer>
    <div class="container py-4">
        <div class="row">
            <div class="col-md-6 col-lg-3 mb-4">
                <h5 style="color:#fd7e14;">Electro</h5>
                <p>Your one-stop shop for quality electronics at the best prices.</p>
            </div>
            <div class="col-md-6 col-lg-3 mb-4">
                <h5 class="text-white">Customer Service</h5>
                <a href="<%=request.getContextPath()%>/home">Contact Us</a>
                <a href="<%=request.getContextPath()%>/home">Returns</a>
                <a href="<%=request.getContextPath()%>/customer/orders">Order History</a>
            </div>
            <div class="col-md-6 col-lg-3 mb-4">
                <h5 class="text-white">Information</h5>
                <a href="<%=request.getContextPath()%>/home">About Us</a>
                <a href="<%=request.getContextPath()%>/home">Privacy Policy</a>
                <a href="<%=request.getContextPath()%>/home">Terms &amp; Conditions</a>
            </div>
            <div class="col-md-6 col-lg-3 mb-4">
                <h5 class="text-white">My Account</h5>
                <a href="<%=request.getContextPath()%>/customer/profile">My Account</a>
                <a href="<%=request.getContextPath()%>/customer/orders">My Orders</a>
                <a href="<%=request.getContextPath()%>/customer/cart">My Cart</a>
            </div>
        </div>
    </div>
    <div class="text-center py-3" style="border-top:1px solid #343a40;">
        &copy; 2026 Electro. All rights reserved.
    </div>
</footer>

<script src="<%=request.getContextPath()%>/assets/js/jquery.min.js"></script>
<script src="<%=request.getContextPath()%>/assets/js/bootstrap.bundle.min.js"></script>
</body>
</html>
