<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Dashboard – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="dashboard-header">
        <div>
            <h1>🏍️ Driver Dashboard</h1>
            <p>Welcome, <strong>${sessionScope.loggedInUser.fullName}</strong> &mdash;
               <span class="status-badge status-${driver.availabilityStatus.name().toLowerCase()}">
                   ${driver.availabilityStatus}
               </span>
            </p>
        </div>
    </div>

    <c:if test="${not empty param.updated}">
        <div class="alert alert-success">Delivery status updated successfully.</div>
    </c:if>

    <!-- Driver stats -->
    <div class="stats-row">
        <div class="stat-card">
            <span class="stat-card-number">${driver.totalDeliveries}</span>
            <span class="stat-card-label">Total Deliveries</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${driver.rating} ★</span>
            <span class="stat-card-label">Rating</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${driver.vehicleType}</span>
            <span class="stat-card-label">Vehicle</span>
        </div>
    </div>

    <!-- Active deliveries -->
    <section class="table-section">
        <h2>My Deliveries</h2>
        <c:choose>
            <c:when test="${empty deliveries}">
                <div class="empty-state">
                    <p>No deliveries assigned yet. Make sure your status is set to AVAILABLE.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Tracking #</th>
                                <th>Status</th>
                                <th>Assigned</th>
                                <th>Picked Up</th>
                                <th>Delivered</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="d" items="${deliveries}">
                                <tr>
                                    <td><code>${d.trackingNumber}</code></td>
                                    <td>
                                        <span class="status-badge status-${d.status.name().toLowerCase()}">
                                            ${d.status}
                                        </span>
                                    </td>
                                    <td><fmt:formatDate value="${d.assignedAt}" pattern="dd MMM HH:mm"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty d.pickedUpAt}">
                                                <fmt:formatDate value="${d.pickedUpAt}" pattern="dd MMM HH:mm"/>
                                            </c:when>
                                            <c:otherwise>–</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty d.deliveredAt}">
                                                <fmt:formatDate value="${d.deliveredAt}" pattern="dd MMM HH:mm"/>
                                            </c:when>
                                            <c:otherwise>–</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="action-cell">
                                        <c:if test="${d.status == 'ASSIGNED'}">
                                            <form action="${pageContext.request.contextPath}/driver/dashboard"
                                                  method="post" class="inline-form">
                                                <input type="hidden" name="deliveryId" value="${d.id}">
                                                <input type="hidden" name="action" value="pickup">
                                                <button class="btn btn-sm btn-success">Mark Picked Up</button>
                                            </form>
                                        </c:if>
                                        <c:if test="${d.status == 'PICKED_UP' or d.status == 'IN_TRANSIT'}">
                                            <form action="${pageContext.request.contextPath}/driver/dashboard"
                                                  method="post" class="inline-form">
                                                <input type="hidden" name="deliveryId" value="${d.id}">
                                                <input type="hidden" name="action" value="deliver">
                                                <button class="btn btn-sm btn-primary">Mark Delivered</button>
                                            </form>
                                            <form action="${pageContext.request.contextPath}/driver/dashboard"
                                                  method="post" class="inline-form">
                                                <input type="hidden" name="deliveryId" value="${d.id}">
                                                <input type="hidden" name="action" value="fail">
                                                <button class="btn btn-sm btn-danger">Report Failed</button>
                                            </form>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/track?number=${d.trackingNumber}"
                                           class="btn btn-sm">View Tracking</a>
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
