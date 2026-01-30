<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id']) || $_SESSION['role'] !== 'user') {
    header("Location: index.php");
    exit();
}

$booking_id = isset($_GET['booking_id']) ? intval($_GET['booking_id']) : 0;

if (!$booking_id) {
    header("Location: home.php");
    exit();
}

// First, try to get existing boarding pass
$bp_query = $conn->query("
    SELECT bp.boarding_pass_id, bp.boarding_pass_id AS pass_id,
           f.flight_no, f.scheduled_departure, f.scheduled_arrival,
           s.seat_number, s.seat_class,
           a1.city AS origin_city, a1.airport_code AS origin_code, a1.name AS origin_name,
           a2.city AS dest_city, a2.airport_code AS dest_code, a2.name AS dest_name,
           p.first_name, p.last_name,
           b.booking_date
    FROM boarding_passes bp
    JOIN booking_items bi ON bp.booking_item_id = bi.item_id
    JOIN flights f ON bp.flight_id = f.flight_id
    JOIN routes r ON f.route_id = r.route_id
    JOIN airport a1 ON r.origin_airport_id = a1.airport_id
    JOIN airport a2 ON r.destination_airport_id = a2.airport_id
    JOIN seats s ON bp.seat_id = s.seat_id
    JOIN passengers p ON bp.passenger_id = p.passenger_id
    JOIN bookings b ON bi.booking_id = b.booking_id
    WHERE bi.booking_id = $booking_id AND b.account_id = " . $_SESSION['account_id']
);

// If boarding pass doesn't exist, try to create it from booking data
if (!$bp_query || $bp_query->num_rows === 0) {
    // Get booking details with seat reservation (use current flight from booking_items)
    $booking_data = $conn->query("
        SELECT bi.item_id, bi.flight_id, bi.passenger_id,
               sr.seat_id, f.flight_no, f.scheduled_departure, f.scheduled_arrival
        FROM bookings b
        JOIN booking_items bi ON b.booking_id = bi.booking_id
        JOIN flights f ON bi.flight_id = f.flight_id
        LEFT JOIN seat_reservations sr ON bi.item_id = sr.item_id AND sr.flight_id = bi.flight_id
        WHERE b.booking_id = $booking_id 
        AND b.account_id = " . $_SESSION['account_id'] . "
        AND b.booking_status = 'Confirmed'
        LIMIT 1
    ")->fetch_assoc();
    
    // If booking exists with seat reservation, create boarding pass
    if ($booking_data && $booking_data['seat_id']) {
        $conn->query("
            INSERT INTO boarding_passes (booking_item_id, flight_id, seat_id, passenger_id)
            VALUES (" . $booking_data['item_id'] . ", " . $booking_data['flight_id'] . ", 
                    " . $booking_data['seat_id'] . ", " . $booking_data['passenger_id'] . ")
        ");
        
        // Retry query after creating boarding pass
        $bp_query = $conn->query("
            SELECT bp.boarding_pass_id, bp.boarding_pass_id AS pass_id,
                   f.flight_no, f.scheduled_departure, f.scheduled_arrival,
                   s.seat_number, s.seat_class,
                   a1.city AS origin_city, a1.airport_code AS origin_code, a1.name AS origin_name,
                   a2.city AS dest_city, a2.airport_code AS dest_code, a2.name AS dest_name,
                   p.first_name, p.last_name,
                   b.booking_date
            FROM boarding_passes bp
            JOIN booking_items bi ON bp.booking_item_id = bi.item_id
            JOIN flights f ON bp.flight_id = f.flight_id
            JOIN routes r ON f.route_id = r.route_id
            JOIN airport a1 ON r.origin_airport_id = a1.airport_id
            JOIN airport a2 ON r.destination_airport_id = a2.airport_id
            JOIN seats s ON bp.seat_id = s.seat_id
            JOIN passengers p ON bp.passenger_id = p.passenger_id
            JOIN bookings b ON bi.booking_id = b.booking_id
            WHERE bi.booking_id = $booking_id AND b.account_id = " . $_SESSION['account_id']
        );
    }
}

if (!$bp_query || $bp_query->num_rows === 0) {
    header("Location: home.php");
    exit();
}

$bp = $bp_query->fetch_assoc();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Boarding Pass | Airline Reservation System</title>
    <link rel="stylesheet" href="css/home.css">
    <style>
        body {
            background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
            min-height: 100vh;
        }
        
        .main-content {
            margin-left: 250px;
            padding: 40px;
        }
        .boarding-pass-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 0;
        }
        
        .back-link {
            display: block;
            margin-bottom: 20px;
            color: white;
            text-decoration: none;
            font-weight: 500;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
        
        .boarding-pass {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            overflow: hidden;
            position: relative;
        }
        
        .pass-header {
            background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
            color: white;
            padding: 25px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .airline-logo {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .airline-logo img {
            height: 35px;
            width: auto;
            object-fit: contain;
        }
        
        .airline-name {
            font-size: 20px;
            font-weight: 700;
            line-height: 1.2;
        }
        
        .pass-id {
            font-size: 12px;
            opacity: 0.9;
            margin-top: 4px;
        }
        
        .pass-body {
            padding: 30px;
        }
        
        .pass-main {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }
        
        @media (max-width: 968px) {
            .pass-main {
                grid-template-columns: 1fr;
            }
        }
        
        .route-section {
            border-right: 2px dashed #e0e0e0;
            padding-right: 30px;
        }
        
        @media (max-width: 968px) {
            .route-section {
                border-right: none;
                border-bottom: 2px dashed #e0e0e0;
                padding-right: 0;
                padding-bottom: 30px;
                margin-bottom: 30px;
            }
        }
        
        .route-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .airport {
            text-align: center;
        }
        
        .airport-code {
            font-size: 48px;
            font-weight: 700;
            color: #2c5364;
            margin-bottom: 5px;
        }
        
        .airport-city {
            font-size: 16px;
            color: #666;
            font-weight: 500;
        }
        
        .airport-name {
            font-size: 12px;
            color: #999;
            margin-top: 3px;
        }
        
        .route-arrow {
            font-size: 32px;
            color: #ccc;
            margin: 0 20px;
        }
        
        .flight-details {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-top: 20px;
        }
        
        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .detail-label {
            font-size: 12px;
            color: #999;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .detail-value {
            font-size: 18px;
            font-weight: 600;
            color: #333;
        }
        
        .passenger-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
        }
        
        .passenger-name {
            font-size: 24px;
            font-weight: 700;
            color: #2c5364;
            margin-bottom: 15px;
        }
        
        .seat-info {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-top: 15px;
        }
        
        .seat-badge {
            background: #2c5364;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 20px;
            font-weight: 700;
        }
        
        .seat-class {
            color: #666;
            font-size: 14px;
        }
        
        .pass-footer {
            background: #f8f9fa;
            padding: 20px 30px;
            border-top: 2px dashed #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .barcode {
            font-family: 'Courier New', monospace;
            font-size: 24px;
            letter-spacing: 3px;
            color: #333;
        }
        
        .print-btn {
            background: #203a43;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            margin-top: 20px;
            transition: all 0.3s ease;
        }
        
        .print-btn:hover {
            background: #2c5364;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(44,83,100,0.3);
        }
        
        .action-buttons {
            text-align: center;
            margin-top: 30px;
        }
        
        .action-buttons a {
            display: inline-block;
            margin: 0 10px;
            padding: 12px 25px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-home {
            background: #e0e0e0;
            color: #333;
        }
        
        .btn-home:hover {
            background: #d0d0d0;
        }
        
        @media print {
            .action-buttons, .back-link {
                display: none;
            }
            
            .boarding-pass {
                box-shadow: none;
            }
            
            .main-content {
                margin-left: 0;
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<?php include 'partials/header.php'; ?>
<?php include 'partials/sidebar.php'; ?>

<main class="main-content fade-in">
<div class="boarding-pass-container">
    <a href="home.php" class="back-link" style="color: #2c5364; text-decoration: none; margin-bottom: 20px; display: inline-block;">← Back to Home</a>
    
    <div class="boarding-pass">
        <div class="pass-header">
            <div class="airline-logo">
                <img src="assets/logo.png" alt="Logo">
                <div>
                    <div class="airline-name">Airline Reservation</div>
                    <div class="pass-id">Pass ID: <?= str_pad($bp['pass_id'], 8, '0', STR_PAD_LEFT) ?></div>
                </div>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 14px; opacity: 0.9;">Boarding Pass</div>
                <div style="font-size: 12px; opacity: 0.8; margin-top: 5px;"><?= date("d M Y", strtotime($bp['booking_date'])) ?></div>
            </div>
        </div>
        
        <div class="pass-body">
            <div class="pass-main">
                <div class="route-section">
                    <div class="route-info">
                        <div class="airport">
                            <div class="airport-code"><?= htmlspecialchars($bp['origin_code']) ?></div>
                            <div class="airport-city"><?= htmlspecialchars($bp['origin_city']) ?></div>
                            <div class="airport-name"><?= htmlspecialchars($bp['origin_name']) ?></div>
                        </div>
                        <div class="route-arrow">→</div>
                        <div class="airport">
                            <div class="airport-code"><?= htmlspecialchars($bp['dest_code']) ?></div>
                            <div class="airport-city"><?= htmlspecialchars($bp['dest_city']) ?></div>
                            <div class="airport-name"><?= htmlspecialchars($bp['dest_name']) ?></div>
                        </div>
                    </div>
                    
                    <div class="flight-details">
                        <div class="detail-item">
                            <span class="detail-label">Flight Number</span>
                            <span class="detail-value"><?= htmlspecialchars($bp['flight_no']) ?></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Date</span>
                            <span class="detail-value"><?= date("d M Y", strtotime($bp['scheduled_departure'])) ?></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Departure</span>
                            <span class="detail-value"><?= date("H:i", strtotime($bp['scheduled_departure'])) ?></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Arrival</span>
                            <span class="detail-value"><?= date("H:i", strtotime($bp['scheduled_arrival'])) ?></span>
                        </div>
                    </div>
                </div>
                
                <div class="passenger-section">
                    <div class="passenger-name">
                        <?= htmlspecialchars($bp['first_name'] . ' ' . $bp['last_name']) ?>
                    </div>
                    <div class="seat-info">
                        <div class="seat-badge"><?= htmlspecialchars($bp['seat_number']) ?></div>
                        <div>
                            <div style="font-weight: 600; color: #333;">Seat</div>
                            <div class="seat-class"><?= htmlspecialchars($bp['seat_class']) ?> Class</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="pass-footer">
            <div>
                <div style="font-size: 12px; color: #999; margin-bottom: 5px;">Booking Reference</div>
                <div style="font-weight: 600; color: #333;"><?= str_pad($booking_id, 8, '0', STR_PAD_LEFT) ?></div>
            </div>
            <div class="barcode"><?= str_repeat('|', 40) ?></div>
        </div>
    </div>
    
    <div class="action-buttons">
        <button onclick="window.print()" class="print-btn">Print Boarding Pass</button>
        <br><br>
        <a href="home.php" class="btn-home">Back to Home</a>
    </div>
</div>
</main>

</body>
</html>
