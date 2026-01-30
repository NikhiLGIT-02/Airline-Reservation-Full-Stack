-- ============================================
-- COUNT ROWS ACROSS ALL TABLES
-- Run this query in phpMyAdmin to see row counts for all tables
-- ============================================

-- Method 1: Simple UNION query (works in all MySQL/MariaDB versions)
SELECT 'accounts' as table_name, COUNT(*) as row_count FROM accounts
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

-- ============================================
-- Method 2: Total count across all tables
-- ============================================
SELECT 
    'TOTAL' as table_name,
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
    (SELECT COUNT(*) FROM ticket_payments) as row_count;

-- ============================================
-- Method 3: Detailed view with percentage (optional)
-- ============================================
SELECT 
    'accounts' as table_name, 
    COUNT(*) as row_count,
    ROUND(COUNT(*) * 100.0 / (
        SELECT COUNT(*) FROM accounts +
        SELECT COUNT(*) FROM aircraft +
        SELECT COUNT(*) FROM aircraft_types +
        SELECT COUNT(*) FROM airport +
        SELECT COUNT(*) FROM boarding_passes +
        SELECT COUNT(*) FROM bookings +
        SELECT COUNT(*) FROM booking_items +
        SELECT COUNT(*) FROM cancellations +
        SELECT COUNT(*) FROM crew +
        SELECT COUNT(*) FROM crew_assignments +
        SELECT COUNT(*) FROM delays +
        SELECT COUNT(*) FROM flights +
        SELECT COUNT(*) FROM passengers +
        SELECT COUNT(*) FROM routes +
        SELECT COUNT(*) FROM seats +
        SELECT COUNT(*) FROM seat_reservations +
        SELECT COUNT(*) FROM ticket_payments
    ), 2) as percentage
FROM accounts
UNION ALL
SELECT 'aircraft', COUNT(*), 0 FROM aircraft
UNION ALL
SELECT 'aircraft_types', COUNT(*), 0 FROM aircraft_types
UNION ALL
SELECT 'airport', COUNT(*), 0 FROM airport
UNION ALL
SELECT 'boarding_passes', COUNT(*), 0 FROM boarding_passes
UNION ALL
SELECT 'bookings', COUNT(*), 0 FROM bookings
UNION ALL
SELECT 'booking_items', COUNT(*), 0 FROM booking_items
UNION ALL
SELECT 'cancellations', COUNT(*), 0 FROM cancellations
UNION ALL
SELECT 'crew', COUNT(*), 0 FROM crew
UNION ALL
SELECT 'crew_assignments', COUNT(*), 0 FROM crew_assignments
UNION ALL
SELECT 'delays', COUNT(*), 0 FROM delays
UNION ALL
SELECT 'flights', COUNT(*), 0 FROM flights
UNION ALL
SELECT 'passengers', COUNT(*), 0 FROM passengers
UNION ALL
SELECT 'routes', COUNT(*), 0 FROM routes
UNION ALL
SELECT 'seats', COUNT(*), 0 FROM seats
UNION ALL
SELECT 'seat_reservations', COUNT(*), 0 FROM seat_reservations
UNION ALL
SELECT 'ticket_payments', COUNT(*), 0 FROM ticket_payments
ORDER BY row_count DESC;

