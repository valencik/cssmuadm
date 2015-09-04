#!/usr/bin/env bash
set -e

# This script creates mongo users and enables mongod authentication

#Check usage
if [ $# -ne 1 ]; then
  echo "ERROR: This script requires a user:password file as a parameter."
  exit
fi

#Check the input file is valid
if [ -f $1 ];
then
  usrpasswdfile=$1
else
  echo "ERROR: $1 is not valid"
  exit
fi

# Generate the mongo-user.js file
while IFS=: read -r user pass;
do
  echo "db = db.getSiblingDB('$user')" >> mongo-users.js
  echo "db.createUser( { user: \"$user\", pwd: \"$pass\", roles: [ { role: \"readWrite\", db: \"$user\" } ] })" >> mongo-users.js
done < "$usrpasswdfile"

# Create new mongo users
mongo admin mongo-users.js

# Enable mongo authentication
sed -i '/#auth = true/s/^#//' /etc/mongod.conf

# Restart mongod
service mongod restart
