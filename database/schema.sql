-- ============================================================
--  NowNow Courier Delivery System – Database Schema
--  Database: MySQL 8.x
-- ============================================================

CREATE DATABASE IF NOT EXISTS nownow_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE nownow_db;

-- -------------------------------------------------------
-- Table: users
--   Stores customers, drivers, and administrators.
--   The `role` column differentiates them.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id            INT          NOT NULL AUTO_INCREMENT,
    full_name     VARCHAR(120) NOT NULL,
    email         VARCHAR(180) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,          -- BCrypt hash
    phone         VARCHAR(20),
    role          ENUM('CUSTOMER','DRIVER','ADMIN') NOT NULL DEFAULT 'CUSTOMER',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_users_email (email),
    INDEX idx_users_role  (role)
) ENGINE=InnoDB;

-- -------------------------------------------------------
-- Table: drivers
--   Extended profile for users with role = 'DRIVER'.
-- -------------------------------------------------------
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

-- -------------------------------------------------------
-- Table: packages
--   A package that a customer wants to send.
-- -------------------------------------------------------
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

-- -------------------------------------------------------
-- Table: deliveries
--   Links a package to the driver assigned to deliver it.
-- -------------------------------------------------------
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

-- -------------------------------------------------------
-- Table: tracking_events
--   Immutable audit log of every status change for a package.
-- -------------------------------------------------------
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
