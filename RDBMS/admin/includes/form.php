<?php
// Form for Create/Edit
$is_edit = ($action === 'edit' && $id > 0);
$form_data = [];

if ($is_edit) {
    $result = $conn->query("SELECT * FROM `$table` WHERE `$pk_column` = $id");
    if ($result && $result->num_rows > 0) {
        $form_data = $result->fetch_assoc();
    } else {
        header("Location: ?table=$table&action=list&error=Record not found");
        exit();
    }
}
?>

<div class="form-container">
    <form method="POST" class="data-form">
        <?php foreach ($columns as $col): ?>
            <?php
            $field = $col['Field'];
            $value = $is_edit ? ($form_data[$field] ?? '') : '';
            $is_pk = ($field === $pk_column);
            $is_required = ($col['Null'] === 'NO' && strpos($col['Extra'], 'auto_increment') === false);
            $type = $col['Type'];
            ?>
            
            <?php if ($is_pk && $is_edit): ?>
                <!-- Primary Key (read-only in edit mode) -->
                <div class="form-group">
                    <label><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $field))); ?></label>
                    <input type="text" value="<?php echo htmlspecialchars($value); ?>" disabled class="form-input">
                    <input type="hidden" name="<?php echo $field; ?>" value="<?php echo htmlspecialchars($value); ?>">
                </div>
            <?php elseif (strpos($col['Extra'], 'auto_increment') !== false && !$is_edit): ?>
                <!-- Skip auto-increment fields on create -->
            <?php elseif (strpos($field, '_id') !== false && $field !== $pk_column): ?>
                <!-- Foreign Key - Dropdown -->
                <div class="form-group">
                    <label><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $field))); ?> <?php if ($is_required): ?><span class="required">*</span><?php endif; ?></label>
                    <select name="<?php echo $field; ?>" class="form-input" <?php if ($is_required): ?>required<?php endif; ?>>
                        <option value="">-- Select --</option>
                        <?php
                        $options = getForeignKeyOptions($conn, $table, $field);
                        foreach ($options as $opt):
                        ?>
                            <option value="<?php echo $opt['id']; ?>" <?php echo ($value == $opt['id']) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($opt['label']); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            <?php elseif (strpos($type, 'enum') !== false): ?>
                <!-- Enum - Dropdown -->
                <div class="form-group">
                    <label><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $field))); ?> <?php if ($is_required): ?><span class="required">*</span><?php endif; ?></label>
                    <select name="<?php echo $field; ?>" class="form-input" <?php if ($is_required): ?>required<?php endif; ?>>
                        <?php
                        preg_match("/enum\('(.+)'\)/", $type, $matches);
                        $enum_values = explode("','", $matches[1] ?? '');
                        foreach ($enum_values as $enum_val):
                        ?>
                            <option value="<?php echo htmlspecialchars($enum_val); ?>" <?php echo ($value === $enum_val) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($enum_val); ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            <?php elseif (strpos($type, 'date') !== false || strpos($type, 'timestamp') !== false): ?>
                <!-- Date/DateTime -->
                <div class="form-group">
                    <label><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $field))); ?> <?php if ($is_required): ?><span class="required">*</span><?php endif; ?></label>
                    <input type="<?php echo (strpos($type, 'timestamp') !== false || strpos($type, 'datetime') !== false) ? 'datetime-local' : 'date'; ?>" 
                           name="<?php echo $field; ?>" 
                           value="<?php echo $value ? date('Y-m-d' . (strpos($type, 'timestamp') !== false || strpos($type, 'datetime') !== false ? '\TH:i' : ''), strtotime($value)) : ''; ?>" 
                           class="form-input" <?php if ($is_required): ?>required<?php endif; ?>>
                </div>
            <?php elseif (strpos($type, 'int') !== false || strpos($type, 'decimal') !== false): ?>
                <!-- Number -->
                <div class="form-group">
                    <label><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $field))); ?> <?php if ($is_required): ?><span class="required">*</span><?php endif; ?></label>
                    <input type="number" 
                           name="<?php echo $field; ?>" 
                           value="<?php echo htmlspecialchars($value); ?>" 
                           class="form-input" 
                           <?php if ($is_required): ?>required<?php endif; ?>
                           <?php if (strpos($type, 'decimal') !== false): ?>step="0.01"<?php endif; ?>>
                </div>
            <?php else: ?>
                <!-- Text -->
                <div class="form-group">
                    <label><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $field))); ?> <?php if ($is_required): ?><span class="required">*</span><?php endif; ?></label>
                    <?php if (strpos($type, 'text') !== false || strpos($type, 'varchar(255)') !== false): ?>
                        <textarea name="<?php echo $field; ?>" class="form-input form-textarea" <?php if ($is_required): ?>required<?php endif; ?>><?php echo htmlspecialchars($value); ?></textarea>
                    <?php else: ?>
                        <input type="text" 
                               name="<?php echo $field; ?>" 
                               value="<?php echo htmlspecialchars($value); ?>" 
                               class="form-input" 
                               <?php if ($is_required): ?>required<?php endif; ?>
                               maxlength="<?php echo preg_match('/varchar\((\d+)\)/', $type, $m) ? $m[1] : ''; ?>">
                    <?php endif; ?>
                </div>
            <?php endif; ?>
        <?php endforeach; ?>
        
        <div class="form-actions">
            <button type="submit" class="btn btn-primary"><?php echo $is_edit ? 'Update' : 'Create'; ?> Record</button>
            <a href="?table=<?php echo $table; ?>&action=list" class="btn btn-secondary">Cancel</a>
        </div>
    </form>
</div>

