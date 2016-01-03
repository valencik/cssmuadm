#!/usr/bin/env bash
set -e

#Check usage
if [ $# -ne 2 ]; then
  echo "ERROR: This script requires two user:password files as parameters."
  echo "USAGE: ./$0 faculty.usrpwd student.usrpwd"
  exit
fi

#Check the input files are valid
if [ -f $1 ];
then
  faculty=$1
else
  echo "ERROR: Faculty list $1 is not valid"
  exit
fi
if [ -f $2 ];
then
  students=$2
else
  echo "ERROR: Student list $2 is not valid"
  exit
fi

#Loop over faculty
while IFS=: read -r faculty_user other;
do
  #Loop over students
  while IFS=: read -r student_user other;
  do
  
    mysql --user="root" --password="$MYSQL_ROOT_PASS" \
      --execute="GRANT ALL privileges ON $student_user.* TO $faculty_user@localhost;"
  
  done < "$students"
done < "$faculty"

# Flush MySQL privileges to update changes
mysql --user="root" --password="$MYSQL_ROOT_PASS" \
  --execute="FLUSH PRIVILEGES;"
