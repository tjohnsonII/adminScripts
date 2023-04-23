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
    if ping -q -c 10 -W 10 google.com >/dev/null; then
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

# Initialize a new Git repository
git init



# MIDDLE SECTION
# TODO: Add middle section commands here

print_color 32 $network_status

# Add all files to the repository
git add .


# END SECTION
# TODO: Add end section commands here

# Make an initial commit
git commit -m "Initial commit"
