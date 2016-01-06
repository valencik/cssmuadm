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

# Create mongo user siteUserAdmin
echo "db = db.getSiblingDB('admin')" >> tasks/MongoDB/mongo-users.js
echo "db.createUser( { user: \"$mongoAdminUser\", pwd: \"$mongoAdminPass\", roles: [ { role: \"userAdminAnyDatabase\", db: \"admin\" } ] })" >> tasks/MongoDB/mongo-users.js

# Generate the mongo-user.js file
while IFS=: read -r user pass other;
do
  echo "db = db.getSiblingDB('$user')" >> tasks/MongoDB/mongo-users.js
  echo "db.createUser( { user: \"$user\", pwd: \"$pass\", roles: [ { role: \"readWrite\", db: \"$user\" } ] })" >> tasks/MongoDB/mongo-users.js
done < "$usrpasswdfile"

# Create new mongo users
mongo admin tasks/MongoDB/mongo-users.js

# Create the studentAdminActions role
mongo admin tasks/MongoDB/create-studentAdminActions-role.js

# Add users to StudentAdminActions role
source tasks/MongoDB/add-Mongo-Role.sh $usrpasswdfile tasks/MongoDB/studentAdminActions
mongo admin tasks/MongoDB/mongo-user-roles.js

# Enable mongo authentication
sed -i '/#auth = true/s/^#//' /etc/mongod.conf

# Restart mongod
service mongod restart
