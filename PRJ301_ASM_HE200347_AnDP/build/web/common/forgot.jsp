<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    String errorMsg = (String) request.getAttribute("error");
    String successMsg = (String) request.getAttribute("success");
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
    <title>Forgot Password - Electro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/forgot.css">
</head>
<body>

<%@include file="customerHeader.jsp" %>

<div class="forgot-wrap">
    <div class="container">
        <div class="forgot-card mx-auto">

            <div class="forgot-side d-none d-md-flex">
                <h2><i class="fas fa-key me-2"></i>Forgot Password</h2>
                <p>Enter the email associated with your account and we'll send you a link to reset your password securely.</p>
                <div class="features">
                    <div><i class="fas fa-shield-alt"></i> Secure token-based reset</div>
                    <div><i class="fas fa-clock"></i> Link expires after single use</div>
                    <div><i class="fas fa-envelope-open-text"></i> Check inbox &amp; spam folder</div>
                    <div><i class="fas fa-headset"></i> Need help? Contact support</div>
                </div>
            </div>

            <div class="forgot-form-side">
                <h3>Reset your password</h3>
                <p class="subtitle">We'll email you a link to set a new password.</p>

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

                <form action="<%=ctx%>/forgot" method="post" autocomplete="on">

                    <div class="form-floating mb-4">
                        <input type="email"
                               class="form-control"
                               id="email"
                               name="email"
                               placeholder="name@example.com"
                               required>
                        <label for="email"><i class="fas fa-envelope me-2 text-muted"></i>Email address</label>
                    </div>

                    <button type="submit" class="btn btn-forgot">
                        <i class="fas fa-paper-plane me-2"></i>Send Reset Link
                    </button>

                    <div class="forgot-divider"><span>OR</span></div>

                    <a href="<%=ctx%>/login" class="btn forgot-back-btn w-100">
                        <i class="fas fa-arrow-left me-2"></i>Back to Sign In
                    </a>

                    <p class="forgot-footer-text">
                        Don't have an account?
                        <a href="<%=ctx%>/register">Create one</a>
                    </p>
                </form>
            </div>

        </div>
    </div>
</div>

<%@include file="customerFooter.jsp" %>

</body>
</html>