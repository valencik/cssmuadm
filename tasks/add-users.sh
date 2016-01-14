#!/usr/bin/env bash
set -e

#Check usage
if [ $# -ne 1 ]; then
  echo "ERROR: This script requires a user:password file."
  echo "USAGE: ./$0 student.usrpasswd"
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

while IFS=: read -r pw_name pw_passwd pw_uid pw_gid pw_gecos pw_dir pw_shell;
do
  #Ensure users exist and passwords match file
  if id -u $pw_name >/dev/null 2>&1; then
    echo "User $user already exists. Continuing will update password."
    read -p "Press [Enter] key to continue or Ctrl+C to cancel..."
    echo "$pw_name:$pw_passwd" | chpasswd 
  else
    #Create users in $path
    useradd --home-dir $pw_dir --create-home --skel /etc/skel \
            --shell $pw_shell --password $(openssl passwd $pw_passwd) $pw_name
    fullname=$(echo "$pw_gecos" | sed s/,//g)
    chfn -f "$fullname" $pw_name
  fi
done < "$usrpasswdfile"
