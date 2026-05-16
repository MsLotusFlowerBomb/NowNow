-- ============================================================
--  NowNow Courier Delivery System – Seed Data (Apache Derby)
--  Run AFTER schema creation script.
--  Gives 10+ records per main table for Assessment 5.
-- ============================================================
 
-- -------------------------------------------------------
-- Clear existing data (FK-safe order)
-- -------------------------------------------------------
DELETE FROM tracking_events;
DELETE FROM deliveries;
DELETE FROM packages;
DELETE FROM drivers;
DELETE FROM users;
 
-- -------------------------------------------------------
-- USERS  (10 rows: 1 admin, 4 customers, 5 drivers)
-- Derby uses GENERATED ALWAYS AS IDENTITY — don't supply id.
-- -------------------------------------------------------
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Alice Admin',      'admin@nownow.com',      '0110001111', 'ADMIN',    'Admin@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Carol Customer',   'carol@example.com',     '0821112222', 'CUSTOMER', 'Carol@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Frank Fast',       'frank@example.com',     '0833334444', 'CUSTOMER', 'Frank@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Grace Green',      'grace@example.com',     '0844445555', 'CUSTOMER', 'Grace@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Henry Hill',       'henry@example.com',     '0855556666', 'CUSTOMER', 'Henry@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Dan Deliverer',    'dan@nownow.com',        '0711110001', 'DRIVER',   'Driver@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Eve Express',      'eve@nownow.com',        '0711110002', 'DRIVER',   'Driver@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Ivan Igwe',        'ivan@nownow.com',       '0711110003', 'DRIVER',   'Driver@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Joyce Jansen',     'joyce@nownow.com',      '0711110004', 'DRIVER',   'Driver@1234');
INSERT INTO users (full_name, email, phone, role, password) VALUES
('Kevin Khumalo',    'kevin@nownow.com',      '0711110005', 'DRIVER',   'Driver@1234');
 
-- -------------------------------------------------------
-- DRIVERS  (5 rows — subselect by email avoids hardcoded IDs)
-- -------------------------------------------------------
INSERT INTO drivers (user_id, vehicle_type, license_number, availability_status, current_latitude, current_longitude, rating, total_deliveries) VALUES
((SELECT id FROM users WHERE email = 'dan@nownow.com'),   'MOTORBIKE', 'GP-MOT-001', 'AVAILABLE',    -25.7479,  28.2293, 4.85, 127);
INSERT INTO drivers (user_id, vehicle_type, license_number, availability_status, current_latitude, current_longitude, rating, total_deliveries) VALUES
((SELECT id FROM users WHERE email = 'eve@nownow.com'),   'CAR',       'GP-CAR-002', 'OFFLINE',      -26.2041,  28.0473, 4.92,  89);
INSERT INTO drivers (user_id, vehicle_type, license_number, availability_status, current_latitude, current_longitude, rating, total_deliveries) VALUES
((SELECT id FROM users WHERE email = 'ivan@nownow.com'),  'BICYCLE',   'GP-BIC-003', 'AVAILABLE',    -25.8553,  28.1878, 4.70,  54);
INSERT INTO drivers (user_id, vehicle_type, license_number, availability_status, current_latitude, current_longitude, rating, total_deliveries) VALUES
((SELECT id FROM users WHERE email = 'joyce@nownow.com'), 'MOTORBIKE', 'GP-MOT-004', 'ON_DELIVERY',  -26.1500,  27.8700, 4.60,  38);
INSERT INTO drivers (user_id, vehicle_type, license_number, availability_status, current_latitude, current_longitude, rating, total_deliveries) VALUES
((SELECT id FROM users WHERE email = 'kevin@nownow.com'), 'CAR',       'GP-CAR-005', 'AVAILABLE',    -25.7800,  28.3000, 4.78,  71);
 
-- -------------------------------------------------------
-- PACKAGES  (12 rows across 4 customers)
-- Derby does not support NOW() - use CURRENT_TIMESTAMP.
-- Derby does not support INTERVAL arithmetic in plain SQL.
-- Use fixed timestamps spread over the past few months.
-- -------------------------------------------------------
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240001', (SELECT id FROM users WHERE email = 'carol@example.com'), 'Laptop bag',         2.50, '12 Rose St, Johannesburg',  '55 Park Ave, Sandton',          'Bob Recipient',   '0821119991', 'DELIVERED',  13.75);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240002', (SELECT id FROM users WHERE email = 'carol@example.com'), 'Legal documents',    0.30, '12 Rose St, Johannesburg',  '120 West St, Sandton',          'Sara Smith',      '0831119992', 'IN_TRANSIT',  6.05);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240003', (SELECT id FROM users WHERE email = 'frank@example.com'), 'Birthday cake box',  3.00, '7 Oak Ave, Pretoria',       '5 Church St, Pretoria CBD',     'Legal Dept',      '0121110003', 'PENDING',    15.50);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240004', (SELECT id FROM users WHERE email = 'frank@example.com'), 'Electronics kit',    4.20, '7 Oak Ave, Pretoria',       '230 5th St, Hatfield',          'Tech Department', '0121110004', 'ASSIGNED',   19.70);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240005', (SELECT id FROM users WHERE email = 'carol@example.com'), 'Clothing parcel',    1.80, '12 Rose St, Johannesburg',  '800 Lexington Rd, Midrand',     'Mary Johnson',    '0841119995', 'PENDING',    11.30);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240006', (SELECT id FROM users WHERE email = 'grace@example.com'), 'Medical supplies',   0.90, '3 Elm Rd, Centurion',       '14 Hospital Rd, Centurion',     'Dr. Nkosi',       '0124440006', 'DELIVERED',   8.15);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240007', (SELECT id FROM users WHERE email = 'grace@example.com'), 'Textbooks',          5.00, '3 Elm Rd, Centurion',       '22 University Ave, Pretoria',   'Prof. Adams',     '0124440007', 'DELIVERED',  22.50);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240008', (SELECT id FROM users WHERE email = 'henry@example.com'), 'Baby shower gift',   2.10, '9 Maple Dr, Roodepoort',    '67 Pine Rd, Krugersdorp',       'Lindiwe Dube',    '0112220008', 'IN_TRANSIT', 12.35);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240009', (SELECT id FROM users WHERE email = 'henry@example.com'), 'Office stationery',  1.20, '9 Maple Dr, Roodepoort',    '101 Commissioner St, CBD',      'Office Manager',  '0112220009', 'DELIVERED',   9.20);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240010', (SELECT id FROM users WHERE email = 'frank@example.com'), 'Fragile glassware',  3.80, '7 Oak Ave, Pretoria',       '88 Lynnwood Rd, Menlyn',        'Sandra Nel',      '0761110010', 'ASSIGNED',   18.30);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240011', (SELECT id FROM users WHERE email = 'carol@example.com'), 'Gym equipment',      8.50, '12 Rose St, Johannesburg',  '45 Fitness Blvd, Midrand',      'Thabo Mokoena',   '0791110011', 'PENDING',    34.75);
INSERT INTO packages (tracking_number, sender_id, description, weight_kg, pickup_address, delivery_address, recipient_name, recipient_phone, status, estimated_price) VALUES
('NN-20240012', (SELECT id FROM users WHERE email = 'grace@example.com'), 'Art supplies',       1.50, '3 Elm Rd, Centurion',       '19 Gallery Lane, Hatfield',     'Riya Patel',      '0731110012', 'PENDING',    10.25);
 
-- -------------------------------------------------------
-- DELIVERIES  (8 rows for assigned/in-transit/delivered packages)
-- -------------------------------------------------------
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-MOT-001'),
 TIMESTAMP('2024-03-10 09:00:00'), TIMESTAMP('2024-03-10 09:30:00'), TIMESTAMP('2024-03-10 10:45:00'),
 'DELIVERED', 'Delivered successfully, signature obtained.');
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-MOT-004'),
 TIMESTAMP('2024-03-12 14:00:00'), TIMESTAMP('2024-03-12 14:20:00'), NULL,
 'IN_TRANSIT', 'Package picked up, en route to destination.');
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240004'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-MOT-001'),
 TIMESTAMP('2024-03-13 08:00:00'), NULL, NULL,
 'ASSIGNED', 'Driver assigned, awaiting pickup.');
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240006'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-BIC-003'),
 TIMESTAMP('2024-03-15 10:00:00'), TIMESTAMP('2024-03-15 10:30:00'), TIMESTAMP('2024-03-15 12:00:00'),
 'DELIVERED', 'Left at reception desk with security.');
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240007'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-CAR-005'),
 TIMESTAMP('2024-03-18 09:00:00'), TIMESTAMP('2024-03-18 09:45:00'), TIMESTAMP('2024-03-18 11:30:00'),
 'DELIVERED', 'Recipient confirmed delivery via SMS.');
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240008'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-MOT-004'),
 TIMESTAMP('2024-03-20 13:00:00'), TIMESTAMP('2024-03-20 13:30:00'), NULL,
 'IN_TRANSIT', 'Out for delivery, ETA this afternoon.');
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240009'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-CAR-002'),
 TIMESTAMP('2024-03-22 08:00:00'), TIMESTAMP('2024-03-22 08:30:00'), TIMESTAMP('2024-03-22 10:00:00'),
 'DELIVERED', 'Delivered to office reception.');
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status, notes) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240010'),
 (SELECT id FROM drivers  WHERE license_number  = 'GP-MOT-001'),
 TIMESTAMP('2024-03-25 07:30:00'), NULL, NULL,
 'ASSIGNED', 'Handle with care – fragile contents.');
 
-- -------------------------------------------------------
-- TRACKING EVENTS  (full timeline per package)
-- -------------------------------------------------------
-- Package 1 (DELIVERED)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 08:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -26.2041,  28.0473);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 09:00:00'), 'ASSIGNED',   'Driver Dan Deliverer has been assigned.',            -26.2041,  28.0473);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 09:30:00'), 'PICKED_UP',  'Package picked up from sender.',                     -26.2041,  28.0473);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 10:15:00'), 'IN_TRANSIT', 'Package on the way to destination.',                 -26.1929,  28.0305);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 10:45:00'), 'DELIVERED',  'Package delivered successfully. Signature obtained.', -26.1076,  28.0567);
 
-- Package 2 (IN_TRANSIT)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 13:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -26.2041,  28.0473);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 14:00:00'), 'ASSIGNED',   'Driver Joyce Jansen has been assigned.',             -26.2041,  28.0473);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 14:20:00'), 'PICKED_UP',  'Package picked up from sender.',                     -26.2041,  28.0473);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 14:50:00'), 'IN_TRANSIT', 'En route to destination.',                           -26.1500,  28.0400);
 
-- Package 3 (PENDING)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240003'), TIMESTAMP('2024-03-14 10:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -25.7479,  28.2293);
 
-- Package 4 (ASSIGNED)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240004'), TIMESTAMP('2024-03-13 07:30:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -25.7479,  28.2293);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240004'), TIMESTAMP('2024-03-13 08:00:00'), 'ASSIGNED',   'Driver Dan Deliverer has been assigned.',            -25.7479,  28.2293);
 
-- Package 5 (PENDING)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240005'), TIMESTAMP('2024-03-15 11:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -26.2041,  28.0473);
 
-- Package 6 (DELIVERED)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240006'), TIMESTAMP('2024-03-15 09:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -25.8553,  28.1878);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240006'), TIMESTAMP('2024-03-15 10:00:00'), 'ASSIGNED',   'Driver Ivan Igwe has been assigned.',                -25.8553,  28.1878);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240006'), TIMESTAMP('2024-03-15 10:30:00'), 'PICKED_UP',  'Package picked up from sender.',                     -25.8553,  28.1878);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240006'), TIMESTAMP('2024-03-15 12:00:00'), 'DELIVERED',  'Left at reception desk with security.',              -25.8700,  28.1900);
 
-- Package 7 (DELIVERED)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240007'), TIMESTAMP('2024-03-18 08:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -25.8553,  28.1878);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240007'), TIMESTAMP('2024-03-18 09:00:00'), 'ASSIGNED',   'Driver Kevin Khumalo has been assigned.',            -25.8553,  28.1878);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240007'), TIMESTAMP('2024-03-18 09:45:00'), 'PICKED_UP',  'Package picked up from sender.',                     -25.8553,  28.1878);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240007'), TIMESTAMP('2024-03-18 10:30:00'), 'IN_TRANSIT', 'Package on the way to destination.',                 -25.7700,  28.2000);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240007'), TIMESTAMP('2024-03-18 11:30:00'), 'DELIVERED',  'Recipient confirmed delivery via SMS.',              -25.7480,  28.2293);
 
-- Package 8 (IN_TRANSIT)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240008'), TIMESTAMP('2024-03-20 12:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -26.1500,  27.8700);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240008'), TIMESTAMP('2024-03-20 13:00:00'), 'ASSIGNED',   'Driver Joyce Jansen has been assigned.',             -26.1500,  27.8700);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240008'), TIMESTAMP('2024-03-20 13:30:00'), 'PICKED_UP',  'Package picked up from sender.',                     -26.1500,  27.8700);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240008'), TIMESTAMP('2024-03-20 14:10:00'), 'IN_TRANSIT', 'Out for delivery, ETA this afternoon.',              -26.1200,  27.7800);
 
-- Package 9 (DELIVERED)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240009'), TIMESTAMP('2024-03-22 07:30:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -26.1500,  27.8700);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240009'), TIMESTAMP('2024-03-22 08:00:00'), 'ASSIGNED',   'Driver Eve Express has been assigned.',              -26.1500,  27.8700);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240009'), TIMESTAMP('2024-03-22 08:30:00'), 'PICKED_UP',  'Package picked up from sender.',                     -26.1500,  27.8700);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240009'), TIMESTAMP('2024-03-22 10:00:00'), 'DELIVERED',  'Package delivered to office reception.',             -26.2023,  28.0436);
 
-- Package 10 (ASSIGNED)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240010'), TIMESTAMP('2024-03-25 07:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -25.7479,  28.2293);
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240010'), TIMESTAMP('2024-03-25 07:30:00'), 'ASSIGNED',   'Driver Dan Deliverer has been assigned.',            -25.7479,  28.2293);
 
-- Package 11 (PENDING)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240011'), TIMESTAMP('2024-04-01 09:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -26.2041,  28.0473);
 
-- Package 12 (PENDING)
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
((SELECT id FROM packages WHERE tracking_number = 'NN-20240012'), TIMESTAMP('2024-04-05 11:00:00'), 'PENDING',    'Package registered and awaiting driver assignment.', -25.8553,  28.1878);
 
-- -------------------------------------------------------
-- VERIFY (run these individually to confirm row counts)
-- -------------------------------------------------------
SELECT 'users'           AS tbl, COUNT(*) AS cnt FROM users
UNION ALL SELECT 'drivers',          COUNT(*) FROM drivers
UNION ALL SELECT 'packages',         COUNT(*) FROM packages
UNION ALL SELECT 'deliveries',       COUNT(*) FROM deliveries
UNION ALL SELECT 'tracking_events',  COUNT(*) FROM tracking_events;
