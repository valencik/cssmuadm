#!/usr/bin/env bash
set -e

#Add Webupd8 PPA
if [ -f /etc/apt/sources.list.d/webupd8team-java-trusty.list ];
then
  echo "Webupd8 PPA already installed"
else
  echo "Adding Webupd8 Toolchain PPA"
  apt-add-repository --yes ppa:webupd8team/java
  apt-get --quiet update
fi

#Install Oracle Java 8
echo "oracle-java8-installer  shared/accepted-oracle-license-v1-1     boolean true" | debconf-set-selections
apt-get install --assume-yes --quiet oracle-java8-installer
