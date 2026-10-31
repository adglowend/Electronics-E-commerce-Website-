<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    String errorMsg   = (String) request.getAttribute("error");
    String successMsg = (String) session.getAttribute("success");
    if (successMsg != null) session.removeAttribute("success");

    if (session.getAttribute("account") != null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }

    String fFullName = (String) request.getAttribute("fullName");
    if (fFullName == null) fFullName = "";
    String fEmail = (String) request.getAttribute("email");
    if (fEmail == null) fEmail = "";
    String fPhone = (String) request.getAttribute("phone");
    if (fPhone == null) fPhone = "";
    String fAddress = (String) request.getAttribute("address");
    if (fAddress == null) fAddress = "";

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register - Electro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/register.css">
</head>
<body>

<%@include file="customerHeader.jsp" %>

<div class="register-wrap">
    <div class="container">
        <div class="register-card mx-auto d-flex">

            <div class="register-side d-none d-md-flex flex-column justify-content-center">
                <h2><i class="fas fa-user-plus me-2"></i>Electro</h2>
                <p>Create your account to enjoy a better shopping experience with exclusive benefits.</p>
                <div class="features">
                    <div><i class="fas fa-bolt"></i> Exclusive deals for members</div>
                    <div><i class="fas fa-truck"></i> Faster checkout & order tracking</div>
                    <div><i class="fas fa-heart"></i> Save your favorite products</div>
                    <div><i class="fas fa-headset"></i> Priority customer support</div>
                </div>
            </div>

            <div class="register-form-side">

                <h3>Create account</h3>
                <p class="sub">Already a member?
                    <a href="<%= ctx %>/login" class="text-decoration-none" style="color:#e65100; font-weight:600;">Sign in</a>
                </p>

                <% if (errorMsg != null) { %>
                    <div class="alert alert-danger py-2">
                        <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
                    </div>
                <% } %>
                <% if (successMsg != null) { %>
                    <div class="alert alert-success py-2">
                        <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                    </div>
                <% } %>

                <form action="<%= ctx %>/register" method="post" novalidate>

                    <div class="mb-3">
                        <label class="form-label">Full name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="fullName"
                               placeholder="Nguyen Van A"
                               value="<%= fFullName %>" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Email <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" name="email"
                               placeholder="name@example.com"
                               value="<%= fEmail %>" required>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Password <span class="text-danger">*</span></label>
                            <div class="password-wrap">
                                <input type="password" class="form-control" id="password"
                                       name="password" placeholder="At least 8 chars: Aa1!" required
                                       minlength="8"
                                       pattern="(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':&quot;\\|,.<>/?`~]).{8,}"
                                       title="At least 8 chars, 1 uppercase, 1 lowercase, 1 digit, 1 special character">
                                <span class="input-icon" onclick="togglePwd(this)" title="Show/Hide password">
                                    <i class="fas fa-eye"></i>
                                </span>
                            </div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Confirm password <span class="text-danger">*</span></label>
                            <div class="password-wrap">
                                <input type="password" class="form-control" id="confirmPassword"
                                       name="confirmPassword" placeholder="Re-enter password" required minlength="8">
                                <span class="input-icon" onclick="togglePwd(this, 'confirmPassword')" title="Show/Hide password">
                                    <i class="fas fa-eye"></i>
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Phone <span class="text-danger">*</span></label>
                            <input type="tel" class="form-control" name="phone"
                                   placeholder="0901234567"
                                   value="<%= fPhone %>"
                                   pattern="0[0-9]{9}" maxlength="10" required
                                   title="Phone must be exactly 10 digits starting with 0">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Address <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" name="address"
                                   placeholder="Street, district, city"
                                   value="<%= fAddress %>" required>
                        </div>
                    </div>

                    <div class="form-check mb-4">
                        <input class="form-check-input" type="checkbox" id="agree" name="agree" value="on" required>
                        <label class="form-check-label" for="agree">
                            I agree to the <a href="#" class="text-decoration-none" style="color:#e65100;">Terms</a>
                            and <a href="#" class="text-decoration-none" style="color:#e65100;">Privacy Policy</a>
                        </label>
                    </div>

                    <button type="submit" class="btn btn-register">
                        <i class="fas fa-user-plus me-2"></i>Create account
                    </button>

                </form>
            </div>

        </div>
    </div>
</div>

<%@include file="customerFooter.jsp" %>

<script>
function togglePwd(el, targetId) {
    var input = document.getElementById(targetId || 'password');
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