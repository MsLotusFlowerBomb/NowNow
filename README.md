# NowNow Courier Delivery System

> A 3-tiered **Uber-style package delivery** web application built as a university Computer Science project.

---

## 🏗 Architecture

| Tier | Technology |
|------|------------|
| **Tier 1 – Client** | HTML5, CSS3, JavaScript (vanilla) |
| **Tier 2 – Application Server** | Java 17 Servlets + JSP on Apache Tomcat 10 |
| **Tier 3 – Database** | MySQL 8.x |

---

## 📁 Project Structure

```
NowNow/
├── pom.xml                              # Maven build descriptor
├── database/
│   ├── schema.sql                       # MySQL DDL (all tables)
│   └── seed-data.sql                    # Sample data for development
├── docs/
│   ├── architecture.md                  # System architecture & deployment guide
│   ├── database-schema.md               # Full ERD and column reference
│   └── api-documentation.md             # HTTP endpoint reference
├── prototype/                           # ★ Interactive HTML prototype (no server needed)
│   ├── index.html                       # Landing page
│   ├── login.html                       # Login
│   ├── register.html                    # Registration (Customer & Driver)
│   ├── customer-dashboard.html          # Customer package overview
│   ├── new-package.html                 # Send a new package
│   ├── driver-dashboard.html            # Driver delivery management
│   ├── admin-dashboard.html             # Admin – assign drivers, view all data
│   ├── track.html                       # Public package tracker
│   ├── css/prototype.css
│   └── js/prototype.js
└── src/main/
    ├── java/com/nownow/
    │   ├── model/       User · Driver · Package · Delivery · TrackingEvent
    │   ├── dao/         UserDAO · DriverDAO · PackageDAO · DeliveryDAO · TrackingEventDAO
    │   ├── servlet/     Login · Logout · Register · Package · Tracking
    │   │                CustomerDashboard · DriverDashboard · AdminDashboard
    │   └── util/        DBConnection · TrackingNumberUtil
    ├── resources/
    │   └── db.properties                # Database connection settings
    └── webapp/
        ├── index.jsp                    # Landing page (JSP)
        ├── css/style.css
        ├── js/app.js
        └── WEB-INF/
            ├── web.xml                  # Servlet configuration
            └── views/                   # JSP view templates
```

---

## ⚡ Interactive Prototype

Open **`prototype/index.html`** in any browser to explore the full UI without installing Java or MySQL.

**Demo accounts (prototype login page):**

| Role | Email |
|------|-------|
| Customer | carol@example.com |
| Driver | dan@nownow.com |
| Admin | admin@nownow.com |

*(Password for all demo accounts: `Password1!`)*

---

## 🚀 Running the Full Application

### Prerequisites
- Java 17+ JDK
- Apache Maven 3.8+
- Apache Tomcat 10
- MySQL 8.x

### Steps

```bash
# 1. Set up the database
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed-data.sql

# 2. Create a MySQL user for the app
mysql -u root -p -e "
  CREATE USER 'nownow_user'@'localhost' IDENTIFIED BY 'changeme';
  GRANT ALL PRIVILEGES ON nownow_db.* TO 'nownow_user'@'localhost';
  FLUSH PRIVILEGES;"

# 3. Update connection settings (if needed)
# Edit src/main/resources/db.properties

# 4. Build the WAR
mvn clean package

# 5. Run with embedded Tomcat (quickest)
mvn tomcat7:run
# Then open: http://localhost:8080/nownow
```

---

## 🔐 GlassFish JDBC Realm (Container Auth)

When deploying to GlassFish/Payara with FORM authentication, configure a JDBC realm
that points at the same `users` table used by the app:

1. Create a JDBC connection pool/resource for your NowNow database.
2. Create a JDBC realm named **`NowNowRealm`** with:
   - **User Table:** `users`
   - **User Name Column:** `email`
   - **Password Column:** `password`
   - **Group Table:** `users`
   - **Group Name Column:** `role`
3. Ensure the realm uses **plain text** passwords (no digest) to match the schema.

The app’s `web.xml` references `NowNowRealm`, and the login form posts to
`j_security_check` to use the container-managed JDBC realm.

---

## 📋 Key Features

| Feature | Description |
|---------|-------------|
| **Registration** | Customers and drivers can self-register; admin accounts are seeded |
| **Send a Package** | Customers enter pickup/delivery addresses and recipient details |
| **Driver Assignment** | Admins assign available drivers to pending packages |
| **Delivery Management** | Drivers mark packages as picked up, delivered, or failed |
| **Package Tracking** | Anyone can track a package by its unique tracking number |
| **Role-based dashboards** | Separate views for customer, driver, and admin |

---

## 📚 Documentation

- [System Architecture](docs/architecture.md)
- [Database Schema](docs/database-schema.md)
- [API / Endpoint Reference](docs/api-documentation.md)

---

## 🔒 Security

- Passwords are stored in plain text (school project requirement)
- All SQL uses **PreparedStatement** to prevent injection
- Role-based access control enforced in every servlet
- Session timeout: 30 minutes
