-- ============================================================
--  NowNow Courier Delivery System – Seed / Sample Data
--  Run after schema.sql
-- ============================================================

USE nownow_db;

-- -------------------------------------------------------
-- Users
-- Passwords are BCrypt hashes of 'Password1!'
-- -------------------------------------------------------
INSERT INTO users (full_name, email, password_hash, phone, role) VALUES
('Alice Admin',   'admin@nownow.com',    '$2a$12$KIXsOCb0xRGP1ZNuMwJqiOFP0j7aGJ2sEe2v4e.lnJoEKzlTWkpPy', '555-0100', 'ADMIN'),
('Carol Customer','carol@example.com',   '$2a$12$KIXsOCb0xRGP1ZNuMwJqiOFP0j7aGJ2sEe2v4e.lnJoEKzlTWkpPy', '555-0200', 'CUSTOMER'),
('Dan Deliverer',  'dan@nownow.com',     '$2a$12$KIXsOCb0xRGP1ZNuMwJqiOFP0j7aGJ2sEe2v4e.lnJoEKzlTWkpPy', '555-0300', 'DRIVER'),
('Eve Express',    'eve@nownow.com',     '$2a$12$KIXsOCb0xRGP1ZNuMwJqiOFP0j7aGJ2sEe2v4e.lnJoEKzlTWkpPy', '555-0400', 'DRIVER'),
('Frank Fast',     'frank@example.com',  '$2a$12$KIXsOCb0xRGP1ZNuMwJqiOFP0j7aGJ2sEe2v4e.lnJoEKzlTWkpPy', '555-0500', 'CUSTOMER');

-- -------------------------------------------------------
-- Driver profiles (for users with role = DRIVER)
-- -------------------------------------------------------
INSERT INTO drivers (user_id, vehicle_type, license_number, availability_status,
                     current_latitude, current_longitude, rating, total_deliveries)
VALUES
(3, 'MOTORBIKE', 'DL-DAN-001', 'AVAILABLE', 40.7128, -74.0060, 4.85, 127),
(4, 'CAR',       'DL-EVE-002', 'OFFLINE',   40.7580, -73.9855, 4.92,  89);

-- -------------------------------------------------------
-- Packages
-- -------------------------------------------------------
INSERT INTO packages (tracking_number, sender_id, description, weight_kg,
                      pickup_address, delivery_address,
                      recipient_name, recipient_phone, status, estimated_price)
VALUES
('NN-20240001', 2, 'Laptop bag',        1.50, '10 Main St, New York, NY',   '55 Park Ave, New York, NY',    'Bob Recipient',  '555-1001', 'DELIVERED',  12.50),
('NN-20240002', 2, 'Birthday gift box', 0.80, '10 Main St, New York, NY',   '120 Wall St, New York, NY',    'Sara Smith',     '555-1002', 'IN_TRANSIT',  9.00),
('NN-20240003', 5, 'Documents folder',  0.20, '98 Broadway, New York, NY',  '5 Times Sq, New York, NY',     'Legal Dept',     '555-1003', 'PENDING',     5.50),
('NN-20240004', 5, 'Electronics kit',   2.30, '98 Broadway, New York, NY',  '230 5th Ave, New York, NY',    'Tech Dept',      '555-1004', 'ASSIGNED',   15.00),
('NN-20240005', 2, 'Clothing parcel',   1.10, '10 Main St, New York, NY',   '800 Lexington Ave, New York, NY','Mary Johnson',  '555-1005', 'PENDING',     8.00);

-- -------------------------------------------------------
-- Deliveries (assigned packages)
-- -------------------------------------------------------
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status)
VALUES
(1, 1, '2024-03-10 09:00:00', '2024-03-10 09:30:00', '2024-03-10 10:45:00', 'DELIVERED'),
(2, 1, '2024-03-12 14:00:00', '2024-03-12 14:20:00', NULL,                  'IN_TRANSIT'),
(4, 2, '2024-03-13 08:00:00', NULL,                  NULL,                  'ASSIGNED');

-- -------------------------------------------------------
-- Tracking events
-- -------------------------------------------------------
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
-- Package 1 (delivered)
(1, '2024-03-10 09:00:00', 'PENDING',    'Package registered',               40.7128, -74.0060),
(1, '2024-03-10 09:00:00', 'ASSIGNED',   'Driver Dan Deliverer assigned',    40.7128, -74.0060),
(1, '2024-03-10 09:30:00', 'PICKED_UP',  'Package picked up by driver',      40.7128, -74.0060),
(1, '2024-03-10 10:15:00', 'IN_TRANSIT', 'On the way to destination',        40.7200, -74.0030),
(1, '2024-03-10 10:45:00', 'DELIVERED',  'Package delivered successfully',   40.7484, -74.0059),
-- Package 2 (in transit)
(2, '2024-03-12 13:00:00', 'PENDING',    'Package registered',               40.7128, -74.0060),
(2, '2024-03-12 14:00:00', 'ASSIGNED',   'Driver Dan Deliverer assigned',    40.7128, -74.0060),
(2, '2024-03-12 14:20:00', 'PICKED_UP',  'Package picked up by driver',      40.7128, -74.0060),
(2, '2024-03-12 14:50:00', 'IN_TRANSIT', 'En route to destination',          40.7250, -74.0020),
-- Package 3 (pending)
(3, '2024-03-13 10:00:00', 'PENDING',    'Package registered, awaiting driver', 40.7080, -74.0100),
-- Package 4 (assigned)
(4, '2024-03-13 07:30:00', 'PENDING',    'Package registered',               40.7080, -74.0100),
(4, '2024-03-13 08:00:00', 'ASSIGNED',   'Driver Eve Express assigned',      40.7580, -73.9855),
-- Package 5 (pending)
(5, '2024-03-13 11:00:00', 'PENDING',    'Package registered, awaiting driver', 40.7128, -74.0060);
