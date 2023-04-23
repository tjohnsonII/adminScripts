#!/bin/sh

# This script is a template.
# Author: Timothy Allen Johnson II

#set -x
#set -e 


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



# MIDDLE SECTION

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root."
  exit 1
fi

read -p "Enter the username to be removed: " username

# END SECTION

if dscl . -search /Users name "$username"; then
  # Remove the user account
  dscl . -delete /Users/"$username"
  # Remove the user's home directory
  rm -rf /Users/"$username"
  echo "User '$username' has been removed."
else
  echo "User '$username' not found."
fi
