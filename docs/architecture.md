# NowNow Courier – System Architecture

## Overview

NowNow is a **3-tiered web application** that models an Uber-style courier package delivery service. It is built with:

| Tier | Technology |
|------|------------|
| **Tier 1 – Client** | HTML5, CSS3, JavaScript (vanilla, no framework) |
| **Tier 2 – Application Server** | Java 11 Servlets + JSP (JavaServer Pages) on Apache Tomcat 10 |
| **Tier 3 – Database** | MySQL 8.x |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    TIER 1 – CLIENT                          │
│  Browser (Chrome / Firefox / Safari / Edge)                 │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │ index.jsp│  │login.jsp │  │ track.jsp│  │ …other    │  │
│  │ (Home)   │  │          │  │          │  │ JSP pages │  │
│  └──────────┘  └──────────┘  └──────────┘  └───────────┘  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         CSS (style.css)  +  JS (app.js)             │    │
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────┬──────────────────────────────────┘
                           │  HTTP (GET / POST)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    TIER 2 – APPLICATION SERVER              │
│            Apache Tomcat 10  (port 8080)                    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   Servlets                          │    │
│  │  LoginServlet  RegisterServlet  TrackingServlet     │    │
│  │  PackageServlet  CustomerDashboardServlet           │    │
│  │  DriverDashboardServlet  AdminDashboardServlet      │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Data Access Objects (DAOs)             │    │
│  │  UserDAO  DriverDAO  PackageDAO                     │    │
│  │  DeliveryDAO  TrackingEventDAO                      │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Model Classes (POJOs)                  │    │
│  │  User  Driver  Package  Delivery  TrackingEvent     │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Utility Classes                        │    │
│  │  DBConnection  PasswordUtil  TrackingNumberUtil     │    │
│  └─────────────────────────────────────────────────────┘    │
└──────────────────────────┬──────────────────────────────────┘
                           │  JDBC (mysql-connector-java)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    TIER 3 – DATABASE                        │
│            MySQL 8.x  (port 3306)                           │
│                                                             │
│  Tables: users · drivers · packages · deliveries           │
│          tracking_events                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Responsibilities

### Tier 1 – Client Layer

| Component | Purpose |
|-----------|---------|
| JSP pages | Dynamic HTML rendered server-side; contain JSTL expressions and include shared partials (navbar, footer) |
| `style.css` | All visual styling; uses CSS custom properties for theming |
| `app.js` | Client-side enhancements: role-selector toggle, live price estimate, alert auto-dismiss, form validation |

### Tier 2 – Application Layer

| Component | Purpose |
|-----------|---------|
| **Servlets** | Handle HTTP requests. Each servlet validates input, calls DAOs, sets request attributes, and forwards to JSP |
| **DAOs** | Encapsulate all SQL. Use `PreparedStatement` to prevent SQL injection. Return model objects |
| **Model POJOs** | Plain Java objects matching database table columns. Used throughout the request lifecycle |
| **Utilities** | Cross-cutting concerns: database connection pooling (`DBConnection`), BCrypt password hashing (`PasswordUtil`), unique tracking-number generation (`TrackingNumberUtil`) |

### Tier 3 – Database Layer

| Table | Purpose |
|-------|---------|
| `users` | All accounts (customers, drivers, admins). Password stored as BCrypt hash |
| `drivers` | Extended driver profile linked 1-to-1 with a `users` row |
| `packages` | Package details and current status |
| `deliveries` | Assignment of package to driver; timestamps for pickup and delivery |
| `tracking_events` | Immutable audit log of every status change for a package |

---

## Request Flow Example – Customer Submits a Package

```
Browser                Tomcat / PackageServlet           MySQL
  │                           │                            │
  │  POST /customer/packages  │                            │
  │──────────────────────────►│                            │
  │                           │  validate form fields      │
  │                           │  generate tracking number  │
  │                           │──── INSERT packages ──────►│
  │                           │◄─── generated id ──────────│
  │                           │──── INSERT tracking_events►│
  │                           │                            │
  │◄──── 302 Redirect ────────│                            │
  │  /customer/packages?created=NN-...                     │
```

---

## Security Considerations

| Area | Implementation |
|------|----------------|
| **Authentication** | HTTP session (`HttpSession`). Session invalidated on logout |
| **Password storage** | BCrypt with work factor 12 (never stored in plain text) |
| **SQL injection prevention** | All queries use `PreparedStatement` with bound parameters |
| **Role-based access control** | Each servlet checks `session.getAttribute("loggedInUser")` and the user's `Role` enum before processing |
| **Session timeout** | 30 minutes idle timeout configured in `web.xml` |

---

## Deployment

### Prerequisites

- Java 11+ (JDK)
- Apache Maven 3.8+
- Apache Tomcat 10
- MySQL 8.x

### Steps

```bash
# 1. Create the database and populate it
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed-data.sql

# 2. Create a MySQL user for the application
mysql -u root -p -e "CREATE USER 'nownow_user'@'localhost' IDENTIFIED BY 'changeme';
GRANT ALL PRIVILEGES ON nownow_db.* TO 'nownow_user'@'localhost'; FLUSH PRIVILEGES;"

# 3. Edit the database connection settings
vi src/main/resources/db.properties

# 4. Build the WAR file
mvn clean package

# 5. Deploy to Tomcat
cp target/nownow.war $CATALINA_HOME/webapps/

# 6. Start Tomcat (or use the Maven plugin)
mvn tomcat7:run   # then open http://localhost:8080/nownow
```
