<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery History Report – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="dashboard-header">
        <div>
            <h1>🚚 Delivery History Report</h1>
            <p class="dashboard-sub">Delivery records for ${rangeLabel}</p>
        </div>
        <div style="display:flex;gap:.6rem">
            <button class="btn btn-outline" onclick="exportCSV()">⬇ CSV</button>
            <button class="btn btn-primary" onclick="exportPDF()">⬇ PDF</button>
        </div>
    </div>

    <c:if test="${not empty warnings}">
        <div class="alert alert-info">
            <c:forEach var="w" items="${warnings}"><p>${w}</p></c:forEach>
        </div>
    </c:if>

    <!-- Filters -->
    <section class="form-card" style="max-width:900px;margin-bottom:1.5rem">
        <h2>Filters</h2>
        <p class="dashboard-sub">Defaults to the current month.</p>
        <form action="${pageContext.request.contextPath}/admin/reports/deliveries" method="get">
            <div class="form-row" style="grid-template-columns:1fr 1fr 1fr 1fr">
                <div class="form-group">
                    <label for="startDate">Start Date</label>
                    <input id="startDate" name="startDate" type="date" value="${startDate}">
                </div>
                <div class="form-group">
                    <label for="endDate">End Date</label>
                    <input id="endDate" name="endDate" type="date" value="${endDate}">
                </div>
                <div class="form-group">
                    <label for="status">Status</label>
                    <select id="status" name="status">
                        <option value="">All statuses</option>
                        <c:forEach var="s" items="${statuses}">
                            <option value="${s}" ${statusFilter == s.name() ? 'selected' : ''}>${s}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label for="driverId">Driver</label>
                    <select id="driverId" name="driverId">
                        <option value="">All drivers</option>
                        <c:forEach var="drv" items="${drivers}">
                            <option value="${drv.id}" ${driverFilter == drv.id ? 'selected' : ''}>
                                ${drv.driverFullName}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">Apply Filters</button>
        </form>
    </section>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-card">
            <span class="stat-card-number">${countTotal}</span>
            <span class="stat-card-label">Total Deliveries</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${countDelivered}</span>
            <span class="stat-card-label">Delivered</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${countFailed}</span>
            <span class="stat-card-label">Failed</span>
        </div>
        <div class="stat-card">
            <span class="stat-card-number">${countActive}</span>
            <span class="stat-card-label">Active</span>
        </div>
    </div>

    <!-- Table -->
    <section class="table-section">
        <c:choose>
            <c:when test="${empty deliveries}">
                <div class="empty-state"><p>No deliveries match the selected filters.</p></div>
            </c:when>
            <c:otherwise>
                <div class="table-wrapper">
                    <table class="data-table" id="reportTable">
                        <thead>
                            <tr>
                                <th>Tracking #</th>
                                <th>Driver</th>
                                <th>Status</th>
                                <th>Assigned</th>
                                <th>Picked Up</th>
                                <th>Delivered</th>
                                <th>Notes</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="d" items="${deliveries}">
                                <tr>
                                    <td><code>${d.trackingNumber}</code></td>
                                    <td>${d.driverName}</td>
                                    <td>
                                        <span class="status-badge status-${d.status.name().toLowerCase()}">
                                            ${d.status}
                                        </span>
                                    </td>
                                    <td><fmt:formatDate value="${d.assignedAt}"  pattern="dd MMM yyyy HH:mm"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty d.pickedUpAt}">
                                                <fmt:formatDate value="${d.pickedUpAt}" pattern="dd MMM yyyy HH:mm"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty d.deliveredAt}">
                                                <fmt:formatDate value="${d.deliveredAt}" pattern="dd MMM yyyy HH:mm"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${not empty d.notes ? d.notes : '—'}</td>
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
        var lines = ['"NowNow – Delivery History Report"', '"${rangeLabel}"', ''];
        lines.push(d.headers.map(function(h){ return '"'+h.replace(/"/g,'""')+'"'; }).join(','));
        d.rows.forEach(function(r){ lines.push(r.map(function(c){ return '"'+String(c).replace(/"/g,'""')+'"'; }).join(',')); });
        var a = document.createElement('a');
        a.href = URL.createObjectURL(new Blob([lines.join('\r\n')], {type:'text/csv'}));
        a.download = 'deliveries_report_'+today()+'.csv';
        a.click();
    }

    function exportPDF() {
        var d = getTableData();
        var { jsPDF } = window.jspdf;
        var doc = new jsPDF({orientation:'landscape', unit:'mm', format:'a4'});
        var m = 14, y = 18;
        doc.setFontSize(15); doc.setFont('helvetica','bold');
        doc.text('NowNow – Delivery History Report', m, y); y += 7;
        doc.setFontSize(9); doc.setFont('helvetica','normal'); doc.setTextColor(100);
        doc.text('${rangeLabel}', m, y); y += 8;
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
        doc.save('deliveries_report_'+today()+'.pdf');
    }
</script>
</body>
</html>
