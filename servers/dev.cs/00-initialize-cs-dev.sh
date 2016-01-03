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
mkdir /home/faculty
newusers servers/dev.cs/faculty.usrpasswd
mkdir /home/student
newusers servers/dev.cs/student.usrpasswd

#Create SQL databases
bash tasks/LAMP/add-SQL-users.sh servers/dev.cs/faculty.usrpasswd
bash tasks/LAMP/add-SQL-users.sh servers/dev.cs/student.usrpasswd
