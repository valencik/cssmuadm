#!/usr/bin/env bash
set -e

while IFS=: read -r user pass;
  do
    #Ensure users exist and passwords match file
    if id -u $user >/dev/null 2>&1; then
      echo "User $user exists. Updating password..."
      echo "$user:$pass" | chpasswd 
    else
      echo "User $user does not exist."
    fi
done < "$1"
