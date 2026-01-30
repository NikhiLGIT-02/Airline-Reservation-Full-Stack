<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id'])) {
    header("Location: index.php");
    exit();
}

$booking_id = isset($_GET['booking_id']) ? intval($_GET['booking_id']) : 0;
$confirmed = isset($_POST['confirmed']) && $_POST['confirmed'] === 'yes';
$new_date = isset($_POST['new_date']) ? $_POST['new_date'] : (isset($_GET['new_date']) ? $_GET['new_date'] : '');
$new_flight_id = isset($_POST['new_flight_id']) ? intval($_POST['new_flight_id']) : 0;

$success = false;
$error = '';
$booking_info = null;
$available_flights = [];
$updated_flight_info = null;

// Get booking information
if ($booking_id) {
    $booking_check = $conn->query("
        SELECT b.booking_id, b.booking_status,
               bi.item_id, bi.flight_id as current_flight_id,
               f.flight_no, f.scheduled_departure, f.scheduled_arrival,
               a1.city as origin_city, a1.airport_code as origin_code, a1.airport_id as origin_id,
               a2.city as dest_city, a2.airport_code as dest_code, a2.airport_id as dest_id,
               r.route_id
        FROM bookings b
        JOIN booking_items bi ON b.booking_id = bi.booking_id
        JOIN flights f ON bi.flight_id = f.flight_id
        JOIN routes r ON f.route_id = r.route_id
        JOIN airport a1 ON r.origin_airport_id = a1.airport_id
        JOIN airport a2 ON r.destination_airport_id = a2.airport_id
        WHERE b.booking_id = $booking_id 
        AND b.account_id = " . $_SESSION['account_id'] . "
        AND b.booking_status = 'Confirmed'
        LIMIT 1
    ");
    
    if ($booking_check && $booking_check->num_rows > 0) {
        $booking_info = $booking_check->fetch_assoc();
    } else {
        header("Location: home.php");
        exit();
    }
}

// Process date change
if ($confirmed && $booking_id && $new_flight_id) {
    // Verify new flight exists and is on the same route
    $new_flight_check = $conn->query("
        SELECT f.flight_id, f.route_id
        FROM flights f
        WHERE f.flight_id = $new_flight_id
        AND f.route_id = " . $booking_info['route_id'] . "
        AND f.scheduled_departure > NOW()
        LIMIT 1
    ");
    
    if ($new_flight_check && $new_flight_check->num_rows > 0) {
        // Get current booking item
        $current_item = $conn->query("
            SELECT item_id, passenger_id FROM booking_items
            WHERE booking_id = $booking_id AND flight_id = " . $booking_info['current_flight_id'] . "
            LIMIT 1
        ")->fetch_assoc();
        
        if ($current_item) {
            // Update booking item to new flight
            $conn->query("
                UPDATE booking_items 
                SET flight_id = $new_flight_id
                WHERE item_id = " . $current_item['item_id']
            );
            
            // Get new flight details for confirmation
            $new_flight_details = $conn->query("
                SELECT f.flight_no, f.scheduled_departure, f.scheduled_arrival
                FROM flights f
                WHERE f.flight_id = $new_flight_id
            ")->fetch_assoc();
            
            // Get seat reservation (check by item_id only, since flight_id will be updated)
            $seat_reservation = $conn->query("
                SELECT seat_reservation_id, seat_id FROM seat_reservations
                WHERE item_id = " . $current_item['item_id'] . "
                LIMIT 1
            ")->fetch_assoc();
            
            $seat_id_for_bp = null;
            
            if ($seat_reservation) {
                // Check if same seat is available on new flight
                $seat_available = $conn->query("
                    SELECT COUNT(*) as count FROM seat_reservations
                    WHERE flight_id = $new_flight_id AND seat_id = " . $seat_reservation['seat_id'] . "
                ")->fetch_assoc();
                
                if ($seat_available['count'] == 0) {
                    // Update seat reservation to new flight
                    $conn->query("
                        UPDATE seat_reservations
                        SET flight_id = $new_flight_id
                        WHERE seat_reservation_id = " . $seat_reservation['seat_reservation_id']
                    );
                    $seat_id_for_bp = $seat_reservation['seat_id'];
                } else {
                    // Seat not available, remove reservation (user will need to select new seat)
                    $conn->query("
                        DELETE FROM seat_reservations
                        WHERE seat_reservation_id = " . $seat_reservation['seat_reservation_id']
                    );
                }
            }
            
            // Update or create boarding pass - ALWAYS update to new flight
            // Delete old boarding pass first (if exists)
            $conn->query("
                DELETE FROM boarding_passes
                WHERE booking_item_id = " . $current_item['item_id']
            );
            
            // Create new boarding pass with updated flight and seat
            if ($seat_id_for_bp) {
                $conn->query("
                    INSERT INTO boarding_passes (booking_item_id, flight_id, seat_id, passenger_id)
                    VALUES (" . $current_item['item_id'] . ", $new_flight_id, $seat_id_for_bp, " . $current_item['passenger_id'] . ")
                ");
            } else {
                // If no seat, still create boarding pass but we'll need to get a seat later
                // For now, try to get the seat from the old boarding pass or seat reservation
                $old_seat = $conn->query("
                    SELECT seat_id FROM seat_reservations
                    WHERE item_id = " . $current_item['item_id'] . "
                    LIMIT 1
                ")->fetch_assoc();
                
                if ($old_seat) {
                    $conn->query("
                        INSERT INTO boarding_passes (booking_item_id, flight_id, seat_id, passenger_id)
                        VALUES (" . $current_item['item_id'] . ", $new_flight_id, " . $old_seat['seat_id'] . ", " . $current_item['passenger_id'] . ")
                    ");
                } else {
                    // Get any available seat for this flight
                    $available_seat = $conn->query("
                        SELECT s.seat_id FROM seats s
                        JOIN flights f ON s.aircraft_id = (SELECT aircraft_id FROM flights WHERE flight_id = $new_flight_id)
                        WHERE s.seat_id NOT IN (
                            SELECT seat_id FROM seat_reservations WHERE flight_id = $new_flight_id
                        )
                        LIMIT 1
                    ")->fetch_assoc();
                    
                    if ($available_seat) {
                        $conn->query("
                            INSERT INTO boarding_passes (booking_item_id, flight_id, seat_id, passenger_id)
                            VALUES (" . $current_item['item_id'] . ", $new_flight_id, " . $available_seat['seat_id'] . ", " . $current_item['passenger_id'] . ")
                        ");
                    }
                }
            }
            
            // Verify the update by fetching the updated booking info directly from the new flight
            $updated_booking_check = $conn->query("
                SELECT f.flight_no, f.scheduled_departure, f.scheduled_arrival,
                       a1.airport_code as origin_code, a2.airport_code as dest_code
                FROM flights f
                JOIN routes r ON f.route_id = r.route_id
                JOIN airport a1 ON r.origin_airport_id = a1.airport_id
                JOIN airport a2 ON r.destination_airport_id = a2.airport_id
                WHERE f.flight_id = $new_flight_id
                LIMIT 1
            ")->fetch_assoc();
            
            // Also verify booking_items was updated
            $verify_booking_item = $conn->query("
                SELECT flight_id FROM booking_items
                WHERE item_id = " . $current_item['item_id']
            )->fetch_assoc();
            
            if ($updated_booking_check && $verify_booking_item && $verify_booking_item['flight_id'] == $new_flight_id) {
                $success = true;
                $updated_flight_info = $updated_booking_check;
            } else {
                $error = "Date changed but unable to verify update. Please check your bookings.";
            }
        } else {
            $error = "Unable to update booking. Please try again.";
        }
    } else {
        $error = "Selected flight is not available or invalid.";
    }
}

// Get available flights for selected date (show flights when date is selected but not yet confirmed)
if ($booking_info && $new_date && !$confirmed && !$success) {
    $available_flights_result = $conn->query("
        SELECT f.flight_id, f.flight_no, f.scheduled_departure, f.scheduled_arrival,
               r.distance_km
        FROM flights f
        JOIN routes r ON f.route_id = r.route_id
        WHERE r.route_id = " . $booking_info['route_id'] . "
        AND DATE(f.scheduled_departure) = '$new_date'
        AND f.scheduled_departure > NOW()
        AND f.flight_id != " . $booking_info['current_flight_id'] . "
        ORDER BY f.scheduled_departure ASC
    ");
    
    if ($available_flights_result) {
        while($row = $available_flights_result->fetch_assoc()) {
            $available_flights[] = $row;
        }
    }
    
    // If no flights found, create one automatically (using the logic from search_flights.php)
    if (empty($available_flights)) {
        // Get first available aircraft
        $aircraft = $conn->query("SELECT aircraft_id FROM aircraft LIMIT 1")->fetch_assoc();
        
        if ($aircraft) {
            $aircraft_id = $aircraft['aircraft_id'];
            $departure_time = $new_date . ' 10:00:00';
            $arrival_time = date('Y-m-d H:i:s', strtotime($departure_time . ' +2 hours'));
            
            // Generate flight number
            $flight_no = strtoupper($booking_info['origin_code'] . $booking_info['dest_code']) . rand(100, 999);
            
            $conn->query("
                INSERT INTO flights (flight_no, route_id, aircraft_id, scheduled_departure, scheduled_arrival)
                VALUES ('$flight_no', " . $booking_info['route_id'] . ", $aircraft_id, '$departure_time', '$arrival_time')
            ");
            
            $new_flight_id = $conn->insert_id;
            
            // Get the newly created flight
            $new_flight = $conn->query("
                SELECT f.flight_id, f.flight_no, f.scheduled_departure, f.scheduled_arrival,
                       r.distance_km
                FROM flights f
                JOIN routes r ON f.route_id = r.route_id
                WHERE f.flight_id = $new_flight_id
            ")->fetch_assoc();
            
            if ($new_flight) {
                $available_flights[] = $new_flight;
            }
        }
    }
}

include 'partials/header.php';
include 'partials/sidebar.php';
?>

<link rel="stylesheet" href="css/home.css">
<link rel="stylesheet" href="css/change_date.css">

<main class="main-content fade-in">

    <section class="card change-date-card">
        
        <?php if ($success && isset($updated_flight_info)): 
            $new_departure = new DateTime($updated_flight_info['scheduled_departure']);
            $new_arrival = new DateTime($updated_flight_info['scheduled_arrival']);
            $old_departure = new DateTime($booking_info['scheduled_departure']);
        ?>
            <div class="change-success">
                <div class="success-icon">✅</div>
                <h2>Flight Date Changed Successfully!</h2>
                <p class="success-message">Your booking has been updated. The changes are reflected in your bookings and boarding pass.</p>
                
                <div class="date-comparison">
                    <div class="old-date-info">
                        <h5>Previous Flight</h5>
                        <div class="date-detail">
                            <span class="date-label">Date:</span>
                            <span class="date-value"><?= $old_departure->format('M d, Y') ?></span>
                        </div>
                        <div class="date-detail">
                            <span class="date-label">Time:</span>
                            <span class="date-value"><?= $old_departure->format('h:i A') ?></span>
                        </div>
                        <div class="date-detail">
                            <span class="date-label">Flight:</span>
                            <span class="date-value"><?= htmlspecialchars($booking_info['flight_no']) ?></span>
                        </div>
                    </div>
                    
                    <div class="arrow-icon">→</div>
                    
                    <div class="new-date-info">
                        <h5>Updated Flight</h5>
                        <div class="date-detail">
                            <span class="date-label">Date:</span>
                            <span class="date-value highlight"><?= $new_departure->format('M d, Y') ?></span>
                        </div>
                        <div class="date-detail">
                            <span class="date-label">Time:</span>
                            <span class="date-value highlight"><?= $new_departure->format('h:i A') ?></span>
                        </div>
                        <div class="date-detail">
                            <span class="date-label">Flight:</span>
                            <span class="date-value highlight"><?= htmlspecialchars($updated_flight_info['flight_no']) ?></span>
                        </div>
                    </div>
                </div>
                
                <div class="updated-booking-info">
                    <h4>Complete Updated Details</h4>
                    <div class="booking-summary">
                        <div class="summary-item">
                            <span class="summary-label">Flight Number</span>
                            <span class="summary-value"><?= htmlspecialchars($updated_flight_info['flight_no']) ?></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Route</span>
                            <span class="summary-value"><?= htmlspecialchars($updated_flight_info['origin_code']) ?> → <?= htmlspecialchars($updated_flight_info['dest_code']) ?></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">New Date</span>
                            <span class="summary-value highlight"><?= $new_departure->format('M d, Y') ?></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Departure Time</span>
                            <span class="summary-value highlight"><?= $new_departure->format('h:i A') ?></span>
                        </div>
                        <div class="summary-item">
                            <span class="summary-label">Arrival Time</span>
                            <span class="summary-value highlight"><?= $new_arrival->format('h:i A') ?></span>
                        </div>
                    </div>
                </div>
                
                <div class="confirmation-note">
                    <p><strong>✓ Confirmed:</strong> Your booking, boarding pass, and all related records have been updated with the new flight date.</p>
                </div>
                
                <div class="action-buttons">
                    <a href="home.php" class="primary-btn">Back to Home</a>
                    <a href="boarding_pass.php?booking_id=<?= $booking_id ?>" class="view-bp-btn">View Updated Boarding Pass</a>
                </div>
            </div>
        <?php elseif ($error): ?>
            <div class="change-error">
                <div class="error-icon">⚠️</div>
                <h2>Unable to Change Date</h2>
                <p><?= htmlspecialchars($error) ?></p>
                <div class="action-buttons">
                    <a href="change_flight_date.php?booking_id=<?= $booking_id ?>" class="primary-btn">Try Again</a>
                    <a href="home.php" class="cancel-btn">Back to Home</a>
                </div>
            </div>
        <?php elseif ($booking_info): 
            $current_departure = new DateTime($booking_info['scheduled_departure']);
            $current_arrival = new DateTime($booking_info['scheduled_arrival']);
        ?>
            <div class="card-header">
                <h3>📅 Change Flight Date</h3>
                <p>Reschedule your confirmed booking to a different date</p>
            </div>

            <div class="current-booking-info">
                <h4>Current Booking Details</h4>
                <div class="booking-summary">
                    <div class="summary-item">
                        <span class="summary-label">Flight Number</span>
                        <span class="summary-value"><?= htmlspecialchars($booking_info['flight_no']) ?></span>
                    </div>
                    <div class="summary-item">
                        <span class="summary-label">Route</span>
                        <span class="summary-value"><?= htmlspecialchars($booking_info['origin_code']) ?> → <?= htmlspecialchars($booking_info['dest_code']) ?></span>
                    </div>
                    <div class="summary-item">
                        <span class="summary-label">Current Date</span>
                        <span class="summary-value"><?= $current_departure->format('M d, Y') ?></span>
                    </div>
                    <div class="summary-item">
                        <span class="summary-label">Departure Time</span>
                        <span class="summary-value"><?= $current_departure->format('h:i A') ?></span>
                    </div>
                    <div class="summary-item">
                        <span class="summary-label">Arrival Time</span>
                        <span class="summary-value"><?= $current_arrival->format('h:i A') ?></span>
                    </div>
                </div>
            </div>

            <form method="POST" class="change-date-form" action="?booking_id=<?= $booking_id ?>">
                <div class="form-group">
                    <label>Select New Date <span class="required">*</span></label>
                    <input type="date" 
                           name="new_date" 
                           id="new_date" 
                           required 
                           min="<?= date('Y-m-d', strtotime('+1 day')) ?>"
                           value="<?= htmlspecialchars($new_date) ?>"
                           onchange="this.form.submit()">
                    <small class="field-hint">Select a date after today</small>
                </div>
            </form>

            <?php if (!empty($available_flights)): ?>
                <div class="available-flights-section">
                    <h4>Available Flights on <?= date('M d, Y', strtotime($new_date)) ?></h4>
                    <div class="flights-list">
                        <?php foreach($available_flights as $flight): 
                            $departure = new DateTime($flight['scheduled_departure']);
                            $arrival = new DateTime($flight['scheduled_arrival']);
                            $duration = $departure->diff($arrival);
                            $duration_str = $duration->format('%h') . 'h ' . $duration->format('%i') . 'm';
                        ?>
                            <div class="flight-option">
                                <div class="flight-time-info">
                                    <div class="time-block">
                                        <span class="time"><?= $departure->format('H:i') ?></span>
                                        <span class="airport-code"><?= htmlspecialchars($booking_info['origin_code']) ?></span>
                                    </div>
                                    <div class="duration-info">
                                        <span class="duration"><?= $duration_str ?></span>
                                        <div class="route-line-small"></div>
                                    </div>
                                    <div class="time-block">
                                        <span class="time"><?= $arrival->format('H:i') ?></span>
                                        <span class="airport-code"><?= htmlspecialchars($booking_info['dest_code']) ?></span>
                                    </div>
                                </div>
                                <div class="flight-number"><?= htmlspecialchars($flight['flight_no']) ?></div>
                                <form method="POST" style="display: inline;" action="?booking_id=<?= $booking_id ?>">
                                    <input type="hidden" name="new_date" value="<?= htmlspecialchars($new_date) ?>">
                                    <input type="hidden" name="new_flight_id" value="<?= $flight['flight_id'] ?>">
                                    <button type="submit" 
                                            name="confirmed" 
                                            value="yes" 
                                            class="select-flight-btn"
                                            onclick="return confirm('Are you sure you want to change your flight to this date?')">
                                        Select This Flight
                                    </button>
                                </form>
                            </div>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php elseif ($new_date && empty($available_flights)): ?>
                <div class="no-flights">
                    <p>No flights available for the selected date. Please try a different date.</p>
                </div>
            <?php endif; ?>

            <div class="change-warning">
                <p><strong>⚠️ Important Notes:</strong></p>
                <ul>
                    <li>You can only change the date, not the route</li>
                    <li>If your current seat is not available on the new flight, you'll need to select a new seat</li>
                    <li>Any price difference will be handled as per airline policy</li>
                    <li>Changes can only be made for confirmed bookings</li>
                </ul>
            </div>

            <div class="action-buttons">
                <a href="home.php" class="cancel-btn">Cancel</a>
            </div>

        <?php else: ?>
            <div class="error-message">
                <p>Invalid booking or booking not found.</p>
                <a href="home.php" class="primary-btn">Back to Home</a>
            </div>
        <?php endif; ?>
        
    </section>

</main>

