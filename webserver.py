#!/usr/bin/env python3

import os
import socket
import subprocess
import sys


def print_color(color, *args):
    colors = {
        'black': '0;30',
        'red': '0;31',
        'green': '0;32',
        'yellow': '0;33',
        'blue': '0;34',
        'purple': '0;35',
        'cyan': '0;36',
        'white': '0;37',
    }
    color_code = colors.get(color.lower())
    if color_code is None:
        raise ValueError(f'invalid color: {color}')
    print(f'\033[{color_code}m', *args, '\033[0m')


def check_network_connectivity():
    try:
        subprocess.check_call(['ping', '-q', '-c', '1', '-W', '1', 'google.com'], stdout=subprocess.DEVNULL)
        return 'Connected to the internet'
    except subprocess.CalledProcessError:
        return 'No internet connection'


def save_users():
    with open('user_list.txt', 'w') as f:
        users = subprocess.check_output(['dscl', '.', '-list', '/Users', 'UniqueID'])
        for line in users.decode().splitlines():
            username, uid = line.split()
            if int(uid) >= 1000:
                print(username, file=f)


def save_groups():
    with open('group_list.txt', 'w') as f:
        groups = subprocess.check_output(['dscl', '.', '-list', '/Groups'])
        for groupname in groups.decode().splitlines():
            print(groupname, end='\t', file=f)
            primary_gid = subprocess.check_output(['dscl', '.', '-read', f'/Groups/{groupname}', 'PrimaryGroupID'])
            print(primary_gid.decode().strip().split()[-1], file=f)


def main():
    print_color('green', 'Starting Script')
    network_status = check_network_connectivity()
    print_color('green', network_status)

    while True:
        # Wait for a request and store the headers in a variable
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('localhost', 8080))
            s.listen()
            conn, addr = s.accept()
            with conn:
                print(f'Received request from {addr[0]}:{addr[1]}')
                request = conn.recv(4096).decode()
                print(request)

                # Extract the requested filename from the first line of the headers
                filename = request.split()[1]
                if filename == '/':
                    filename = '/Users/Shared/adminScripts/index.html'
                    print(f'Serving file: {filename}')

                # Check if the file exists and is readable
                if os.path.isfile(filename) and os.access(filename, os.R_OK):
                    # Send an HTTP 200 response and the file contents
                    with open(filename, 'rb') as f:
                        content = f.read()
                    response = f'HTTP/1.1 200 OK\r\nContent-Length: {len(content)}\r\n\r\n{content}'
                    conn.sendall(response.encode())
                else:
                    # Send an HTTP 404 response and an error message
                    response = 'HTTP/1.1 404 Not Found\r\nContent-Length: 13\r\n\r\nFile not found'
                    conn.sendall(response.encode())

    print_color('green', 'Server Down')


if __name__ == '__main__':
    main()
