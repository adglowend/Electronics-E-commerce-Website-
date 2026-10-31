<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    request.setAttribute("pageTitle", "Change Password - Electro");
    request.setAttribute("active", "profile");
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/change-password.css">

<section class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            <div class="cp-card">
                <h3 class="mb-4"><i class="fa fa-key me-2 text-primary"></i>Change Password</h3>

                <% if (error != null) { %>
                    <div class="alert alert-danger"><%=error%></div>
                <% } %>
                <% if (message != null) { %>
                    <div class="alert alert-success"><%=message%></div>
                <% } %>

                <form action="<%=ctx%>/customer/changePassword" method="post">
                    <div class="mb-3">
                        <label class="form-label">Old Password</label>
                        <input type="password" name="oldPassword" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">New Password</label>
                        <input type="password" name="newPassword" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Confirm Password</label>
                        <input type="password" name="confirmPassword" class="form-control">
                    </div>
                    <button type="submit" class="btn btn-primary rounded-pill px-4">
                        <i class="fa fa-save me-1"></i>Change Password
                    </button>
                    <a href="<%=ctx%>/customer/profile" class="btn btn-secondary rounded-pill px-4">
                        <i class="fa fa-arrow-left me-1"></i>Back
                    </a>
                </form>
            </div>
        </div>
    </div>
</section>

<%@include file="../common/customerFooter.jsp" %>
