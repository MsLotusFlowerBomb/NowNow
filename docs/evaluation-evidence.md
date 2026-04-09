# NowNow Courier System – Evaluation Evidence

> This document covers all required demonstration criteria for the 3-tiered web application assessment.

---

## 1. ERD – Entity Relationship Diagram

### Diagram

```
┌────────────────────────────────────────┐
│                 users                  │
├────────────────────────────────────────┤
│ PK  id            INT AUTO_INCREMENT   │
│     full_name     VARCHAR(120) NOT NULL│
│     email         VARCHAR(180) UNIQUE  │
│     password_hash VARCHAR(255) NOT NULL│
│     phone         VARCHAR(20)          │
│     role          ENUM(CUSTOMER,       │
│                        DRIVER,ADMIN)   │
│     created_at    DATETIME             │
│     updated_at    DATETIME             │
└──────────────┬─────────────────────────┘
               │ 1
        ┌──────┴──────┐
        │             │
        │ 1           │ 1..M
        ▼             ▼
┌─────────────────┐  ┌──────────────────────────────────────┐
│    drivers      │  │              packages                 │
├─────────────────┤  ├──────────────────────────────────────┤
│PK id  INT       │  │PK id              INT AUTO_INCREMENT  │
│FK user_id INT   │  │   tracking_number VARCHAR(20) UNIQUE  │
│   vehicle_type  │  │FK sender_id       INT → users.id      │
│     ENUM(BICYCLE│  │   description     VARCHAR(255)        │
│     MOTORBIKE,  │  │   weight_kg       DECIMAL(8,2)        │
│     CAR,VAN)    │  │   pickup_address  VARCHAR(300)        │
│   license_number│  │   delivery_address VARCHAR(300)       │
│   availability_ │  │   recipient_name  VARCHAR(120)        │
│     status ENUM │  │   recipient_phone VARCHAR(20)         │
│   current_lat   │  │   status ENUM(PENDING,ASSIGNED,       │
│   current_lng   │  │          PICKED_UP,IN_TRANSIT,        │
│   rating        │  │          DELIVERED,CANCELLED)         │
│   total_deliv   │  │   estimated_price DECIMAL(10,2)       │
│   created_at    │  │   created_at      DATETIME            │
│   updated_at    │  │   updated_at      DATETIME            │
└──────┬──────────┘  └──────────────┬───────────────────────┘
       │ 1..M                       │ 1
       │           ┌────────────────┘
       │           │
       ▼           ▼
┌──────────────────────────────────┐
│           deliveries             │
├──────────────────────────────────┤
│ PK id           INT AUTO_INCREMENT│
│ FK package_id   INT UNIQUE        │
│ FK driver_id    INT               │
│    assigned_at  DATETIME          │
│    picked_up_at DATETIME NULL     │
│    delivered_at DATETIME NULL     │
│    status ENUM(ASSIGNED,          │
│               PICKED_UP,          │
│               IN_TRANSIT,         │
│               DELIVERED,FAILED)   │
│    notes TEXT                     │
└──────────────────────────────────┘
       │ 1
       ▼ M
┌──────────────────────────────────┐
│         tracking_events          │
├──────────────────────────────────┤
│ PK id          INT AUTO_INCREMENT│
│ FK package_id  INT → packages.id │
│    event_time  DATETIME          │
│    status      VARCHAR(50)       │
│    description VARCHAR(300)      │
│    latitude    DECIMAL(10,7) NULL│
│    longitude   DECIMAL(10,7) NULL│
└──────────────────────────────────┘
```

### Naming Standards

| Convention | Example |
|---|---|
| Table names: lowercase plural | `users`, `drivers`, `packages`, `deliveries`, `tracking_events` |
| Column names: snake_case | `full_name`, `created_at`, `weight_kg`, `sender_id` |
| Primary keys: always `id` | `users.id`, `packages.id` |
| Foreign keys: `<table_singular>_id` | `sender_id`, `driver_id`, `package_id`, `user_id` |
| Indexes: `idx_<table>_<column>` | `idx_users_email`, `idx_packages_status` |

### Relationships

| From Table | To Table | Cardinality | Foreign Key | Notes |
|---|---|---|---|---|
| `users` | `drivers` | One-to-One | `drivers.user_id → users.id` | One user may have one driver profile |
| `users` | `packages` | One-to-Many | `packages.sender_id → users.id` | One customer sends many packages |
| `packages` | `deliveries` | One-to-One | `deliveries.package_id → packages.id` | One package has one delivery job |
| `drivers` | `deliveries` | One-to-Many | `deliveries.driver_id → drivers.id` | One driver handles many deliveries |
| `packages` | `tracking_events` | One-to-Many | `tracking_events.package_id → packages.id` | One package has many status events |

---

## 2. Database Script

**File:** `database/schema.sql`

```sql
-- ============================================================
--  NowNow Courier Delivery System – Database Schema
--  Database: MySQL 8.x
-- ============================================================

CREATE DATABASE IF NOT EXISTS nownow_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE nownow_db;

-- Table: users
CREATE TABLE IF NOT EXISTS users (
    id            INT          NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(120) NOT NULL,
    email         VARCHAR(180) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone         VARCHAR(20),
    role          ENUM('CUSTOMER','DRIVER','ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_users_email (email),
    INDEX idx_users_role  (role)
) ENGINE=InnoDB;

-- Table: drivers
CREATE TABLE IF NOT EXISTS drivers (
    id                  INT          NOT NULL AUTO_INCREMENT,
    user_id             INT          NOT NULL UNIQUE,
    vehicle_type        ENUM('BICYCLE','MOTORBIKE','CAR','VAN') NOT NULL DEFAULT 'MOTORBIKE',
    license_number      VARCHAR(50),
    availability_status ENUM('AVAILABLE','ON_DELIVERY','OFFLINE') NOT NULL DEFAULT 'OFFLINE',
    current_latitude    DECIMAL(10,7),
    current_longitude   DECIMAL(10,7),
    rating              DECIMAL(3,2) DEFAULT 5.00,
    total_deliveries    INT          NOT NULL DEFAULT 0,
    created_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_drivers_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_drivers_availability (availability_status)
) ENGINE=InnoDB;

-- Table: packages
CREATE TABLE IF NOT EXISTS packages (
    id               INT          NOT NULL AUTO_INCREMENT,
    tracking_number  VARCHAR(20)  NOT NULL UNIQUE,
    sender_id        INT          NOT NULL,
    description      VARCHAR(255),
    weight_kg        DECIMAL(8,2),
    pickup_address   VARCHAR(300) NOT NULL,
    delivery_address VARCHAR(300) NOT NULL,
    recipient_name   VARCHAR(120) NOT NULL,
    recipient_phone  VARCHAR(20),
    status           ENUM('PENDING','ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED')
                     NOT NULL DEFAULT 'PENDING',
    estimated_price  DECIMAL(10,2),
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_packages_sender FOREIGN KEY (sender_id) REFERENCES users(id),
    INDEX idx_packages_tracking (tracking_number),
    INDEX idx_packages_sender   (sender_id),
    INDEX idx_packages_status   (status)
) ENGINE=InnoDB;

-- Table: deliveries
CREATE TABLE IF NOT EXISTS deliveries (
    id              INT      NOT NULL AUTO_INCREMENT,
    package_id      INT      NOT NULL UNIQUE,
    driver_id       INT      NOT NULL,
    assigned_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    picked_up_at    DATETIME,
    delivered_at    DATETIME,
    status          ENUM('ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED')
                    NOT NULL DEFAULT 'ASSIGNED',
    notes           TEXT,
    PRIMARY KEY (id),
    CONSTRAINT fk_deliveries_package FOREIGN KEY (package_id) REFERENCES packages(id),
    CONSTRAINT fk_deliveries_driver  FOREIGN KEY (driver_id)  REFERENCES drivers(id),
    INDEX idx_deliveries_driver  (driver_id),
    INDEX idx_deliveries_status  (status)
) ENGINE=InnoDB;

-- Table: tracking_events
CREATE TABLE IF NOT EXISTS tracking_events (
    id          INT          NOT NULL AUTO_INCREMENT,
    package_id  INT          NOT NULL,
    event_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status      VARCHAR(50)  NOT NULL,
    description VARCHAR(300),
    latitude    DECIMAL(10,7),
    longitude   DECIMAL(10,7),
    PRIMARY KEY (id),
    CONSTRAINT fk_events_package FOREIGN KEY (package_id) REFERENCES packages(id),
    INDEX idx_events_package (package_id)
) ENGINE=InnoDB;
```

---

## 3. Example Tables – Sample Data (≥5 records each)

**File:** `database/seed-data.sql`

### Table: `users` (5 records)

| id | full_name | email | role |
|---|---|---|---|
| 1 | Alice Admin | admin@nownow.com | ADMIN |
| 2 | Carol Customer | carol@example.com | CUSTOMER |
| 3 | Dan Deliverer | dan@nownow.com | DRIVER |
| 4 | Eve Express | eve@nownow.com | DRIVER |
| 5 | Frank Fast | frank@example.com | CUSTOMER |

```sql
INSERT INTO users (full_name, email, password_hash, phone, role) VALUES
('Alice Admin',    'admin@nownow.com',  '$2a$12$KIX...', '555-0100', 'ADMIN'),
('Carol Customer', 'carol@example.com', '$2a$12$KIX...', '555-0200', 'CUSTOMER'),
('Dan Deliverer',  'dan@nownow.com',    '$2a$12$KIX...', '555-0300', 'DRIVER'),
('Eve Express',    'eve@nownow.com',    '$2a$12$KIX...', '555-0400', 'DRIVER'),
('Frank Fast',     'frank@example.com', '$2a$12$KIX...', '555-0500', 'CUSTOMER');
```

### Table: `packages` (5 records)

| tracking_number | sender | description | status | estimated_price |
|---|---|---|---|---|
| NN-20240001 | Carol (id=2) | Laptop bag | DELIVERED | $12.50 |
| NN-20240002 | Carol (id=2) | Birthday gift box | IN_TRANSIT | $9.00 |
| NN-20240003 | Frank (id=5) | Documents folder | PENDING | $5.50 |
| NN-20240004 | Frank (id=5) | Electronics kit | ASSIGNED | $15.00 |
| NN-20240005 | Carol (id=2) | Clothing parcel | PENDING | $8.00 |

```sql
INSERT INTO packages (tracking_number, sender_id, description, weight_kg,
                      pickup_address, delivery_address,
                      recipient_name, recipient_phone, status, estimated_price)
VALUES
('NN-20240001', 2, 'Laptop bag',        1.50, '10 Main St, New York, NY', '55 Park Ave, New York, NY',       'Bob Recipient', '555-1001', 'DELIVERED',  12.50),
('NN-20240002', 2, 'Birthday gift box', 0.80, '10 Main St, New York, NY', '120 Wall St, New York, NY',       'Sara Smith',    '555-1002', 'IN_TRANSIT',  9.00),
('NN-20240003', 5, 'Documents folder',  0.20, '98 Broadway, New York, NY','5 Times Sq, New York, NY',        'Legal Dept',    '555-1003', 'PENDING',     5.50),
('NN-20240004', 5, 'Electronics kit',   2.30, '98 Broadway, New York, NY','230 5th Ave, New York, NY',       'Tech Dept',     '555-1004', 'ASSIGNED',   15.00),
('NN-20240005', 2, 'Clothing parcel',   1.10, '10 Main St, New York, NY', '800 Lexington Ave, New York, NY', 'Mary Johnson',  '555-1005', 'PENDING',     8.00);
```

### Table: `tracking_events` (13 records across 5 packages)

| package_id | event_time | status | description |
|---|---|---|---|
| 1 | 2024-03-10 09:00 | PENDING | Package registered |
| 1 | 2024-03-10 09:00 | ASSIGNED | Driver Dan Deliverer assigned |
| 1 | 2024-03-10 09:30 | PICKED_UP | Package picked up by driver |
| 1 | 2024-03-10 10:15 | IN_TRANSIT | On the way to destination |
| 1 | 2024-03-10 10:45 | DELIVERED | Package delivered successfully |
| 2 | 2024-03-12 13:00 | PENDING | Package registered |
| 2 | 2024-03-12 14:00 | ASSIGNED | Driver Dan Deliverer assigned |
| 2 | 2024-03-12 14:20 | PICKED_UP | Package picked up by driver |
| 2 | 2024-03-12 14:50 | IN_TRANSIT | En route to destination |
| 3 | 2024-03-13 10:00 | PENDING | Package registered, awaiting driver |
| 4 | 2024-03-13 07:30 | PENDING | Package registered |
| 4 | 2024-03-13 08:00 | ASSIGNED | Driver Eve Express assigned |
| 5 | 2024-03-13 11:00 | PENDING | Package registered, awaiting driver |

---

## 4. Three-Tiered Application Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                       TIER 1: CLIENT                             │
│              Web Browser (Chrome, Firefox, IE)                   │
│                                                                  │
│  User visits:  http://<web-server-ip>:8080/nownow                │
│  Renders JSP pages as HTML / CSS / JavaScript                    │
│  Submits HTML <form> POST requests over HTTP                     │
└─────────────────────────┬────────────────────────────────────────┘
                          │  HTTP (port 8080) over network
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                    TIER 2: WEB SERVER                            │
│              Apache Tomcat running nownow.war                    │
│                                                                  │
│  Servlet URL mappings:                                           │
│    /login              → LoginServlet                            │
│    /register           → RegisterServlet                         │
│    /customer/dashboard → CustomerDashboardServlet                │
│    /customer/packages  → PackageServlet                          │
│    /customer/packages/new → PackageServlet (GET)                 │
│    /driver/dashboard   → DriverDashboardServlet                  │
│    /admin/dashboard    → AdminDashboardServlet                   │
│    /track              → TrackingServlet                         │
│                                                                  │
│  JSP Views in WEB-INF/views/ render the HTML responses          │
│  DAO layer (UserDAO, PackageDAO, ...) talks to the database      │
└─────────────────────────┬────────────────────────────────────────┘
                          │  JDBC over TCP (port 3306)
                          │  separate machine on same network
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                    TIER 3: DATABASE SERVER                       │
│                  MySQL 8.x on a separate machine                 │
│                                                                  │
│  Database: nownow_db                                             │
│  Tables:   users, drivers, packages,                             │
│            deliveries, tracking_events                           │
└──────────────────────────────────────────────────────────────────┘
```

### How the 3-Tier Separation Works

| Tier | Responsibility | Technology |
|---|---|---|
| **Client** | Display UI, capture user input, send HTTP requests | Web browser (any) |
| **Web Server** | Business logic, session management, request routing, HTML rendering | Java Servlets + JSP on Apache Tomcat |
| **Database** | Persistent data storage, relational integrity, indexed querying | MySQL 8.x (separate host) |

- The **client** never talks directly to the database.
- The **web server** (`DBConnection.java`) connects to MySQL via JDBC using a configurable host URL (e.g. `jdbc:mysql://192.168.1.20:3306/nownow_db`), meaning Tomcat and MySQL run on **different machines**.
- Any browser on the same network can reach the application at `http://<web-server-ip>:8080/nownow`.

---

## 5. Web Application – LIST, INSERT, UPDATE, DELETE by Page

### Summary Matrix

| Page | URL | LIST | INSERT | UPDATE | DELETE |
|---|---|:---:|:---:|:---:|:---:|
| Login | `/login` | ✅ (reads user) | | | |
| Register | `/register` | ✅ (duplicate check) | ✅ users + drivers | | |
| Customer Dashboard | `/customer/dashboard` | ✅ packages | | | |
| Send Package | `/customer/packages/new` | | ✅ packages + events | | |
| Package List | `/customer/packages` | ✅ packages | | | |
| Track (public) | `/track` | ✅ packages + events | | | |
| Driver Dashboard | `/driver/dashboard` | ✅ deliveries | | ✅ deliveries + packages + drivers | |
| Admin Dashboard | `/admin/dashboard` | ✅ all tables | ✅ deliveries + events | ✅ packages + drivers | |

---

### Page 1 – `/register` — **INSERT** into `users` and `drivers`

**Student A demonstrates: list (duplicate check) + insert**

```
Browser → POST /register
              │
              ├─▶ UserDAO.findByEmail()          ← LIST (check duplicate)
              │     SELECT * FROM users WHERE email = ?
              │
              ├─▶ UserDAO.create(user)           ← INSERT
              │     INSERT INTO users (full_name, email, password_hash, phone, role)
              │     VALUES (?, ?, ?, ?, ?)
              │
              └─▶ DriverDAO.create(driver)       ← INSERT (if DRIVER role)
                    INSERT INTO drivers (user_id, vehicle_type, license_number, ...)
                    VALUES (?, ?, ?, ...)
```

---

### Page 2 – `/customer/packages` and `/customer/packages/new` — **LIST + INSERT**

**Student B demonstrates: list packages + insert new package**

**List:**
```
Browser → GET /customer/packages
              │
              └─▶ PackageDAO.findBySender(userId)   ← LIST
                    SELECT p.*, u.full_name AS sender_name
                    FROM packages p
                    JOIN users u ON u.id = p.sender_id
                    WHERE p.sender_id = ?

JSP renders a table of the customer's packages with tracking number,
recipient, destination, status badge, and date.
```

**Insert:**
```
Browser → POST /customer/packages
              │
              ├─▶ PackageDAO.create(pkg)             ← INSERT
              │     INSERT INTO packages
              │     (tracking_number, sender_id, description, weight_kg,
              │      pickup_address, delivery_address,
              │      recipient_name, recipient_phone, status, estimated_price)
              │     VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)
              │
              └─▶ TrackingEventDAO.create(event)     ← INSERT
                    INSERT INTO tracking_events
                    (package_id, status, description)
                    VALUES (?, 'PENDING', 'Package registered and awaiting driver assignment.')
```

---

### Page 3 – `/admin/dashboard` — **LIST + INSERT + UPDATE**

**Student C demonstrates: list all tables + assign package (insert delivery + update package/driver)**

**List:**
```
Browser → GET /admin/dashboard
              │
              ├─▶ PackageDAO.findAll()              ← LIST all packages
              ├─▶ PackageDAO.findByStatus(PENDING)  ← LIST pending packages
              ├─▶ DriverDAO.findAll()               ← LIST all drivers
              ├─▶ DriverDAO.findAvailable()         ← LIST available drivers
              └─▶ DeliveryDAO.findAll()             ← LIST all deliveries

JSP renders:
  - Stats cards (total packages, pending, registered drivers, available drivers)
  - "Assign a Package" form (dropdown of pending packages + available drivers)
  - Full packages table with tracking number, sender, status, date
  - Full drivers table with name, vehicle, status, rating, delivery count
```

**Insert + Update (Assign driver to package):**
```
Browser → POST /admin/dashboard  (action=assign, packageId=X, driverId=Y)
              │
              ├─▶ PackageDAO.updateStatus(X, ASSIGNED)      ← UPDATE
              │     UPDATE packages SET status = 'ASSIGNED' WHERE id = ?
              │
              ├─▶ DeliveryDAO.create(delivery)              ← INSERT
              │     INSERT INTO deliveries
              │     (package_id, driver_id, status)
              │     VALUES (?, ?, 'ASSIGNED')
              │
              ├─▶ DriverDAO.updateAvailability(Y, ON_DELIVERY) ← UPDATE
              │     UPDATE drivers
              │     SET availability_status = 'ON_DELIVERY'
              │     WHERE id = ?
              │
              └─▶ TrackingEventDAO.create(event)            ← INSERT
                    INSERT INTO tracking_events
                    (package_id, status, description)
                    VALUES (?, 'ASSIGNED', 'Package assigned to [driver name].')
```

---

### Page 4 – `/driver/dashboard` — **LIST + UPDATE**

**Student D demonstrates: list assigned deliveries + update delivery status**

**List:**
```
Browser → GET /driver/dashboard
              │
              ├─▶ DriverDAO.findByUserId(userId)            ← READ driver profile
              │     SELECT d.*, u.full_name, u.email
              │     FROM drivers d JOIN users u ON u.id = d.user_id
              │     WHERE d.user_id = ?
              │
              └─▶ DeliveryDAO.findByDriverId(driverId)      ← LIST deliveries
                    SELECT d.*, p.tracking_number, u.full_name AS driver_name
                    FROM deliveries d
                    JOIN packages p ON p.id = d.package_id
                    JOIN drivers dr ON dr.id = d.driver_id
                    JOIN users u ON u.id = dr.user_id
                    WHERE d.driver_id = ?

JSP renders:
  - Driver stats (total deliveries, rating, vehicle type)
  - Table of active deliveries with status badges and action buttons
  - "Mark Picked Up" button (when status = ASSIGNED)
  - "Mark Delivered" / "Report Failed" buttons (when IN_TRANSIT or PICKED_UP)
```

**Update (mark pickup / delivered / failed):**
```
Browser → POST /driver/dashboard  (action=pickup|deliver|fail, deliveryId=X)
              │
              ├─▶ DeliveryDAO.updateStatus(X, PICKED_UP/DELIVERED/FAILED)  ← UPDATE
              │     UPDATE deliveries
              │     SET status = ?, picked_up_at = NOW()   -- or delivered_at
              │     WHERE id = ?
              │
              ├─▶ PackageDAO.updateStatus(packageId, ...)               ← UPDATE
              │     UPDATE packages SET status = ? WHERE id = ?
              │
              ├─▶ TrackingEventDAO.create(event)                        ← INSERT
              │     INSERT INTO tracking_events
              │     (package_id, status, description)
              │     VALUES (?, ?, ?)
              │
              └─▶ (on DELIVERED only)
                    DriverDAO.incrementDeliveryCount(driverId)          ← UPDATE
                      UPDATE drivers
                      SET total_deliveries = total_deliveries + 1
                      WHERE id = ?

                    DriverDAO.updateAvailability(driverId, AVAILABLE)   ← UPDATE
                      UPDATE drivers
                      SET availability_status = 'AVAILABLE'
                      WHERE id = ?
```

---

### Page 5 – `/track` — **LIST** (public, no login required)

**Student E demonstrates: public package tracking (list package + list events)**

```
Browser → GET /track?number=NN-20240001
              │
              ├─▶ PackageDAO.findByTrackingNumber("NN-20240001")   ← LIST
              │     SELECT p.*, u.full_name AS sender_name
              │     FROM packages p
              │     JOIN users u ON u.id = p.sender_id
              │     WHERE p.tracking_number = ?
              │
              └─▶ TrackingEventDAO.findByPackageId(pkg.getId())    ← LIST
                    SELECT * FROM tracking_events
                    WHERE package_id = ?
                    ORDER BY event_time ASC

JSP renders:
  ┌──────────────────────────────────────────┐
  │ Tracking: NN-20240001                    │
  │ Status: DELIVERED                        │
  │ Recipient: Bob Recipient                 │
  │                                          │
  │ Timeline:                                │
  │  ✔ PENDING    10 Mar 09:00  Registered  │
  │  ✔ ASSIGNED   10 Mar 09:00  Dan assigned│
  │  ✔ PICKED_UP  10 Mar 09:30  Picked up   │
  │  ✔ IN_TRANSIT 10 Mar 10:15  On the way  │
  │  ✔ DELIVERED  10 Mar 10:45  Delivered   │
  └──────────────────────────────────────────┘
```

---

## 6. Marks Mapping

| Criterion | Marks | Evidence in this project |
|---|---|---|
| ERD created, naming standards followed | 2 | Section 1 – ERD diagram + naming table |
| Database script created | 1 | Section 2 – `database/schema.sql` |
| 3 tables populated with ≥5 records | 1 | Section 3 – `users`, `packages`, `tracking_events` seed data |
| Relationships as per ERD | 2 | Section 1 – FK constraints table; Section 2 – SQL `CONSTRAINT` lines |
| Web server set up, client connects via browser | 3 | Section 4 – Tier 1 & Tier 2 description, Tomcat WAR deployment |
| Database on different machine from web server | 2 | Section 4 – Tier 2 → Tier 3 JDBC connection over network |
| Learner illustrates understanding of 3-tier setup | 2 | Section 4 – architecture diagram + responsibility table |
| List functionality (2 marks per student) | 2 each | Section 5 – every page includes at least one SELECT |
| Insert / Update / Delete (5 marks per student) | 5 each | Section 5 – Pages 1–4 each demonstrate INSERT or UPDATE |
