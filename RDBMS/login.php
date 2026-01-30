<?php
session_start();
include 'db_connect.php';

$success = "";
$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'];
    $password = $_POST['password'];

    $result = $conn->query("SELECT * FROM Accounts WHERE email='$email'");

    if ($result->num_rows == 1) {
        $user = $result->fetch_assoc();

        if (password_verify($password, $user['password'])) {
            $_SESSION['account_id'] = $user['account_id'];
            $_SESSION['email'] = $user['email'];

            $success = "Login successful. Redirecting...";
            header("refresh:2;url=home.php");
        } else {
            $error = "Invalid password.";
        }
    } else {
        $error = "Account not found.";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>

<div class="auth-container">
    <div class="brand">
        <h2>Login</h2>
        <span>Airline Reservation System</span>
    </div>

    <?php if ($success) echo "<p style='color:green;text-align:center;'>$success</p>"; ?>
    <?php if ($error) echo "<p style='color:red;text-align:center;'>$error</p>"; ?>

    <form method="POST">
        <input type="email" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Login</button>
    </form>
</div>

</body>
</html>
