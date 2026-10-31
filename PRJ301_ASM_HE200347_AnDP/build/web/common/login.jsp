<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    String errorMsg = (String) request.getAttribute("error");
    if (errorMsg == null) errorMsg = (String) session.getAttribute("error");
    if (errorMsg != null) session.removeAttribute("error");

    String successMsg = (String) session.getAttribute("success");
    if (successMsg != null) session.removeAttribute("success");

    String loginEmail = (String) session.getAttribute("loginEmail");
    if (loginEmail == null) {
        loginEmail = (String) request.getAttribute("loginEmail");
    }
    if (loginEmail != null) session.removeAttribute("loginEmail");

    if (session.getAttribute("account") != null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Electro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/login.css">
</head>
<body>

<%@include file="customerHeader.jsp" %>

<div class="login-wrap">
    <div class="container">
        <div class="login-card mx-auto">

            <div class="login-side d-none d-md-flex">
                <h2><i class="fas fa-shopping-bag me-2"></i>Electro</h2>
                <p>Sign in to manage your orders, track shipments, and enjoy a personalized shopping experience.</p>
                <div class="features">
                    <div><i class="fas fa-bolt"></i> Exclusive deals for members</div>
                    <div><i class="fas fa-truck"></i> Track your orders in real time</div>
                    <div><i class="fas fa-heart"></i> Save your favorite products</div>
                    <div><i class="fas fa-headset"></i> Priority customer support</div>
                </div>
            </div>

            <div class="login-form-side">
                <h3>Welcome Back</h3>
                <p class="subtitle">Please sign in to continue shopping.</p>

                <% if (errorMsg != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                <% if (successMsg != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="<%=ctx%>/login" method="post" autocomplete="on">

                    <div class="form-floating mb-3">
                        <input type="email"
                               class="form-control"
                               id="email"
                               name="email"
                               placeholder="name@example.com"
                               value="<%= loginEmail != null ? loginEmail : "" %>"
                               required>
                        <label for="email"><i class="fas fa-envelope me-2 text-muted"></i>Email address</label>
                    </div>

                    <div class="mb-2 position-relative password-wrap">
                        <input type="password"
                               class="form-control"
                               id="password"
                               name="password"
                               placeholder="Password"
                               required>
                        <span class="input-icon" toggle="#password" onclick="togglePwd(this)" title="Show/Hide password">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="remember" name="remember">
                            <label class="form-check-label" for="remember">Remember me</label>
                        </div>
                        <a href="<%=ctx%>/common/forgot.jsp" class="text-decoration-none" style="color:#e65100; font-size:14px; font-weight:600;">
                            Forgot password?
                        </a>
                    </div>

                    <button type="submit" class="btn btn-login">
                        <i class="fas fa-sign-in-alt me-2"></i>Sign In
                    </button>

                    <div class="login-divider"><span>OR</span></div>

                    <a href="<%=ctx%>/home" class="btn btn-outline-ecom w-100">
                        <i class="fas fa-arrow-left me-2"></i>Back to Home
                    </a>

                    <p class="login-footer-text">
                        Don't have an account?
                        <a href="<%=ctx%>/register">Create one</a>
                    </p>
                </form>
            </div>

        </div>
    </div>
</div>

<%@include file="customerFooter.jsp" %>

<script>
function togglePwd(el) {
    var input = document.getElementById('password');
    if (!input) return;
    var icon = el.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        if (icon) {
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        }
    } else {
        input.type = 'password';
        if (icon) {
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }
}
</script>

</body>
</html>
