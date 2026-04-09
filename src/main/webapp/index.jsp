<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NowNow – Fast Package Delivery</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<section class="hero">
    <div class="hero-content">
        <h1>Deliver Anything, <span class="highlight">Anywhere</span></h1>
        <p class="hero-sub">NowNow connects senders with nearby drivers for same-day package delivery.</p>
        <div class="hero-actions">
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Get Started</a>
            <a href="${pageContext.request.contextPath}/track"    class="btn btn-outline">Track a Package</a>
        </div>
    </div>
    <div class="hero-illustration">
        <div class="delivery-animation">
            <div class="package-icon">📦</div>
            <div class="arrow-icon">➡️</div>
            <div class="driver-icon">🏍️</div>
            <div class="arrow-icon">➡️</div>
            <div class="home-icon">🏠</div>
        </div>
    </div>
</section>

<section class="features" id="how-it-works">
    <h2 class="section-title">How It Works</h2>
    <div class="features-grid">
        <div class="feature-card">
            <div class="feature-icon">📋</div>
            <h3>1. Send a Package</h3>
            <p>Log in as a customer, fill in the pickup and delivery details, and submit your request.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">🔍</div>
            <h3>2. Driver Assigned</h3>
            <p>Our system automatically matches your package with the nearest available driver.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">📍</div>
            <h3>3. Real-time Tracking</h3>
            <p>Track your package at every step using your unique tracking number.</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">✅</div>
            <h3>4. Delivered!</h3>
            <p>Your package arrives safely. Rate your delivery experience.</p>
        </div>
    </div>
</section>

<section class="stats-bar">
    <div class="stat">
        <span class="stat-number">5,000+</span>
        <span class="stat-label">Deliveries Made</span>
    </div>
    <div class="stat">
        <span class="stat-number">200+</span>
        <span class="stat-label">Active Drivers</span>
    </div>
    <div class="stat">
        <span class="stat-number">98%</span>
        <span class="stat-label">On-time Rate</span>
    </div>
    <div class="stat">
        <span class="stat-number">4.9 ★</span>
        <span class="stat-label">Average Rating</span>
    </div>
</section>

<section class="cta-section">
    <h2>Ready to ship your first package?</h2>
    <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-lg">Create an Account</a>
    <p>Already have an account? <a href="${pageContext.request.contextPath}/login">Sign in</a></p>
</section>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
