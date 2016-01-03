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

