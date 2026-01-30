<?php
$conn = new mysqli("localhost", "root", "", "airline_system");

if ($conn->connect_error) {
    die("Database Connection Failed: " . $conn->connect_error);
}
?>
