#!/usr/bin/env bash
set -e

#Set hostname
NEW_HOSTNAME=os
hostnamectl set-hostname $NEW_HOSTNAME
sed -i 's/127.0.1.1.*/127.0.1.1\t'"$NEW_HOSTNAME"'/g' /etc/hosts

#Get and apply any updates
apt-get update
apt-get --assume-yes upgrade

#Install basic tools
apt-get --assume-yes --quiet install git vim ethtool iperf p7zip-full aspell ispell finger software-properties-common

#Install gcc5 and others
if [ -f /etc/apt/sources.list.d/ubuntu-toolchain-r-test-trusty.list ];
then
  echo "Ubuntu Toolchain PPA already installed"
else
  echo "Adding Ubuntu Toolchain PPA"
  add-apt-repository --yes ppa:ubuntu-toolchain-r/test
  apt-get update
fi
apt-get --assume-yes --quiet install gcc-5 build-essential

#Install X2go server
if [ -f /etc/apt/sources.list.d/x2go-stable-trusty.list ];
then
  echo "X2goPPA already installed"
else
  echo "Adding X2go Toolchain PPA"
  apt-add-repository --yes ppa:x2go/stable
  apt-get update
fi
apt-get install --assume-yes --quiet x2goserver x2goserver-xsession

#Install XFCE4
apt-get --assume-yes --quiet install xfce4 xfce4-goodies
