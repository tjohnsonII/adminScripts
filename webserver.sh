#!/bin/bash

# This script is a template.
# Author: Timothy Allen Johnson II

#set -x
#set -e 

# Define colors for printing text
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define function for printing colored text
print_color () {
  local color=$1
  shift
  printf "${color}%s${NC}\n" "$@"
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
print_color "${GREEN}" "Starting Script"
network_status=$(check_network_connectivity)
print_color "${YELLOW}" "$network_status"

while true; do
    # Wait for a request and store the headers in a variable
    request=$(nc -l 8080)

    # Extract the requested filename from the first line of the headers
    print_color "${YELLOW}" "Received request:"
    print_color "${YELLOW}" "$request"
    filename=$(echo "$request" | grep -o '^GET /\S*' | sed 's/GET \/\(.*\)\sHTTP.*/\1/')
    
    # If the filename is empty, assume it's the root and serve index.html
    if [ -z "$filename" ]; then
        filename="/Users/Shared/adminScripts/index.html"
        print_color "${YELLOW}" "Serving file: $filename"
    fi

    # Check if the file exists and is readable
    if [ -r "$filename" ]; then
        # Send an HTTP 200 response and the file contents
        echo -e "HTTP/1.1 200 OK\n\n$(cat $filename)" | nc -l 8080 > /dev/null
    else
        # Send an HTTP 404 response and an error message
        echo -e "HTTP/1.1 404 Not Found\n\nFile not found" | nc -l 8080 > /dev/null
    fi
done

# END SECTION
print_color "${GREEN}" "Server Down"
