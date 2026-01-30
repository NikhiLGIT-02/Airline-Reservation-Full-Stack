<?php
session_start();
include 'db_connect.php';

if (!isset($_SESSION['account_id']) || $_SESSION['role'] !== 'user') {
    header("Location: index.php");
    exit();
}

$user_id = $_SESSION['account_id'];
$flight_id = isset($_GET['flight_id']) ? intval($_GET['flight_id']) : 0;

if (!$flight_id) {
    header("Location: home.php");
    exit();
}

// Verify flight exists
$flight_check = $conn->query("SELECT flight_id FROM flights WHERE flight_id = $flight_id");
if (!$flight_check || $flight_check->num_rows === 0) {
    header("Location: home.php");
    exit();
}

// Get or create passenger record for the user
$user_info = $conn->query("SELECT full_name, email FROM Accounts WHERE account_id = $user_id")->fetch_assoc();
if ($user_info && isset($user_info['full_name']) && !empty($user_info['full_name'])) {
    $name_parts = explode(' ', $user_info['full_name'], 2);
    $first_name = $name_parts[0];
    $last_name = isset($name_parts[1]) ? $name_parts[1] : '';
} else {
    // Fallback to email username
    $email_parts = explode('@', $user_info['email'] ?? 'user');
    $first_name = $email_parts[0];
    $last_name = 'User';
}

// Check if passenger already exists for this account
$passenger_check = $conn->query("
    SELECT passenger_id FROM passengers 
    WHERE first_name = '" . $conn->real_escape_string($first_name) . "' 
    AND last_name = '" . $conn->real_escape_string($last_name) . "'
    LIMIT 1
");

if ($passenger_check && $passenger_check->num_rows > 0) {
    $passenger_id = $passenger_check->fetch_assoc()['passenger_id'];
} else {
    // Create new passenger record
    $conn->query("
        INSERT INTO passengers (first_name, last_name, gender, age)
        VALUES (
            '" . $conn->real_escape_string($first_name) . "',
            '" . $conn->real_escape_string($last_name) . "',
            'Other',
            25
        )
    ");
    $passenger_id = $conn->insert_id;
}

// Create booking
$conn->query("INSERT INTO bookings (account_id, booking_status)
              VALUES ($user_id, 'Confirmed')");
$booking_id = $conn->insert_id;

// Create booking item
$conn->query("INSERT INTO booking_items (booking_id, flight_id, passenger_id)
              VALUES ($booking_id, $flight_id, $passenger_id)");

header("Location: select_seat.php?flight_id=$flight_id&booking_id=$booking_id");
exit();
