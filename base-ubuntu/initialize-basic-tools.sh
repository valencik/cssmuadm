#!/usr/bin/env bash
set -e

#Get and apply any updates
apt-get update
apt-get --assume-yes upgrade

#Basic tools
apt-get --assume-yes --quiet install git vim ethtool iperf finger
