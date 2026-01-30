<?php
// Handle delete action
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
?>

