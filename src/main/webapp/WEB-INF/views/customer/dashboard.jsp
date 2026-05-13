<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="dashboard-header">
        <div>
            <h1>👋 Hello, ${sessionScope.loggedInUser.fullName}</h1>
            <p class="dashboard-sub">Here's an overview of your packages.</p>
        </div>
        <a href="${pageContext.request.contextPath}/customer/packages/new"
           class="btn btn-primary">+ Send a Package</a>
    </div>

    <c:if test="${not empty param.created}">
        <div class="alert alert-success">
            Package created! Tracking number: <strong>${param.created}</strong>
        </div>
    </c:if>

    <!-- Stats summary -->
    <div class="stats-row">
        <div class="stat-card">
            <span class="stat-card-number">${packages.size()}</span>
            <span class="stat-card-label">Total Packages</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">
                <c:set var="inTransitCount" value="0"/>
                <c:forEach var="p" items="${packages}">
                    <c:if test="${p.status == 'IN_TRANSIT' or p.status == 'PICKED_UP'}">
                        <c:set var="inTransitCount" value="${inTransitCount + 1}"/>
                    </c:if>
                </c:forEach>
                ${inTransitCount}
            </span>
            <span class="stat-card-label">In Transit</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">
                <c:set var="deliveredCount" value="0"/>
                <c:forEach var="p" items="${packages}">
                    <c:if test="${p.status == 'DELIVERED'}">
                        <c:set var="deliveredCount" value="${deliveredCount + 1}"/>
                    </c:if>
                </c:forEach>
                ${deliveredCount}
            </span>
            <span class="stat-card-label">Delivered</span>
        </div>
    </div>

    <!-- Package list -->
    <section class="table-section">
        <h2>My Packages</h2>
        <c:choose>
            <c:when test="${empty packages}">
                <div class="empty-state">
                    <p>You haven't sent any packages yet.</p>
                    <a href="${pageContext.request.contextPath}/customer/packages/new"
                       class="btn btn-primary">Send Your First Package</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Tracking #</th>
                                <th>Recipient</th>
                                <th>Destination</th>
                                <th>Status</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="pkg" items="${packages}">
                                <tr>
                                    <td><code>${pkg.trackingNumber}</code></td>
                                    <td>${pkg.recipientName}</td>
                                    <td>${pkg.deliveryAddress}</td>
                                    <td>
                                        <span class="status-badge status-${pkg.status.name().toLowerCase()}">
                                            ${pkg.status}
                                        </span>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${pkg.createdAt}" pattern="dd MMM yyyy"/>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/track?number=${pkg.trackingNumber}"
                                           class="btn btn-sm">Track</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
