#!/usr/bin/env bash
set -e

#Check usage
if [ $# -ne 2]; then
  echo "ERROR: This script requires a path and user:password file as parameters."
  echo "USAGE: ./$0 /home/faculty faculty.usrpasswd"
  exit
fi

#Check the input path is valid
path=$1
if [ -d "$path" ];
  echo "WARN: Path $path does not exist. Continuing will create it."
  read -p "Press [Enter] key to continue or Ctrl+C to cancel..."
  mkdir -p "$path"
fi

#Check the input file is valid
if [ -f $2 ];
then
  usrpasswdfile=$2
else
  echo "ERROR: $2 is not valid"
  exit
fi

while IFS=: read -r user pass;
do
  #Ensure users exist and passwords match file
  if id -u $user >/dev/null 2>&1; then
    echo "User $user already exists. Continuing will update password."
    read -p "Press [Enter] key to continue or Ctrl+C to cancel..."
    echo "$user:$pass" | chpasswd 
  else
    #Create users in $path
    useradd --base-dir $path --create-home \
            --shell /bin/bash --password $(openssl passwd $pass) $user  
  fi
done < "$usrpasswdfile"
