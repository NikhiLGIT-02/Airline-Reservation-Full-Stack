<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id'])) {
    header("Location: index.php");
    exit();
}

$booking_id = isset($_GET['booking_id']) ? intval($_GET['booking_id']) : 0;
$confirmed = isset($_GET['confirmed']) && $_GET['confirmed'] === 'yes';

if (!$booking_id && !$confirmed) {
    header("Location: home.php");
    exit();
}

$success = false;
$error = '';
$booking_info = null;

if ($booking_id && $confirmed) {
    // Verify booking belongs to the logged-in user
    $booking_check = $conn->query("
        SELECT b.booking_id, b.booking_status,
               f.flight_no, f.scheduled_departure,
               a1.city as origin_city, a1.airport_code as origin_code,
               a2.city as dest_city, a2.airport_code as dest_code
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
        
        // Cancel the booking
        $conn->query("UPDATE bookings SET booking_status='Cancelled'
                      WHERE booking_id=$booking_id AND account_id=" . $_SESSION['account_id']);
        
        $success = true;
    } else {
        $error = "Booking not found or already cancelled.";
    }
} elseif ($booking_id) {
    // Get booking info for confirmation
    $booking_check = $conn->query("
        SELECT b.booking_id, b.booking_status,
               f.flight_no, f.scheduled_departure,
               a1.city as origin_city, a1.airport_code as origin_code,
               a2.city as dest_city, a2.airport_code as dest_code
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

include 'partials/header.php';
include 'partials/sidebar.php';
?>

<link rel="stylesheet" href="css/home.css">
<link rel="stylesheet" href="css/cancel_booking.css">

<main class="main-content fade-in">

    <section class="card cancel-booking-card">
        
        <?php if ($success): ?>
            <div class="cancel-success">
                <div class="success-icon">✅</div>
                <h2>Booking Cancelled Successfully</h2>
                <p>Your booking has been cancelled. You will receive a confirmation email shortly.</p>
                
                <?php if ($booking_info): 
                    $departure = new DateTime($booking_info['scheduled_departure']);
                ?>
                    <div class="cancelled-booking-info">
                        <h3>Cancelled Booking Details</h3>
                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">Flight Number</span>
                                <span class="info-value"><?= htmlspecialchars($booking_info['flight_no']) ?></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Route</span>
                                <span class="info-value"><?= htmlspecialchars($booking_info['origin_code']) ?> → <?= htmlspecialchars($booking_info['dest_code']) ?></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Departure Date</span>
                                <span class="info-value"><?= $departure->format('M d, Y') ?></span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Booking ID</span>
                                <span class="info-value">#<?= str_pad($booking_info['booking_id'], 8, '0', STR_PAD_LEFT) ?></span>
                            </div>
                        </div>
                    </div>
                <?php endif; ?>
                
                <div class="action-buttons">
                    <a href="home.php" class="primary-btn">Back to Home</a>
                </div>
            </div>
        <?php elseif ($error): ?>
            <div class="cancel-error">
                <div class="error-icon">⚠️</div>
                <h2>Unable to Cancel Booking</h2>
                <p><?= htmlspecialchars($error) ?></p>
                <div class="action-buttons">
                    <a href="home.php" class="primary-btn">Back to Home</a>
                </div>
            </div>
        <?php elseif ($booking_info): 
            $departure = new DateTime($booking_info['scheduled_departure']);
        ?>
            <div class="cancel-confirmation">
                <div class="warning-icon">⚠️</div>
                <h2>Confirm Cancellation</h2>
                <p>Are you sure you want to cancel this booking? This action cannot be undone.</p>
                
                <div class="booking-details-box">
                    <h3>Booking Details</h3>
                    <div class="details-grid">
                        <div class="detail-item">
                            <span class="detail-label">Flight Number</span>
                            <span class="detail-value"><?= htmlspecialchars($booking_info['flight_no']) ?></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Route</span>
                            <span class="detail-value"><?= htmlspecialchars($booking_info['origin_code']) ?> → <?= htmlspecialchars($booking_info['dest_code']) ?></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Departure</span>
                            <span class="detail-value"><?= $departure->format('M d, Y h:i A') ?></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Status</span>
                            <span class="detail-value badge-confirmed"><?= htmlspecialchars($booking_info['booking_status']) ?></span>
                        </div>
                    </div>
                </div>
                
                <div class="cancellation-warning">
                    <p><strong>⚠️ Important:</strong> Cancelling this booking will:</p>
                    <ul>
                        <li>Release your seat for other passengers</li>
                        <li>Process refund as per cancellation policy</li>
                        <li>Send cancellation confirmation to your email</li>
                    </ul>
                </div>
                
                <div class="action-buttons">
                    <a href="cancel_booking.php?booking_id=<?= $booking_id ?>&confirmed=yes" class="cancel-confirm-btn">Yes, Cancel Booking</a>
                    <a href="home.php" class="cancel-cancel-btn">No, Keep Booking</a>
                </div>
            </div>
        <?php endif; ?>
        
    </section>

</main>
