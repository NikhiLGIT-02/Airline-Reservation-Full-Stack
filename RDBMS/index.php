<?php
session_start();
include 'db_connect.php';

$mode = isset($_GET['mode']) ? $_GET['mode'] : 'register';
$success = "";
$error = "";

/* ================= REGISTER (USER ONLY) ================= */
if ($mode === 'register' && $_SERVER["REQUEST_METHOD"] === "POST") {

    $full_name = trim($_POST['full_name']);
    $email = trim($_POST['email']);
    $password = $_POST['password'];

    // REGEX VALIDATIONS
    if (!preg_match("/^[A-Za-z ]{3,100}$/", $full_name)) {
        $error = "Name must contain only letters and spaces (min 3 characters).";
    }
    else if (!preg_match("/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/", $email)) {
        $error = "Invalid email format.";
    }
    else if (!preg_match("/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$/", $password)) {
        $error = "Password must be at least 6 characters and include uppercase, lowercase, and a number.";
    }
    else {
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);

        // ROLE FIXED AS USER
        $sql = "INSERT INTO Accounts (full_name, email, password, role)
                VALUES ('$full_name', '$email', '$hashed_password', 'user')";

        if ($conn->query($sql)) {
            $success = "Registration successful. Please login.";
            header("refresh:2;url=index.php?mode=login");
        } else {
            $error = "Email already exists.";
        }
    }
}

/* ================= LOGIN (ADMIN + USER) ================= */
if ($mode === 'login' && $_SERVER["REQUEST_METHOD"] === "POST") {

    $email = trim($_POST['email']);
    $password = $_POST['password'];

    if (!preg_match("/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/", $email)) {
        $error = "Invalid email format.";
    } else {
        $result = $conn->query("SELECT * FROM Accounts WHERE email='$email'");

        if ($result->num_rows === 1) {
            $user = $result->fetch_assoc();

            if (password_verify($password, $user['password'])) {

                // SESSION DATA
                $_SESSION['account_id'] = $user['account_id'];
                $_SESSION['email'] = $user['email'];
                $_SESSION['full_name'] = $user['full_name'];
                $_SESSION['role'] = $user['role'];

                $success = "Login successful. Redirecting...";

                // ROLE-BASED REDIRECT
                if ($user['role'] === 'admin') {
                    header("refresh:2;url=admin/dashboard.php");
                } else {
                    header("refresh:2;url=home.php");
                }

            } else {
                $error = "Invalid password.";
            }
        } else {
            $error = "Account not found.";
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Airline Reservation and Operation System</title>
    <link rel="stylesheet" href="css/auth.css">
</head>
<body>

<div class="auth-container">
    <div class="brand">
        <img src="assets/logo.png" alt="Logo">
        <h2>Airline Reservation</h2>
        <span>and Operation System</span>
    </div>

    <?php if ($success) echo "<p style='color:green;text-align:center;'>$success</p>"; ?>
    <?php if ($error) echo "<p style='color:red;text-align:center;'>$error</p>"; ?>

    <?php if ($mode === 'register'): ?>
        <!-- REGISTER FORM -->
        <form method="POST">
            <input type="text"
                   name="full_name"
                   placeholder="Full Name"
                   pattern="[A-Za-z ]{3,100}"
                   title="Only letters and spaces, minimum 3 characters"
                   required>

            <input type="email"
                   name="email"
                   placeholder="Email address"
                   pattern="[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"
                   required>

            <input type="password"
                   name="password"
                   placeholder="Password"
                   pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{6,}"
                   title="At least 6 characters, include uppercase, lowercase, and number"
                   required>

            <button type="submit">Register</button>
        </form>

        <div class="alt-link">
            Already have an account?
            <a href="index.php?mode=login">Login</a>
        </div>

    <?php else: ?>
        <!-- LOGIN FORM -->
        <form method="POST">
            <input type="email"
                   name="email"
                   placeholder="Email address"
                   required>

            <input type="password"
                   name="password"
                   placeholder="Password"
                   required>

            <button type="submit">Login</button>
        </form>

        <div class="alt-link">
            New user?
            <a href="index.php?mode=register">Create an account</a>
        </div>
    <?php endif; ?>

</div>

</body>
</html>
