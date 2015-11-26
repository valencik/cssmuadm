#!/usr/bin/env bash
set -e

#This script should setup a Ubuntu 14.04 VM for numeric computing research for Paul Muir

#Set hostname
NEW_HOSTNAME=paulR
hostnamectl set-hostname $NEW_HOSTNAME
sed -i 's/127.0.1.1.*/127.0.1.1\t'"$NEW_HOSTNAME"'/g' /etc/hosts

#Get and apply any updates
apt-get update
apt-get --assume-yes upgrade

#Install basic tools
apt-get --assume-yes --quiet install git vim ethtool iperf p7zip-full aspell zsh

#Install GNU Parallel and other build tools
apt-get --assume-yes --quiet install build-essential gfortran parallel texlive texlive-font-utils graphviz

#Install python3 requirements
apt-get --assume-yes --quiet install python3-notebook python3-matplotlib python3-numpy python3-pip
sudo pip3 install gprof2dot
