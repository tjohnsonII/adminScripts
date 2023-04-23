#!/usr/bin/env python3

import socket
import os
import signal


def print_color(color, message):
    """Print a message in a specific color."""
    colors = {
        'black': '\u001b[30m',
        'red': '\u001b[31m',
        'green': '\u001b[32m',
        'yellow': '\u001b[33m',
        'blue': '\u001b[34m',
        'magenta': '\u001b[35m',
        'cyan': '\u001b[36m',
        'white': '\u001b[37m',
        'reset': '\u001b[0m'
    }
    print(f"{colors[color]}{message}{colors['reset']}")


def check_network_connectivity():
    """Check if the machine is connected to the internet."""
    try:
        socket.create_connection(("www.google.com", 80))
        print_color("green", "Connected to the internet")
    except OSError:
        print_color("red", "No internet connection")


def save_users():
    """Save a list of all users on the system."""
    with open("user_list.txt", "w") as f:
        os.system("dscl . -list /Users UniqueID | awk '$2 >= 1000 {print $1}' > user_list.txt")


def save_groups():
    """Save a list of all groups on the system."""
    with open("group_list.txt", "w") as f:
        os.system("dscl . -list /Groups | while read groupname; do printf '%s\\t' \"$groupname\"; dscl . -read /Groups/\"$groupname\" PrimaryGroupID | awk '{print $2}'; done > group_list.txt")


def handle_request(conn, addr):
    """Handle a single HTTP request."""
    request = conn.recv(1024).decode()
    print(f"Received request from {addr[0]}:{addr[1]}:")
    print(request)

    filename = request.split()[1][1:]
    if not filename:
        filename = "/Users/Shared/adminScripts/index.html"

    if os.path.exists(filename) and os.path.isfile(filename):
        with open(filename, "rb") as f:
            content = f.read()
        response = b"HTTP/1.1 200 OK\r\n\r\n" + content
    else:
        response = b"HTTP/1.1 404 Not Found\r\n\r\nFile not found"

    conn.sendall(response)
    conn.close()


def start_server():
    """Start the HTTP server."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        # Kill any process already using port 8080
        os.system("kill $(lsof -t -i:8080)")

        s.bind(('192.168.1.59', 8080))
        s.listen()
        print_color("green", "Server started")

        while True:
            conn, addr = s.accept()
            handle_request(conn, addr)


def main():
    print_color("green", "Starting script")
    check_network_connectivity()
    save_users()
    save_groups()
    start_server()
    print_color("red", "Server down")


if __name__ == '__main__':
    main()
