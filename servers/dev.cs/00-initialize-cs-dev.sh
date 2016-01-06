#!/usr/bin/env bash
set -e

#Load configuration file
source config.env

#Create home folders
if [ ! -d /home/faculty ]; then
  mkdir /home/faculty
fi
if [ ! -d /home/student ]; then
  mkdir /home/student
fi

#usrpasswd file handling
sort student.usrpasswd | uniq > uniq_student.usrpasswd
mv uniq_student.usrpasswd student.usrpasswd
cat student.usrpasswd faculty.usrpasswd > full.usrpasswd

#Create users
newusers full.usrpasswd

#Modify and copy /etc/skel to users
mkdir /etc/skel/public_html
while IFS=: read -r pw_name pw_passwd pw_uid pw_gid pw_gecos pw_dir pw_shell;
do
  if [ -d "$pw_dir" ]; then
    cp /etc/skel/. "$pw_dir"
  fi
done < full.usrpasswd

#Get and apply any updates
apt-get update
apt-get --assume-yes upgrade

#Change to project root directory
cd ../../

#Tasks
source tasks/install-LAMP.sh
source tasks/install-NodeJS.sh
source tasks/install-MongoDB.sh
source tasks/install-Java8.sh
source tasks/install-gcc.sh

#Install R
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
apt-get --assume-yes --quiet install r-recommended

#Change the server hostname to config.env value
source tasks/change-hostname.sh

#Create SQL databases
source tasks/LAMP/add-SQL-users.sh servers/dev.cs/faculty.usrpasswd
source tasks/LAMP/add-SQL-users.sh servers/dev.cs/student.usrpasswd
source tasks/LAMP/create-dataset-db.sh pawan dataset 10

#Grant faculty permissions on student DBs
source tasks/LAMP/grant-faculty-SQL-privileges.sh servers/dev.cs/faculty.usrpasswd servers/dev.cs/student.usrpasswd

#Create MongoDB users and add role
source tasks/MongoDB/create-MongoDB-users.sh servers/dev.cs/full.usrpasswd

#Change VG name and restart
source tasks/change-vg-name.sh
shutdown -r now
