<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    String ctx = request.getContextPath();
    String orderId  = request.getParameter("orderId");
    String amount   = request.getParameter("amount");
    if (orderId == null) orderId = "";
    if (amount  == null) amount  = "0";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VNPay Payment - Electro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/vnpay.css">
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
</head>
<body>

<%@include file="../common/customerHeader.jsp" %>

<div class="vnpay-wrap">
    <div class="container">
        <div class="vnpay-card mx-auto">

            <div class="vnpay-side d-none d-md-flex">
                <h2><i class="fas fa-shield-alt me-2"></i>VNPay</h2>
                <p>Thanh toán trực tuyến an toàn với cổng VNPay. Hỗ trợ QR, thẻ ATM nội địa và thẻ quốc tế.</p>
                <div class="features">
                    <div><i class="fas fa-lock"></i> Mã hoá chuẩn quốc tế</div>
                    <div><i class="fas fa-bolt"></i> Xử lý tức thì</div>
                    <div><i class="fas fa-undo"></i> Hoàn tiền nhanh chóng</div>
                    <div><i class="fas fa-headset"></i> Hỗ trợ 24/7</div>
                </div>
            </div>

            <div class="vnpay-form-side">
                <h3>Thanh toán đơn hàng #<%= orderId %></h3>
                <p class="subtitle">Số tiền cần thanh toán</p>
                <div class="vnpay-amount"><%= String.format("%,d", Long.parseLong(amount)) %> VND</div>

                <form id="frmCreateOrder" action="<%=ctx%>/vnpay/create" method="post">

                    <input type="hidden" name="amount"   value="<%= amount %>">
                    <input type="hidden" name="orderId"  value="<%= orderId %>">
                    <input type="hidden" name="orderInfo" value="Thanh toan don hang: <%= orderId %>">

                    <h5 class="vnpay-section-title">Chọn phương thức thanh toán</h5>

                    <label class="vnpay-bank-opt">
                        <input type="radio" name="bankCode" value="" checked>
                        <span><i class="fas fa-globe me-2"></i>Cổng VNPAYQR (mặc định)</span>
                    </label>
                    <label class="vnpay-bank-opt">
                        <input type="radio" name="bankCode" value="VNPAYQR">
                        <span><i class="fas fa-qrcode me-2"></i>Thanh toán bằng ứng dụng hỗ trợ VNPAYQR</span>
                    </label>
                    <label class="vnpay-bank-opt">
                        <input type="radio" name="bankCode" value="VNBANK">
                        <span><i class="fas fa-credit-card me-2"></i>Thẻ ATM / Tài khoản nội địa</span>
                    </label>
                    <label class="vnpay-bank-opt">
                        <input type="radio" name="bankCode" value="INTCARD">
                        <span><i class="fab fa-cc-visa me-2"></i>Thẻ quốc tế (Visa, Master, JCB...)</span>
                    </label>

                    <h5 class="vnpay-section-title mt-4">Ngôn ngữ</h5>
                    <label class="vnpay-lang-opt">
                        <input type="radio" name="language" value="vn" checked>
                        <span>Tiếng Việt</span>
                    </label>
                    <label class="vnpay-lang-opt">
                        <input type="radio" name="language" value="en">
                        <span>English</span>
                    </label>

                    <button type="submit" class="btn btn-vnpay mt-4">
                        <i class="fas fa-paper-plane me-2"></i>Thanh toán ngay
                    </button>

                    <a href="<%=ctx%>/customer/cart" class="btn vnpay-back-btn w-100 mt-2">
                        <i class="fas fa-arrow-left me-2"></i>Quay lại giỏ hàng
                    </a>
                </form>
            </div>

        </div>
    </div>
</div>

<%@include file="../common/customerFooter.jsp" %>

<link href="https://pay.vnpay.vn/lib/vnpay/vnpay.css" rel="stylesheet" />
<script src="https://pay.vnpay.vn/lib/vnpay/vnpay.min.js"></script>
<script>
    $("#frmCreateOrder").submit(function () {
        var postData  = $("#frmCreateOrder").serialize();
        var submitUrl = $("#frmCreateOrder").attr("action");
        $.ajax({
            type: "POST",
            url: submitUrl,
            data: postData,
            dataType: 'JSON',
            success: function (x) {
                if (x.code === '00') {
                    if (window.vnpay) {
                        vnpay.open({width: 768, height: 600, url: x.data});
                    } else {
                        location.href = x.data;
                    }
                    return false;
                } else {
                    alert(x.message);
                }
            },
            error: function () {
                alert('Không thể kết nối tới cổng thanh toán. Vui lòng thử lại.');
            }
        });
        return false;
    });
</script>

</body>
</html>