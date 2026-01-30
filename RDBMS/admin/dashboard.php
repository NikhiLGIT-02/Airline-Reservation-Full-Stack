<?php
session_start();
include '../db_connect.php';

if (!isset($_SESSION['account_id']) || $_SESSION['role'] !== 'admin') {
    header("Location: ../index.php");
    exit();
}

// Define all tables with their display names and primary keys
$tables = [
    'accounts' => ['name' => 'Accounts', 'pk' => 'account_id'],
    'aircraft' => ['name' => 'Aircraft', 'pk' => 'aircraft_id'],
    'aircraft_types' => ['name' => 'Aircraft Types', 'pk' => 'aircraft_type_id'],
    'airport' => ['name' => 'Airports', 'pk' => 'airport_id'],
    'bookings' => ['name' => 'Bookings', 'pk' => 'booking_id'],
    'booking_items' => ['name' => 'Booking Items', 'pk' => 'item_id'],
    'boarding_passes' => ['name' => 'Boarding Passes', 'pk' => 'boarding_pass_id'],
    'cancellations' => ['name' => 'Cancellations', 'pk' => 'cancellation_id'],
    'crew' => ['name' => 'Crew', 'pk' => 'crew_id'],
    'crew_assignments' => ['name' => 'Crew Assignments', 'pk' => 'assignment_id'],
    'delays' => ['name' => 'Delays', 'pk' => 'delay_id'],
    'flights' => ['name' => 'Flights', 'pk' => 'flight_id'],
    'passengers' => ['name' => 'Passengers', 'pk' => 'passenger_id'],
    'routes' => ['name' => 'Routes', 'pk' => 'route_id'],
    'seats' => ['name' => 'Seats', 'pk' => 'seat_id'],
    'seat_reservations' => ['name' => 'Seat Reservations', 'pk' => 'seat_reservation_id'],
    'ticket_payments' => ['name' => 'Ticket Payments', 'pk' => 'payment_id']
];

$table = isset($_GET['table']) ? $_GET['table'] : 'accounts';
$action = isset($_GET['action']) ? $_GET['action'] : 'list';
$id = isset($_GET['id']) ? intval($_GET['id']) : 0;

$success = isset($_GET['success']) ? $_GET['success'] : '';
$error = isset($_GET['error']) ? $_GET['error'] : '';

// Validate table name
if (!isset($tables[$table])) {
    $table = 'accounts';
}

$pk_column = $tables[$table]['pk'];

// Handle delete action (must be after $pk_column is defined)
if ($action === 'delete' && $id > 0) {
    // Check if record exists
    $result = $conn->query("SELECT * FROM `$table` WHERE `$pk_column` = $id");
    if ($result && $result->num_rows > 0) {
        // Delete the record
        if ($conn->query("DELETE FROM `$table` WHERE `$pk_column` = $id")) {
            header("Location: ?table=$table&action=list&success=" . urlencode("Record deleted successfully"));
        } else {
            header("Location: ?table=$table&action=list&error=" . urlencode("Error deleting record: " . $conn->error));
        }
    } else {
        header("Location: ?table=$table&action=list&error=" . urlencode("Record not found"));
    }
    exit();
}

// Get table structure for form generation
function getTableColumns($conn, $table) {
    $result = $conn->query("DESCRIBE `$table`");
    $columns = [];
    while ($row = $result->fetch_assoc()) {
        $columns[] = $row;
    }
    return $columns;
}

// Get foreign key relationships for dropdowns
function getForeignKeyOptions($conn, $table, $column) {
    // Extract table name from column (e.g., aircraft_id -> aircraft)
    $ref_table = str_replace('_id', '', $column);
    if ($ref_table === 'aircraft_type') $ref_table = 'aircraft_types';
    if ($ref_table === 'origin_airport' || $ref_table === 'destination_airport') $ref_table = 'airport';
    if ($ref_table === 'booking_item') $ref_table = 'booking_items';
    
    $result = $conn->query("SELECT * FROM `$ref_table` LIMIT 100");
    $options = [];
    while ($row = $result->fetch_assoc()) {
        $pk = $ref_table . '_id';
        $label = '';
        if (isset($row['name'])) $label = $row['name'];
        elseif (isset($row['email'])) $label = $row['email'];
        elseif (isset($row['model'])) $label = $row['model'];
        elseif (isset($row['flight_no'])) $label = $row['flight_no'];
        elseif (isset($row['first_name'])) $label = $row['first_name'] . ' ' . ($row['last_name'] ?? '');
        else $label = $row[$pk];
        $options[] = ['id' => $row[$pk], 'label' => $label];
    }
    return $options;
}

$columns = getTableColumns($conn, $table);

// Handle form submission (must be before any HTML output)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($action === 'create' || $action === 'edit')) {
    $is_edit = ($action === 'edit' && $id > 0);
    $fields = [];
    $values = [];
    
    foreach ($columns as $col) {
        $field = $col['Field'];
        
        // Skip auto-increment primary key on create
        if ($field === $pk_column && !$is_edit) {
            continue;
        }
        
        // Skip auto-generated fields
        if (strpos($col['Extra'], 'auto_increment') !== false && !$is_edit) {
            continue;
        }
        
        if (isset($_POST[$field])) {
            $value = $conn->real_escape_string($_POST[$field]);
            
            // Handle NULL values
            if ($value === '' && $col['Null'] === 'YES') {
                $fields[] = "`$field`";
                $values[] = "NULL";
            } else {
                $fields[] = "`$field`";
                $values[] = "'$value'";
            }
        }
    }
    
    if ($is_edit) {
        // Update
        $set_parts = [];
        for ($i = 0; $i < count($fields); $i++) {
            $set_parts[] = $fields[$i] . " = " . $values[$i];
        }
        $query = "UPDATE `$table` SET " . implode(", ", $set_parts) . " WHERE `$pk_column` = $id";
    } else {
        // Insert
        $query = "INSERT INTO `$table` (" . implode(", ", $fields) . ") VALUES (" . implode(", ", $values) . ")";
    }
    
    if ($conn->query($query)) {
        $msg = $is_edit ? "Record updated successfully" : "Record created successfully";
        header("Location: ?table=$table&action=list&success=" . urlencode($msg));
        exit();
    } else {
        $error_msg = "Error: " . $conn->error;
        header("Location: ?table=$table&action=" . ($is_edit ? "edit&id=$id" : "create") . "&error=" . urlencode($error_msg));
        exit();
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | <?php echo htmlspecialchars($tables[$table]['name']); ?></title>
    <link rel="stylesheet" href="../css/admin.css">
</head>
<body>
    <div class="admin-container">
        <!-- Sidebar -->
        <aside class="admin-sidebar">
            <div class="sidebar-header">
                <img src="../assets/logo.png" alt="Logo" class="sidebar-logo">
                <h2>Admin Panel</h2>
            </div>
            <nav class="sidebar-nav">
                <?php foreach ($tables as $tbl => $info): ?>
                    <a href="?table=<?php echo $tbl; ?>&action=list" 
                       class="nav-item <?php echo $table === $tbl ? 'active' : ''; ?>">
                        <span class="nav-icon">📊</span>
                        <span class="nav-text"><?php echo htmlspecialchars($info['name']); ?></span>
                    </a>
                <?php endforeach; ?>
            </nav>
            <div class="sidebar-footer">
                <a href="../home.php" class="back-link">← Back to Site</a>
                <a href="../logout.php" class="logout-link">Logout</a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="admin-main">
            <header class="admin-header">
                <h1><?php echo htmlspecialchars($tables[$table]['name']); ?> Management</h1>
                <div class="header-actions">
                    <a href="?table=<?php echo $table; ?>&action=create" class="btn btn-primary">
                        ➕ Add New
                    </a>
                </div>
            </header>

            <?php if ($success): ?>
                <div class="alert alert-success"><?php echo htmlspecialchars($success); ?></div>
            <?php endif; ?>
            <?php if ($error): ?>
                <div class="alert alert-error"><?php echo htmlspecialchars($error); ?></div>
            <?php endif; ?>

            <div class="admin-content">
                <?php if ($action === 'list'): ?>
                    <?php include 'includes/list.php'; ?>
                <?php elseif ($action === 'create'): ?>
                    <?php include 'includes/form.php'; ?>
                <?php elseif ($action === 'edit'): ?>
                    <?php include 'includes/form.php'; ?>
                <?php endif; ?>
            </div>
        </main>
    </div>

    <script src="../js/admin.js"></script>
</body>
</html>
