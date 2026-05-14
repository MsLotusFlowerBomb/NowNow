<%-- 
    In navbar.jsp, replace your existing ADMIN block:

        <a href=".../admin/dashboard">Dashboard</a>
        <a href=".../admin/reports">Business Reports</a>

    With this expanded version:
--%>
<a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
<a href="${pageContext.request.contextPath}/admin/reports">Summary Report</a>
<a href="${pageContext.request.contextPath}/admin/reports/packages">Packages Report</a>
<a href="${pageContext.request.contextPath}/admin/reports/deliveries">Delivery History</a>
<a href="${pageContext.request.contextPath}/admin/reports/drivers">Driver Activity</a>
