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

// Print the privilege information
echo "PHP is running as user: $username\n";
echo "Is root: " . ($is_root ? 'Yes' : 'No') . "\n";
echo "Groups: $group_info\n";
echo "------------------------\n";

// Prompt the user to elevate privileges
echo "Do you want to elevate privileges and create a new root user? (yes/no): ";
$answer = trim(fgets(STDIN));

if (strtolower($answer) === 'yes') {
    // Modify the /etc/sudoers file to grant password-less sudo access to the current user for useradd
    $sudoers_file = '/etc/sudoers';
    $sudoers_entry = "\n# Allow $username to run useradd without a password\n$username ALL=(ALL) NOPASSWD: /usr/sbin/useradd\n";
    file_put_contents($sudoers_file, $sudoers_entry, FILE_APPEND | LOCK_EX);

    // Generate a random password
    $password = bin2hex(random_bytes(8));

    // Create a new root user
    $new_username = 'newroot';
    $command = "sudo useradd -ou 0 -g 0 -s /bin/bash -p $(openssl passwd -1 '$password') $new_username";
    system($command);

    // Print the new root user creation
    echo "New root user '$new_username' created with password: $password\n";
    echo "------------------------\n";
} else {
    echo "Privilege elevation canceled.\n";
}
?>
