#!/usr/bin/env bash
set -e

#Install Mongodb
if [ ! -f /usr/bin/mongod ];
then
  #Increase appropriate limits for database usage
  ulimit -n 64000
  ulimit -u 64000

  #Install MongoDB from mongo's packages
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
  echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
  apt-get update
  apt-get --assume-yes --quiet install mongodb-org
  service mongod restart
fi
