#!/usr/bin/env bash
set -e

#Create all necessary user accounts for csci2356

#Configuration
courseShortName=csc356
path=/home/course/$courseShortName
mkdir -p $path
instructor=pawan
marker=matt
#TODO echo configuration data


#Generate username/password file for usrpasswd command
if [ ! -f ./$courseShortName.usrpasswd ];
then
  echo "Generating new $courseShortName.usrpasswd file"
  read -p "Press [Enter] key to continue or Ctrl+C to cancel..."
  for i in $(seq -w $minAccount $maxAccount); do

      #Generate usernames and passwords and write them to a file
      user=$courseShortName$i
      pass=$(tr -dc A-Za-z0-9 < /dev/urandom | tr -d 1lLiIo0 | head -c 8)
      #pass=$(grep -v "'" /usr/share/dict/words | shuf -n3 | xargs | tr -t " " "-")
      #pass=$(apg -a1 -n1 -x8 -m8 -M NLC -c cl_seed -E 0oO1liLIsSzZxXcCvV)
      echo "$user:$pass">>$courseShortName.usrpasswd
  done
else
  echo "Found existing $courseShortName.usrpasswd file."
fi

#Create users from $courseShortName.usrpasswd
while IFS=: read -r user pass;
do
      #Ensure users exist and passwords match file
      if id -u $user >/dev/null 2>&1; then
        echo "User $user already exists. Continuing will update password."
        read -p "Press [Enter] key to continue or Ctrl+C to cancel..."
        echo "$user:$pass" | chpasswd 
      else
        #Create users in /home/course/$courseShortName with ./$courseShortName-skel contents
        useradd --base-dir $path --create-home --skel ./courseShortName-skel \
                --shell /bin/bash --password $(openssl passwd $pass) $user  
      fi

    #Give special accounts ownership of student accounts
    usermod -aG $user $marker
    usermod -aG $user $instructor
done < "$courseShortName.usrpasswd"
