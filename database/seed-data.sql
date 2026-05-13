-- ============================================================
--  NowNow Courier Delivery System – Seed Data (Derby/JavaDB)
-- ============================================================

-- -------------------------------------------------------
-- Users (no password column — add it to schema if needed)
-- -------------------------------------------------------
INSERT INTO users (full_name, email, phone, role, password) VALUES
 ('Alice Admin',    'admin@nownow.com',  '0612345678', 'ADMIN','password!'),
 ('Carol Customer', 'carol@example.com', '0612345677', 'CUSTOMER','password!'),
 ('Dan Deliverer',  'dan@nownow.com',    '0612345676', 'DRIVER','password!'),
 ('Eve Express',    'eve@nownow.com',    '0612345675', 'DRIVER','password!'),
 ('Frank Fast',     'frank@example.com', '0612345674', 'CUSTOMER','password!'),
 ('Frank Ocean',    'ocean@gmail.com',   '0612345673', 'CUSTOMER','password!'),
 ('Eze Ebube',      'ezeB@yahoo.com',    '0612345672', 'CUSTOMER','password!');

-- -------------------------------------------------------
-- Driver profiles (look up user_id by email to avoid hardcoding)
-- -------------------------------------------------------
INSERT INTO drivers (user_id, vehicle_type, license_number, availability_status,
    current_latitude, current_longitude, rating, total_deliveries)
VALUES
 ((SELECT id FROM users WHERE email = 'dan@nownow.com'),
  'MOTORBIKE', 'DL-DAN-001', 'AVAILABLE', 40.7128, -74.0060, 4.85, 127),

 ((SELECT id FROM users WHERE email = 'eve@nownow.com'),
  'CAR', 'DL-EVE-002', 'OFFLINE', 40.7580, -73.9855, 4.92, 89);

-- -------------------------------------------------------
-- Packages (look up sender_id by email)
-- -------------------------------------------------------
INSERT INTO packages (tracking_number, sender_id, description, weight_kg,
    pickup_address, delivery_address,
    recipient_name, recipient_phone, status, estimated_price)
VALUES
 ('NN-20240001', (SELECT id FROM users WHERE email = 'carol@example.com'),
  'Laptop bag',        1.50, '10 Main St, New York, NY',  '55 Park Ave, New York, NY',
  'Bob Recipient', '0621234568', 'DELIVERED',  112.50),

 ('NN-20240002', (SELECT id FROM users WHERE email = 'carol@example.com'),
  'Birthday gift box', 0.80, '10 Main St, New York, NY',  '120 Wall St, New York, NY',
  'Sara Smith',    '0621234566', 'IN_TRANSIT', 198.00),

 ('NN-20240003', (SELECT id FROM users WHERE email = 'frank@example.com'),
  'Documents folder',  0.20, '98 Broadway, New York, NY', '5 Times Sq, New York, NY',
  'Legal Dept',    '0621234565', 'PENDING',    150.50),

 ('NN-20240004', (SELECT id FROM users WHERE email = 'frank@example.com'),
  'Electronics kit',   2.30, '98 Broadway, New York, NY', '230 5th Ave, New York, NY',
  'Tech Dept',     '0621234564', 'ASSIGNED',   115.00),

 ('NN-20240005', (SELECT id FROM users WHERE email = 'carol@example.com'),
  'Clothing parcel',   1.10, '10 Main St, New York, NY',  '800 Lexington Ave, New York, NY',
  'Mary Johnson',  '0621234563', 'PENDING',    185.00);

-- -------------------------------------------------------
-- Deliveries (look up package_id and driver_id by natural keys)
-- -------------------------------------------------------
INSERT INTO deliveries (package_id, driver_id, assigned_at, picked_up_at, delivered_at, status)
VALUES
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'),
  (SELECT id FROM drivers  WHERE license_number  = 'DL-DAN-001'),
  TIMESTAMP('2024-03-10 09:00:00'), TIMESTAMP('2024-03-10 09:30:00'), TIMESTAMP('2024-03-10 10:45:00'),
  'DELIVERED'),

 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'),
  (SELECT id FROM drivers  WHERE license_number  = 'DL-DAN-001'),
  TIMESTAMP('2024-03-12 14:00:00'), TIMESTAMP('2024-03-12 14:20:00'), NULL,
  'IN_TRANSIT'),

 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240004'),
  (SELECT id FROM drivers  WHERE license_number  = 'DL-EVE-002'),
  TIMESTAMP('2024-03-13 08:00:00'), NULL, NULL,
  'ASSIGNED');

-- -------------------------------------------------------
-- Tracking events
-- -------------------------------------------------------
INSERT INTO tracking_events (package_id, event_time, status, description, latitude, longitude) VALUES
 -- Package 1 (delivered)
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 09:00:00'), 'PENDING',    'Package registered',                    40.7128, -74.0060),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 09:00:00'), 'ASSIGNED',   'Driver Dan Deliverer assigned',         40.7128, -74.0060),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 09:30:00'), 'PICKED_UP',  'Package picked up by driver',           40.7128, -74.0060),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 10:15:00'), 'IN_TRANSIT', 'On the way to destination',             40.7200, -74.0030),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240001'), TIMESTAMP('2024-03-10 10:45:00'), 'DELIVERED',  'Package delivered successfully',        40.7484, -74.0059),
 -- Package 2 (in transit)
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 13:00:00'), 'PENDING',    'Package registered',                    40.7128, -74.0060),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 14:00:00'), 'ASSIGNED',   'Driver Dan Deliverer assigned',         40.7128, -74.0060),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 14:20:00'), 'PICKED_UP',  'Package picked up by driver',           40.7128, -74.0060),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240002'), TIMESTAMP('2024-03-12 14:50:00'), 'IN_TRANSIT', 'En route to destination',               40.7250, -74.0020),
 -- Package 3 (pending)
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240003'), TIMESTAMP('2024-03-13 10:00:00'), 'PENDING',    'Package registered, awaiting driver',   40.7080, -74.0100),
 -- Package 4 (assigned)
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240004'), TIMESTAMP('2024-03-13 07:30:00'), 'PENDING',    'Package registered',                    40.7080, -74.0100),
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240004'), TIMESTAMP('2024-03-13 08:00:00'), 'ASSIGNED',   'Driver Eve Express assigned',           40.7580, -73.9855),
 -- Package 5 (pending)
 ((SELECT id FROM packages WHERE tracking_number = 'NN-20240005'), TIMESTAMP('2024-03-13 11:00:00'), 'PENDING',    'Package registered, awaiting driver',   40.7128, -74.0060);
