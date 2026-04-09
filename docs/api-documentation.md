# NowNow Courier – API / Servlet Endpoint Documentation

All endpoints are relative to the application context root (e.g., `http://localhost:8080/nownow`).

---

## Public Endpoints (no authentication required)

### `GET /`
Returns the landing page.

**Response:** `index.jsp`

---

### `GET /login`
Displays the login form. If the user already has an active session, they are redirected to their dashboard.

**Response:** `login.jsp`

---

### `POST /login`

Authenticates a user.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `email` | string | ✅ | User's registered email address |
| `password` | string | ✅ | Plain-text password (compared against BCrypt hash) |

**Responses:**
- **302 Redirect** to `/customer/dashboard`, `/driver/dashboard`, or `/admin/dashboard` on success.
- **200 + login.jsp** with `errorMessage` attribute on failure.

---

### `GET /register`
Displays the registration form.

**Response:** `register.jsp`

---

### `POST /register`

Creates a new user account.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `fullName` | string | ✅ | User's full name |
| `email` | string | ✅ | Must be unique |
| `password` | string | ✅ | Minimum 8 characters |
| `phone` | string | | Contact number |
| `role` | string | | `CUSTOMER` (default) or `DRIVER` |
| `vehicleType` | string | Driver only | `BICYCLE`, `MOTORBIKE`, `CAR`, or `VAN` |
| `licenseNumber` | string | Driver only | Government-issued license |

**Responses:**
- **200 + login.jsp** with `successMessage` on success.
- **200 + register.jsp** with `errorMessage` on validation failure.

---

### `GET /track`
Displays the public package tracking page. Optionally accepts a tracking number query parameter.

| Query Param | Type | Required | Description |
|-------------|------|----------|-------------|
| `number` | string | | Tracking number to look up (e.g. `NN-20240313-A3F9C21B`) |

**Response:** `track.jsp` with:
- `pkg` attribute (Package object) if found
- `events` attribute (List of TrackingEvent) if found
- `notFound` attribute (`true`) if not found

---

### `GET /logout`
Invalidates the HTTP session and redirects to `/login`.

---

## Customer Endpoints (requires CUSTOMER or ADMIN session)

### `GET /customer/dashboard`
Returns the customer's personal dashboard showing all their packages.

**Response:** `customer/dashboard.jsp` with `packages` attribute (List of Package).

---

### `GET /customer/packages`
Same as dashboard — lists all packages belonging to the logged-in customer.

---

### `GET /customer/packages/new`
Displays the "Send a Package" form.

**Response:** `customer/new-package.jsp`

---

### `POST /customer/packages`
Creates a new package and logs the initial tracking event.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pickupAddress` | string | ✅ | Sender's address |
| `deliveryAddress` | string | ✅ | Recipient's address |
| `recipientName` | string | ✅ | Name of the person receiving the package |
| `recipientPhone` | string | | Recipient's contact number |
| `description` | string | | Contents description |
| `weight` | decimal | | Weight in kg |

**Tracking number format:** `NN-YYYYMMDD-XXXXXXXX`

**Price calculation:** `$5.00 + ($3.50 × weight_kg)`

**Responses:**
- **302 Redirect** to `/customer/packages?created=<tracking_number>` on success.
- **200 + new-package.jsp** with `errorMessage` on validation failure.

---

## Driver Endpoints (requires DRIVER session)

### `GET /driver/dashboard`
Returns the driver's dashboard with a list of all their deliveries.

**Response:** `driver/dashboard.jsp` with:
- `driver` attribute (Driver object)
- `deliveries` attribute (List of Delivery)

---

### `POST /driver/dashboard`
Updates the status of a delivery.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `deliveryId` | int | ✅ | The delivery to update |
| `action` | string | ✅ | `pickup`, `deliver`, or `fail` |

**Side effects by action:**

| Action | Delivery Status | Package Status | Notes |
|--------|-----------------|----------------|-------|
| `pickup` | `PICKED_UP` | `PICKED_UP` | Sets `picked_up_at = NOW()` |
| `deliver` | `DELIVERED` | `DELIVERED` | Sets `delivered_at = NOW()`; increments driver's `total_deliveries`; sets driver `AVAILABLE` |
| `fail` | `FAILED` | `CANCELLED` | Logs failed tracking event |

**Response:** **302 Redirect** to `/driver/dashboard?updated=true`.

---

## Admin Endpoints (requires ADMIN session)

### `GET /admin/dashboard`
Returns the admin overview dashboard.

**Response:** `admin/dashboard.jsp` with:
- `allPackages` — all packages (newest first)
- `pendingPackages` — packages awaiting driver assignment
- `availableDrivers` — drivers with status `AVAILABLE`
- `allDrivers` — all registered drivers
- `activeDeliveries` — all delivery records

---

### `POST /admin/dashboard`
Assigns a pending package to an available driver.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `action` | string | ✅ | Must be `assign` |
| `packageId` | int | ✅ | ID of the pending package |
| `driverId` | int | ✅ | ID of the available driver |

**Side effects:**
1. Package status → `ASSIGNED`
2. New `deliveries` row created with status `ASSIGNED`
3. Driver `availability_status` → `ON_DELIVERY`
4. Tracking event logged: `ASSIGNED`

**Response:** **302 Redirect** to `/admin/dashboard?assigned=true`.

---

## Session Management

| Attribute | Type | Set By | Description |
|-----------|------|--------|-------------|
| `loggedInUser` | `User` object | `LoginServlet` | The authenticated user |

- Session timeout: **30 minutes** (configured in `web.xml`).
- Role checking is performed in every protected servlet before processing the request.
