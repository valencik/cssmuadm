#!/bin/bash
#This script installs required software for hosting the CSCI2356 course.

#Set hostname
NEW_HOSTNAME=cs2356
hostnamectl set-hostname $NEW_HOSTNAME
sed -i 's/127.0.1.1.*/127.0.1.1\t'"$NEW_HOSTNAME"'/g' /etc/hosts

#Make sure loopback device has IP
ip addr add 127.0.0.1 dev lo

#Get and apply any updates
apt-get update
apt-get --assume-yes upgrade

#Install basic tools
apt-get --assume-yes --quiet install git vim ethtool iperf
apt-get --assume-yes --quiet install p7zip-full
apt-get --assume-yes --quiet install aspell

#Install Apache2 if it does not exist
if [ ! -f /etc/apache2/apache2.conf ];
then
  #Install Apache2
  apt-get --assume-yes install apache2 apache2-utils
  service apache2 restart

  #Enable necessary apache2 mods for per-user directories
  a2enmod userdir 
  
  #Make sure loopback device has IP
  ip addr add 127.0.0.1 dev lo
  
fi

#Install NodeJS
if [ ! -f /usr/bin/nodejs ];
then
  curl -sL https://deb.nodesource.com/setup | sudo bash -
  apt-get --assume-yes --quiet install nodejs
  apt-get --assume-yes --quiet install build-essential
fi

#Install Mongodb
if [ ! -f /usr/bin/mongod ];
then
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
  sudo apt-get update
  apt-get --assume-yes --quiet install mongodb-org
fi
