<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="nav-brand">
        <span class="brand-icon">🚀</span> NowNow
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/track">Track Package</a>
        
        <c:choose>
            <c:when test="${not empty sessionScope.loggedInUser}">
                <c:choose>
                    <c:when test="${sessionScope.loggedInUser.role.name() == 'ADMIN'}">
                        <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
                        <a href="${pageContext.request.contextPath}/admin/reports">Business Reports</a>
                    </c:when>
                    <c:when test="${sessionScope.loggedInUser.role == 'DRIVER'}">
                        <a href="${pageContext.request.contextPath}/driver/dashboard">Dashboard</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/customer/dashboard">Dashboard</a>
                    </c:otherwise>
                </c:choose>
                
                <span class="nav-user">👤 ${sessionScope.loggedInUser.fullName}</span>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm">Logout</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/login">Login</a>
                <a href="${pageContext.request.contextPath}/register" class="btn btn-sm btn-primary">Sign Up</a>
            </c:otherwise>
        </c:choose>
    </div>
</nav>