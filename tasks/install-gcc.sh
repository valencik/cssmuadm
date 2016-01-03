#!/usr/bin/env bash
set -e

#Add Toolchain PPA
if [ -f /etc/apt/sources.list.d/ubuntu-toolchain-r-test-trusty.list ];
then
  echo "Ubuntu Toolchain PPA already installed"
else
  echo "Adding Ubuntu Toolchain PPA"
  add-apt-repository --yes ppa:ubuntu-toolchain-r/test
  apt-get --quiet update
fi

#Install gcc5 and others
apt-get --assume-yes --quiet install gcc-5 build-essential
