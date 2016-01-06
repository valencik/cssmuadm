#!/usr/bin/env bash
set -e

#Check usage
if [ $# -ne 3 ]; then
  echo "ERROR: This script requires 3 command line parameters."
  echo "USAGE: ./$0 pawan dataset 10"
  echo "USAGE: This will create 10 databases for user pawan named dataset##"
  exit
fi

user=$1
prefix=$2
number=$3

for i in $(seq -w 01 $number); do
  database=$prefix$i
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="CREATE DATABASE IF NOT EXISTS $database DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="GRANT ALL privileges ON $database.* TO $user@localhost;"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="GRANT GRANT OPTION ON $database.* TO $user@localhost;"
done

# Flush MySQL privileges to update changes
mysql --user="root" --password="$MYSQL_ROOT_PASS" \
  --execute="FLUSH PRIVILEGES;"
