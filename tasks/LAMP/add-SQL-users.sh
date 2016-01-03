#!/usr/bin/env bash
set -e

#Load configuration file
source config.env

#Check usage
if [ $# -ne 1 ]; then
  echo "ERROR: This script requires a user:password file as a parameter."
  exit
fi

#Check the input file is valid
if [ -f $1 ];
then
  usrpasswdfile=$1
else
  echo "ERROR: $1 is not valid"
  exit
fi

#Loop over names and passwords
while IFS=: read -r user pass;
do

  #Create databases and set privileges for all users
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="CREATE USER '$user'@'%' IDENTIFIED BY '$pass';"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="CREATE DATABASE IF NOT EXISTS $user DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="GRANT ALL privileges ON $user.* TO $user@localhost;"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="UPDATE mysql.user SET password=PASSWORD('$pass') WHERE user='$user';"

done < "$usrpasswdfile"

# Flush MySQL privileges to update changes
mysql --user="root" --password="$MYSQL_ROOT_PASS" \
  --execute="FLUSH PRIVILEGES;"
