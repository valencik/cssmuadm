#!/bin/bash -e
#This script adds an htaccess and htpasswd file to user directories

#Check usage
if [ $# -ne 2 ]; then
  echo "ERROR: This script requires two arguments"
  echo "  $0 users-to-affect.usrpasswd admin.usrpasswd"
  exit
fi

#Check that Apache2 exists
if [ ! -f /etc/apache2/apache2.conf ]; then
  echo "ERROR: Install apache before running this script."
  exit
fi

#Create users from $courseShortName.usrpasswd
while IFS=: read -r user pass;
do
  #Ensure users exists
  if grep "^$user:" /etc/passwd >/dev/null; then
    home=$(getent passwd $user | cut -d ":" -f 6)

    #Ensure the .htinfo directory exists
    if [ -d "$home"/.htinfo ]; then
      echo "User $user already exists. Modifying htpasswd file..."

      #Add admin users to .htpasswd
      while IFS=: read -r admin pw; do
        htpasswd -B -b "$home"/.htinfo/.htpasswd $admin $pw
      done < "$2"
    fi

  else
    echo "ERROR: User $user not found!"
  fi

done < "$1"
