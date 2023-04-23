#!/bin/sh

# This script is a template.
# Author: Timothy Allen Johnson II

#set -x
#set -e 

#FUNCTIONS 

# Define function for printing colored text
print_color () {
  local color=$1
  shift
  printf "\e[${color}m%s\e[0m\n" "$@"
}

check_network_connectivity() {
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "Connected to the internet"
    else
        echo "No internet connection"
    fi
}


function save_users {
  dscl . -list /Users UniqueID | awk '$2 >= 1000 {print $1}' > user_list.txt
}


function save_groups {
  dscl . -list /Groups | while read groupname; do printf "%s\t" "$groupname"; dscl . -read /Groups/"$groupname" PrimaryGroupID | awk '{print $2}'; done > group_list.txt
}


# START SECTION
# TODO: Add start section commands here
print_color 32 "Starting Script"
network_status=$(check_network_connectivity)


# MIDDLE SECTION
# TODO: Add middle section commands here
print_color 32 $network_status

while true; do
    # Wait for a request and store the headers in a variable
    request=$(nc -l -p 8080 -q 1)

    # Extract the requested filename from the first line of the headers
    filename=$(echo "$request" | head -n 1 | cut -d ' ' -f 2)

    # If the filename is empty, assume it's the root and serve index.html
    if [ -z "$filename" ]; then
        filename="index.html"
    fi

    # Check if the file exists and is readable
    if [ -r "$filename" ]; then
        # Send an HTTP 200 response and the file contents
        echo -e "HTTP/1.1 200 OK\n\n$(cat $filename)" | nc -w 1 -N -l -p 8080
    else
        # Send an HTTP 404 response and an error message
        echo -e "HTTP/1.1 404 Not Found\n\nFile not found" | nc -w 1 -N -l -p 8080
    fi
done

# END SECTION
# TODO: Add end section commands here
