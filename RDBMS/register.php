<?php
include 'db_connect.php';

$success = "";
$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'];
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);

    $sql = "INSERT INTO Accounts (email, password) VALUES ('$email', '$password')";

    if ($conn->query($sql)) {
        $success = "Registration successful. Redirecting to login...";
        header("refresh:2;url=login.php");
    } else {
        $error = "Email already exists.";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>

<div class="auth-container">
    <div class="brand">
        <h2>Create Account</h2>
        <span>Airline Reservation System</span>
    </div>

    <?php if ($success) echo "<p style='color:green;text-align:center;'>$success</p>"; ?>
    <?php if ($error) echo "<p style='color:red;text-align:center;'>$error</p>"; ?>

    <form method="POST">
        <input type="email" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Register</button>
    </form>

    <div class="alt-link">
        Already registered? <a href="login.php">Login</a>
    </div>
</div>

</body>
</html>
