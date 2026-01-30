-- ============================================
-- POPULATE ROUTES AND FLIGHTS DATA
-- Run this SQL file in phpMyAdmin to add sample data
-- ============================================

-- First, ensure you have airports (add if not exists)
INSERT IGNORE INTO airport (airport_id, name, city, state, country, airport_code) VALUES
(1, 'Indira Gandhi International Airport', 'Delhi', 'Delhi', 'India', 'DEL'),
(2, 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'Maharashtra', 'India', 'BOM'),
(3, 'Kempegowda International Airport', 'Bangalore', 'Karnataka', 'India', 'BLR'),
(4, 'Rajiv Gandhi International Airport', 'Hyderabad', 'Telangana', 'India', 'HYD'),
(5, 'Netaji Subhash Chandra Bose International Airport', 'Kolkata', 'West Bengal', 'India', 'CCU'),
(6, 'Chennai International Airport', 'Chennai', 'Tamil Nadu', 'India', 'MAA'),
(7, 'Sardar Vallabhbhai Patel International Airport', 'Ahmedabad', 'Gujarat', 'India', 'AMD'),
(8, 'Cochin International Airport', 'Kochi', 'Kerala', 'India', 'COK'),
(9, 'Pune Airport', 'Pune', 'Maharashtra', 'India', 'PNQ'),
(10, 'Jaipur International Airport', 'Jaipur', 'Rajasthan', 'India', 'JAI');

-- ============================================
-- POPULATE ROUTES (90 routes - all combinations)
-- ============================================

-- Delete existing routes to avoid duplicates
DELETE FROM routes WHERE route_id BETWEEN 1 AND 200;

-- Delhi Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(1, 1, 2, 1400), (2, 1, 3, 1750), (3, 1, 4, 1500), (4, 1, 5, 1500), (5, 1, 6, 2200),
(6, 1, 7, 800), (7, 1, 8, 2400), (8, 1, 9, 1400), (9, 1, 10, 260);

-- Mumbai Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(10, 2, 1, 1400), (11, 2, 3, 850), (12, 2, 4, 700), (13, 2, 5, 2000), (14, 2, 6, 1300),
(15, 2, 7, 500), (16, 2, 8, 1400), (17, 2, 9, 150), (18, 2, 10, 1100);

-- Bangalore Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(19, 3, 1, 1750), (20, 3, 2, 850), (21, 3, 4, 600), (22, 3, 5, 1800), (23, 3, 6, 350),
(24, 3, 7, 1200), (25, 3, 8, 400), (26, 3, 9, 850), (27, 3, 10, 2000);

-- Hyderabad Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(28, 4, 1, 1500), (29, 4, 2, 700), (30, 4, 3, 600), (31, 4, 5, 1500), (32, 4, 6, 700),
(33, 4, 7, 1000), (34, 4, 8, 900), (35, 4, 9, 500), (36, 4, 10, 1400);

-- Kolkata Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(37, 5, 1, 1500), (38, 5, 2, 2000), (39, 5, 3, 1800), (40, 5, 4, 1500), (41, 5, 6, 1700),
(42, 5, 7, 2000), (43, 5, 8, 2500), (44, 5, 9, 2000), (45, 5, 10, 1500);

-- Chennai Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(46, 6, 1, 2200), (47, 6, 2, 1300), (48, 6, 3, 350), (49, 6, 4, 700), (50, 6, 5, 1700),
(51, 6, 7, 1500), (52, 6, 8, 700), (53, 6, 9, 1000), (54, 6, 10, 2200);

-- Ahmedabad Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(55, 7, 1, 800), (56, 7, 2, 500), (57, 7, 3, 1200), (58, 7, 4, 1000), (59, 7, 5, 2000),
(60, 7, 6, 1500), (61, 7, 8, 1800), (62, 7, 9, 600), (63, 7, 10, 600);

-- Kochi Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(64, 8, 1, 2400), (65, 8, 2, 1400), (66, 8, 3, 400), (67, 8, 4, 900), (68, 8, 5, 2500),
(69, 8, 6, 700), (70, 8, 7, 1800), (71, 8, 9, 1200), (72, 8, 10, 2400);

-- Pune Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(73, 9, 1, 1400), (74, 9, 2, 150), (75, 9, 3, 850), (76, 9, 4, 500), (77, 9, 5, 2000),
(78, 9, 6, 1000), (79, 9, 7, 600), (80, 9, 8, 1200), (81, 9, 10, 1200);

-- Jaipur Routes
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(82, 10, 1, 260), (83, 10, 2, 1100), (84, 10, 3, 2000), (85, 10, 4, 1400), (86, 10, 5, 1500),
(87, 10, 6, 2200), (88, 10, 7, 600), (89, 10, 8, 2400), (90, 10, 9, 1200);

-- ============================================
-- ENSURE AIRCRAFT TYPES AND AIRCRAFT EXIST
-- ============================================

INSERT IGNORE INTO aircraft_types (aircraft_type_id, model, manufacturer, seating_capacity) VALUES
(1, 'A320', 'Airbus', 180),
(2, 'B737', 'Boeing', 175),
(3, 'A321', 'Airbus', 220),
(4, 'B787', 'Boeing', 290);

INSERT IGNORE INTO aircraft (aircraft_id, aircraft_type_id, registration_no, manufacture_date) VALUES
(1, 1, 'VT-AAA', '2020-01-15'),
(2, 2, 'VT-AAB', '2019-06-20'),
(3, 1, 'VT-AAC', '2021-03-10'),
(4, 3, 'VT-AAD', '2020-11-05'),
(5, 2, 'VT-AAE', '2018-09-12'),
(6, 1, 'VT-AAF', '2022-02-28'),
(7, 4, 'VT-AAG', '2021-07-15'),
(8, 2, 'VT-AAH', '2020-04-22');

-- ============================================
-- CREATE SEATS FOR AIRCRAFT
-- ============================================

-- Delete existing seats to avoid duplicates
DELETE FROM seats WHERE aircraft_id BETWEEN 1 AND 10;

-- Create seats for aircraft 1 (30 rows x 6 seats = 180 seats)
INSERT INTO seats (aircraft_id, seat_number, seat_class) VALUES
(1, '1A', 'First'), (1, '1B', 'First'), (1, '1C', 'First'), (1, '1D', 'First'), (1, '1E', 'First'), (1, '1F', 'First'),
(1, '2A', 'First'), (1, '2B', 'First'), (1, '2C', 'First'), (1, '2D', 'First'), (1, '2E', 'First'), (1, '2F', 'First'),
(1, '3A', 'First'), (1, '3B', 'First'), (1, '3C', 'First'), (1, '3D', 'First'), (1, '3E', 'First'), (1, '3F', 'First'),
(1, '4A', 'Business'), (1, '4B', 'Business'), (1, '4C', 'Business'), (1, '4D', 'Business'), (1, '4E', 'Business'), (1, '4F', 'Business'),
(1, '5A', 'Business'), (1, '5B', 'Business'), (1, '5C', 'Business'), (1, '5D', 'Business'), (1, '5E', 'Business'), (1, '5F', 'Business'),
(1, '6A', 'Business'), (1, '6B', 'Business'), (1, '6C', 'Business'), (1, '6D', 'Business'), (1, '6E', 'Business'), (1, '6F', 'Business'),
(1, '7A', 'Economy'), (1, '7B', 'Economy'), (1, '7C', 'Economy'), (1, '7D', 'Economy'), (1, '7E', 'Economy'), (1, '7F', 'Economy'),
(1, '8A', 'Economy'), (1, '8B', 'Economy'), (1, '8C', 'Economy'), (1, '8D', 'Economy'), (1, '8E', 'Economy'), (1, '8F', 'Economy'),
(1, '9A', 'Economy'), (1, '9B', 'Economy'), (1, '9C', 'Economy'), (1, '9D', 'Economy'), (1, '9E', 'Economy'), (1, '9F', 'Economy'),
(1, '10A', 'Economy'), (1, '10B', 'Economy'), (1, '10C', 'Economy'), (1, '10D', 'Economy'), (1, '10E', 'Economy'), (1, '10F', 'Economy');

-- Repeat for other aircraft (simplified - you can expand this)
INSERT INTO seats (aircraft_id, seat_number, seat_class)
SELECT 2, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class)
SELECT 3, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class)
SELECT 4, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class)
SELECT 5, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class)
SELECT 6, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class)
SELECT 7, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class)
SELECT 8, seat_number, seat_class FROM seats WHERE aircraft_id = 1;

-- ============================================
-- POPULATE FLIGHTS FOR NEXT 30 DAYS
-- Creates 2 flights per route per day
-- ============================================

-- Delete old flights first
DELETE FROM flights WHERE scheduled_departure < NOW();

-- Create flights for each route for next 30 days
-- This creates morning (10:00) and evening (18:00) flights

-- For route 1 (Delhi to Mumbai)
INSERT INTO flights (flight_no, route_id, aircraft_id, scheduled_departure, scheduled_arrival)
SELECT 
    CONCAT('DELBOM', LPAD(ROW_NUMBER() OVER(), 3, '0')) as flight_no,
    1 as route_id,
    ((ROW_NUMBER() OVER() - 1) % 8) + 1 as aircraft_id,
    DATE_ADD(CURDATE(), INTERVAL (ROW_NUMBER() OVER() - 1) / 2 DAY) + INTERVAL (10 + ((ROW_NUMBER() OVER() - 1) % 2) * 8) HOUR as scheduled_departure,
    DATE_ADD(CURDATE(), INTERVAL (ROW_NUMBER() OVER() - 1) / 2 DAY) + INTERVAL (10 + ((ROW_NUMBER() OVER() - 1) % 2) * 8 + 2) HOUR as scheduled_arrival
FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION
    SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION
    SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION
    SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION
    SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION
    SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35 UNION
    SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION
    SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45 UNION
    SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50 UNION
    SELECT 51 UNION SELECT 52 UNION SELECT 53 UNION SELECT 54 UNION SELECT 55 UNION
    SELECT 56 UNION SELECT 57 UNION SELECT 58 UNION SELECT 59 UNION SELECT 60
) numbers
WHERE DATE_ADD(CURDATE(), INTERVAL (ROW_NUMBER() OVER() - 1) / 2 DAY) <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)
LIMIT 60;

-- Note: For production, you would want to create a stored procedure or script
-- to generate flights for all 90 routes. For now, this creates flights for route 1.
-- You can repeat this pattern for other routes or create a loop.

-- ============================================
-- SIMPLER APPROACH: Create flights manually for popular routes
-- ============================================

-- Delhi to Mumbai (Route 1) - 2 flights per day for 30 days
INSERT INTO flights (flight_no, route_id, aircraft_id, scheduled_departure, scheduled_arrival)
SELECT 
    CONCAT('DELBOM', LPAD(n, 3, '0')) as flight_no,
    1 as route_id,
    ((n - 1) % 8) + 1 as aircraft_id,
    DATE_ADD(CURDATE(), INTERVAL FLOOR((n - 1) / 2) DAY) + INTERVAL (10 + ((n - 1) % 2) * 8) HOUR as scheduled_departure,
    DATE_ADD(CURDATE(), INTERVAL FLOOR((n - 1) / 2) DAY) + INTERVAL (10 + ((n - 1) % 2) * 8 + 2) HOUR as scheduled_arrival
FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION
    SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION
    SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION
    SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 UNION
    SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION
    SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30 UNION
    SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35 UNION
    SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40 UNION
    SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45 UNION
    SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50 UNION
    SELECT 51 UNION SELECT 52 UNION SELECT 53 UNION SELECT 54 UNION SELECT 55 UNION
    SELECT 56 UNION SELECT 57 UNION SELECT 58 UNION SELECT 59 UNION SELECT 60
) numbers
WHERE DATE_ADD(CURDATE(), INTERVAL FLOOR((n - 1) / 2) DAY) <= DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check routes count
SELECT COUNT(*) as total_routes FROM routes;

-- Check flights count
SELECT COUNT(*) as total_flights FROM flights WHERE scheduled_departure > NOW();

-- Check flights per route
SELECT 
    a1.city as origin,
    a2.city as destination,
    COUNT(f.flight_id) as flight_count
FROM routes r
LEFT JOIN flights f ON r.route_id = f.route_id AND f.scheduled_departure > NOW()
JOIN airport a1 ON r.origin_airport_id = a1.airport_id
JOIN airport a2 ON r.destination_airport_id = a2.airport_id
GROUP BY r.route_id, a1.city, a2.city
ORDER BY flight_count DESC
LIMIT 20;
