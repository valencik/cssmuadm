// Creates a simple role that allows users to change their own password
// mongo admin -p -u siteUserAdmin create-studentAdminActions-role.js

db.getSiblingDB('admin')
db.createRole(
   { role: "studentAdminActions",
     privileges: [
        {
          resource: { db: "", collection: ""},
          actions: [ "changeOwnPassword" ]
        }
     ],
     roles: []
   }
)
