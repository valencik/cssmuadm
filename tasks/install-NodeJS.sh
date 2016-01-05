#!/usr/bin/env bash
set -e

#Install NodeJS v4.x via NodeSource installer script
if [ -x /usr/bin/nodejs ];
then
  echo "NodeJS already installed"
else
  echo "Running NodeSource installer script"
  bash tasks/NodeJS/setup_4.x
  apt-get install --assume-yes --quiet nodejs build-essential
fi
