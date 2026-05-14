<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body class="auth-page">
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <h1>🚀 Welcome Back</h1>
            <p>Sign in to your NowNow account</p>
        </div>

        <c:choose>
            <c:when test="${not empty errorMessage}">
                <div id="loginError" class="alert alert-error">${errorMessage}</div>
            </c:when>
            <c:otherwise>
                <div id="loginError" class="alert alert-error" hidden></div>
            </c:otherwise>
        </c:choose>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">${successMessage}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post" class="auth-form" id="loginForm" novalidate>
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" required
                       placeholder="example@gmail.com" autocomplete="email">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required
                       placeholder="••••••••" autocomplete="current-password">
            </div>
            <button type="submit" class="btn btn-primary btn-full">Sign In</button>
        </form>

        <p class="auth-footer-text">
            Don't have an account?
            <a href="${pageContext.request.contextPath}/register">Create one</a>
        </p>
        <p class="auth-footer-text">
            <a href="${pageContext.request.contextPath}/track">Track a package without logging in</a>
        </p>
    </div>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
