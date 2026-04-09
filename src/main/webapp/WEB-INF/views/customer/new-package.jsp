<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send a Package – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="page-header-row">
        <h1>📦 Send a Package</h1>
        <a href="${pageContext.request.contextPath}/customer/dashboard" class="btn btn-outline">
            ← Back to Dashboard
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">${errorMessage}</div>
    </c:if>

    <div class="form-card">
        <form action="${pageContext.request.contextPath}/customer/packages"
              method="post" id="newPackageForm" novalidate>

            <h2 class="form-section-title">📍 Pickup &amp; Delivery</h2>
            <div class="form-group">
                <label for="pickupAddress">Pickup Address *</label>
                <input type="text" id="pickupAddress" name="pickupAddress" required
                       placeholder="123 Main Street, New York, NY 10001">
            </div>
            <div class="form-group">
                <label for="deliveryAddress">Delivery Address *</label>
                <input type="text" id="deliveryAddress" name="deliveryAddress" required
                       placeholder="456 Park Avenue, New York, NY 10022">
            </div>

            <h2 class="form-section-title">👤 Recipient</h2>
            <div class="form-row">
                <div class="form-group">
                    <label for="recipientName">Recipient Full Name *</label>
                    <input type="text" id="recipientName" name="recipientName" required
                           placeholder="Jane Smith">
                </div>
                <div class="form-group">
                    <label for="recipientPhone">Recipient Phone</label>
                    <input type="tel" id="recipientPhone" name="recipientPhone"
                           placeholder="+1 555-0199">
                </div>
            </div>

            <h2 class="form-section-title">📋 Package Details</h2>
            <div class="form-row">
                <div class="form-group">
                    <label for="description">Description</label>
                    <input type="text" id="description" name="description"
                           placeholder="e.g. Laptop bag, Birthday gift...">
                </div>
                <div class="form-group">
                    <label for="weight">Estimated Weight (kg)</label>
                    <input type="number" id="weight" name="weight"
                           min="0.1" step="0.1" placeholder="1.5">
                </div>
            </div>

            <div class="price-estimate" id="priceEstimate">
                Estimated price: <strong id="priceDisplay">$5.00</strong>
                <span class="price-note">(Base $5.00 + $3.50/kg)</span>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary btn-lg">Submit Package Request</button>
                <a href="${pageContext.request.contextPath}/customer/dashboard"
                   class="btn btn-outline">Cancel</a>
            </div>
        </form>
    </div>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
