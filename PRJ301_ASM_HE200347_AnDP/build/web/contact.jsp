<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%
    request.setAttribute("pageTitle", "Contact Us - Electro");

    String ctx = request.getContextPath();

    // Preserve form values on error
    String nameVal    = request.getParameter("name")    != null ? request.getParameter("name")    : "";
    String emailVal   = request.getParameter("email")   != null ? request.getParameter("email")   : "";
    String subjectVal = request.getParameter("subject") != null ? request.getParameter("subject") : "";
    String msgVal     = request.getParameter("message") != null ? request.getParameter("message") : "";

    String success = (String) request.getAttribute("success");
    String error   = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Contact Us - Electro</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.4/css/all.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/style.css">
    <link rel="stylesheet" href="<%=ctx%>/assets/css/contact.css">
</head>
<body>

<%@include file="common/customerHeader.jsp" %>

<div class="contact-wrap">
    <div class="container">
        <div class="contact-card mx-auto d-flex">

            <!-- Left: info panel -->
            <div class="contact-side d-none d-md-flex flex-column justify-content-center">
                <h2><i class="fas fa-headset me-2"></i>Electro</h2>
                <p>Have a question or need help? Our team is here to assist you with any inquiries.</p>
                <div class="contact-info-list">
                    <div class="contact-info-row">
                        <div class="contact-info-icon"><i class="fas fa-map-marker-alt"></i></div>
                        <div>
                            <strong>Our Address</strong>
                            <span>123 Electro Street, District 1,<br>Ho Chi Minh City, Vietnam</span>
                        </div>
                    </div>
                    <div class="contact-info-row">
                        <div class="contact-info-icon"><i class="fas fa-phone-alt"></i></div>
                        <div>
                            <strong>Hotline</strong>
                            <span>(+84) 123 456 789</span>
                        </div>
                    </div>
                    <div class="contact-info-row">
                        <div class="contact-info-icon"><i class="fas fa-envelope"></i></div>
                        <div>
                            <strong>Email</strong>
                            <span>thieuducdung254@gmail.com</span>
                        </div>
                    </div>
                    <div class="contact-info-row">
                        <div class="contact-info-icon"><i class="fas fa-clock"></i></div>
                        <div>
                            <strong>Working Hours</strong>
                            <span>Mon - Sat: 8:00 AM - 9:00 PM<br>Sunday: 9:00 AM - 6:00 PM</span>
                        </div>
                    </div>
                </div>
                <div class="contact-social mt-4">
                    <a href="#" class="contact-social-btn"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="contact-social-btn"><i class="fab fa-instagram"></i></a>
                    <a href="#" class="contact-social-btn"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="contact-social-btn"><i class="fab fa-youtube"></i></a>
                </div>
            </div>

            <!-- Right: form panel -->
            <div class="contact-form-side">
                <h3>Get In Touch</h3>
                <p class="subtitle">Fill out the form and we'll get back to you within 24 hours.</p>

                <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i><%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>
                <% if (success != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i><%= success %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <form action="<%=ctx%>/contact" method="post" novalidate>

                    <div class="form-floating mb-3">
                        <input type="text" class="form-control" id="name" name="name"
                               placeholder="Nguyen Van A" value="<%= nameVal %>"
                               required>
                        <label for="name"><i class="fas fa-user me-2 text-muted"></i>Full Name</label>
                    </div>

                    <div class="form-floating mb-3">
                        <input type="email" class="form-control" id="email" name="email"
                               placeholder="name@example.com" value="<%= emailVal %>"
                               required>
                        <label for="email"><i class="fas fa-envelope me-2 text-muted"></i>Email Address</label>
                    </div>

                    <div class="mb-3 position-relative">
                        <label class="form-label">Subject</label>
                        <select class="form-select" name="subject" required>
                            <option value="">-- Choose a topic --</option>
                            <option value="Order Inquiry"     <%= "Order Inquiry".equals(subjectVal)    ? "selected" : "" %>>Order Inquiry</option>
                            <option value="Product Question"  <%= "Product Question".equals(subjectVal)  ? "selected" : "" %>>Product Question</option>
                            <option value="Technical Support" <%= "Technical Support".equals(subjectVal) ? "selected" : "" %>>Technical Support</option>
                            <option value="Return & Refund"   <%= "Return & Refund".equals(subjectVal)   ? "selected" : "" %>>Return & Refund</option>
                            <option value="Feedback"          <%= "Feedback".equals(subjectVal)          ? "selected" : "" %>>Feedback</option>
                            <option value="Other"            <%= "Other".equals(subjectVal)            ? "selected" : "" %>>Other</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Message</label>
                        <textarea class="form-control" name="message" rows="5"
                                  placeholder="Describe your question or issue..." required><%= msgVal %></textarea>
                    </div>

                    <button type="submit" class="btn btn-contact w-100">
                        <i class="fas fa-paper-plane me-2"></i>Send Message
                    </button>

                    <div class="contact-divider"><span>OR</span></div>

                    <a href="<%=ctx%>/home" class="btn btn-outline-ecom w-100">
                        <i class="fas fa-arrow-left me-2"></i>Back to Home
                    </a>

                </form>
            </div>

        </div>
    </div>
</div>

<%@include file="common/customerFooter.jsp" %>

</body>
</html>
