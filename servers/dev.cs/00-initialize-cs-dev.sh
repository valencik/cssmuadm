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
apt-get --assume-yes --quiet install r-recommended

#Change the server hostname to config.env value
source tasks/change-hostname.sh

#Create SQL databases
source tasks/LAMP/add-SQL-users.sh servers/dev.cs/faculty.usrpasswd
source tasks/LAMP/add-SQL-users.sh servers/dev.cs/student.usrpasswd

#Grant faculty permissions on student DBs
source tasks/LAMP/grant-faculty-SQL-privileges.sh servers/dev.cs/faculty.usrpasswd servers/dev.cs/student.usrpasswd

#Change VG name and restart
source tasks/change-vg-name.sh
shutdown -r now
