<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Track Your Package – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <h1 class="page-title">📍 Track Your Package</h1>

    <form action="${pageContext.request.contextPath}/track" method="get" class="track-form">
        <div class="track-input-group">
            <input type="text" name="number"
                   value="${param.number}"
                   placeholder="Enter tracking number  e.g. NN-20240313-A3F9C21B"
                   class="track-input" required>
            <button type="submit" class="btn btn-primary">Track</button>
        </div>
    </form>

    <!-- Not found message -->
    <c:if test="${notFound}">
        <div class="alert alert-error">
            No package found with tracking number <strong>${param.number}</strong>.
            Please check the number and try again.
        </div>
    </c:if>

    <!-- Package found -->
    <c:if test="${not empty pkg}">
        <div class="tracking-card">
            <div class="tracking-header">
                <div>
                    <h2>${pkg.trackingNumber}</h2>
                    <p class="tracking-sub">Recipient: <strong>${pkg.recipientName}</strong></p>
                </div>
                <span class="status-badge status-${pkg.status.name().toLowerCase()}">${pkg.status}</span>
            </div>

            <div class="tracking-addresses">
                <div class="address-item">
                    <span class="address-label">📦 From</span>
                    <span>${pkg.pickupAddress}</span>
                </div>
                <div class="address-arrow">→</div>
                <div class="address-item">
                    <span class="address-label">🏠 To</span>
                    <span>${pkg.deliveryAddress}</span>
                </div>
            </div>

            <!-- Timeline -->
            <h3 class="timeline-title">Tracking History</h3>
            <div class="timeline">
                <c:forEach var="event" items="${events}" varStatus="loop">
                    <div class="timeline-item ${loop.last ? 'timeline-current' : ''}">
                        <div class="timeline-dot"></div>
                        <div class="timeline-content">
                            <span class="timeline-status">${event.status}</span>
                            <p class="timeline-desc">${event.description}</p>
                            <time class="timeline-time">
                                <fmt:formatDate value="${event.eventTime}" pattern="dd MMM yyyy, HH:mm"/>
                            </time>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${empty events}">
                    <p>No tracking events yet.</p>
                </c:if>
            </div>
        </div>
    </c:if>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
