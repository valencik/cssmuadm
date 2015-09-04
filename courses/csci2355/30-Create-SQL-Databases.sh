#!/usr/bin/env bash
set -e

#From phpMyAdmin
#CREATE USER 'research'@'%' IDENTIFIED BY  '***';
#GRANT USAGE ON * . * TO  'research'@'%' IDENTIFIED BY  '***' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;
#GRANT ALL PRIVILEGES ON  `research` . * TO  'research'@'%';

#Configuration
courseShortName=csc355
path=/home/course/$courseShortName
minAccount=01
maxAccount=49
instructor=$courseShortName"00"
marker=$courseShortName"50"
numberSubmissions=10
MYSQL_ROOT_PASS="mySecretPassword"

#Pause before starting backup
read -p "Press [Enter] key to continue or Ctrl+C to cancel..."


#Loop over names and passwords
while IFS=: read -r user pass;
do

  #Create databases and set privledges for all users
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="CREATE USER '$user'@'%' IDENTIFIED BY '$pass';"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="CREATE DATABASE IF NOT EXISTS $user DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="GRANT ALL privileges ON $user.* TO $user@localhost;"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="UPDATE mysql.user SET password=PASSWORD('$pass') WHERE user='$user';"

done < "$courseShortName.usrpasswd"

mysql --user="root" --password="$MYSQL_ROOT_PASS" \
  --execute="FLUSH PRIVILEGES;"

#Make symlinks to students in special accounts
for specialAccount in "$marker" "$instructor"; do
  for i in $(seq -w $minAccount $maxAccount); do
    user=$courseShortName$i

    mysql --user="root" --password="$MYSQL_ROOT_PASS" \
      --execute="GRANT ALL privileges ON $user.* TO $specialAccount@localhost;"

  done
done
