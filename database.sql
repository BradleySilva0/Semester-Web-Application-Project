


CREATE TABLE IF NOT EXISTS users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    password TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'Passenger' CHECK(role IN ('Passenger','Driver','Admin')),
    date_created TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS user_login (
    login_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    last_login TEXT DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS bookings (
    booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    pickup_location TEXT NOT NULL,
    dropoff_location TEXT NOT NULL,
    pickup_time TEXT,
    distance_km REAL,
    estimated_fare REAL,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK(status IN ('Pending','Accepted','Completed','Cancelled')),
    booking_date TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_availability (
    availability_id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id INTEGER NOT NULL,
    available_from TEXT,
    available_until TEXT,
    current_location TEXT,
    status TEXT NOT NULL DEFAULT 'Available' CHECK(status IN ('Available','Unavailable')),
    FOREIGN KEY (driver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    booking_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    method TEXT NOT NULL DEFAULT 'Cash' CHECK(method IN ('Cash','Card','Wallet','Other')),
    payment_status TEXT NOT NULL DEFAULT 'Pending' CHECK(payment_status IN ('Pending','Paid','Failed')),
    transaction_date TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_profile (
    driver_id INTEGER PRIMARY KEY,
    license_number TEXT,
    vehicle_make TEXT,
    vehicle_model TEXT,
    vehicle_plate TEXT,
    profile_picture TEXT,
    rating REAL DEFAULT 0.00,
    FOREIGN KEY (driver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_routes (
    route_id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id INTEGER NOT NULL,
    start_location TEXT,
    end_location TEXT,
    route_distance_km REAL,
    trip_time_estimate TEXT,
    FOREIGN KEY (driver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS driver_earnings (
    earning_id INTEGER PRIMARY KEY AUTOINCREMENT,
    driver_id INTEGER NOT NULL,
    total_trips INTEGER DEFAULT 0,
    total_earnings REAL DEFAULT 0.00,
    last_payment_date TEXT,
    FOREIGN KEY (driver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_activity (
    activity_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    page_name TEXT,
    action_description TEXT,
    timestamp TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);






BEGIN TRANSACTION;

-- USERS
INSERT OR IGNORE INTO users (full_name, email, phone, password, role, date_created) VALUES
('Aisha Ncube', 'aisha.admin@example.com', '+263771000001', 'adminpass', 'Admin', datetime('now','-30 days')),
('Daniel King', 'daniel.driver@example.com', '+263771000002', 'driverpass', 'Driver', datetime('now','-25 days')),
('Maria Gomez', 'maria.driver@example.com', '+263771000003', 'driverpass2', 'Driver', datetime('now','-20 days')),
('Noah Patel', 'noah.passenger@example.com', '+263771000004', 'password123', 'Passenger', datetime('now','-10 days')),
('Lina Chen', 'lina.passenger@example.com', '+263771000005', 'securepwd', 'Passenger', datetime('now','-9 days')),
('Omar Ali', 'omar.driver@example.com', '+263771000006', 'driverpwd3', 'Driver', datetime('now','-8 days')),
('Test User', 'test.user@example.com', '+263771000007', 'testpass', 'Passenger', datetime('now','-2 days')),
('Sara Lee', 'sara.lee@example.com', '+263771000008', 'sarapass', 'Passenger', datetime('now','-1 days'));


-- LOGIN TRACKING
INSERT INTO user_login (user_id, last_login) VALUES
(1, datetime('now','-1 day')),
(2, datetime('now','-3 hours')),
(4, datetime('now','-2 days')),
(5, datetime('now','-5 hours')),
(7, datetime('now','-30 minutes'));

-- DRIVER PROFILE
INSERT OR IGNORE INTO driver_profile (license_number, vehicle_make, vehicle_model, vehicle_plate, profile_picture, rating) VALUES
('DL-89234', 'Toyota', 'Corolla', 'ABC-234', '/images/drivers/daniel.jpg', 4.85),
('DL-77411', 'Hyundai', 'Accent', 'XYZ-111', '/images/drivers/maria.jpg', 4.72),
('DL-66009', 'Kia', 'Rio', 'KIA-660', '/images/drivers/omar.jpg', 4.60);

-- DRIVER AVAILABILITY
INSERT INTO driver_availability (driver_id, available_from, available_until, current_location, status) VALUES
(2, datetime('now','-2 hours'), datetime('now','+6 hours'), 'Downtown', 'Available'),
(3, datetime('now','-1 hour'), datetime('now','+4 hours'), 'Northside', 'Available'),
(6, datetime('now','+1 hour'), datetime('now','+8 hours'), 'Airport Road', 'Unavailable');

-- BOOKINGS
INSERT INTO bookings (user_id, pickup_location, dropoff_location, pickup_time, distance_km, estimated_fare, status, booking_date) VALUES
(4, '12 A Maple St', 'Central Station', '2025-10-23 14:00:00', 8.4, 7.50, 'Completed', datetime('now','-2 days')),
(5, '45 B Oak St', 'City Mall', NULL, 3.2, 3.00, 'Pending', datetime('now','-1 day')),
(7, 'Office Park', 'Airport', '2025-10-24 09:30:00', 15.0, 18.00, 'Accepted', datetime('now','-6 hours')),
(8, 'Northside Plaza', 'University Gate', '2025-10-23 18:00:00', 6.1, 5.50, 'Cancelled', datetime('now','-3 days')),
(4, 'Central Station', '12 A Maple St', '2025-10-23 16:00:00', 8.4, 7.50, 'Completed', datetime('now','-1 day')),
(5, 'City Mall', 'Home Lane 7', '2025-10-25 20:00:00', 4.8, 4.20, 'Pending', datetime('now'));

-- PAYMENTS
INSERT INTO payments (booking_id, user_id, amount, method, payment_status, transaction_date) VALUES
(1, 4, 7.50, 'Card', 'Paid', datetime('now','-2 days')),
(5, 4, 7.50, 'Wallet', 'Paid', datetime('now','-1 day')),
(4, 8, 5.50, 'Card', 'Failed', datetime('now','-3 days'));

-- DRIVER ROUTES
INSERT INTO driver_routes (driver_id, start_location, end_location, route_distance_km, trip_time_estimate) VALUES
(2, 'Downtown', 'Central Station', 8.5, '20 mins'),
(3, 'Northside', 'City Mall', 3.3, '10 mins'),
(6, 'Airport Road', 'City Center', 14.8, '30 mins'),
(2, 'Central Station', 'Airport', 16.0, '35 mins');

-- DRIVER EARNINGS
INSERT INTO driver_earnings (driver_id, total_trips, total_earnings, last_payment_date) VALUES
(2, 124, 950.75, date('now','-7 days')),
(3, 88, 642.40, date('now','-14 days')),
(6, 42, 310.00, date('now','-30 days'));

-- USER ACTIVITY
INSERT INTO user_activity (user_id, page_name, action_description, timestamp) VALUES
(4, 'Booking', 'Created booking #1 from 12 A Maple St to Central Station', datetime('now','-2 days')),
(2, 'Availability', 'Set status Available and updated current location to Downtown', datetime('now','-2 hours')),
(7, 'Profile', 'Updated phone number', datetime('now','-1 day')),
(5, 'Payment', 'Attempted payment for booking #4 (failed)', datetime('now','-3 days')),
(1, 'Admin', 'Reviewed driver earnings report', datetime('now','-5 hours'));

COMMIT;
