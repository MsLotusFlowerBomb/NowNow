# System Test Cases

| Test Case ID | TC-01 |
|--------------|-------|
| **Module** | Authentication & Security |
| **Description** | Verify that unauthenticated users cannot access protected resources. |
| **Steps** | 1. Open browser.<br>2. Attempt to navigate directly to `http://localhost:8080/nownow/admin/dashboard` without logging in. |
| **Expected Result** | The GlassFish server intercepts the request and automatically redirects the user to the `/login` page. |
| **Actual Result** | Redirected to `/login`. |
| **Pass/Fail** | ✅ Pass |

---

| Test Case ID | TC-02 |
|--------------|-------|
| **Module** | Authorization & Integrity |
| **Description** | Verify that a logged-in Driver cannot access Admin reports. |
| **Steps** | 1. Log in with Driver credentials (`dan@nownow.com`).<br>2. Attempt to navigate to `http://localhost:8080/nownow/admin/reports`. |
| **Expected Result** | The server returns a `403 Forbidden` error because the user lacks the `ADMIN` role. |
| **Actual Result** | 403 Forbidden page displayed. |
| **Pass/Fail** | ✅ Pass |

---

| Test Case ID | TC-03 |
|--------------|-------|
| **Module** | Core Functionality (Customer) |
| **Description** | Verify that a customer can successfully create a new package. |
| **Steps** | 1. Log in as Customer (`carol@example.com`).<br>2. Click "Send a Package".<br>3. Fill in pickup, delivery, and recipient details.<br>4. Click "Submit". |
| **Expected Result** | Package is saved to the database. A unique tracking number is generated. The user is redirected to the dashboard with a success message containing the tracking number. |
| **Actual Result** | Package saved, tracking number displayed on dashboard. |
| **Pass/Fail** | ✅ Pass |

---

| Test Case ID | TC-04 |
|--------------|-------|
| **Module** | Core Functionality (Admin) |
| **Description** | Verify that an admin can assign a driver to a pending package. |
| **Steps** | 1. Log in as Admin (`admin@nownow.com`).<br>2. On the dashboard, select a "Pending" package and an "Available" driver from the dropdowns.<br>3. Click "Assign Driver". |
| **Expected Result** | Package status updates to `ASSIGNED`. Driver availability updates to `ON_DELIVERY`. A new record is inserted into the `deliveries` table. |
| **Actual Result** | System stats update immediately, package moves to assigned status. |
| **Pass/Fail** | ✅ Pass |

---

| Test Case ID | TC-05 |
|--------------|-------|
| **Module** | Exception Handling |
| **Description** | Verify server-level exception handling for 404 errors. |
| **Steps** | 1. Navigate to a non-existent URL (e.g., `http://localhost:8080/nownow/does-not-exist`). |
| **Expected Result** | The application catches the error via `web.xml` and routes the user to the custom `404.jsp` error page rather than showing a raw Tomcat/GlassFish stack trace. |
| **Actual Result** | Custom "Page Not Found" UI is displayed. |
| **Pass/Fail** | ✅ Pass |
