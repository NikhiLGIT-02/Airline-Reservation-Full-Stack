<?php
// List view with search and pagination
$search = isset($_GET['search']) ? $conn->real_escape_string($_GET['search']) : '';
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$per_page = 20;
$offset = ($page - 1) * $per_page;

// Build search query
$search_where = '';
if ($search) {
    $search_fields = [];
    foreach ($columns as $col) {
        if (in_array($col['Type'], ['varchar(100)', 'varchar(50)', 'varchar(255)', 'char(3)', 'varchar(10)', 'varchar(20)'])) {
            $search_fields[] = "`{$col['Field']}` LIKE '%$search%'";
        }
    }
    if (!empty($search_fields)) {
        $search_where = "WHERE " . implode(" OR ", $search_fields);
    }
}

// Get total count
$count_result = $conn->query("SELECT COUNT(*) as total FROM `$table` $search_where");
$total_rows = $count_result->fetch_assoc()['total'];
$total_pages = ceil($total_rows / $per_page);

// Get data
$query = "SELECT * FROM `$table` $search_where ORDER BY `$pk_column` DESC LIMIT $per_page OFFSET $offset";
$result = $conn->query($query);
?>

<div class="list-container">
    <!-- Search Bar -->
    <div class="search-bar">
        <form method="GET" class="search-form">
            <input type="hidden" name="table" value="<?php echo htmlspecialchars($table); ?>">
            <input type="hidden" name="action" value="list">
            <input type="text" name="search" placeholder="Search..." value="<?php echo htmlspecialchars($search); ?>" class="search-input">
            <button type="submit" class="btn btn-search">🔍 Search</button>
            <?php if ($search): ?>
                <a href="?table=<?php echo $table; ?>&action=list" class="btn btn-clear">Clear</a>
            <?php endif; ?>
        </form>
        <div class="results-info">
            Showing <?php echo $offset + 1; ?>-<?php echo min($offset + $per_page, $total_rows); ?> of <?php echo $total_rows; ?> records
        </div>
    </div>

    <!-- Data Table -->
    <div class="table-wrapper">
        <table class="data-table">
            <thead>
                <tr>
                    <?php foreach ($columns as $col): ?>
                        <th><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $col['Field']))); ?></th>
                    <?php endforeach; ?>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if ($result && $result->num_rows > 0): ?>
                    <?php while ($row = $result->fetch_assoc()): ?>
                        <tr>
                            <?php foreach ($columns as $col): ?>
                                <td>
                                    <?php 
                                    $value = $row[$col['Field']];
                                    if (strlen($value) > 50) {
                                        echo htmlspecialchars(substr($value, 0, 50)) . '...';
                                    } else {
                                        echo htmlspecialchars($value ?? 'NULL');
                                    }
                                    ?>
                                </td>
                            <?php endforeach; ?>
                            <td class="actions-cell">
                                <a href="?table=<?php echo $table; ?>&action=edit&id=<?php echo $row[$pk_column]; ?>" 
                                   class="btn-icon btn-edit" title="Edit">✏️</a>
                                <a href="?table=<?php echo $table; ?>&action=delete&id=<?php echo $row[$pk_column]; ?>" 
                                   class="btn-icon btn-delete" 
                                   onclick="return confirm('Are you sure you want to delete this record?');" 
                                   title="Delete">🗑️</a>
                            </td>
                        </tr>
                    <?php endwhile; ?>
                <?php else: ?>
                    <tr>
                        <td colspan="<?php echo count($columns) + 1; ?>" class="no-data">
                            No records found
                        </td>
                    </tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <?php if ($total_pages > 1): ?>
        <div class="pagination">
            <?php if ($page > 1): ?>
                <a href="?table=<?php echo $table; ?>&action=list&page=<?php echo $page - 1; ?>&search=<?php echo urlencode($search); ?>" class="page-link">← Previous</a>
            <?php endif; ?>
            
            <?php for ($i = max(1, $page - 2); $i <= min($total_pages, $page + 2); $i++): ?>
                <a href="?table=<?php echo $table; ?>&action=list&page=<?php echo $i; ?>&search=<?php echo urlencode($search); ?>" 
                   class="page-link <?php echo $i === $page ? 'active' : ''; ?>">
                    <?php echo $i; ?>
                </a>
            <?php endfor; ?>
            
            <?php if ($page < $total_pages): ?>
                <a href="?table=<?php echo $table; ?>&action=list&page=<?php echo $page + 1; ?>&search=<?php echo urlencode($search); ?>" class="page-link">Next →</a>
            <?php endif; ?>
        </div>
    <?php endif; ?>
</div>

