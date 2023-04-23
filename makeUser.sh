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

# Prompt for the new user's information
read -p "Enter the new username: " USERNAME
read -p "Enter the new password: " -s PASSWORD
echo ""
read -p "Enter the new user's full name: " FULLNAME
read -p "Enter the new user's unique ID: " UNIQUEID


# MIDDLE SECTION

# Create the new user
sudo dscl . -create /Users/$USERNAME
sudo dscl . -create /Users/$USERNAME UserShell /bin/bash
sudo dscl . -create /Users/$USERNAME RealName "$FULLNAME"
sudo dscl . -create /Users/$USERNAME UniqueID "$UNIQUEID"
sudo dscl . -create /Users/$USERNAME PrimaryGroupID 20
sudo dscl . -create /Users/$USERNAME NFSHomeDirectory /Users/$USERNAME

# Set the new user's password
sudo dscl . -passwd /Users/$USERNAME $PASSWORD

# Create the new user's home directory
sudo createhomedir -c -u $USERNAME


# END SECTION

sudo ditto /Users/tim2 /Users/$USERNAME
