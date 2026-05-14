<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NowNow | Management Report</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="dashboard-header">
        <div>
            <h1>📊 Management Summary Report</h1>
            <p class="dashboard-sub">Operational performance overview for ${rangeLabel}</p>
        </div>
    </div>

    <c:if test="${not empty filterWarnings}">
        <div class="alert alert-info">
            <ul>
                <c:forEach var="warning" items="${filterWarnings}">
                    <li>${warning}</li>
                </c:forEach>
            </ul>
        </div>
    </c:if>

    <section class="form-card">
        <h2>Report Filters</h2>
        <p class="dashboard-sub">Defaults to the current month to simplify filter selection.</p>
        <form action="${pageContext.request.contextPath}/admin/reports" method="get">
            <div class="form-row">
                <div class="form-group">
                    <label for="startDate">Start date</label>
                    <input id="startDate" name="startDate" type="date" value="${startDate}" required>
                </div>
                <div class="form-group">
                    <label for="endDate">End date</label>
                    <input id="endDate" name="endDate" type="date" value="${endDate}" required>
                </div>
                <div class="form-group">
                    <label for="driverId">Driver</label>
                    <select id="driverId" name="driverId">
                        <option value="">All drivers</option>
                        <c:forEach var="driver" items="${drivers}">
                            <option value="${driver.id}" <c:if test="${driver.id == selectedDriverId}">selected</c:if>>
                                ${driver.driverFullName}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Apply Filters</button>
        </form>
    </section>

    <section class="stats-row">
        <div class="stat-card">
            <span class="stat-card-number">${totalAssigned}</span>
            <span class="stat-card-label">Total Assignments</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${deliveredCount}</span>
            <span class="stat-card-label">Delivered</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${failedCount}</span>
            <span class="stat-card-label">Failed</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${activeCount}</span>
            <span class="stat-card-label">Active</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${successRate}%</span>
            <span class="stat-card-label">Success Rate</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${revenueDisplay}</span>
            <span class="stat-card-label">Estimated Revenue</span>
        </div>
    </section>

    <section class="table-section">
        <h2>Individual Driver Performance</h2>
        <c:choose>
            <c:when test="${empty reportRows}">
                <div class="empty-state">
                    <p>No deliveries match the selected filters.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-wrapper">
                    <table class="data-table">
                        <thead>
                        <tr>
                            <th>Driver</th>
                            <th>Vehicle</th>
                            <th>Status</th>
                            <th>Total</th>
                            <th>Delivered</th>
                            <th>Failed</th>
                            <th>Active</th>
                            <th>Success Rate</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="row" items="${reportRows}">
                            <tr>
                                <td>${row.driverName}</td>
                                <td>${row.vehicleType}</td>
                                <td>
                                    <span class="status-badge status-${row.availabilityStatus.toLowerCase()}">
                                        ${row.availabilityStatus}
                                    </span>
                                </td>
                                <td>${row.totalAssigned}</td>
                                <td>${row.deliveredCount}</td>
                                <td>${row.failedCount}</td>
                                <td>${row.activeCount}</td>
                                <td>${row.successRate}%</td>
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
</body>
</html>
