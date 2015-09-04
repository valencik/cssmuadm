#!/usr/bin/env bash
set -e

#This script adds an htaccess and htpasswd file to user directories

#Check usage
if [ $# -ne 1 ]; then
  echo "ERROR: This script requires a user:password file as a parameter."
  exit
fi

#Check that Apache2 exists
if [ -f /etc/apache2/apache2.conf ];
then
  #Create users from $courseShortName.usrpasswd
  while IFS=: read -r user pass;
  do
    #Ensure users exist and passwords match file
    if grep "^$user:" /etc/passwd >/dev/null; then
      echo "User $user already exists. Creating htaccess and htpasswd files..."
      home=$(getent passwd $user | cut -d ":" -f 6)

      #Create htpasswd file
      mkdir -p "$home"/.htinfo
      htpasswd -B -b -c "$home"/.htinfo/.htpasswd $user $pass

      #Setup .htaccess file for students
      mkdir -p "$home"/public_html
      echo "AuthType Basic" > "$home"/public_html/.htaccess
      echo "AuthName "user"" >> "$home"/public_html/.htaccess
      echo "AuthUserFile "$home"/.htinfo/.htpasswd" >> "$home"/public_html/.htaccess
      echo "Require valid-user" >> "$home"/public_html/.htaccess

      #Set proper permissions
      chown -R :www-data "$home"/.htinfo
    else
      echo "ERROR: User $user not found!"
    fi

  done < "$1"

else
  echo "ERROR: Install apache before running this script."
fi
