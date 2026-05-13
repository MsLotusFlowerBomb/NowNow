<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="auth-page">
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="auth-container">
    <div class="auth-card auth-card-wide">
        <div class="auth-header">
            <h1>🚀 Create Account</h1>
            <p>Join NowNow to start sending and tracking packages</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">${errorMessage}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="post"
              class="auth-form" id="registerForm" novalidate>

            <div class="form-row">
                <div class="form-group">
                    <label for="fullName">Full Name *</label>
                    <input type="text" id="fullName" name="fullName" required
                           placeholder="Jane Doe" autocomplete="name">
                </div>
                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="tel" id="phone" name="phone"
                           placeholder="+27 12 345 6789" autocomplete="tel">
                </div>
            </div>

            <div class="form-group">
                <label for="email">Email Address *</label>
                <input type="email" id="email" name="email" required
                       placeholder="exampe@gmail.com" autocomplete="email">
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="password">Password * (min 8 chars)</label>
                    <input type="password" id="password" name="password" required
                           minlength="8" placeholder="••••••••" autocomplete="new-password">
                </div>
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required
                           placeholder="••••••••" autocomplete="new-password">
                </div>
            </div>

            <div class="form-group">
                <label>Account Type *</label>
                <div class="role-selector">
                    <label class="role-option">
                        <input type="radio" name="role" value="CUSTOMER" checked>
                        <span class="role-card">
                            <span class="role-icon">📦</span>
                            <span class="role-name">Customer</span>
                            <span class="role-desc">Send &amp; track packages</span>
                        </span>
                    </label>
                    <label class="role-option">
                        <input type="radio" name="role" value="DRIVER" id="driverRadio">
                        <span class="role-card">
                            <span class="role-icon">🏍️</span>
                            <span class="role-name">Driver</span>
                            <span class="role-desc">Deliver packages &amp; earn</span>
                        </span>
                    </label>
                </div>
            </div>

            <!-- Driver-only fields -->
            <div class="form-section driver-fields" id="driverFields" style="display:none">
                <h3>Driver Details</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label for="vehicleType">Vehicle Type</label>
                        <select id="vehicleType" name="vehicleType">
                            <option value="BICYCLE">Bicycle</option>
                            <option value="MOTORBIKE" selected>Motorbike</option>
                            <option value="CAR">Car</option>
                            <option value="VAN">Van</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="licenseNumber">License Number</label>
                        <input type="text" id="licenseNumber" name="licenseNumber"
                               placeholder="DL-XXXXX">
                    </div>
                </div>
            </div>

            <button type="submit" class="btn btn-primary btn-full">Create Account</button>
        </form>

        <p class="auth-footer-text">
            Already have an account?
            <a href="${pageContext.request.contextPath}/login">Sign in</a>
        </p>
    </div>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
