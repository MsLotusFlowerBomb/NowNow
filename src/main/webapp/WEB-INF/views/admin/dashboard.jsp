<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <h1>⚙️ Admin Dashboard</h1>

    <c:if test="${not empty param.assigned}">
        <div class="alert alert-success">Package successfully assigned to driver.</div>
    </c:if>

    <!-- System stats -->
    <div class="stats-row">
        <div class="stat-card">
            <span class="stat-card-number">${allPackages.size()}</span>
            <span class="stat-card-label">Total Packages</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${pendingPackages.size()}</span>
            <span class="stat-card-label">Pending Assignment</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${allDrivers.size()}</span>
            <span class="stat-card-label">Registered Drivers</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${availableDrivers.size()}</span>
            <span class="stat-card-label">Available Drivers</span>
        </div>
    </div>

    <!-- Assign Package Section -->
    <c:if test="${not empty pendingPackages and not empty availableDrivers}">
    <section class="form-card">
        <h2>📋 Assign a Package to a Driver</h2>
        <form action="${pageContext.request.contextPath}/admin/dashboard" method="post">
            <input type="hidden" name="action" value="assign">
            <div class="form-row">
                <div class="form-group">
                    <label for="packageId">Pending Package</label>
                    <select id="packageId" name="packageId" required>
                        <option value="">-- Select Package --</option>
                        <c:forEach var="pkg" items="${pendingPackages}">
                            <option value="${pkg.id}">
                                ${pkg.trackingNumber} → ${pkg.recipientName} (${pkg.deliveryAddress})
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label for="driverId">Available Driver</label>
                    <select id="driverId" name="driverId" required>
                        <option value="">-- Select Driver --</option>
                        <c:forEach var="drv" items="${availableDrivers}">
                            <option value="${drv.id}">
                                ${drv.driverFullName} (${drv.vehicleType}, ★ ${drv.rating})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Assign Driver</button>
        </form>
    </section>
    </c:if>

    <!-- All Packages -->
    <section class="table-section">
        <h2>All Packages</h2>
        <div class="table-wrapper">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Tracking #</th>
                        <th>Sender</th>
                        <th>Recipient</th>
                        <th>Destination</th>
                        <th>Status</th>
                        <th>Created</th>
                        <th>Track</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="pkg" items="${allPackages}">
                        <tr>
                            <td><code>${pkg.trackingNumber}</code></td>
                            <td>${pkg.senderName}</td>
                            <td>${pkg.recipientName}</td>
                            <td>${pkg.deliveryAddress}</td>
                            <td>
                                <span class="status-badge status-${pkg.status.name().toLowerCase()}">
                                    ${pkg.status}
                                </span>
                            </td>
                            <td><fmt:formatDate value="${pkg.createdAt}" pattern="dd MMM yyyy"/></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/track?number=${pkg.trackingNumber}"
                                   class="btn btn-sm">Track</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </section>

    <!-- All Drivers -->
    <section class="table-section">
        <h2>All Drivers</h2>
        <div class="table-wrapper">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Vehicle</th>
                        <th>Status</th>
                        <th>Rating</th>
                        <th>Deliveries</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="drv" items="${allDrivers}">
                        <tr>
                            <td>${drv.driverFullName}</td>
                            <td>${drv.vehicleType}</td>
                            <td>
                                <span class="status-badge status-${drv.availabilityStatus.name().toLowerCase()}">
                                    ${drv.availabilityStatus}
                                </span>
                            </td>
                            <td>${drv.rating} ★</td>
                            <td>${drv.totalDeliveries}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </section>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
