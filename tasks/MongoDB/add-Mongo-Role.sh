#!/usr/bin/env bash
set -e

# This script adds a mongo role to the users in the provided usr.passwd file
# If the role does not already exist in the admin database, you must create it
# mongo admin -p -u siteUserAdmin create-studentAdminActions-role.js

#Check usage
if [ $# -ne 2 ]; then
  echo "ERROR: This script requires a user:password and a mongo role as parameters."
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

# Confirm the role with the user
echo "Going to add role $2 to all users in $1?"

# Generate the mongo-user.js file
while IFS=: read -r user pass;
do
  echo "db = db.getSiblingDB('$user')" >> tasks/MongoDB/mongo-user-roles.js
  echo "db.grantRolesToUser( \"$user\", [ { role: \"$2\", db: \"admin\" } ])" >> tasks/MongoDB/mongo-user-roles.js
done < "$usrpasswdfile"

# Print out instructions
echo "Run mongo mongo-user-roles.js to make the user modifications."
