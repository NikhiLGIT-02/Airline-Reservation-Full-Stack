<?php if (!isset($_SESSION)) session_start(); ?>
<header class="topbar">
    <div class="brand">
        <?php if (file_exists('assets/logo.png')): ?>
            <img src="assets/logo.png" alt="Airline Logo" class="logo-img">
        <?php endif; ?>
        <span class="brand-text">✈ Airline Reservation System</span>
    </div>
    <div class="top-actions">
        <span class="user">
            <?php 
            if (isset($_SESSION['full_name'])) {
                echo "Hello, " . htmlspecialchars($_SESSION['full_name']);
            } elseif (isset($_SESSION['email'])) {
                echo "Hello, " . htmlspecialchars(explode('@', $_SESSION['email'])[0]);
            } else {
                echo "Welcome!";
            }
            ?>
        </span>
        <a href="logout.php" class="logout-btn">Logout</a>
    </div>
</header>
