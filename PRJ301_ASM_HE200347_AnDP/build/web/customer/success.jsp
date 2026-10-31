<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    request.setAttribute("pageTitle", "Order Success - Electro");
    request.setAttribute("active", "");
    String ctx = request.getContextPath();
%>
<%@include file="../common/customerHeader.jsp" %>

<section class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8 col-lg-6">
            <div class="text-center bg-white p-5 rounded-3 shadow-sm">
                <i class="fa fa-check-circle text-success" style="font-size:5rem;"></i>
                <h2 class="mt-3 text-success">${message}</h2>
                <p class="text-muted">Thank you for your purchase!</p>
                <a href="<%=ctx%>/home" class="btn btn-primary rounded-pill px-4 mt-3">
                    <i class="fa fa-shopping-bag me-1"></i>Continue Shopping
                </a>
                <a href="<%=ctx%>/customer/orders" class="btn btn-outline-secondary rounded-pill px-4 mt-3">
                    <i class="fa fa-list me-1"></i>View My Orders
                </a>
            </div>
        </div>
    </div>
</section>

<%@include file="../common/customerFooter.jsp" %>
