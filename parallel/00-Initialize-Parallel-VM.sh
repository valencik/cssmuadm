#!/bin/bash
#This script is testing installation and setup on Ubuntu 14

#Set hostname
NEW_HOSTNAME=paulR
hostnamectl set-hostname $NEW_HOSTNAME
sed -i 's/127.0.1.1.*/127.0.1.1\t'"$NEW_HOSTNAME"'/g' /etc/hosts

#Get and apply any updates
apt-get update
apt-get --assume-yes upgrade

#Install basic tools
apt-get --assume-yes --quiet install git vim ethtool iperf
apt-get --assume-yes --quiet install p7zip-full
apt-get --assume-yes --quiet install aspell

apt-get --assume-yes --quiet install parallel

