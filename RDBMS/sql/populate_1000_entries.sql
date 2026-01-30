-- ============================================
-- POPULATE DATABASE WITH 1000+ ENTRIES
-- This script adds data to all 18 tables
-- Run this in phpMyAdmin
-- ============================================

-- ============================================
-- 1. AIRCRAFT_TYPES (Add more types)
-- ============================================
INSERT IGNORE INTO aircraft_types (aircraft_type_id, model, manufacturer, seating_capacity) VALUES
(5, 'A330', 'Airbus', 335),
(6, 'B777', 'Boeing', 396),
(7, 'A350', 'Airbus', 325),
(8, 'B787-9', 'Boeing', 290),
(9, 'A380', 'Airbus', 555),
(10, 'B747', 'Boeing', 416);

-- ============================================
-- 2. AIRPORTS (Add more airports - total 25)
-- ============================================
INSERT IGNORE INTO airport (airport_id, name, city, state, country, airport_code) VALUES
(11, 'Goa International Airport', 'Goa', 'Goa', 'India', 'GOI'),
(12, 'Srinagar Airport', 'Srinagar', 'Jammu and Kashmir', 'India', 'SXR'),
(13, 'Leh Airport', 'Leh', 'Ladakh', 'India', 'IXL'),
(14, 'Amritsar Airport', 'Amritsar', 'Punjab', 'India', 'ATQ'),
(15, 'Varanasi Airport', 'Varanasi', 'Uttar Pradesh', 'India', 'VNS'),
(16, 'Lucknow Airport', 'Lucknow', 'Uttar Pradesh', 'India', 'LKO'),
(17, 'Patna Airport', 'Patna', 'Bihar', 'India', 'PAT'),
(18, 'Guwahati Airport', 'Guwahati', 'Assam', 'India', 'GAU'),
(19, 'Imphal Airport', 'Imphal', 'Manipur', 'India', 'IMF'),
(20, 'Agartala Airport', 'Agartala', 'Tripura', 'India', 'IXA'),
(21, 'Bhubaneswar Airport', 'Bhubaneswar', 'Odisha', 'India', 'BBI'),
(22, 'Raipur Airport', 'Raipur', 'Chhattisgarh', 'India', 'RPR'),
(23, 'Indore Airport', 'Indore', 'Madhya Pradesh', 'India', 'IDR'),
(24, 'Bhopal Airport', 'Bhopal', 'Madhya Pradesh', 'India', 'BHO'),
(25, 'Nagpur Airport', 'Nagpur', 'Maharashtra', 'India', 'NAG');

-- ============================================
-- 3. AIRCRAFT (Add more aircraft - total 40)
-- ============================================
INSERT IGNORE INTO aircraft (aircraft_id, aircraft_type_id, registration_no, manufacture_date) VALUES
(9, 1, 'VT-AAI', '2021-05-10'),
(10, 2, 'VT-AAJ', '2020-08-15'),
(11, 3, 'VT-AAK', '2022-01-20'),
(12, 4, 'VT-AAL', '2021-11-05'),
(13, 5, 'VT-AAM', '2020-03-12'),
(14, 1, 'VT-AAN', '2022-06-18'),
(15, 2, 'VT-AAO', '2019-09-25'),
(16, 3, 'VT-AAP', '2021-12-30'),
(17, 5, 'VT-AAQ', '2020-07-08'),
(18, 1, 'VT-AAR', '2022-02-14'),
(19, 2, 'VT-AAS', '2021-04-22'),
(20, 4, 'VT-AAT', '2020-10-11'),
(21, 3, 'VT-AAU', '2022-08-05'),
(22, 1, 'VT-AAV', '2021-01-19'),
(23, 2, 'VT-AAW', '2020-05-27'),
(24, 5, 'VT-AAX', '2022-03-09'),
(25, 1, 'VT-AAY', '2021-07-16'),
(26, 3, 'VT-AAZ', '2020-12-03'),
(27, 2, 'VT-ABA', '2022-09-21'),
(28, 4, 'VT-ABB', '2021-02-28'),
(29, 1, 'VT-ABC', '2020-06-14'),
(30, 5, 'VT-ABD', '2022-04-07'),
(31, 2, 'VT-ABE', '2021-08-23'),
(32, 3, 'VT-ABF', '2020-11-30'),
(33, 1, 'VT-ABG', '2022-10-12'),
(34, 4, 'VT-ABH', '2021-03-18'),
(35, 2, 'VT-ABI', '2020-09-05'),
(36, 5, 'VT-ABJ', '2022-05-25'),
(37, 1, 'VT-ABK', '2021-09-11'),
(38, 3, 'VT-ABL', '2020-04-20'),
(39, 2, 'VT-ABM', '2022-11-08'),
(40, 4, 'VT-ABN', '2021-05-02');

-- ============================================
-- 4. ROUTES (Add routes for all airport combinations - total 600 routes)
-- ============================================
-- Generate routes for airports 11-25 with existing airports 1-10
-- This creates routes like: 11->1, 11->2, ..., 11->25, 12->1, etc.

-- Routes from new airports (11-25) to all airports (1-25)
INSERT IGNORE INTO routes (origin_airport_id, destination_airport_id, distance_km)
SELECT 
    o.airport_id as origin,
    d.airport_id as dest,
    CASE 
        WHEN o.airport_id = d.airport_id THEN 0
        ELSE 500 + (ABS(o.airport_id - d.airport_id) * 50) + (RAND() * 2000)
    END as distance
FROM airport o
CROSS JOIN airport d
WHERE o.airport_id BETWEEN 11 AND 25
AND d.airport_id BETWEEN 1 AND 25
AND o.airport_id != d.airport_id
AND NOT EXISTS (
    SELECT 1 FROM routes r 
    WHERE r.origin_airport_id = o.airport_id 
    AND r.destination_airport_id = d.airport_id
)
LIMIT 300;

-- ============================================
-- 5. SEATS (Add seats for new aircraft - total 2000+ seats)
-- ============================================
-- Create seats for aircraft 9-40 (32 aircraft x ~60 seats = 1920 seats)
-- Using a stored procedure approach with INSERT statements

-- Aircraft 9-40: Create 60 seats each (20 rows x 3 seats per row for simplicity)
INSERT IGNORE INTO seats (aircraft_id, seat_number, seat_class)
SELECT 
    a.aircraft_id,
    CONCAT(
        FLOOR((n-1)/3) + 1,
        CASE ((n-1) % 3)
            WHEN 0 THEN 'A'
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'C'
        END
    ) as seat_number,
    CASE 
        WHEN n <= 6 THEN 'First'
        WHEN n <= 18 THEN 'Business'
        ELSE 'Economy'
    END as seat_class
FROM aircraft a
CROSS JOIN (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION
    SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11 UNION SELECT 12 UNION
    SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION
    SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION
    SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION
    SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35 UNION SELECT 36 UNION
    SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION SELECT 41 UNION SELECT 42 UNION
    SELECT 43 UNION SELECT 44 UNION SELECT 45 UNION SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION
    SELECT 49 UNION SELECT 50 UNION SELECT 51 UNION SELECT 52 UNION SELECT 53 UNION SELECT 54 UNION
    SELECT 55 UNION SELECT 56 UNION SELECT 57 UNION SELECT 58 UNION SELECT 59 UNION SELECT 60
) numbers
WHERE a.aircraft_id BETWEEN 9 AND 40
AND NOT EXISTS (
    SELECT 1 FROM seats s 
    WHERE s.aircraft_id = a.aircraft_id 
    AND s.seat_number = CONCAT(
        FLOOR((numbers.n-1)/3) + 1,
        CASE ((numbers.n-1) % 3)
            WHEN 0 THEN 'A'
            WHEN 1 THEN 'B'
            WHEN 2 THEN 'C'
        END
    )
);

-- ============================================
-- 6. FLIGHTS (Add flights for next 60 days - total 500+ flights)
-- ============================================
-- Create flights for all routes for next 60 days
-- 2 flights per route per day = lots of flights

INSERT INTO flights (flight_no, route_id, aircraft_id, scheduled_departure, scheduled_arrival)
SELECT 
    CONCAT(
        UPPER(SUBSTRING(a1.airport_code, 1, 2)),
        UPPER(SUBSTRING(a2.airport_code, 1, 2)),
        LPAD(FLOOR(RAND() * 1000), 3, '0')
    ) as flight_no,
    r.route_id,
    (SELECT aircraft_id FROM aircraft ORDER BY RAND() LIMIT 1) as aircraft_id,
    DATE_ADD(CURDATE(), INTERVAL day_offset DAY) + INTERVAL hour_offset HOUR as scheduled_departure,
    DATE_ADD(CURDATE(), INTERVAL day_offset DAY) + INTERVAL hour_offset HOUR + INTERVAL FLOOR(r.distance_km / 800) + 1 HOUR as scheduled_arrival
FROM routes r
JOIN airport a1 ON r.origin_airport_id = a1.airport_id
JOIN airport a2 ON r.destination_airport_id = a2.airport_id
CROSS JOIN (
    SELECT 0 as day_offset UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION
    SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION
    SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION
    SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION
    SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION
    SELECT 29 UNION SELECT 30 UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION
    SELECT 35 UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION
    SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45 UNION SELECT 46 UNION
    SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50 UNION SELECT 51 UNION SELECT 52 UNION
    SELECT 53 UNION SELECT 54 UNION SELECT 55 UNION SELECT 56 UNION SELECT 57 UNION SELECT 58 UNION
    SELECT 59 UNION SELECT 60
) days
CROSS JOIN (
    SELECT 6 as hour_offset UNION SELECT 10 UNION SELECT 14 UNION SELECT 18
) hours
WHERE DATE_ADD(CURDATE(), INTERVAL day_offset DAY) + INTERVAL hour_offset HOUR > NOW()
AND NOT EXISTS (
    SELECT 1 FROM flights f 
    WHERE f.route_id = r.route_id 
    AND DATE(f.scheduled_departure) = DATE_ADD(CURDATE(), INTERVAL day_offset DAY)
    AND HOUR(f.scheduled_departure) = hour_offset
)
LIMIT 500;

-- ============================================
-- 7. ACCOUNTS (Add more user accounts - total 100)
-- ============================================
INSERT IGNORE INTO accounts (email, password) VALUES
('user1@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user2@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user3@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user4@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user5@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user6@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user7@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user8@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user9@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user10@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user11@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user12@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user13@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user14@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user15@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user16@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user17@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user18@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user19@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user20@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user21@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user22@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user23@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user24@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user25@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user26@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user27@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user28@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user29@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user30@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user31@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user32@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user33@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user34@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user35@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user36@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user37@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user38@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user39@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user40@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user41@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user42@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user43@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user44@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user45@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user46@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user47@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user48@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user49@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user50@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user51@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user52@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user53@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user54@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user55@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user56@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user57@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user58@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user59@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user60@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user61@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user62@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user63@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user64@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user65@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user66@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user67@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user68@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user69@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user70@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user71@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user72@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user73@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user74@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user75@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user76@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user77@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user78@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user79@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user80@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user81@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user82@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user83@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user84@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user85@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user86@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user87@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user88@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user89@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi'),
('user90@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- ============================================
-- 8. PASSENGERS (Add passengers - total 150)
-- ============================================
INSERT IGNORE INTO passengers (first_name, last_name, gender, age) VALUES
('Raj', 'Kumar', 'Male', 35), ('Priya', 'Sharma', 'Female', 28), ('Amit', 'Patel', 'Male', 42),
('Sneha', 'Singh', 'Female', 31), ('Vikram', 'Reddy', 'Male', 39), ('Anjali', 'Mehta', 'Female', 26),
('Rahul', 'Gupta', 'Male', 33), ('Kavita', 'Verma', 'Female', 29), ('Suresh', 'Joshi', 'Male', 45),
('Meera', 'Desai', 'Female', 37), ('Arjun', 'Malhotra', 'Male', 30), ('Divya', 'Nair', 'Female', 32),
('Karan', 'Iyer', 'Male', 28), ('Pooja', 'Menon', 'Female', 34), ('Rohan', 'Kapoor', 'Male', 41),
('Shreya', 'Bansal', 'Female', 27), ('Nikhil', 'Chopra', 'Male', 36), ('Riya', 'Agarwal', 'Female', 29),
('Aditya', 'Saxena', 'Male', 38), ('Neha', 'Tiwari', 'Female', 31), ('Manish', 'Rao', 'Male', 44),
('Swati', 'Krishnan', 'Female', 28), ('Deepak', 'Narayan', 'Male', 35), ('Anita', 'Pillai', 'Female', 40),
('Gaurav', 'Subramanian', 'Male', 32), ('Lakshmi', 'Venkatesh', 'Female', 33), ('Harsh', 'Mishra', 'Male', 39),
('Sunita', 'Yadav', 'Female', 36), ('Vivek', 'Pandey', 'Male', 41), ('Radha', 'Shukla', 'Female', 30),
('Siddharth', 'Bhatt', 'Male', 37), ('Kiran', 'Gandhi', 'Female', 34), ('Ravi', 'Jain', 'Male', 43),
('Madhuri', 'Seth', 'Female', 31), ('Abhishek', 'Dutta', 'Male', 29), ('Nisha', 'Bose', 'Female', 38),
('Tarun', 'Banerjee', 'Male', 40), ('Isha', 'Mukherjee', 'Female', 32), ('Yash', 'Das', 'Male', 35),
('Tanvi', 'Ghosh', 'Female', 28), ('Rishabh', 'Sen', 'Male', 36), ('Aishwarya', 'Roy', 'Female', 39),
('Kunal', 'Basu', 'Male', 42), ('Sakshi', 'Chakraborty', 'Female', 30), ('Mohit', 'Dey', 'Male', 33),
('Preeti', 'Mandal', 'Female', 37), ('Akash', 'Saha', 'Male', 41), ('Richa', 'Pal', 'Female', 29),
('Sahil', 'Biswas', 'Male', 34), ('Nidhi', 'Kar', 'Female', 31), ('Rohit', 'Mazumdar', 'Male', 38),
('Pallavi', 'Ganguly', 'Female', 35), ('Varun', 'Chatterjee', 'Male', 40), ('Shilpa', 'Ray', 'Female', 32),
('Ankit', 'Bhattacharya', 'Male', 36), ('Jyoti', 'Mitra', 'Female', 28), ('Sandeep', 'Guha', 'Male', 39),
('Rashmi', 'Bhowmick', 'Female', 33), ('Prateek', 'Sengupta', 'Male', 37), ('Monika', 'Dhar', 'Female', 30),
('Ashish', 'Barman', 'Male', 41), ('Deepika', 'Barua', 'Female', 34), ('Naveen', 'Chanda', 'Male', 38),
('Sonal', 'Deb', 'Female', 31), ('Ritesh', 'Goswami', 'Male', 35), ('Kanika', 'Hazra', 'Female', 29),
('Siddhant', 'Lahiri', 'Male', 42), ('Anushka', 'Mallick', 'Female', 36), ('Raghav', 'Mondal', 'Male', 40),
('Shweta', 'Naskar', 'Female', 33), ('Karan', 'Paul', 'Male', 37), ('Ishita', 'Podder', 'Female', 30),
('Vishal', 'Purkayastha', 'Male', 38), ('Aditi', 'Sarkar', 'Female', 32), ('Rohan', 'Sinha', 'Male', 41),
('Surbhi', 'Talukdar', 'Female', 35), ('Aman', 'Thakur', 'Male', 39), ('Bhavna', 'Bhatia', 'Female', 28),
('Chirag', 'Chawla', 'Male', 36), ('Disha', 'Dhawan', 'Female', 31), ('Eshan', 'Garg', 'Male', 40),
('Fiza', 'Gill', 'Female', 34), ('Gagan', 'Grewal', 'Male', 37), ('Harshita', 'Handa', 'Female', 29),
('Ishaan', 'Jindal', 'Male', 42), ('Jhanvi', 'Kalsi', 'Female', 33), ('Karanveer', 'Kang', 'Male', 38),
('Lavanya', 'Khurana', 'Female', 35), ('Manveer', 'Luthra', 'Male', 39), ('Navya', 'Mahajan', 'Female', 30),
('Ojas', 'Mehra', 'Male', 36), ('Palak', 'Nanda', 'Female', 32), ('Qasim', 'Oberoi', 'Male', 41),
('Rakhi', 'Puri', 'Female', 34), ('Sahaj', 'Rana', 'Male', 37), ('Tanya', 'Sethi', 'Female', 28),
('Uday', 'Sodhi', 'Male', 40), ('Vanya', 'Taneja', 'Female', 33), ('Waseem', 'Verma', 'Male', 38),
('Xara', 'Walia', 'Female', 31), ('Yash', 'Yadav', 'Male', 35), ('Zara', 'Zutshi', 'Female', 29),
('Aarav', 'Ahuja', 'Male', 42), ('Bhavya', 'Batra', 'Female', 36), ('Chetan', 'Chadha', 'Male', 39),
('Daksha', 'Dua', 'Female', 33), ('Eshwar', 'Gaba', 'Male', 37), ('Falak', 'Gulati', 'Female', 30),
('Garv', 'Handa', 'Male', 40), ('Hamsika', 'Jain', 'Female', 34), ('Ishan', 'Kakkar', 'Male', 38),
('Jhanvi', 'Kohli', 'Female', 32), ('Kartik', 'Malik', 'Male', 41), ('Lavina', 'Narang', 'Female', 35),
('Manan', 'Nayyar', 'Male', 39), ('Navya', 'Oberoi', 'Female', 28), ('Omkar', 'Pahwa', 'Male', 36),
('Pari', 'Rai', 'Female', 31), ('Qadir', 'Saini', 'Male', 40), ('Rashi', 'Seth', 'Female', 33),
('Sahil', 'Tandon', 'Male', 37), ('Tara', 'Verma', 'Female', 30), ('Ujjwal', 'Wadhwa', 'Male', 38),
('Vanshika', 'Agarwal', 'Female', 32), ('Waseem', 'Bansal', 'Male', 41), ('Xara', 'Chopra', 'Female', 35),
('Yash', 'Dua', 'Male', 39), ('Zara', 'Garg', 'Female', 28), ('Aarav', 'Gupta', 'Male', 36),
('Bhavya', 'Jain', 'Female', 31), ('Chetan', 'Kapoor', 'Male', 40), ('Daksha', 'Malhotra', 'Female', 34),
('Eshwar', 'Mehta', 'Male', 37), ('Falak', 'Nair', 'Female', 30), ('Garv', 'Patel', 'Male', 38),
('Hamsika', 'Rao', 'Female', 32), ('Ishan', 'Sharma', 'Male', 41), ('Jhanvi', 'Singh', 'Female', 35),
('Kartik', 'Verma', 'Male', 39), ('Lavina', 'Yadav', 'Female', 28), ('Manan', 'Agarwal', 'Male', 36),
('Navya', 'Bansal', 'Female', 31), ('Omkar', 'Chopra', 'Male', 40), ('Pari', 'Dua', 'Female', 33),
('Qadir', 'Garg', 'Male', 37), ('Rashi', 'Gupta', 'Female', 30), ('Sahil', 'Jain', 'Male', 38),
('Tara', 'Kapoor', 'Female', 32), ('Ujjwal', 'Malhotra', 'Male', 41), ('Vanshika', 'Mehta', 'Female', 35),
('Waseem', 'Nair', 'Male', 39), ('Xara', 'Patel', 'Female', 28), ('Yash', 'Rao', 'Male', 36),
('Zara', 'Sharma', 'Female', 31), ('Aarav', 'Singh', 'Male', 40), ('Bhavya', 'Verma', 'Female', 34),
('Chetan', 'Yadav', 'Male', 37), ('Daksha', 'Agarwal', 'Female', 30), ('Eshwar', 'Bansal', 'Male', 38),
('Falak', 'Chopra', 'Female', 32), ('Garv', 'Dua', 'Male', 41), ('Hamsika', 'Garg', 'Female', 35),
('Ishan', 'Gupta', 'Male', 39), ('Jhanvi', 'Jain', 'Female', 28), ('Kartik', 'Kapoor', 'Male', 36),
('Lavina', 'Malhotra', 'Female', 31), ('Manan', 'Mehta', 'Male', 40), ('Navya', 'Nair', 'Female', 33),
('Omkar', 'Patel', 'Male', 37), ('Pari', 'Rao', 'Female', 30), ('Qadir', 'Sharma', 'Male', 38),
('Rashi', 'Singh', 'Female', 32), ('Sahil', 'Verma', 'Male', 41), ('Tara', 'Yadav', 'Female', 35);

-- ============================================
-- 9. CREW (Add crew members - total 80)
-- ============================================
INSERT IGNORE INTO crew (first_name, last_name, email, role) VALUES
('Captain', 'Rajesh Kumar', 'capt.rajesh@airline.com', 'Pilot'),
('First Officer', 'Priya Sharma', 'fo.priya@airline.com', 'Co-Pilot'),
('Captain', 'Amit Patel', 'capt.amit@airline.com', 'Pilot'),
('First Officer', 'Sneha Singh', 'fo.sneha@airline.com', 'Co-Pilot'),
('Captain', 'Vikram Reddy', 'capt.vikram@airline.com', 'Pilot'),
('First Officer', 'Anjali Mehta', 'fo.anjali@airline.com', 'Co-Pilot'),
('Captain', 'Rahul Gupta', 'capt.rahul@airline.com', 'Pilot'),
('First Officer', 'Kavita Verma', 'fo.kavita@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.1@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.1@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.2@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.3@airline.com', 'Flight Attendant'),
('Senior', 'Flight Attendant', 'sfa.2@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.4@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.5@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.6@airline.com', 'Flight Attendant'),
('Captain', 'Suresh Joshi', 'capt.suresh@airline.com', 'Pilot'),
('First Officer', 'Meera Desai', 'fo.meera@airline.com', 'Co-Pilot'),
('Captain', 'Arjun Malhotra', 'capt.arjun@airline.com', 'Pilot'),
('First Officer', 'Divya Nair', 'fo.divya@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.3@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.7@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.8@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.9@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.10@airline.com', 'Flight Attendant'),
('Captain', 'Karan Iyer', 'capt.karan@airline.com', 'Pilot'),
('First Officer', 'Pooja Menon', 'fo.pooja@airline.com', 'Co-Pilot'),
('Captain', 'Rohan Kapoor', 'capt.rohan@airline.com', 'Pilot'),
('First Officer', 'Shreya Bansal', 'fo.shreya@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.4@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.11@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.12@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.13@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.14@airline.com', 'Flight Attendant'),
('Captain', 'Nikhil Chopra', 'capt.nikhil@airline.com', 'Pilot'),
('First Officer', 'Riya Agarwal', 'fo.riya@airline.com', 'Co-Pilot'),
('Captain', 'Aditya Saxena', 'capt.aditya@airline.com', 'Pilot'),
('First Officer', 'Neha Tiwari', 'fo.neha@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.5@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.15@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.16@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.17@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.18@airline.com', 'Flight Attendant'),
('Captain', 'Manish Rao', 'capt.manish@airline.com', 'Pilot'),
('First Officer', 'Swati Krishnan', 'fo.swati@airline.com', 'Co-Pilot'),
('Captain', 'Deepak Narayan', 'capt.deepak@airline.com', 'Pilot'),
('First Officer', 'Anita Pillai', 'fo.anita@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.6@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.19@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.20@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.21@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.22@airline.com', 'Flight Attendant'),
('Captain', 'Gaurav Subramanian', 'capt.gaurav@airline.com', 'Pilot'),
('First Officer', 'Lakshmi Venkatesh', 'fo.lakshmi@airline.com', 'Co-Pilot'),
('Captain', 'Harsh Mishra', 'capt.harsh@airline.com', 'Pilot'),
('First Officer', 'Sunita Yadav', 'fo.sunita@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.7@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.23@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.24@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.25@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.26@airline.com', 'Flight Attendant'),
('Captain', 'Vivek Pandey', 'capt.vivek@airline.com', 'Pilot'),
('First Officer', 'Radha Shukla', 'fo.radha@airline.com', 'Co-Pilot'),
('Captain', 'Siddharth Bhatt', 'capt.siddharth@airline.com', 'Pilot'),
('First Officer', 'Kiran Gandhi', 'fo.kiran@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.8@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.27@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.28@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.29@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.30@airline.com', 'Flight Attendant'),
('Captain', 'Ravi Jain', 'capt.ravi@airline.com', 'Pilot'),
('First Officer', 'Madhuri Seth', 'fo.madhuri@airline.com', 'Co-Pilot'),
('Captain', 'Abhishek Dutta', 'capt.abhishek@airline.com', 'Pilot'),
('First Officer', 'Nisha Bose', 'fo.nisha@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.9@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.31@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.32@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.33@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.34@airline.com', 'Flight Attendant'),
('Captain', 'Tarun Banerjee', 'capt.tarun@airline.com', 'Pilot'),
('First Officer', 'Isha Mukherjee', 'fo.isha@airline.com', 'Co-Pilot'),
('Captain', 'Yash Das', 'capt.yash@airline.com', 'Pilot'),
('First Officer', 'Tanvi Ghosh', 'fo.tanvi@airline.com', 'Co-Pilot'),
('Senior', 'Flight Attendant', 'sfa.10@airline.com', 'Senior Flight Attendant'),
('Flight', 'Attendant', 'fa.35@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.36@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.37@airline.com', 'Flight Attendant'),
('Flight', 'Attendant', 'fa.38@airline.com', 'Flight Attendant');

-- ============================================
-- 10. BOOKINGS (Add bookings - total 120)
-- ============================================
-- Create bookings for various accounts
INSERT INTO bookings (account_id, booking_status, booking_date)
SELECT 
    a.account_id,
    CASE WHEN RAND() > 0.2 THEN 'Confirmed' ELSE 'Cancelled' END as status,
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 90) DAY) as booking_date
FROM accounts a
CROSS JOIN (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
) multiplier
WHERE a.account_id BETWEEN 1 AND 90
ORDER BY RAND()
LIMIT 120;

-- ============================================
-- 11. BOOKING_ITEMS (Add booking items - total 120)
-- ============================================
-- Create booking items for each booking
INSERT INTO booking_items (booking_id, flight_id, passenger_id)
SELECT 
    b.booking_id,
    (SELECT flight_id FROM flights WHERE scheduled_departure > NOW() ORDER BY RAND() LIMIT 1) as flight_id,
    (SELECT passenger_id FROM passengers ORDER BY RAND() LIMIT 1) as passenger_id
FROM bookings b
WHERE NOT EXISTS (
    SELECT 1 FROM booking_items bi WHERE bi.booking_id = b.booking_id
)
LIMIT 120;

-- ============================================
-- 12. SEAT_RESERVATIONS (Add seat reservations - total 100)
-- ============================================
-- Create seat reservations for booking items
INSERT INTO seat_reservations (item_id, seat_id, flight_id)
SELECT 
    bi.item_id,
    (SELECT s.seat_id FROM seats s 
     JOIN flights f ON s.aircraft_id = (SELECT aircraft_id FROM flights WHERE flight_id = bi.flight_id)
     WHERE s.seat_id NOT IN (
         SELECT seat_id FROM seat_reservations WHERE flight_id = bi.flight_id
     )
     ORDER BY RAND() LIMIT 1) as seat_id,
    bi.flight_id
FROM booking_items bi
WHERE NOT EXISTS (
    SELECT 1 FROM seat_reservations sr WHERE sr.item_id = bi.item_id
)
LIMIT 100;

-- ============================================
-- 13. BOARDING_PASSES (Add boarding passes - total 100)
-- ============================================
-- Create boarding passes for bookings with seat reservations
INSERT INTO boarding_passes (booking_item_id, flight_id, seat_id, passenger_id)
SELECT 
    bi.item_id,
    bi.flight_id,
    sr.seat_id,
    bi.passenger_id
FROM booking_items bi
JOIN seat_reservations sr ON bi.item_id = sr.item_id
WHERE NOT EXISTS (
    SELECT 1 FROM boarding_passes bp WHERE bp.booking_item_id = bi.item_id
)
LIMIT 100;

-- ============================================
-- 14. TICKET_PAYMENTS (Add payments - total 100)
-- ============================================
-- Create payments for confirmed bookings
INSERT INTO ticket_payments (booking_id, amount, payment_method)
SELECT 
    b.booking_id,
    ROUND(5000 + (RAND() * 15000), 2) as amount,
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN 'Card'
        WHEN 1 THEN 'UPI'
        ELSE 'NetBanking'
    END as payment_method
FROM bookings b
WHERE b.booking_status = 'Confirmed'
AND NOT EXISTS (
    SELECT 1 FROM ticket_payments tp WHERE tp.booking_id = b.booking_id
)
LIMIT 100;

-- ============================================
-- 15. CREW_ASSIGNMENTS (Add crew assignments - total 150)
-- ============================================
-- Assign crew to flights (2-4 crew per flight)
INSERT INTO crew_assignments (flight_id, crew_id)
SELECT DISTINCT
    f.flight_id,
    c.crew_id
FROM flights f
CROSS JOIN crew c
WHERE f.scheduled_departure > NOW()
AND NOT EXISTS (
    SELECT 1 FROM crew_assignments ca 
    WHERE ca.flight_id = f.flight_id AND ca.crew_id = c.crew_id
)
ORDER BY RAND()
LIMIT 150;

-- ============================================
-- 16. DELAYS (Add delays - total 30)
-- ============================================
-- Add some flight delays
INSERT INTO delays (flight_id, delay_minutes)
SELECT 
    f.flight_id,
    15 + FLOOR(RAND() * 120) as delay_minutes
FROM flights f
WHERE f.scheduled_departure > NOW()
AND NOT EXISTS (
    SELECT 1 FROM delays d WHERE d.flight_id = f.flight_id
)
ORDER BY RAND()
LIMIT 30;

-- ============================================
-- 17. CANCELLATIONS (Add cancellations - total 20)
-- ============================================
-- Add some flight cancellations
INSERT INTO cancellations (flight_id, cancelled_at, cancellation_reason)
SELECT 
    f.flight_id,
    NOW() - INTERVAL FLOOR(RAND() * 30) DAY as cancelled_at,
    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN 'Weather conditions'
        WHEN 1 THEN 'Technical issues'
        WHEN 2 THEN 'Operational reasons'
        ELSE 'Air traffic control'
    END as reason
FROM flights f
WHERE f.scheduled_departure > NOW()
AND NOT EXISTS (
    SELECT 1 FROM cancellations c WHERE c.flight_id = f.flight_id
)
ORDER BY RAND()
LIMIT 20;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
SELECT 'Total Entries Count' as info, 
       (SELECT COUNT(*) FROM accounts) +
       (SELECT COUNT(*) FROM aircraft) +
       (SELECT COUNT(*) FROM aircraft_types) +
       (SELECT COUNT(*) FROM airport) +
       (SELECT COUNT(*) FROM boarding_passes) +
       (SELECT COUNT(*) FROM bookings) +
       (SELECT COUNT(*) FROM booking_items) +
       (SELECT COUNT(*) FROM cancellations) +
       (SELECT COUNT(*) FROM crew) +
       (SELECT COUNT(*) FROM crew_assignments) +
       (SELECT COUNT(*) FROM delays) +
       (SELECT COUNT(*) FROM flights) +
       (SELECT COUNT(*) FROM passengers) +
       (SELECT COUNT(*) FROM routes) +
       (SELECT COUNT(*) FROM seats) +
       (SELECT COUNT(*) FROM seat_reservations) +
       (SELECT COUNT(*) FROM ticket_payments) as total_count;

-- Count per table
SELECT 'accounts' as table_name, COUNT(*) as count FROM accounts
UNION ALL SELECT 'aircraft', COUNT(*) FROM aircraft
UNION ALL SELECT 'aircraft_types', COUNT(*) FROM aircraft_types
UNION ALL SELECT 'airport', COUNT(*) FROM airport
UNION ALL SELECT 'boarding_passes', COUNT(*) FROM boarding_passes
UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL SELECT 'booking_items', COUNT(*) FROM booking_items
UNION ALL SELECT 'cancellations', COUNT(*) FROM cancellations
UNION ALL SELECT 'crew', COUNT(*) FROM crew
UNION ALL SELECT 'crew_assignments', COUNT(*) FROM crew_assignments
UNION ALL SELECT 'delays', COUNT(*) FROM delays
UNION ALL SELECT 'flights', COUNT(*) FROM flights
UNION ALL SELECT 'passengers', COUNT(*) FROM passengers
UNION ALL SELECT 'routes', COUNT(*) FROM routes
UNION ALL SELECT 'seats', COUNT(*) FROM seats
UNION ALL SELECT 'seat_reservations', COUNT(*) FROM seat_reservations
UNION ALL SELECT 'ticket_payments', COUNT(*) FROM ticket_payments
ORDER BY table_name;

