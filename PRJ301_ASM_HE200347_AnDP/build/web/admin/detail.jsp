<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="dao.ProductDAO"%>
<%@page import="model.Product"%>

<%
Product p = (Product) request.getAttribute("product");
String mainImage = new ProductDAO().getMainImage(p.getProductID());
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Product Detail</title>
</head>
<body>

<h2>Product Detail</h2>
<hr>

<h3><%=p.getProductName()%></h3>

<p>Price : <b>$ <%=p.getPrice()%></b></p>
<p>Quantity : <%=p.getQuantity()%></p>
<p>Description : <%=p.getDescription()%></p>

<p>Image :
<%
if (mainImage != null && !mainImage.isEmpty()) {
%>
    <img src="<%=mainImage%>" style="max-width:240px;max-height:160px;">
<%
} else {
%>
    -
<%
}
%>
</p>

<p>Status : <%=p.isStatus() ? "Active" : "Inactive"%></p>

<br>

<a href="<%=request.getContextPath()%>/customer/addCart?id=<%=p.getProductID()%>">Add To Cart</a> |
<a href="<%=request.getContextPath()%>/home">Back</a>

</body>
</html>