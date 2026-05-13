<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NowNow | Business Reports</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-container">
    <header class="report-header">
        <h1>Operational Reports</h1>
        <p class="subtitle">System performance and delivery metrics</p>
    </header>

    <section class="stats-overview">
        <div class="stat-card">
            <h3>Total Revenue</h3>
            <p class="stat-value">$4,250.00</p>
        </div>
        <div class="stat-card">
            <h3>Success Rate</h3>
            <p class="stat-value">94%</p>
        </div>
    </section>

    <section class="report-section">
        <h2>Driver Performance Summary</h2>
        <table class="report-table">
            <thead>
                <tr>
                    <th>Driver Name</th>
                    <th>Vehicle</th>
                    <th>Total Deliveries</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%-- This data would usually come from your DriverDAO --%>
                <tr>
                    <td>Dan Delivery</td>
                    <td>Motorbike</td>
                    <td>42</td>
                    <td><span class="badge available">Active</span></td>
                </tr>
                <tr>
                    <td>Eve Express</td>
                    <td>Van</td>
                    <td>28</td>
                    <td><span class="badge busy">On Delivery</span></td>
                </tr>
            </tbody>
        </table>
    </section>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
</body>
</html>