#!/usr/bin/env bash
set -e

#Load configuration file
source config.env

#Get and apply any updates
apt-get update
apt-get --assume-yes upgrade

#Change to project root directory
cd ../../

#Tasks
source tasks/install-LAMP.sh
source tasks/install-MongoDB.sh
source tasks/install-Java8.sh
source tasks/install-gcc.sh
source tasks/change-hostname.sh
source tasks/change-vg-name.sh

#Create users
if [ ! -d /home/faculty ]; then
  mkdir /home/faculty
fi
newusers servers/dev.cs/faculty.usrpasswd
if [ ! -d /home/student ]; then
  mkdir /home/student
fi
newusers servers/dev.cs/student.usrpasswd

#Create SQL databases
source tasks/LAMP/add-SQL-users.sh servers/dev.cs/faculty.usrpasswd
source tasks/LAMP/add-SQL-users.sh servers/dev.cs/student.usrpasswd

#Grant faculty permissions on student DBs
source tasks/LAMP/grant-faculty-SQL-privileges.sh servers/dev.cs/faculty.usrpasswd servers/dev.cs/student.usrpasswd
