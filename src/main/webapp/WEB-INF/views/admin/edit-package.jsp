<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Package – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

<main class="page-main">
    <div class="page-header-row">
        <h1>✏️ Edit Package</h1>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline">
            ← Back to Dashboard
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-error">${errorMessage}</div>
    </c:if>

    <c:choose>
        <c:when test="${not empty pkg}">
            <div class="form-card" style="max-width:750px">

                <!-- Read-only info strip -->
                <div style="background:var(--color-bg);border-radius:var(--radius-sm);
                            padding:1rem 1.2rem;margin-bottom:1.5rem;
                            display:flex;gap:2rem;flex-wrap:wrap;font-size:.9rem">
                    <div>
                        <span style="font-weight:700;color:var(--color-text-muted);font-size:.78rem;
                                     text-transform:uppercase">Tracking #</span><br>
                        <code style="font-size:1rem">${pkg.trackingNumber}</code>
                    </div>
                    <div>
                        <span style="font-weight:700;color:var(--color-text-muted);font-size:.78rem;
                                     text-transform:uppercase">Sender</span><br>
                        ${pkg.senderName}
                    </div>
                    <div>
                        <span style="font-weight:700;color:var(--color-text-muted);font-size:.78rem;
                                     text-transform:uppercase">Pickup Address</span><br>
                        ${pkg.pickupAddress}
                    </div>
                </div>

                <!-- Edit form -->
                <form action="${pageContext.request.contextPath}/admin/packages/edit"
                      method="post" id="editForm" novalidate>
                    <input type="hidden" name="id" value="${pkg.id}">

                    <h2 class="form-section-title">📋 Package Details</h2>

                    <div class="form-group">
                        <label for="recipientName">Recipient Name *</label>
                        <input type="text" id="recipientName" name="recipientName"
                               value="${pkg.recipientName}" required maxlength="100"
                               placeholder="Full name of recipient">
                        <small style="color:var(--color-text-muted)">Max 100 characters</small>
                    </div>

                    <div class="form-group">
                        <label for="deliveryAddress">Delivery Address *</label>
                        <input type="text" id="deliveryAddress" name="deliveryAddress"
                               value="${pkg.deliveryAddress}" required maxlength="255"
                               placeholder="Full delivery address">
                        <small style="color:var(--color-text-muted)">Max 255 characters</small>
                    </div>

                    <div class="form-group">
                        <label for="description">Description</label>
                        <input type="text" id="description" name="description"
                               value="${pkg.description}"
                               placeholder="e.g. Laptop bag, Birthday gift...">
                    </div>

                    <h2 class="form-section-title">🔄 Status</h2>

                    <div class="form-group">
                        <label for="status">Package Status *</label>
                        <select id="status" name="status" required>
                            <c:forEach var="s" items="${statuses}">
                                <option value="${s}" ${pkg.status == s ? 'selected' : ''}>
                                    ${s}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div id="formError" class="alert alert-error" style="display:none"></div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary btn-lg">Save Changes</button>
                        <a href="${pageContext.request.contextPath}/admin/dashboard"
                           class="btn btn-outline">Cancel</a>
                    </div>
                </form>

                <!-- Delete section -->
                <div style="margin-top:2rem;padding-top:1.5rem;
                            border-top:1px solid var(--color-border)">
                    <h2 class="form-section-title" style="color:var(--color-danger)">
                        ⚠️ Danger Zone
                    </h2>
                    <p style="font-size:.9rem;color:var(--color-text-muted);margin-bottom:1rem">
                        Permanently delete this package and all its tracking history.
                        This action cannot be undone.
                    </p>
                    <form action="${pageContext.request.contextPath}/admin/packages/delete"
                          method="post" id="deleteForm">
                        <input type="hidden" name="id" value="${pkg.id}">
                        <button type="button" class="btn btn-danger"
                                onclick="confirmDelete()">
                            🗑 Delete Package
                        </button>
                    </form>
                </div>

            </div>
        </c:when>
        <c:otherwise>
            <div class="empty-state">
                <p>Package not found.</p>
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="btn btn-primary">Back to Dashboard</a>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<%@ include file="/WEB-INF/views/partials/footer.jsp" %>
<script>
    /* Client-side validation */
    document.getElementById('editForm').addEventListener('submit', function(e) {
        var errDiv      = document.getElementById('formError');
        var recipient   = document.getElementById('recipientName').value.trim();
        var address     = document.getElementById('deliveryAddress').value.trim();
        errDiv.style.display = 'none';

        if (!recipient) {
            errDiv.textContent = 'Recipient name is required.';
            errDiv.style.display = 'block';
            e.preventDefault();
            return;
        }
        if (recipient.length > 100) {
            errDiv.textContent = 'Recipient name must be 100 characters or fewer.';
            errDiv.style.display = 'block';
            e.preventDefault();
            return;
        }
        if (!address) {
            errDiv.textContent = 'Delivery address is required.';
            errDiv.style.display = 'block';
            e.preventDefault();
            return;
        }
        if (address.length > 255) {
            errDiv.textContent = 'Delivery address must be 255 characters or fewer.';
            errDiv.style.display = 'block';
            e.preventDefault();
        }
    });

    function confirmDelete() {
        if (confirm('Are you sure you want to permanently delete this package?\nThis cannot be undone.')) {
            document.getElementById('deleteForm').submit();
        }
    }
</script>
</body>
</html>
