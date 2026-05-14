<%-- 
    In your admin/dashboard.jsp, find the packages table's <th>Track</th> column
    and add two more columns. Replace this section:

        <th>Track</th>
    ...
        <td>
            <a href="...track..." class="btn btn-sm">Track</a>
        </td>

    With the version below (adds Edit and Delete columns):
--%>

<%-- TABLE HEADER - replace your existing Track <th> with these three: --%>
<th>Track</th>
<th>Edit</th>
<th>Delete</th>

<%-- TABLE ROW ACTIONS - replace your existing Track <td> with these three: --%>
<td>
    <a href="${pageContext.request.contextPath}/track?number=${pkg.trackingNumber}"
       class="btn btn-sm">Track</a>
</td>
<td>
    <a href="${pageContext.request.contextPath}/admin/packages/edit?id=${pkg.id}"
       class="btn btn-sm btn-outline">✏️ Edit</a>
</td>
<td>
    <form action="${pageContext.request.contextPath}/admin/packages/delete"
          method="post" class="inline-form">
        <input type="hidden" name="id" value="${pkg.id}">
        <button type="button" class="btn btn-sm btn-danger"
                onclick="if(confirm('Delete this package? This cannot be undone.')) this.form.submit()">
            🗑
        </button>
    </form>
</td>

<%--
    Also add this alert near the top of dashboard.jsp (after the assigned alert):
--%>
<c:if test="${not empty param.updated}">
    <div class="alert alert-success">Package updated successfully.</div>
</c:if>
<c:if test="${not empty param.deleted}">
    <div class="alert alert-success">Package deleted successfully.</div>
</c:if>
