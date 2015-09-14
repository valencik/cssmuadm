#!/usr/bin/env bash
set -e

#Configuration
courseShortName=os
path=/home/course/$courseShortName
mkdir -p $path
minAccount=00
maxAccount=50
instructor="tami"
marker="marker"
numberSubmissions=10


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

      #Ensure users exist and passwords match file
      if id -u $user >/dev/null 2>&1; then
        echo "User $user already exists. Continuing will update password."
        read -p "Press [Enter] key to continue or Ctrl+C to cancel..."
        echo "$user:$pass" | chpasswd 
      else
        #Create users in /home/course/$courseShortName with ./$courseShortName-skel contents
        useradd --base-dir $path --create-home --skel ./$courseShortName-skel \
                --shell /bin/bash --password $(openssl passwd $pass) $user  
      fi
  done
else
  echo "Found existing $courseShortName.usrpasswd file."
  while IFS=: read -r user pass;
  do
    #Ensure users exist and passwords match file
    if id -u $user >/dev/null 2>&1; then
      echo "User $user already exists. Continuing will update password."
      read -p "Press [Enter] key to continue or Ctrl+C to cancel..."
      echo "$user:$pass" | chpasswd 
    else
      #Create users in /home/course/$courseShortName with ./$courseShortName-skel contents
      useradd --base-dir $path --create-home --skel ./$courseShortName-skel \
              --shell /bin/bash --password $(openssl passwd $pass) $user  
    fi
  done < "$courseShortName.usrpasswd"
fi

#Give special accounts ownership of student accounts
while IFS=: read -r user pass;
do
  if [ "$user" != "$instructor" ] &&  [ "$user" != "$marker" ]; then
    usermod -aG $user $marker
    usermod -aG $user $instructor
  fi
done < "$courseShortName.usrpasswd"

#Create admin group, this is used for locking files down
groupadd $courseShortName"admin"
usermod -aG $courseShortName"admin" $instructor 
usermod -aG $courseShortName"admin" $marker 

#Create common group, used for securing webpages from public
#Lets each user create dir (chmod 710) with file (chmod 770) for php to write
groupadd $courseShortName
while IFS=: read -r user pass;
do
  if [ "$user" != "$instructor" ] &&  [ "$user" != "$marker" ]; then
    usermod -aG $courseShortName $user
  fi
done < "$courseShortName.usrpasswd"

#Create osbashrc file
cp os00-skel/.osbashrc $path/$instructor/.osbashrc
chown $instructor:os $path/$instructor/.osbashrc
chmod 750 $path/$instructor/.osbashrc
