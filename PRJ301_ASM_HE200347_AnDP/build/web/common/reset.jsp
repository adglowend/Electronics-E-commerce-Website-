<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    String errorMsg = (String) request.getAttribute("error");
    String token = (String) request.getAttribute("token");
    String email = (String) request.getAttribute("email");
    if (session.getAttribute("account") != null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    if (token == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Reset Password - Electro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/reset.css">
</head>
<body>

<%@include file="customerHeader.jsp" %>

<div class="reset-wrap">
    <div class="container">
        <div class="reset-card mx-auto">

            <div class="reset-side d-none d-md-flex">
                <h2><i class="fas fa-lock me-2"></i>New Password</h2>
                <p>Choose a strong password to secure your Electro account. Make it at least 8 characters with a mix of letters, numbers and symbols.</p>
                <div class="features">
                    <div><i class="fas fa-check-circle"></i> Minimum 8 characters</div>
                    <div><i class="fas fa-font"></i> Uppercase &amp; lowercase letters</div>
                    <div><i class="fas fa-hashtag"></i> At least one number</div>
                    <div><i class="fas fa-asterisk"></i> At least one special character</div>
                </div>
            </div>

            <div class="reset-form-side">
                <h3>Set a new password</h3>
                <p class="subtitle">Enter your new password below to regain access.</p>

                <div class="reset-email-chip">
                    <i class="fas fa-user-circle"></i><%= email %>
                </div>

                <% if (errorMsg != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="<%=ctx%>/reset?token=<%= token %>" method="post" autocomplete="on">

                    <div class="mb-3 position-relative password-wrap">
                        <input type="password"
                               class="form-control"
                               id="password"
                               name="password"
                               placeholder="New password"
                               required>
                        <span class="input-icon" toggle="#password" onclick="togglePwd(this, 'password')" title="Show/Hide password">
                            <i class="fas fa-eye"></i>
                        </span>
                        <div class="reset-pwd-hint">8+ chars, uppercase, lowercase, number &amp; special character.</div>
                    </div>

                    <div class="mb-4 position-relative password-wrap">
                        <input type="password"
                               class="form-control"
                               id="confirmPassword"
                               name="confirmPassword"
                               placeholder="Confirm new password"
                               required>
                        <span class="input-icon" toggle="#confirmPassword" onclick="togglePwd(this, 'confirmPassword')" title="Show/Hide password">
                            <i class="fas fa-eye"></i>
                        </span>
                    </div>

                    <button type="submit" class="btn btn-reset">
                        <i class="fas fa-redo me-2"></i>Reset Password
                    </button>

                    <div class="reset-divider"><span>OR</span></div>

                    <a href="<%=ctx%>/login" class="btn reset-back-btn w-100">
                        <i class="fas fa-arrow-left me-2"></i>Back to Sign In
                    </a>

                    <p class="reset-footer-text">
                        Remembered your password?
                        <a href="<%=ctx%>/login">Sign in</a>
                    </p>
                </form>
            </div>

        </div>
    </div>
</div>

<%@include file="customerFooter.jsp" %>

<script>
function togglePwd(el, id) {
    var input = document.getElementById(id);
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