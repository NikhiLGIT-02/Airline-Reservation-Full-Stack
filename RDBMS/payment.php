<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id'])) {
    header("Location: index.php");
    exit();
}

$booking_id = isset($_GET['booking_id']) ? intval($_GET['booking_id']) : 0;
$flight_id = isset($_GET['flight_id']) ? intval($_GET['flight_id']) : 0;
$seat_id = isset($_GET['seat_id']) ? intval($_GET['seat_id']) : 0;

if (!$booking_id || !$flight_id || !$seat_id) {
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

// Get booking details
$booking_info = $conn->query("
    SELECT f.flight_no, f.scheduled_departure, f.scheduled_arrival,
           a1.city as origin_city, a1.airport_code as origin_code,
           a2.city as dest_city, a2.airport_code as dest_code,
           s.seat_number, s.seat_class,
           r.distance_km
    FROM bookings b
    JOIN booking_items bi ON b.booking_id = bi.booking_id
    JOIN flights f ON bi.flight_id = f.flight_id
    JOIN routes r ON f.route_id = r.route_id
    JOIN airport a1 ON r.origin_airport_id = a1.airport_id
    JOIN airport a2 ON r.destination_airport_id = a2.airport_id
    JOIN seats s ON s.seat_id = $seat_id
    WHERE b.booking_id = $booking_id AND f.flight_id = $flight_id
")->fetch_assoc();

if (!$booking_info) {
    header("Location: home.php");
    exit();
}

// Calculate price
$base_price = 5000;
$price_per_km = 15;
$class_multiplier = ['Economy' => 1, 'Business' => 1.5, 'First' => 2.5];
$multiplier = isset($class_multiplier[$booking_info['seat_class']]) ? $class_multiplier[$booking_info['seat_class']] : 1;
$total_amount = ($base_price + ($booking_info['distance_km'] * $price_per_km)) * $multiplier;

$departure = new DateTime($booking_info['scheduled_departure']);
$arrival = new DateTime($booking_info['scheduled_arrival']);

// Process payment
$payment_success = false;
$payment_error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $payment_method = $_POST['payment_method'] ?? '';
    $card_number = $_POST['card_number'] ?? '';
    $card_expiry = $_POST['card_expiry'] ?? '';
    $card_cvv = $_POST['card_cvv'] ?? '';
    $card_name = $_POST['card_name'] ?? '';
    $upi_id = $_POST['upi_id'] ?? '';
    $bank = $_POST['bank'] ?? '';
    
    // Validation
    $errors = [];
    
    if (empty($payment_method)) {
        $errors[] = "Please select a payment method";
    }
    
    if ($payment_method === 'card') {
        if (empty($card_number) || !preg_match('/^\d{16}$/', str_replace(' ', '', $card_number))) {
            $errors[] = "Invalid card number (16 digits required)";
        }
        if (empty($card_expiry) || !preg_match('/^\d{2}\/\d{2}$/', $card_expiry)) {
            $errors[] = "Invalid expiry date (MM/YY format required)";
        }
        if (empty($card_cvv) || !preg_match('/^\d{3,4}$/', $card_cvv)) {
            $errors[] = "Invalid CVV (3-4 digits required)";
        }
        if (empty($card_name)) {
            $errors[] = "Card holder name is required";
        }
    } elseif ($payment_method === 'upi') {
        if (empty($upi_id) || !preg_match('/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$/', $upi_id)) {
            $errors[] = "Invalid UPI ID format (e.g., name@upi)";
        }
    } elseif ($payment_method === 'netbanking') {
        if (empty($bank)) {
            $errors[] = "Please select a bank";
        }
    }
    
    if (empty($errors)) {
        // Process payment (dummy - in real app, integrate payment gateway)
        $payment_method_db = ucfirst($payment_method === 'netbanking' ? 'NetBanking' : ($payment_method === 'upi' ? 'UPI' : 'Card'));
        
        // Insert payment
        $conn->query("
            INSERT INTO ticket_payments (booking_id, amount, payment_method)
            VALUES ($booking_id, $total_amount, '$payment_method_db')
        ");
        
        // Create boarding pass after successful payment
        // Get booking item and passenger info
        $booking_item_info = $conn->query("
            SELECT bi.item_id, bi.passenger_id
            FROM booking_items bi
            WHERE bi.booking_id = $booking_id AND bi.flight_id = $flight_id
            LIMIT 1
        ")->fetch_assoc();
        
        if ($booking_item_info) {
            $item_id = $booking_item_info['item_id'];
            $passenger_id = $booking_item_info['passenger_id'];
            
            // Check if boarding pass already exists
            $bp_check = $conn->query("
                SELECT boarding_pass_id FROM boarding_passes
                WHERE booking_item_id = $item_id AND flight_id = $flight_id
                LIMIT 1
            ");
            
            // Create boarding pass if it doesn't exist
            if (!$bp_check || $bp_check->num_rows === 0) {
                $conn->query("
                    INSERT INTO boarding_passes (booking_item_id, flight_id, seat_id, passenger_id)
                    VALUES ($item_id, $flight_id, $seat_id, $passenger_id)
                ");
            }
        }
        
        $payment_success = true;
    } else {
        $payment_error = implode('<br>', $errors);
    }
}

include 'partials/header.php';
include 'partials/sidebar.php';
?>

<link rel="stylesheet" href="css/home.css">
<link rel="stylesheet" href="css/payment.css">

<main class="main-content fade-in">

<div class="payment-wrapper">

    <!-- SUMMARY -->
    <div class="summary-card">
        <div class="card-header">
            <h3>📋 Booking Summary</h3>
        </div>
        
        <div class="summary-content">
            <div class="summary-row">
                <span class="summary-label">Flight</span>
                <strong class="summary-value"><?= htmlspecialchars($booking_info['flight_no']) ?></strong>
            </div>
            <div class="summary-row">
                <span class="summary-label">Route</span>
                <strong class="summary-value"><?= htmlspecialchars($booking_info['origin_code']) ?> → <?= htmlspecialchars($booking_info['dest_code']) ?></strong>
            </div>
            <div class="summary-row">
                <span class="summary-label">Date</span>
                <strong class="summary-value"><?= $departure->format('M d, Y') ?></strong>
            </div>
            <div class="summary-row">
                <span class="summary-label">Departure</span>
                <strong class="summary-value"><?= $departure->format('h:i A') ?></strong>
            </div>
            <div class="summary-row">
                <span class="summary-label">Arrival</span>
                <strong class="summary-value"><?= $arrival->format('h:i A') ?></strong>
            </div>
            <div class="summary-row">
                <span class="summary-label">Seat</span>
                <strong class="summary-value"><?= htmlspecialchars($booking_info['seat_number']) ?> (<?= htmlspecialchars($booking_info['seat_class']) ?>)</strong>
            </div>
            <div class="summary-row total">
                <span class="summary-label">Total Amount</span>
                <strong class="summary-value">₹<?= number_format($total_amount, 2) ?></strong>
            </div>
        </div>
    </div>

    <!-- PAYMENT -->
    <div class="payment-card">
        <div class="card-header">
            <h3>💳 Payment</h3>
            <p>Complete your booking by making the payment</p>
        </div>

        <?php if ($payment_success): ?>
            <div class="payment-success">
                <div class="success-icon">✅</div>
                <h3>Payment Successful!</h3>
                <p>Your booking has been confirmed. Redirecting to your bookings...</p>
                <script>
                    setTimeout(function() {
                        window.location.href = 'home.php';
                    }, 2000);
                </script>
            </div>
        <?php else: ?>
            <?php if ($payment_error): ?>
                <div class="alert alert-error">
                    <span>⚠️</span>
                    <span><?= $payment_error ?></span>
                </div>
            <?php endif; ?>

            <form method="POST" id="payment-form" onsubmit="return validatePayment()">
                <div class="form-group">
                    <label>Payment Method <span class="required">*</span></label>
                    <select id="payment_method" name="payment_method" required onchange="switchPaymentMethod()">
                        <option value="">Select Payment Method</option>
                        <option value="card">💳 Debit / Credit Card</option>
                        <option value="upi">📱 UPI</option>
                        <option value="netbanking">🏦 Net Banking</option>
                    </select>
                </div>

                <!-- CARD FIELDS -->
                <div id="card-fields" class="payment-fields hidden">
                    <div class="form-group">
                        <label>Card Number <span class="required">*</span></label>
                        <input type="text" 
                               id="card_number" 
                               name="card_number" 
                               placeholder="1234 5678 9012 3456"
                               maxlength="19"
                               oninput="formatCardNumber(this)">
                        <span class="field-error" id="card_number_error"></span>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Expiry (MM/YY) <span class="required">*</span></label>
                            <input type="text" 
                                   id="card_expiry" 
                                   name="card_expiry" 
                                   placeholder="12/25"
                                   maxlength="5"
                                   oninput="formatExpiry(this)">
                            <span class="field-error" id="card_expiry_error"></span>
                        </div>
                        <div class="form-group">
                            <label>CVV <span class="required">*</span></label>
                            <input type="password" 
                                   id="card_cvv" 
                                   name="card_cvv" 
                                   placeholder="123"
                                   maxlength="4">
                            <span class="field-error" id="card_cvv_error"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Card Holder Name <span class="required">*</span></label>
                        <input type="text" 
                               id="card_name" 
                               name="card_name" 
                               placeholder="John Doe">
                        <span class="field-error" id="card_name_error"></span>
                    </div>
                </div>

                <!-- UPI FIELDS -->
                <div id="upi-fields" class="payment-fields hidden">
                    <div class="form-group">
                        <label>UPI ID <span class="required">*</span></label>
                        <input type="text" 
                               id="upi_id" 
                               name="upi_id" 
                               placeholder="yourname@upi">
                        <span class="field-error" id="upi_id_error"></span>
                        <small class="field-hint">Enter your UPI ID (e.g., name@paytm, name@phonepe)</small>
                    </div>
                </div>

                <!-- NET BANKING FIELDS -->
                <div id="netbanking-fields" class="payment-fields hidden">
                    <div class="form-group">
                        <label>Select Bank <span class="required">*</span></label>
                        <select id="bank" name="bank">
                            <option value="">Choose your bank</option>
                            <option value="SBI">State Bank of India (SBI)</option>
                            <option value="HDFC">HDFC Bank</option>
                            <option value="ICICI">ICICI Bank</option>
                            <option value="Axis">Axis Bank</option>
                            <option value="Kotak">Kotak Mahindra Bank</option>
                            <option value="PNB">Punjab National Bank (PNB)</option>
                        </select>
                        <span class="field-error" id="bank_error"></span>
                    </div>
                </div>

                <button type="submit" class="pay-btn">
                    <span>Pay ₹<?= number_format($total_amount, 2) ?></span>
                    <span class="btn-icon">→</span>
                </button>
            </form>
        <?php endif; ?>
    </div>

</div>

</main>

<script>
function switchPaymentMethod() {
    // Hide all fields
    document.getElementById('card-fields').classList.add('hidden');
    document.getElementById('upi-fields').classList.add('hidden');
    document.getElementById('netbanking-fields').classList.add('hidden');
    
    // Clear all errors
    document.querySelectorAll('.field-error').forEach(el => el.textContent = '');
    
    // Show selected method fields
    const method = document.getElementById('payment_method').value;
    if (method) {
        const fieldId = method === 'netbanking' ? 'netbanking-fields' : method + '-fields';
        document.getElementById(fieldId).classList.remove('hidden');
    }
}

function formatCardNumber(input) {
    let value = input.value.replace(/\s/g, '');
    let formatted = value.match(/.{1,4}/g)?.join(' ') || value;
    input.value = formatted;
}

function formatExpiry(input) {
    let value = input.value.replace(/\D/g, '');
    if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4);
    }
    input.value = value;
}

function validatePayment() {
    const method = document.getElementById('payment_method').value;
    let isValid = true;
    
    // Clear previous errors
    document.querySelectorAll('.field-error').forEach(el => el.textContent = '');
    
    if (!method) {
        alert('Please select a payment method');
        return false;
    }
    
    if (method === 'card') {
        const cardNumber = document.getElementById('card_number').value.replace(/\s/g, '');
        const cardExpiry = document.getElementById('card_expiry').value;
        const cardCvv = document.getElementById('card_cvv').value;
        const cardName = document.getElementById('card_name').value.trim();
        
        if (!/^\d{16}$/.test(cardNumber)) {
            document.getElementById('card_number_error').textContent = 'Invalid card number (16 digits required)';
            isValid = false;
        }
        if (!/^\d{2}\/\d{2}$/.test(cardExpiry)) {
            document.getElementById('card_expiry_error').textContent = 'Invalid format (MM/YY required)';
            isValid = false;
        }
        if (!/^\d{3,4}$/.test(cardCvv)) {
            document.getElementById('card_cvv_error').textContent = 'Invalid CVV (3-4 digits required)';
            isValid = false;
        }
        if (!cardName) {
            document.getElementById('card_name_error').textContent = 'Card holder name is required';
            isValid = false;
        }
    } else if (method === 'upi') {
        const upiId = document.getElementById('upi_id').value.trim();
        if (!/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+$/.test(upiId)) {
            document.getElementById('upi_id_error').textContent = 'Invalid UPI ID format';
            isValid = false;
        }
    } else if (method === 'netbanking') {
        const bank = document.getElementById('bank').value;
        if (!bank) {
            document.getElementById('bank_error').textContent = 'Please select a bank';
            isValid = false;
        }
    }
    
    return isValid;
}
</script>
