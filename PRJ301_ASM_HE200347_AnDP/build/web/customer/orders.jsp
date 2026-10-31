<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.Order"%>
<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    request.setAttribute("pageTitle", "My Orders - Electro");
    request.setAttribute("active", "orders");
    ArrayList<Order> list = (ArrayList<Order>) request.getAttribute("list");
    String ctx = request.getContextPath();
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi", "VN"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

    String flashOk  = (String) session.getAttribute("flash_ok");
    String flashErr = (String) session.getAttribute("flash_err");
    if (flashOk != null)  session.removeAttribute("flash_ok");
    if (flashErr != null) session.removeAttribute("flash_err");
%>
<%@include file="../common/customerHeader.jsp" %>

<link rel="stylesheet" href="<%=ctx%>/assets/css/orders.css">

<section class="container py-5">
    <h3 class="mb-4"><i class="fa fa-list me-2 text-primary"></i>My Orders</h3>

    <% if (flashOk != null) { %>
        <div class="alert alert-success rounded-pill px-3 py-2"><i class="fa fa-check-circle me-1"></i><%= flashOk %></div>
    <% } %>
    <% if (flashErr != null) { %>
        <div class="alert alert-danger rounded-pill px-3 py-2"><i class="fa fa-exclamation-circle me-1"></i><%= flashErr %></div>
    <% } %>

    <div class="orders-card">
        <% if (list == null || list.isEmpty()) { %>
            <p class="text-muted text-center py-4">You have no orders yet.</p>
        <% } else { %>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Order Date</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th class="text-end" style="width:140px;"></th>
                    </tr>
                </thead>
                <tbody>
                <%
                for (Order o : list) {
                    String st = o.getStatus() == null ? "" : o.getStatus().toLowerCase();
                    String cls = "status-pending";
                    if (st.contains("confirm")) cls = "status-confirmed";
                    else if (st.contains("ship") || st.contains("deliver")) cls = "status-shipping";
                    else if (st.contains("complet") || st.contains("done") || st.contains("success")) cls = "status-completed";
                    else if (st.contains("cancel") || st.contains("reject")) cls = "status-cancelled";
                %>
                    <tr>
                        <td>#<%=o.getOrderID()%></td>
                        <td><%= o.getOrderDate() != null ? sdf.format(o.getOrderDate()) : "" %></td>
                        <td><strong><%= nf.format(o.getTotalAmount()) %></strong> VND</td>
                        <td><span class="status-badge <%=cls%>"><%=o.getStatus()%></span></td>
                        <td class="text-end">
                            <a href="<%=ctx%>/customer/orders/detail?id=<%=o.getOrderID()%>"
                               class="btn btn-sm btn-outline-primary rounded-pill">
                                <i class="fa fa-eye me-1"></i>Chi tiết
                            </a>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
        <a href="<%=ctx%>/home" class="btn btn-secondary rounded-pill px-4">
            <i class="fa fa-arrow-left me-1"></i>Back Home
        </a>
    </div>
</section>

<%@include file="../common/customerFooter.jsp" %>