<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id'])) {
    header("Location: index.php");
    exit();
}

$from = isset($_POST['from']) ? intval($_POST['from']) : 0;
$to = isset($_POST['to']) ? intval($_POST['to']) : 0;
$date = isset($_POST['date']) ? $_POST['date'] : '';

$flights = [];
$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $from && $to && $date) {
    // First, check if route exists, if not create it
    $route_check = $conn->query("
        SELECT route_id, distance_km 
        FROM routes 
        WHERE origin_airport_id = $from 
        AND destination_airport_id = $to
        LIMIT 1
    ");
    
    $route_id = null;
    $distance_km = 1000; // Default distance
    
    if ($route_check && $route_check->num_rows > 0) {
        $route_data = $route_check->fetch_assoc();
        $route_id = $route_data['route_id'];
        $distance_km = $route_data['distance_km'];
    } else {
        // Create route if it doesn't exist
        // Calculate approximate distance (you can improve this with actual coordinates)
        $conn->query("
            INSERT INTO routes (origin_airport_id, destination_airport_id, distance_km)
            VALUES ($from, $to, 1000)
        ");
        $route_id = $conn->insert_id;
    }
    
    // Check if flights exist for this route on the selected date
    $flights_exist = $conn->query("
        SELECT COUNT(*) as count 
        FROM flights f
        WHERE f.route_id = $route_id
        AND DATE(f.scheduled_departure) = '$date'
        AND f.scheduled_departure > NOW()
    ")->fetch_assoc();
    
    // If no flights exist, create a default flight for this route
    if ($flights_exist['count'] == 0) {
        // Get first available aircraft
        $aircraft = $conn->query("
            SELECT aircraft_id FROM aircraft LIMIT 1
        ")->fetch_assoc();
        
        if ($aircraft) {
            $aircraft_id = $aircraft['aircraft_id'];
            $departure_time = $date . ' 10:00:00';
            $arrival_time = date('Y-m-d H:i:s', strtotime($departure_time . ' +2 hours'));
            
            // Generate flight number
            $from_code = $conn->query("SELECT airport_code FROM airport WHERE airport_id = $from")->fetch_assoc()['airport_code'];
            $to_code = $conn->query("SELECT airport_code FROM airport WHERE airport_id = $to")->fetch_assoc()['airport_code'];
            $flight_no = strtoupper(substr($from_code, 0, 2) . substr($to_code, 0, 2)) . rand(100, 999);
            
            $conn->query("
                INSERT INTO flights (flight_no, route_id, aircraft_id, scheduled_departure, scheduled_arrival)
                VALUES ('$flight_no', $route_id, $aircraft_id, '$departure_time', '$arrival_time')
            ");
        }
    }
    
    // Now get flights based on route
    $result = $conn->query("
        SELECT f.flight_id, f.flight_no, f.scheduled_departure, f.scheduled_arrival,
               a1.city as origin_city, a1.airport_code as origin_code, a1.name as origin_name,
               a2.city as dest_city, a2.airport_code as dest_code, a2.name as dest_name,
               r.distance_km,
               at.model as aircraft_model, at.manufacturer
        FROM flights f
        JOIN routes r ON f.route_id = r.route_id
        JOIN airport a1 ON r.origin_airport_id = a1.airport_id
        JOIN airport a2 ON r.destination_airport_id = a2.airport_id
        JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
        JOIN aircraft_types at ON ac.aircraft_type_id = at.aircraft_type_id
        WHERE r.origin_airport_id = $from
        AND r.destination_airport_id = $to
        AND DATE(f.scheduled_departure) = '$date'
        AND f.scheduled_departure > NOW()
        ORDER BY f.scheduled_departure ASC
    ");
    
    if ($result && $result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $flights[] = $row;
        }
    } else {
        $error = "No flights available for the selected route and date. Please try a different date.";
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $error = "Please fill in all search fields.";
}

// Get airports for display
$airports = $conn->query("SELECT airport_id, city, airport_code, name FROM airport ORDER BY city");

include 'partials/header.php';
include 'partials/sidebar.php';
?>

<link rel="stylesheet" href="css/home.css">
<link rel="stylesheet" href="css/search_flights.css">

<main class="main-content fade-in">
    
    <section class="card search-results-card">
        <div class="card-header">
            <h3>🔍 Search Results</h3>
            <p>Available flights for your journey</p>
        </div>

        <?php if ($error): ?>
            <div class="alert alert-error">
                <span>⚠️</span>
                <span><?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>

        <?php if (empty($flights) && $_SERVER['REQUEST_METHOD'] !== 'POST'): ?>
            <div class="empty-state">
                <div class="empty-icon">✈️</div>
                <h3>Search for Flights</h3>
                <p>Use the search form on the home page to find available flights</p>
                <a href="home.php#search" class="primary-btn">Go to Search</a>
            </div>
        <?php elseif (!empty($flights)): ?>
            <div class="flights-list">
                <?php foreach($flights as $index => $flight): 
                    $departure = new DateTime($flight['scheduled_departure']);
                    $arrival = new DateTime($flight['scheduled_arrival']);
                    $duration = $departure->diff($arrival);
                    $duration_str = $duration->format('%h') . 'h ' . $duration->format('%i') . 'm';
                    
                    // Calculate price based on distance (dummy pricing)
                    $base_price = 5000;
                    $price_per_km = 15;
                    $price = $base_price + ($flight['distance_km'] * $price_per_km);
                ?>
                    <div class="flight-card slide-up" style="animation-delay: <?= $index * 0.1 ?>s">
                        <div class="flight-header">
                            <div class="flight-number-badge">
                                <span class="flight-code"><?= htmlspecialchars($flight['flight_no']) ?></span>
                            </div>
                            <div class="aircraft-info">
                                <span class="aircraft-name"><?= htmlspecialchars($flight['manufacturer'] . ' ' . $flight['aircraft_model']) ?></span>
                            </div>
                        </div>

                        <div class="flight-route">
                            <div class="route-point">
                                <div class="route-time"><?= $departure->format('H:i') ?></div>
                                <div class="route-airport">
                                    <span class="airport-code-large"><?= htmlspecialchars($flight['origin_code']) ?></span>
                                    <span class="airport-city"><?= htmlspecialchars($flight['origin_city']) ?></span>
                                    <span class="airport-name-small"><?= htmlspecialchars($flight['origin_name']) ?></span>
                                </div>
                            </div>
                            
                            <div class="route-connector">
                                <div class="route-line-connector"></div>
                                <div class="route-duration"><?= $duration_str ?></div>
                            </div>
                            
                            <div class="route-point">
                                <div class="route-time"><?= $arrival->format('H:i') ?></div>
                                <div class="route-airport">
                                    <span class="airport-code-large"><?= htmlspecialchars($flight['dest_code']) ?></span>
                                    <span class="airport-city"><?= htmlspecialchars($flight['dest_city']) ?></span>
                                    <span class="airport-name-small"><?= htmlspecialchars($flight['dest_name']) ?></span>
                                </div>
                            </div>
                        </div>

                        <div class="flight-footer">
                            <div class="flight-price">
                                <span class="price-label">Starting from</span>
                                <span class="price-amount">₹<?= number_format($price, 0) ?></span>
                            </div>
                            <a href="book_flight.php?flight_id=<?= $flight['flight_id'] ?>" class="book-btn">
                                Book Now
                                <span class="btn-arrow">→</span>
                            </a>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        <?php else: ?>
            <div class="empty-state">
                <div class="empty-icon">✈️</div>
                <h3>No Flights Found</h3>
                <p>We couldn't find any flights matching your criteria. Try different dates or routes.</p>
                <a href="home.php#search" class="primary-btn">Search Again</a>
            </div>
        <?php endif; ?>
    </section>

</main>
