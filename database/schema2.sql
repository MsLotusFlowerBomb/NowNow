-- 1. DROP EXISTING TABLES (In reverse order of dependency)
-- Note: You might get errors saying "Table does not exist" on the first run. 
-- That is fine and expected!
DROP TABLE tracking_events;
DROP TABLE deliveries;
DROP TABLE packages;
DROP TABLE drivers;
DROP TABLE users;

-- 2. DROP EXISTING PROCEDURES
DROP PROCEDURE AssignDriverToPackage;
DROP PROCEDURE CompleteDelivery;

-- -------------------------------------------------------
-- Table: users
-- -------------------------------------------------------
CREATE TABLE users (
    id          INT             NOT NULL GENERATED ALWAYS AS IDENTITY,
    full_name   VARCHAR(120)    NOT NULL,
    email       VARCHAR(180)    NOT NULL,
    phone       VARCHAR(20),
    role        VARCHAR(10)     NOT NULL DEFAULT 'CUSTOMER',
    password    VARCHAR(255)    NOT NULL DEFAULT 'Password1!',
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_role CHECK (role IN ('CUSTOMER','DRIVER','ADMIN'))
);

CREATE INDEX idx_users_email ON users (email);

-- -------------------------------------------------------
-- Table: drivers
-- -------------------------------------------------------
CREATE TABLE drivers (
    id                  INT             NOT NULL GENERATED ALWAYS AS IDENTITY,
    user_id             INT             NOT NULL,
    vehicle_type        VARCHAR(10)     NOT NULL DEFAULT 'MOTORBIKE',
    license_number      VARCHAR(50),
    availability_status VARCHAR(12)     NOT NULL DEFAULT 'OFFLINE',
    current_latitude    DECIMAL(10,7),
    current_longitude   DECIMAL(10,7),
    rating              DECIMAL(3,2)    DEFAULT 5.00,
    total_deliveries    INT             NOT NULL DEFAULT 0,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uq_drivers_user UNIQUE (user_id),
    CONSTRAINT fk_drivers_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_drivers_vehicle CHECK (vehicle_type IN ('BICYCLE','MOTORBIKE','CAR','VAN')),
    CONSTRAINT chk_drivers_avail CHECK (availability_status IN ('AVAILABLE','ON_DELIVERY','OFFLINE'))
);

-- -------------------------------------------------------
-- Table: packages
-- -------------------------------------------------------
CREATE TABLE packages (
    id               INT             NOT NULL GENERATED ALWAYS AS IDENTITY,
    tracking_number  VARCHAR(20)     NOT NULL,
    sender_id        INT             NOT NULL,
    description      VARCHAR(255),
    weight_kg        DECIMAL(8,2),
    pickup_address   VARCHAR(300)    NOT NULL,
    delivery_address VARCHAR(300)    NOT NULL,
    recipient_name   VARCHAR(120)    NOT NULL,
    recipient_phone  VARCHAR(20),
    status           VARCHAR(10)     NOT NULL DEFAULT 'PENDING',
    estimated_price  DECIMAL(10,2),
    created_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uq_packages_tracking UNIQUE (tracking_number),
    CONSTRAINT fk_packages_sender FOREIGN KEY (sender_id) REFERENCES users(id),
    CONSTRAINT chk_packages_status CHECK (status IN ('PENDING','ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','CANCELLED'))
);

-- -------------------------------------------------------
-- Table: deliveries
-- -------------------------------------------------------
CREATE TABLE deliveries (
    id           INT         NOT NULL GENERATED ALWAYS AS IDENTITY,
    package_id   INT         NOT NULL,
    driver_id    INT         NOT NULL,
    assigned_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    status       VARCHAR(12) NOT NULL DEFAULT 'ASSIGNED',
    notes        CLOB,
    PRIMARY KEY (id),
    CONSTRAINT uq_deliveries_package UNIQUE (package_id),
    CONSTRAINT fk_deliveries_package FOREIGN KEY (package_id) REFERENCES packages(id),
    CONSTRAINT fk_deliveries_driver  FOREIGN KEY (driver_id)  REFERENCES drivers(id),
    CONSTRAINT chk_deliveries_status CHECK (status IN ('ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED'))
);

-- -------------------------------------------------------
-- Table: tracking_events
-- -------------------------------------------------------
CREATE TABLE tracking_events (
    id          INT             NOT NULL GENERATED ALWAYS AS IDENTITY,
    package_id  INT             NOT NULL,
    event_time  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status      VARCHAR(50)     NOT NULL,
    description VARCHAR(300),
    latitude    DECIMAL(10,7),
    longitude   DECIMAL(10,7),
    PRIMARY KEY (id),
    CONSTRAINT fk_events_package FOREIGN KEY (package_id) REFERENCES packages(id)
);

CREATE INDEX idx_events_package ON tracking_events (package_id);

-- -------------------------------------------------------
-- Register Stored Procedures
-- -------------------------------------------------------
CREATE PROCEDURE AssignDriverToPackage(IN p_pkg_id INT, IN p_driver_id INT)
    PARAMETER STYLE JAVA
    LANGUAGE JAVA
    MODIFIES SQL DATA
    EXTERNAL NAME 'com.nownow.DeliveryProcedures.assignDriverToPackage';

CREATE PROCEDURE CompleteDelivery(IN p_del_id INT, IN p_pkg_id INT, IN p_driver_id INT)
    PARAMETER STYLE JAVA
    LANGUAGE JAVA
    MODIFIES SQL DATA
    EXTERNAL NAME 'com.nownow.DeliveryProcedures.completeDelivery';
