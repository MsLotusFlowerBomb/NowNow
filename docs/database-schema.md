# NowNow Courier – Database Schema

## Entity-Relationship Overview

```
users ──────────────── drivers          (1-to-1, via drivers.user_id)
users ──────────────── packages         (1-to-many, via packages.sender_id)
packages ───────────── deliveries       (1-to-1, via deliveries.package_id)
drivers  ───────────── deliveries       (1-to-many, via deliveries.driver_id)
packages ───────────── tracking_events  (1-to-many, via tracking_events.package_id)
```

---

## Table: `users`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `INT` | PK, AUTO_INCREMENT | Surrogate primary key |
| `full_name` | `VARCHAR(120)` | NOT NULL | Display name |
| `email` | `VARCHAR(180)` | NOT NULL, UNIQUE | Used as login credential |
| `password` | `VARCHAR(255)` | NOT NULL | Plain-text password (school project requirement) |
| `phone` | `VARCHAR(20)` | nullable | Contact number |
| `role` | `ENUM('CUSTOMER','DRIVER','ADMIN')` | NOT NULL, DEFAULT 'CUSTOMER' | Determines access level |
| `created_at` | `DATETIME` | NOT NULL, DEFAULT NOW() | Account creation timestamp |
| `updated_at` | `DATETIME` | NOT NULL, AUTO UPDATE | Last modification timestamp |

**Indexes:** `email` (UNIQUE), `role`

---

## Table: `drivers`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `INT` | PK, AUTO_INCREMENT | Surrogate primary key |
| `user_id` | `INT` | NOT NULL, UNIQUE, FK → users(id) | Links to user account |
| `vehicle_type` | `ENUM('BICYCLE','MOTORBIKE','CAR','VAN')` | NOT NULL | Vehicle used for deliveries |
| `license_number` | `VARCHAR(50)` | nullable | Government-issued license plate |
| `availability_status` | `ENUM('AVAILABLE','ON_DELIVERY','OFFLINE')` | NOT NULL, DEFAULT 'OFFLINE' | Real-time availability |
| `current_latitude` | `DECIMAL(10,7)` | nullable | GPS latitude |
| `current_longitude` | `DECIMAL(10,7)` | nullable | GPS longitude |
| `rating` | `DECIMAL(3,2)` | DEFAULT 5.00 | Average rating (0.00–5.00) |
| `total_deliveries` | `INT` | NOT NULL, DEFAULT 0 | Completed delivery counter |
| `created_at` | `DATETIME` | NOT NULL, DEFAULT NOW() | Profile creation timestamp |
| `updated_at` | `DATETIME` | NOT NULL, AUTO UPDATE | Last modification timestamp |

**Indexes:** `user_id` (UNIQUE FK), `availability_status`

---

## Table: `packages`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `INT` | PK, AUTO_INCREMENT | Surrogate primary key |
| `tracking_number` | `VARCHAR(20)` | NOT NULL, UNIQUE | Customer-facing identifier (e.g. `NN-20240313-A3F9C21B`) |
| `sender_id` | `INT` | NOT NULL, FK → users(id) | The customer who created the package |
| `description` | `VARCHAR(255)` | nullable | Brief description of contents |
| `weight_kg` | `DECIMAL(8,2)` | nullable | Package weight |
| `pickup_address` | `VARCHAR(300)` | NOT NULL | Where the driver collects the package |
| `delivery_address` | `VARCHAR(300)` | NOT NULL | Where the package must be delivered |
| `recipient_name` | `VARCHAR(120)` | NOT NULL | Person to hand the package to |
| `recipient_phone` | `VARCHAR(20)` | nullable | Contact number at destination |
| `status` | `ENUM(...)` | NOT NULL, DEFAULT 'PENDING' | Current lifecycle state (see below) |
| `estimated_price` | `DECIMAL(10,2)` | nullable | Calculated fee ($5 base + $3.50/kg) |
| `created_at` | `DATETIME` | NOT NULL, DEFAULT NOW() | When the package was submitted |
| `updated_at` | `DATETIME` | NOT NULL, AUTO UPDATE | Last modification timestamp |

### Package Status Lifecycle

```
PENDING ──► ASSIGNED ──► PICKED_UP ──► IN_TRANSIT ──► DELIVERED
                │                                        
                └──────────────────────────────────────► CANCELLED
```

**Indexes:** `tracking_number` (UNIQUE), `sender_id`, `status`

---

## Table: `deliveries`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `INT` | PK, AUTO_INCREMENT | Surrogate primary key |
| `package_id` | `INT` | NOT NULL, UNIQUE, FK → packages(id) | The package being delivered |
| `driver_id` | `INT` | NOT NULL, FK → drivers(id) | The assigned driver |
| `assigned_at` | `DATETIME` | NOT NULL, DEFAULT NOW() | When the admin assigned the driver |
| `picked_up_at` | `DATETIME` | nullable | When the driver collected the package |
| `delivered_at` | `DATETIME` | nullable | When delivery was confirmed |
| `status` | `ENUM('ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED')` | NOT NULL | Delivery lifecycle state |
| `notes` | `TEXT` | nullable | Free-text notes (e.g. reason for failure) |

**Indexes:** `package_id` (UNIQUE FK), `driver_id`, `status`

---

## Table: `tracking_events`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `INT` | PK, AUTO_INCREMENT | Surrogate primary key |
| `package_id` | `INT` | NOT NULL, FK → packages(id) | The package this event belongs to |
| `event_time` | `DATETIME` | NOT NULL, DEFAULT NOW() | When the event occurred |
| `status` | `VARCHAR(50)` | NOT NULL | Status at the time of the event |
| `description` | `VARCHAR(300)` | nullable | Human-readable event description |
| `latitude` | `DECIMAL(10,7)` | nullable | GPS latitude of the event |
| `longitude` | `DECIMAL(10,7)` | nullable | GPS longitude of the event |

**Indexes:** `package_id`

> **Design note:** `tracking_events` is an append-only audit log. Rows are never updated or deleted, ensuring a complete, tamper-evident history of every package.

---

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Plain-text passwords | Simplified credential storage for coursework; not recommended for production |
| Prepared statements in all DAOs | Prevents SQL injection at the data access layer |
| Separate `tracking_events` table | Decouples the audit log from the package's current status, enabling a full history |
| ENUM columns for status | Enforces valid values at the database level, reducing the chance of invalid data entering the system |
| `ON DELETE CASCADE` on `drivers` | Deleting a user automatically removes their driver profile |
| `InnoDB` engine | Supports foreign key constraints and ACID transactions |
