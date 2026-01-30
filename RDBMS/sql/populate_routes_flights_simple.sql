-- ============================================
-- SIMPLE POPULATE ROUTES AND FLIGHTS DATA
-- Run this in phpMyAdmin - Works with all MySQL versions
-- ============================================

-- Step 1: Add Airports (if not exists)
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

-- Step 2: Add Aircraft Types
INSERT IGNORE INTO aircraft_types (aircraft_type_id, model, manufacturer, seating_capacity) VALUES
(1, 'A320', 'Airbus', 180),
(2, 'B737', 'Boeing', 175),
(3, 'A321', 'Airbus', 220),
(4, 'B787', 'Boeing', 290);

-- Step 3: Add Aircraft
INSERT IGNORE INTO aircraft (aircraft_id, aircraft_type_id, registration_no, manufacture_date) VALUES
(1, 1, 'VT-AAA', '2020-01-15'),
(2, 2, 'VT-AAB', '2019-06-20'),
(3, 1, 'VT-AAC', '2021-03-10'),
(4, 3, 'VT-AAD', '2020-11-05'),
(5, 2, 'VT-AAE', '2018-09-12'),
(6, 1, 'VT-AAF', '2022-02-28'),
(7, 4, 'VT-AAG', '2021-07-15'),
(8, 2, 'VT-AAH', '2020-04-22');

-- Step 4: Add Routes (90 routes - all combinations between 10 airports)
-- Delete old routes first
DELETE FROM routes WHERE route_id BETWEEN 1 AND 200;

-- Delhi Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(1, 1, 2, 1400), (2, 1, 3, 1750), (3, 1, 4, 1500), (4, 1, 5, 1500), (5, 1, 6, 2200),
(6, 1, 7, 800), (7, 1, 8, 2400), (8, 1, 9, 1400), (9, 1, 10, 260);

-- Mumbai Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(10, 2, 1, 1400), (11, 2, 3, 850), (12, 2, 4, 700), (13, 2, 5, 2000), (14, 2, 6, 1300),
(15, 2, 7, 500), (16, 2, 8, 1400), (17, 2, 9, 150), (18, 2, 10, 1100);

-- Bangalore Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(19, 3, 1, 1750), (20, 3, 2, 850), (21, 3, 4, 600), (22, 3, 5, 1800), (23, 3, 6, 350),
(24, 3, 7, 1200), (25, 3, 8, 400), (26, 3, 9, 850), (27, 3, 10, 2000);

-- Hyderabad Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(28, 4, 1, 1500), (29, 4, 2, 700), (30, 4, 3, 600), (31, 4, 5, 1500), (32, 4, 6, 700),
(33, 4, 7, 1000), (34, 4, 8, 900), (35, 4, 9, 500), (36, 4, 10, 1400);

-- Kolkata Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(37, 5, 1, 1500), (38, 5, 2, 2000), (39, 5, 3, 1800), (40, 5, 4, 1500), (41, 5, 6, 1700),
(42, 5, 7, 2000), (43, 5, 8, 2500), (44, 5, 9, 2000), (45, 5, 10, 1500);

-- Chennai Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(46, 6, 1, 2200), (47, 6, 2, 1300), (48, 6, 3, 350), (49, 6, 4, 700), (50, 6, 5, 1700),
(51, 6, 7, 1500), (52, 6, 8, 700), (53, 6, 9, 1000), (54, 6, 10, 2200);

-- Ahmedabad Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(55, 7, 1, 800), (56, 7, 2, 500), (57, 7, 3, 1200), (58, 7, 4, 1000), (59, 7, 5, 2000),
(60, 7, 6, 1500), (61, 7, 8, 1800), (62, 7, 9, 600), (63, 7, 10, 600);

-- Kochi Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(64, 8, 1, 2400), (65, 8, 2, 1400), (66, 8, 3, 400), (67, 8, 4, 900), (68, 8, 5, 2500),
(69, 8, 6, 700), (70, 8, 7, 1800), (71, 8, 9, 1200), (72, 8, 10, 2400);

-- Pune Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(73, 9, 1, 1400), (74, 9, 2, 150), (75, 9, 3, 850), (76, 9, 4, 500), (77, 9, 5, 2000),
(78, 9, 6, 1000), (79, 9, 7, 600), (80, 9, 8, 1200), (81, 9, 10, 1200);

-- Jaipur Routes (9 routes)
INSERT INTO routes (route_id, origin_airport_id, destination_airport_id, distance_km) VALUES
(82, 10, 1, 260), (83, 10, 2, 1100), (84, 10, 3, 2000), (85, 10, 4, 1400), (86, 10, 5, 1500),
(87, 10, 6, 2200), (88, 10, 7, 600), (89, 10, 8, 2400), (90, 10, 9, 1200);

-- Step 5: Create Seats for Aircraft
-- Delete existing seats
DELETE FROM seats WHERE aircraft_id BETWEEN 1 AND 10;

-- Create seats for aircraft 1 (First 3 rows = First class, Next 3 rows = Business, Rest = Economy)
INSERT INTO seats (aircraft_id, seat_number, seat_class) VALUES
-- First Class (Rows 1-3)
(1, '1A', 'First'), (1, '1B', 'First'), (1, '1C', 'First'), (1, '1D', 'First'), (1, '1E', 'First'), (1, '1F', 'First'),
(1, '2A', 'First'), (1, '2B', 'First'), (1, '2C', 'First'), (1, '2D', 'First'), (1, '2E', 'First'), (1, '2F', 'First'),
(1, '3A', 'First'), (1, '3B', 'First'), (1, '3C', 'First'), (1, '3D', 'First'), (1, '3E', 'First'), (1, '3F', 'First'),
-- Business Class (Rows 4-6)
(1, '4A', 'Business'), (1, '4B', 'Business'), (1, '4C', 'Business'), (1, '4D', 'Business'), (1, '4E', 'Business'), (1, '4F', 'Business'),
(1, '5A', 'Business'), (1, '5B', 'Business'), (1, '5C', 'Business'), (1, '5D', 'Business'), (1, '5E', 'Business'), (1, '5F', 'Business'),
(1, '6A', 'Business'), (1, '6B', 'Business'), (1, '6C', 'Business'), (1, '6D', 'Business'), (1, '6E', 'Business'), (1, '6F', 'Business'),
-- Economy Class (Rows 7-30)
(1, '7A', 'Economy'), (1, '7B', 'Economy'), (1, '7C', 'Economy'), (1, '7D', 'Economy'), (1, '7E', 'Economy'), (1, '7F', 'Economy'),
(1, '8A', 'Economy'), (1, '8B', 'Economy'), (1, '8C', 'Economy'), (1, '8D', 'Economy'), (1, '8E', 'Economy'), (1, '8F', 'Economy'),
(1, '9A', 'Economy'), (1, '9B', 'Economy'), (1, '9C', 'Economy'), (1, '9D', 'Economy'), (1, '9E', 'Economy'), (1, '9F', 'Economy'),
(1, '10A', 'Economy'), (1, '10B', 'Economy'), (1, '10C', 'Economy'), (1, '10D', 'Economy'), (1, '10E', 'Economy'), (1, '10F', 'Economy'),
(1, '11A', 'Economy'), (1, '11B', 'Economy'), (1, '11C', 'Economy'), (1, '11D', 'Economy'), (1, '11E', 'Economy'), (1, '11F', 'Economy'),
(1, '12A', 'Economy'), (1, '12B', 'Economy'), (1, '12C', 'Economy'), (1, '12D', 'Economy'), (1, '12E', 'Economy'), (1, '12F', 'Economy'),
(1, '13A', 'Economy'), (1, '13B', 'Economy'), (1, '13C', 'Economy'), (1, '13D', 'Economy'), (1, '13E', 'Economy'), (1, '13F', 'Economy'),
(1, '14A', 'Economy'), (1, '14B', 'Economy'), (1, '14C', 'Economy'), (1, '14D', 'Economy'), (1, '14E', 'Economy'), (1, '14F', 'Economy'),
(1, '15A', 'Economy'), (1, '15B', 'Economy'), (1, '15C', 'Economy'), (1, '15D', 'Economy'), (1, '15E', 'Economy'), (1, '15F', 'Economy'),
(1, '16A', 'Economy'), (1, '16B', 'Economy'), (1, '16C', 'Economy'), (1, '16D', 'Economy'), (1, '16E', 'Economy'), (1, '16F', 'Economy'),
(1, '17A', 'Economy'), (1, '17B', 'Economy'), (1, '17C', 'Economy'), (1, '17D', 'Economy'), (1, '17E', 'Economy'), (1, '17F', 'Economy'),
(1, '18A', 'Economy'), (1, '18B', 'Economy'), (1, '18C', 'Economy'), (1, '18D', 'Economy'), (1, '18E', 'Economy'), (1, '18F', 'Economy'),
(1, '19A', 'Economy'), (1, '19B', 'Economy'), (1, '19C', 'Economy'), (1, '19D', 'Economy'), (1, '19E', 'Economy'), (1, '19F', 'Economy'),
(1, '20A', 'Economy'), (1, '20B', 'Economy'), (1, '20C', 'Economy'), (1, '20D', 'Economy'), (1, '20E', 'Economy'), (1, '20F', 'Economy'),
(1, '21A', 'Economy'), (1, '21B', 'Economy'), (1, '21C', 'Economy'), (1, '21D', 'Economy'), (1, '21E', 'Economy'), (1, '21F', 'Economy'),
(1, '22A', 'Economy'), (1, '22B', 'Economy'), (1, '22C', 'Economy'), (1, '22D', 'Economy'), (1, '22E', 'Economy'), (1, '22F', 'Economy'),
(1, '23A', 'Economy'), (1, '23B', 'Economy'), (1, '23C', 'Economy'), (1, '23D', 'Economy'), (1, '23E', 'Economy'), (1, '23F', 'Economy'),
(1, '24A', 'Economy'), (1, '24B', 'Economy'), (1, '24C', 'Economy'), (1, '24D', 'Economy'), (1, '24E', 'Economy'), (1, '24F', 'Economy'),
(1, '25A', 'Economy'), (1, '25B', 'Economy'), (1, '25C', 'Economy'), (1, '25D', 'Economy'), (1, '25E', 'Economy'), (1, '25F', 'Economy'),
(1, '26A', 'Economy'), (1, '26B', 'Economy'), (1, '26C', 'Economy'), (1, '26D', 'Economy'), (1, '26E', 'Economy'), (1, '26F', 'Economy'),
(1, '27A', 'Economy'), (1, '27B', 'Economy'), (1, '27C', 'Economy'), (1, '27D', 'Economy'), (1, '27E', 'Economy'), (1, '27F', 'Economy'),
(1, '28A', 'Economy'), (1, '28B', 'Economy'), (1, '28C', 'Economy'), (1, '28D', 'Economy'), (1, '28E', 'Economy'), (1, '28F', 'Economy'),
(1, '29A', 'Economy'), (1, '29B', 'Economy'), (1, '29C', 'Economy'), (1, '29D', 'Economy'), (1, '29E', 'Economy'), (1, '29F', 'Economy'),
(1, '30A', 'Economy'), (1, '30B', 'Economy'), (1, '30C', 'Economy'), (1, '30D', 'Economy'), (1, '30E', 'Economy'), (1, '30F', 'Economy');

-- Copy seats to other aircraft
INSERT INTO seats (aircraft_id, seat_number, seat_class) SELECT 2, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class) SELECT 3, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class) SELECT 4, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class) SELECT 5, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class) SELECT 6, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class) SELECT 7, seat_number, seat_class FROM seats WHERE aircraft_id = 1;
INSERT INTO seats (aircraft_id, seat_number, seat_class) SELECT 8, seat_number, seat_class FROM seats WHERE aircraft_id = 1;

-- Step 6: Create Sample Flights
-- Delete old flights
DELETE FROM flights WHERE scheduled_departure < NOW();

-- Create flights for Route 1 (Delhi to Mumbai) - 2 flights per day for next 30 days
-- Morning flight at 10:00, Evening flight at 18:00
SET @date = CURDATE();
SET @counter = 0;

-- This will be handled by the PHP code automatically when searching
-- But we can add a few sample flights manually:

-- Sample flights for Route 1 (Delhi to Mumbai) - next 7 days
INSERT INTO flights (flight_no, route_id, aircraft_id, scheduled_departure, scheduled_arrival) VALUES
('DELBOM001', 1, 1, DATE_ADD(CURDATE(), INTERVAL 0 DAY) + INTERVAL 10 HOUR, DATE_ADD(CURDATE(), INTERVAL 0 DAY) + INTERVAL 12 HOUR),
('DELBOM002', 1, 2, DATE_ADD(CURDATE(), INTERVAL 0 DAY) + INTERVAL 18 HOUR, DATE_ADD(CURDATE(), INTERVAL 0 DAY) + INTERVAL 20 HOUR),
('DELBOM003', 1, 3, DATE_ADD(CURDATE(), INTERVAL 1 DAY) + INTERVAL 10 HOUR, DATE_ADD(CURDATE(), INTERVAL 1 DAY) + INTERVAL 12 HOUR),
('DELBOM004', 1, 4, DATE_ADD(CURDATE(), INTERVAL 1 DAY) + INTERVAL 18 HOUR, DATE_ADD(CURDATE(), INTERVAL 1 DAY) + INTERVAL 20 HOUR),
('DELBOM005', 1, 5, DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 10 HOUR, DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 12 HOUR),
('DELBOM006', 1, 6, DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 18 HOUR, DATE_ADD(CURDATE(), INTERVAL 2 DAY) + INTERVAL 20 HOUR),
('DELBOM007', 1, 7, DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 10 HOUR, DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 12 HOUR),
('DELBOM008', 1, 8, DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 18 HOUR, DATE_ADD(CURDATE(), INTERVAL 3 DAY) + INTERVAL 20 HOUR);

-- Note: The PHP code in search_flights.php will automatically create flights
-- for any route that doesn't have flights when you search for it.

-- ============================================
-- VERIFICATION
-- ============================================
SELECT 'Routes created:' as info, COUNT(*) as count FROM routes
UNION ALL
SELECT 'Aircraft created:', COUNT(*) FROM aircraft
UNION ALL
SELECT 'Seats created:', COUNT(*) FROM seats
UNION ALL
SELECT 'Flights created:', COUNT(*) FROM flights WHERE scheduled_departure > NOW();

