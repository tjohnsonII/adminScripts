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

function save_users {
  dscl . -list /Users UniqueID | awk '$2 >= 1000 {print $1}' > user_list.txt
}


function save_groups {
  dscl . -list /Groups | while read groupname; do printf "%s\t" "$groupname"; dscl . -read /Groups/"$groupname" PrimaryGroupID | awk '{print $2}'; done > group_list.txt
}


# START SECTION
# TODO: Add start section commands here

# MIDDLE SECTION
# TODO: Add middle section commands here
#!/bin/bash

echo "Logged in users:"
who

# END SECTION
# TODO: Add end section commands here
