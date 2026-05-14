<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NowNow | Management Report</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <!-- jsPDF for client-side PDF export -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.2/jspdf.plugin.autotable.min.js"></script>
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="dashboard-header">
        <div>
            <h1>📊 Management Summary Report</h1>
            <p class="dashboard-sub">Operational performance overview for ${rangeLabel}</p>
        </div>
        <!-- ── Export buttons ── -->
        <div style="display:flex;gap:.6rem;align-items:center">
            <button class="btn btn-outline" onclick="exportCSV()">⬇ Export CSV</button>
            <button class="btn btn-primary" onclick="exportPDF()">⬇ Export PDF</button>
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
        <p class="dashboard-sub">Defaults to the current month to simplify the filter selection.</p>
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

    <!-- Summary stats -->
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

    <!-- Driver performance table -->
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
                    <table class="data-table" id="reportTable">
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

<script>
    /* ── Shared: read the report table into a 2D array ──────────── */
    function getTableData() {
        var table  = document.getElementById('reportTable');
        var result = { headers: [], rows: [] };
        if (!table) return result;

        // Headers — use text content, not inner HTML (strips badge spans)
        var ths = table.querySelectorAll('thead th');
        ths.forEach(function(th) { result.headers.push(th.textContent.trim()); });

        // Rows
        var trs = table.querySelectorAll('tbody tr');
        trs.forEach(function(tr) {
            var row = [];
            tr.querySelectorAll('td').forEach(function(td) {
                row.push(td.textContent.trim());   // .textContent strips badge HTML
            });
            result.rows.push(row);
        });
        return result;
    }

    /* ── Summary stats from the page ────────────────────────────── */
    function getSummaryLines() {
        var cards  = document.querySelectorAll('.stat-card');
        var lines  = [];
        cards.forEach(function(c) {
            var num   = c.querySelector('.stat-card-number');
            var label = c.querySelector('.stat-card-label');
            if (num && label) {
                lines.push(label.textContent.trim() + ': ' + num.textContent.trim());
            }
        });
        return lines;
    }

    /* ── Report period label ─────────────────────────────────────── */
    function getRangeLabel() {
        var sub = document.querySelector('.dashboard-sub');
        return sub ? sub.textContent.trim() : 'Report';
    }

    /* ════════════════════════════════════════════════════════════
       CSV Export
       ════════════════════════════════════════════════════════════ */
    function exportCSV() {
        var data    = getTableData();
        var summary = getSummaryLines();
        var range   = getRangeLabel();

        var lines = [];

        // Title & summary block
        lines.push('"NowNow Courier – Management Report"');
        lines.push('"' + range + '"');
        lines.push('');
        lines.push('"Summary"');
        summary.forEach(function(s) { lines.push('"' + s + '"'); });
        lines.push('');

        // Table header row
        lines.push(data.headers.map(quoteCSV).join(','));

        // Data rows
        data.rows.forEach(function(row) {
            lines.push(row.map(quoteCSV).join(','));
        });

        var csv  = lines.join('\r\n');
        var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
        var url  = URL.createObjectURL(blob);
        var a    = document.createElement('a');
        a.href     = url;
        a.download = 'nownow_report_' + today() + '.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }

    function quoteCSV(val) {
        val = String(val).replace(/"/g, '""');
        return '"' + val + '"';
    }

    /* ════════════════════════════════════════════════════════════
       PDF Export  (jsPDF + autoTable)
       ════════════════════════════════════════════════════════════ */
    function exportPDF() {
        var data    = getTableData();
        var summary = getSummaryLines();
        var range   = getRangeLabel();

        var { jsPDF } = window.jspdf;
        var doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

        var pageW   = doc.internal.pageSize.getWidth();
        var margin  = 14;
        var y       = 18;

        // ── Title ──
        doc.setFontSize(16);
        doc.setFont('helvetica', 'bold');
        doc.text('NowNow Courier – Management Report', margin, y);
        y += 7;

        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        doc.setTextColor(100);
        doc.text(range, margin, y);
        y += 8;

        // ── Summary block ──
        doc.setFontSize(11);
        doc.setFont('helvetica', 'bold');
        doc.setTextColor(0);
        doc.text('Summary', margin, y);
        y += 5;

        doc.setFontSize(9);
        doc.setFont('helvetica', 'normal');

        // Lay out summary items in two columns
        var colW = (pageW - margin * 2) / 2;
        summary.forEach(function(line, i) {
            var x = margin + (i % 2) * colW;
            if (i % 2 === 0 && i > 0) y += 5;
            doc.text(line, x, y);
            if (i % 2 === 1) y += 5;
        });
        if (summary.length % 2 !== 0) y += 5;
        y += 5;

        // ── Driver table ──
        if (data.headers.length > 0) {
            doc.autoTable({
                head:       [data.headers],
                body:       data.rows,
                startY:     y,
                margin:     { left: margin, right: margin },
                styles:     { fontSize: 8, cellPadding: 2 },
                headStyles: { fillColor: [44, 62, 80], textColor: 255, fontStyle: 'bold' },
                alternateRowStyles: { fillColor: [248, 249, 250] },
                theme: 'grid'
            });
        }

        // ── Footer ──
        var pageCount = doc.internal.getNumberOfPages();
        for (var p = 1; p <= pageCount; p++) {
            doc.setPage(p);
            doc.setFontSize(7);
            doc.setTextColor(150);
            doc.text(
                'Generated: ' + new Date().toLocaleString() + '   |   Page ' + p + ' of ' + pageCount,
                margin,
                doc.internal.pageSize.getHeight() - 6
            );
        }

        doc.save('nownow_report_' + today() + '.pdf');
    }

    /* ── Helpers ─────────────────────────────────────────────────── */
    function today() {
        return new Date().toISOString().slice(0, 10).replace(/-/g, '');
    }
</script>
</body>
</html>
