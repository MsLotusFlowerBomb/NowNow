<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Packages – NowNow</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  </head>
  <body>
    <%@ include file="/WEB-INF/views/partials/navbar.jsp" %>

    <main class="page-main">
      <div class="page-header-row">
        <h1>My Package History</h1>
        <a href="${pageContext.request.contextPath}/customer/packages/new" class="btn btn-primary">
          + Send a New Package
        </a>
      </div>

      <td>
        <code>
          <c:if test="${pkg.instant}">
   <br><span class="badge" style="background: var(--color-danger); color:#fff; font-size: 0.7rem; margin-top:4px;">INSTANT</span>
          </c:if>
        </code>
      </td>
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th>Tracking #</th>
              <th>Recipient</th>
              <th>Destination</th>
              <th>Status</th>
              <th>Est. Price</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
            <c:when test="${empty packages}">
            <tr>
              <td colspan="6" style="text-align: center; padding: 2rem;">
                You haven't sent any packages yet. 
              </td>
            </tr>
            </c:when>
            <c:otherwise>
            <c:forEach var="pkg" items="${packages}">
            <tr>
              <td><strong>${pkg.trackingNumber}</strong></td>
              <td>${pkg.recipientName}</td>
              <td>${pkg.deliveryAddress}</td>
              <td>
                <span class="badge badge-${pkg.status}">${pkg.status}</span>
              </td>
              <td>R${pkg.estimatedPrice}</td>
              <td>
                <a href="${pageContext.request.contextPath}/track?number=${pkg.trackingNumber}" 
                   class="btn btn-outline btn-sm">Track</a>
              </td>
            </tr>
            </c:forEach>
            </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </main>

    <%@ include file="/WEB-INF/views/partials/footer.jsp" %>
    <script src="${pageContext.request.contextPath}/js/app.js"></script>
  </body>
</html>
