<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id'])) {
    header("Location: index.php");
    exit();
}

$flight_id = isset($_GET['flight_id']) ? intval($_GET['flight_id']) : 0;
$booking_id = isset($_GET['booking_id']) ? intval($_GET['booking_id']) : 0;

if (!$flight_id || !$booking_id) {
    header("Location: home.php");
    exit();
}

// Verify booking belongs to user
$booking_check = $conn->query("
    SELECT booking_id FROM bookings 
    WHERE booking_id = $booking_id 
    AND account_id = " . $_SESSION['account_id'] . "
    AND booking_status = 'Confirmed'
");

if (!$booking_check || $booking_check->num_rows === 0) {
    header("Location: home.php");
    exit();
}

// Get flight details
$flight_info = $conn->query("
    SELECT f.flight_id, f.flight_no, f.scheduled_departure,
           a1.city as origin_city, a1.airport_code as origin_code,
           a2.city as dest_city, a2.airport_code as dest_code
    FROM flights f
    JOIN routes r ON f.route_id = r.route_id
    JOIN airport a1 ON r.origin_airport_id = a1.airport_id
    JOIN airport a2 ON r.destination_airport_id = a2.airport_id
    WHERE f.flight_id = $flight_id
")->fetch_assoc();

if (!$flight_info) {
    header("Location: home.php");
    exit();
}

// Get aircraft for this flight
$aircraft = $conn->query("
    SELECT ac.aircraft_id, at.seating_capacity
    FROM flights f
    JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
    JOIN aircraft_types at ON ac.aircraft_type_id = at.aircraft_type_id
    WHERE f.flight_id = $flight_id
")->fetch_assoc();

// Get booked seats for this flight
$booked_seats = [];
$booked_result = $conn->query("
    SELECT s.seat_number
    FROM seat_reservations sr
    JOIN seats s ON sr.seat_id = s.seat_id
    WHERE sr.flight_id = $flight_id
");

if ($booked_result) {
    while($row = $booked_result->fetch_assoc()) {
        $booked_seats[] = $row['seat_number'];
    }
}

// Get available seats
$available_seats = $conn->query("
    SELECT s.seat_id, s.seat_number, s.seat_class
    FROM seats s
    WHERE s.aircraft_id = " . $aircraft['aircraft_id'] . "
    ORDER BY s.seat_number
");

// Process seat selection
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['seat_id'])) {
    $seat_id = intval($_POST['seat_id']);
    
    // Get booking item
    $booking_item = $conn->query("
        SELECT item_id FROM booking_items 
        WHERE booking_id = $booking_id AND flight_id = $flight_id
        LIMIT 1
    ")->fetch_assoc();
    
    if ($booking_item) {
        // Check if seat is already booked
        $seat_check = $conn->query("
            SELECT seat_id FROM seats WHERE seat_id = $seat_id
        ")->fetch_assoc();
        
        $seat_number = $seat_check ? $conn->query("
            SELECT seat_number FROM seats WHERE seat_id = $seat_id
        ")->fetch_assoc()['seat_number'] : '';
        
        if (!in_array($seat_number, $booked_seats)) {
            // Reserve the seat
            $conn->query("
                INSERT INTO seat_reservations (item_id, seat_id, flight_id)
                VALUES (" . $booking_item['item_id'] . ", $seat_id, $flight_id)
            ");
            
            header("Location: payment.php?booking_id=$booking_id&flight_id=$flight_id&seat_id=$seat_id");
            exit();
        }
    }
}

include 'partials/header.php';
include 'partials/sidebar.php';
?>

<link rel="stylesheet" href="css/home.css">
<link rel="stylesheet" href="css/seat.css">

<main class="main-content fade-in">
    
    <section class="card seat-selection-card">
        <div class="card-header">
            <h3>🪑 Select Your Seat</h3>
            <p><?= htmlspecialchars($flight_info['flight_no']) ?> • <?= htmlspecialchars($flight_info['origin_code']) ?> → <?= htmlspecialchars($flight_info['dest_code']) ?></p>
        </div>

        <div class="seat-selection-container">
            <!-- Legend -->
            <div class="seat-legend">
                <div class="legend-item">
                    <div class="legend-seat seat-available"></div>
                    <span>Available</span>
                </div>
                <div class="legend-item">
                    <div class="legend-seat seat-booked"></div>
                    <span>Booked</span>
                </div>
                <div class="legend-item">
                    <div class="legend-seat seat-window"></div>
                    <span>Window</span>
                </div>
                <div class="legend-item">
                    <div class="legend-seat seat-middle"></div>
                    <span>Middle</span>
                </div>
                <div class="legend-item">
                    <div class="legend-seat seat-aisle"></div>
                    <span>Aisle</span>
                </div>
            </div>

            <!-- Aircraft Layout -->
            <div class="aircraft-layout">
                <div class="aircraft-header">
                    <div class="aircraft-front">✈️ Front</div>
                </div>
                
                <div class="seat-map">
                    <?php
                    $rows = [];
                    if ($available_seats) {
                        while($seat = $available_seats->fetch_assoc()) {
                            // Parse seat number (e.g., "1A", "2B")
                            preg_match('/(\d+)([A-Z])/', $seat['seat_number'], $matches);
                            if ($matches) {
                                $row_num = intval($matches[1]);
                                $col_letter = $matches[2];
                                if (!isset($rows[$row_num])) {
                                    $rows[$row_num] = [];
                                }
                                $rows[$row_num][$col_letter] = $seat;
                            }
                        }
                    }
                    
                    // Determine seat type based on column
                    $seat_types = [
                        'A' => 'window', 'B' => 'middle', 'C' => 'aisle',
                        'D' => 'aisle', 'E' => 'middle', 'F' => 'window'
                    ];
                    
                    foreach($rows as $row_num => $cols): 
                        ksort($cols);
                    ?>
                        <div class="seat-row">
                            <div class="row-number"><?= $row_num ?></div>
                            <div class="row-seats">
                                <?php 
                                $col_order = ['A', 'B', 'C', 'D', 'E', 'F'];
                                foreach($col_order as $col):
                                    if (isset($cols[$col])):
                                        $seat = $cols[$col];
                                        $is_booked = in_array($seat['seat_number'], $booked_seats);
                                        $seat_type = isset($seat_types[$col]) ? $seat_types[$col] : 'middle';
                                ?>
                                    <form method="POST" class="seat-form">
                                        <input type="hidden" name="seat_id" value="<?= $seat['seat_id'] ?>">
                                        <button type="submit" 
                                                class="seat-btn seat-<?= $seat_type ?> <?= $is_booked ? 'seat-booked' : 'seat-available' ?>"
                                                <?= $is_booked ? 'disabled title="Already Booked"' : 'title="' . ucfirst($seat_type) . ' Seat - ' . $seat['seat_number'] . '"' ?>>
                                            <span class="seat-number"><?= $seat['seat_number'] ?></span>
                                            <?php if ($seat_type === 'window'): ?>
                                                <span class="seat-icon">🪟</span>
                                            <?php elseif ($seat_type === 'aisle'): ?>
                                                <span class="seat-icon">🚶</span>
                                            <?php else: ?>
                                                <span class="seat-icon">🪑</span>
                                            <?php endif; ?>
                                        </button>
                                    </form>
                                <?php else: ?>
                                    <div class="seat-spacer"></div>
                                <?php endif; endforeach; ?>
                            </div>
                            <div class="row-number"><?= $row_num ?></div>
                        </div>
                    <?php endforeach; ?>
                </div>
                
                <div class="aircraft-footer">
                    <div class="aircraft-back">✈️ Back</div>
                </div>
            </div>

            <div class="seat-info-box">
                <p><strong>💡 Tip:</strong> Window seats (A, F) offer views, Aisle seats (C, D) offer more legroom, and Middle seats (B, E) are between them.</p>
            </div>
        </div>
    </section>

</main>
