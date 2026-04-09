<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Page Not Found – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<main class="error-page">
    <div class="error-content">
        <h1>404</h1>
        <h2>Page Not Found</h2>
        <p>The page you're looking for doesn't exist.</p>
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Go Home</a>
    </div>
</main>
</body>
</html>
