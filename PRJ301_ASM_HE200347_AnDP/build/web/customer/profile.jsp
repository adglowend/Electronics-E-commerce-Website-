<%@page import="model.User"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    request.setAttribute("pageTitle", "My Profile - Electro");
    request.setAttribute("active", "profile");
    User user = (User) request.getAttribute("user");
    String ctx = request.getContextPath();
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/profile.css">

<section class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            <div class="profile-card">
                <h3 class="mb-4"><i class="fa fa-user me-2 text-primary"></i>My Profile</h3>
                <form action="<%=ctx%>/customer/profile" method="post">
                    <div class="mb-3">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="fullname" class="form-control"
                               value="<%=user.getFullName()%>">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="text" class="form-control"
                               value="<%=user.getEmail()%>" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Phone</label>
                        <input type="text" name="phone" class="form-control"
                               value="<%=user.getPhone()%>">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Address</label>
                        <input type="text" name="address" class="form-control"
                               value="<%=user.getAddress()%>">
                    </div>
                    <button type="submit" class="btn btn-primary rounded-pill px-4">
                        <i class="fa fa-save me-1"></i>Save
                    </button>
                    <a href="<%=ctx%>/customer/changePassword" class="btn btn-warning rounded-pill px-4">
                        <i class="fa fa-key me-1"></i>Change Password
                    </a>
                    <a href="<%=ctx%>/home" class="btn btn-secondary rounded-pill px-4">
                        <i class="fa fa-arrow-left me-1"></i>Back
                    </a>
                </form>
            </div>
        </div>
    </div>
</section>

<%@include file="../common/customerFooter.jsp" %>
