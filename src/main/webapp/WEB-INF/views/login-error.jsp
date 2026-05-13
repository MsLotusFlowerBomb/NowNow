<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<title>Login Failed – NowNow</title>
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
				<div class="alert alert-error">Invalid email or password. Please try again.</div>
				<form action="j_security_check" method="post" class="auth-form" novalidate>
					<div class="form-group">
						<label for="j_username">Email Address</label>
						<input type="email" id="j_username" name="j_username" required
						       placeholder="you@example.com" autocomplete="email">
					</div>
					<div class="form-group">
						<label for="j_password">Password</label>
						<input type="password" id="j_password" name="j_password" required
						       placeholder="••••••••" autocomplete="current-password">
					</div>
					<button type="submit" class="btn btn-primary btn-full">Sign In</button>
				</form>
				<p class="auth-footer-text">
					Don't have an account?
					<a href="${pageContext.request.contextPath}/register">Create one</a>
				</p>
			</div>
		</main>
		<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
	</body>
</html>