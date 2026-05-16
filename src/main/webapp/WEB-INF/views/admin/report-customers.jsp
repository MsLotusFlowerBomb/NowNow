<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer History Report – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="dashboard-header">
        <div>
            <h1>👥 Customer Delivery History</h1>
            <p class="dashboard-sub">Per-customer package activity for ${rangeLabel}</p>
        </div>
        <div style="display:flex;gap:.6rem">
            <button class="btn btn-outline" onclick="exportCSV()">⬇ CSV</button>
            <button class="btn btn-primary" onclick="exportPDF()">⬇ PDF</button>
        </div>
    </div>

    <%-- Error --%>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">${errorMessage}</div>
    </c:if>

    <%-- Warnings --%>
    <c:if test="${not empty warnings}">
        <div class="alert alert-info">
            <c:forEach var="w" items="${warnings}"><p>${w}</p></c:forEach>
        </div>
    </c:if>

    <%-- Filters --%>
    <section class="form-card" style="max-width:900px;margin-bottom:1.5rem">
        <h2>Filters</h2>
        <p class="dashboard-sub">Filter by date range and/or a specific customer.</p>
        <form action="${pageContext.request.contextPath}/admin/reports/customers" method="get">
            <div class="form-row" style="grid-template-columns:1fr 1fr 1fr">
                <div class="form-group">
                    <label for="startDate">Start Date</label>
                    <input id="startDate" name="startDate" type="date" value="${startDate}">
                </div>
                <div class="form-group">
                    <label for="endDate">End Date</label>
                    <input id="endDate" name="endDate" type="date" value="${endDate}">
                </div>
                <div class="form-group">
                    <label for="customerEmail">Customer</label>
                    <select id="customerEmail" name="customerEmail">
                        <option value="">All customers</option>
                        <c:forEach var="c" items="${allCustomers}">
                            <option value="${c.email}"
                                ${customerFilter == c.email ? 'selected' : ''}>
                                ${c.fullName} (${c.email})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Apply Filters</button>
        </form>
    </section>

    <%-- Summary stats --%>
    <div class="stats-row">
        <div class="stat-card">
            <span class="stat-card-number">${rows.size()}</span>
            <span class="stat-card-label">Active Customers</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${totalPackages}</span>
            <span class="stat-card-label">Total Packages</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${totalDelivered}</span>
            <span class="stat-card-label">Total Delivered</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">R <fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/></span>
            <span class="stat-card-label">Total Revenue</span>
        </div>
    </div>

    <%-- Table --%>
    <section class="table-section">
        <c:choose>
            <c:when test="${empty rows}">
                <div class="empty-state">
                    <p>No customer activity found for the selected filters. Try adjusting the date range.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-wrapper">
                    <table class="data-table" id="reportTable">
                        <thead>
                            <tr>
                                <th>Customer</th>
                                <th>Email</th>
                                <th>Total Packages</th>
                                <th>Delivered</th>
                                <th>In Progress</th>
                                <th>Pending</th>
                                <th>Cancelled</th>
                                <th>Total Spent (R)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="row" items="${rows}">
                                <tr>
                                    <td>${row.customerName}</td>
                                    <td>${row.email}</td>
                                    <td>${row.totalPackages}</td>
                                    <td>
                                        <span class="status-badge status-delivered">${row.delivered}</span>
                                    </td>
                                    <td>
                                        <span class="status-badge status-in_transit">${row.inTransit}</span>
                                    </td>
                                    <td>
                                        <span class="status-badge status-pending">${row.pending}</span>
                                    </td>
                                    <td>
                                        <span class="status-badge status-cancelled">${row.cancelled}</span>
                                    </td>
                                    <td>R <fmt:formatNumber value="${row.totalSpent}" pattern="#,##0.00"/></td>
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
<script>
    function getTableData() {
        var t = document.getElementById('reportTable');
        var r = { headers: [], rows: [] };
        if (!t) return r;
        t.querySelectorAll('thead th').forEach(function(th){ r.headers.push(th.textContent.trim()); });
        t.querySelectorAll('tbody tr').forEach(function(tr){
            var row = [];
            tr.querySelectorAll('td').forEach(function(td){ row.push(td.textContent.trim()); });
            r.rows.push(row);
        });
        return r;
    }
    function today(){ return new Date().toISOString().slice(0,10).replace(/-/g,''); }

    function exportCSV() {
        var d = getTableData();
        var lines = [
            '"NowNow – Customer Delivery History Report"',
            '"${rangeLabel}"',
            '"Active Customers","${rows.size()}"',
            '"Total Packages","${totalPackages}"',
            '"Total Delivered","${totalDelivered}"',
            '"Total Revenue","R ${totalRevenue}"',
            ''
        ];
        lines.push(d.headers.map(function(h){ return '"'+h.replace(/"/g,'""')+'"'; }).join(','));
        d.rows.forEach(function(r){ lines.push(r.map(function(c){ return '"'+String(c).replace(/"/g,'""')+'"'; }).join(',')); });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(new Blob([lines.join('\r\n')], {type:'text/csv'}));
        a.download = 'customer_history_report_'+today()+'.csv';
        a.click();
    }

    function exportPDF() {
        var d = getTableData();
        var { jsPDF } = window.jspdf;
        var doc = new jsPDF({orientation:'landscape', unit:'mm', format:'a4'});
        var m = 14, y = 18;
        doc.setFontSize(15); doc.setFont('helvetica','bold');
        doc.text('NowNow – Customer Delivery History Report', m, y); y += 7;
        doc.setFontSize(9); doc.setFont('helvetica','normal'); doc.setTextColor(100);
        doc.text('${rangeLabel}', m, y); y += 6;
        doc.text('Customers: ${rows.size()}   |   Packages: ${totalPackages}   |   Delivered: ${totalDelivered}   |   Revenue: R ${totalRevenue}', m, y); y += 8;
        doc.setTextColor(0);
        if (d.headers.length) {
            doc.autoTable({ head:[d.headers], body:d.rows, startY:y,
                margin:{left:m,right:m}, styles:{fontSize:7.5},
                headStyles:{fillColor:[44,62,80],textColor:255}, theme:'grid',
                alternateRowStyles:{fillColor:[248,249,250]} });
        }
        var pc = doc.internal.getNumberOfPages();
        for(var p=1;p<=pc;p++){
            doc.setPage(p); doc.setFontSize(7); doc.setTextColor(150);
            doc.text('Generated: '+new Date().toLocaleString()+'   Page '+p+' of '+pc,
                m, doc.internal.pageSize.getHeight()-6);
        }
        doc.save('customer_history_report_'+today()+'.pdf');
    }
</script>
</body>
</html>
