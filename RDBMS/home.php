<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id'])) {
    header("Location: index.php");
    exit();
}

$user_id = $_SESSION['account_id'];

// Get user info
$user_info = $conn->query("SELECT email FROM Accounts WHERE account_id = $user_id")->fetch_assoc();
$user_email = $user_info ? $user_info['email'] : 'User';

// Get airports for search
$airports = $conn->query("SELECT airport_id, city, airport_code, name FROM airport ORDER BY city");

// Get all bookings with detailed information
$allBookings = $conn->query("
    SELECT DISTINCT b.booking_id, b.booking_status, b.booking_date,
           f.flight_no, f.scheduled_departure, f.scheduled_arrival,
           a1.city as src_city, a1.airport_code as src_code, a1.name as src_name,
           a2.city as dst_city, a2.airport_code as dst_code, a2.name as dst_name,
           tp.amount, tp.payment_method
    FROM bookings b
    JOIN booking_items bi ON b.booking_id = bi.booking_id
    JOIN flights f ON bi.flight_id = f.flight_id
    JOIN routes r ON f.route_id = r.route_id
    JOIN airport a1 ON r.origin_airport_id = a1.airport_id
    JOIN airport a2 ON r.destination_airport_id = a2.airport_id
    LEFT JOIN ticket_payments tp ON b.booking_id = tp.booking_id
    WHERE b.account_id = $user_id
    ORDER BY f.scheduled_departure DESC
");

// Get confirmed bookings only
$confirmedBookings = $conn->query("
    SELECT DISTINCT b.booking_id
    FROM bookings b
    WHERE b.account_id = $user_id AND b.booking_status = 'Confirmed'
");

// Get upcoming trips (future flights)
$upcomingTrips = $conn->query("
    SELECT DISTINCT b.booking_id
    FROM bookings b
    JOIN booking_items bi ON b.booking_id = bi.booking_id
    JOIN flights f ON bi.flight_id = f.flight_id
    WHERE b.account_id = $user_id 
    AND b.booking_status = 'Confirmed'
    AND f.scheduled_departure > NOW()
");

// Get total spent
$totalSpent = $conn->query("
    SELECT COALESCE(SUM(tp.amount), 0) as total
    FROM bookings b
    JOIN ticket_payments tp ON b.booking_id = tp.booking_id
    WHERE b.account_id = $user_id
")->fetch_assoc();

$totalBookings = ($allBookings && $allBookings->num_rows > 0) ? $allBookings->num_rows : 0;
$upcomingCount = ($upcomingTrips && $upcomingTrips->num_rows > 0) ? $upcomingTrips->num_rows : 0;
$confirmedCount = ($confirmedBookings && $confirmedBookings->num_rows > 0) ? $confirmedBookings->num_rows : 0;
$totalAmount = $totalSpent ? number_format($totalSpent['total'], 2) : '0.00';
$totalAmountINR = '₹' . number_format($totalSpent['total'], 2);

// Reset result pointer for display
if ($allBookings) {
    $allBookings->data_seek(0);
}

include 'partials/header.php';
include 'partials/sidebar.php';
?>

<link rel="stylesheet" href="css/home.css">

<main class="main-content fade-in">

    <!-- WELCOME SECTION -->
    <section class="welcome-section">
        <div class="welcome-content">
            <h1 class="welcome-title">Welcome Back! <span class="wave">👋</span></h1>
            <p class="welcome-subtitle">Manage your flights and bookings with ease</p>
        </div>
    </section>

    <!-- STATS -->
    <section class="stats">
        <div class="stat-card stat-primary">
            <div class="stat-icon">📋</div>
            <div class="stat-content">
                <h4>Total Bookings</h4>
                <strong><?= $totalBookings ?></strong>
            </div>
        </div>
        <div class="stat-card stat-success">
            <div class="stat-icon">✈️</div>
            <div class="stat-content">
                <h4>Upcoming Trips</h4>
                <strong><?= $upcomingCount ?></strong>
            </div>
        </div>
        <div class="stat-card stat-info">
            <div class="stat-icon">✅</div>
            <div class="stat-content">
                <h4>Confirmed</h4>
                <strong><?= $confirmedCount ?></strong>
            </div>
        </div>
        <div class="stat-card stat-warning">
            <div class="stat-icon">💰</div>
            <div class="stat-content">
                <h4>Total Spent</h4>
                <strong><?= $totalAmountINR ?></strong>
            </div>
        </div>
    </section>

    <!-- SEARCH -->
    <section class="card search-card" id="search">
        <div class="card-header">
            <h3>🔍 Search Flights</h3>
            <p>Find your perfect flight in seconds</p>
        </div>
        <form class="search-form" action="search_flights.php" method="POST">
            <div class="form-group">
                <label>From</label>
                <select name="from" required>
                    <option value="">Select Origin</option>
                    <?php while($a = $airports->fetch_assoc()): ?>
                        <option value="<?= $a['airport_id'] ?>">
                            <?= $a['city'] ?> (<?= $a['airport_code'] ?>)
                        </option>
                    <?php endwhile; ?>
                </select>
            </div>

            <div class="form-group">
                <label>To</label>
                <?php $airports->data_seek(0); ?>
                <select name="to" required>
                    <option value="">Select Destination</option>
                    <?php while($a = $airports->fetch_assoc()): ?>
                        <option value="<?= $a['airport_id'] ?>">
                            <?= $a['city'] ?> (<?= $a['airport_code'] ?>)
                        </option>
                    <?php endwhile; ?>
                </select>
            </div>

            <div class="form-group">
                <label>Departure Date</label>
                <input type="date" name="date" required min="<?= date('Y-m-d') ?>">
            </div>

            <div class="form-group">
                <label>&nbsp;</label>
                <button type="submit" class="primary-btn">
                    <span>Search Flights</span>
                    <span class="btn-icon">→</span>
                </button>
            </div>
        </form>
    </section>

    <!-- MY BOOKINGS -->
    <section class="card bookings-card" id="bookings">
        <div class="card-header">
            <h3>📑 My Bookings</h3>
            <p>View and manage all your flight reservations</p>
        </div>

        <?php if ($totalBookings > 0): ?>
            <div class="bookings-container">
                <?php 
                $counter = 0;
                while($b = $allBookings->fetch_assoc()): 
                    $counter++;
                    $departure = new DateTime($b['scheduled_departure']);
                    $arrival = new DateTime($b['scheduled_arrival']);
                    $isUpcoming = $departure > new DateTime();
                    $statusClass = strtolower($b['booking_status']);
                ?>
                    <div class="booking-card slide-up" style="animation-delay: <?= $counter * 0.1 ?>s">
                        <div class="booking-header">
                            <div class="flight-info">
                                <div class="route">
                                    <div class="airport">
                                        <span class="airport-code"><?= $b['src_code'] ?></span>
                                        <span class="airport-name"><?= $b['src_city'] ?></span>
                                    </div>
                                    <div class="route-line">
                                        <span class="flight-number"><?= $b['flight_no'] ?></span>
                                    </div>
                                    <div class="airport">
                                        <span class="airport-code"><?= $b['dst_code'] ?></span>
                                        <span class="airport-name"><?= $b['dst_city'] ?></span>
                                    </div>
                                </div>
                            </div>
                            <span class="badge badge-<?= $statusClass ?>"><?= $b['booking_status'] ?></span>
                        </div>
                        
                        <div class="booking-details">
                            <div class="detail-item">
                                <span class="detail-label">📅 Departure</span>
                                <span class="detail-value"><?= $departure->format('M d, Y') ?></span>
                                <span class="detail-time"><?= $departure->format('h:i A') ?></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">🛬 Arrival</span>
                                <span class="detail-value"><?= $arrival->format('M d, Y') ?></span>
                                <span class="detail-time"><?= $arrival->format('h:i A') ?></span>
                            </div>
                            <?php if ($b['amount']): ?>
                            <div class="detail-item">
                                <span class="detail-label">💳 Amount</span>
                                <span class="detail-value" style="white-space: nowrap;">₹<?= number_format($b['amount'], 2) ?></span>
                                <span class="detail-time"><?= $b['payment_method'] ?></span>
                            </div>
                            <?php endif; ?>
                        </div>

                        <div class="booking-actions">
                            <a href="boarding_pass.php?booking_id=<?= $b['booking_id'] ?>" class="action-btn view-btn">
                                View Boarding Pass
                            </a>
                            <?php if ($b['booking_status'] == 'Confirmed' && $isUpcoming): ?>
                            <a href="change_flight_date.php?booking_id=<?= $b['booking_id'] ?>" class="action-btn change-date-btn">
                                Change Date
                            </a>
                            <a href="cancel_booking.php?booking_id=<?= $b['booking_id'] ?>" 
                               class="action-btn cancel-btn"
                               onclick="return confirm('Are you sure you want to cancel this booking?')">
                                Cancel Booking
                            </a>
                            <?php endif; ?>
                        </div>
                    </div>
                <?php endwhile; ?>
            </div>
        <?php else: ?>
            <div class="empty-state">
                <div class="empty-icon">✈️</div>
                <h3>No Bookings Yet</h3>
                <p>Start your journey by searching for flights above</p>
                <a href="#search" class="primary-btn">Search Flights</a>
            </div>
        <?php endif; ?>
    </section>

</main>
