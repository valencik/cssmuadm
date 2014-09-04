#! /bin/bash
#This script rebuilds the user submission structure and ensure proper permissions
#It requires a $courseShortName.usrpasswd file exist in current directory

#Configuration
courseShortName=csc355
path=/home/course/$courseShortName
minAccount=01
maxAccount=49
instructor=$courseShortName"00"
marker=$courseShortName"50"
numberSubmissions=12

#TODO echo configuration data

#Ensure we have a password file (created from previous script)
if [ ! -f ./$courseShortName.usrpasswd ];
then
  echo "No $courseShortName.usrpasswd file found."
  exit
fi

#Create the submission directory structure in each users home dir
for i in $(seq -w $minAccount $maxAccount); do
  user=$courseShortName$i
  for j in $(seq -w 00 $numberSubmissions); do
    mkdir -p $path/$user/public_html/submissions/submission$j
  done
done

#Create .htaccess and .htpasswd for each user
while IFS=: read -r user pass;
do
  #Create htpasswd file
  mkdir -p $path/$user/htpasswd
  htpasswd -b -c $path/$user/htpasswd/.htpasswd $user $pass

  #Setup .htaccess file for students
  if [ "$user" != "$marker" ] && [ "$user" != "$instructor" ]; then
    echo "AuthType Basic" > $path/$user/public_html/submissions/.htaccess
    echo "AuthName "user"" >> $path/$user/public_html/submissions/.htaccess
    echo "AuthUserFile $path/$user/htpasswd/.htpasswd" >> $path/$user/public_html/submissions/.htaccess
    echo "Require valid-user" >> $path/$user/public_html/submissions/.htaccess
  fi

  #Configure special accounts web permissions
  if [ "$user" == "$marker" ] || [ "$user" == "$instructor" ]; then
    #Add marker password to students htpasswd file
    for i in $(seq -w $minAccount $maxAccount); do
      htpasswd -b $path/$courseShortName$i/htpasswd/.htpasswd $user $pass
    done

    #Create special account .htaccess files
    mkdir -p $path/$user/public_html
    echo "AuthType Basic" > $path/$user/public_html/.htaccess
    echo "AuthName "user"" >> $path/$user/public_html/.htaccess
    echo "AuthUserFile $path/$user/htpasswd/.htpasswd" >> $path/$user/public_html/.htaccess
    echo "Require valid-user" >> $path/$user/public_html/.htaccess
  fi
done < "$courseShortName.usrpasswd"

#Ensure correct file permissions and ownership
for i in $(seq -w $minAccount $maxAccount); do

    user=$courseShortName$i

    #Protect user folders
    chmod 570 $path/$user
    chown -R www-data:$user $path/$user

    #Protect htaccess from user changes
    chmod 550 $path/$user/public_html/submissions/.htaccess
    chown www-data:$user $path/$user/public_html/submissions/.htaccess

    #Protect htpasswd from user changes
    chmod -R 550 $path/$user/htpasswd
    chown -R www-data:$user $path/$user/htpasswd

done

#Make symlinks to students in special accounts
for specialAccount in "$marker" "$instructor"; do
  for i in $(seq -w $minAccount $maxAccount); do
    user=$courseShortName$i
    mkdir -p $path/$specialAccount/public_html/$user

    for j in $(seq -w 00 $numberSubmissions); do
      if [ ! -h $path/$specialAccount/public_html/$user/submission$j ]; then
        ln -s $path/$user/public_html/submissions/submission$j $path/$specialAccount/public_html/$user/submission$j
      fi
    done

  done
done
