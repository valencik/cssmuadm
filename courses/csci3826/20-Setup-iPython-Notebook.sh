#!/usr/bin/env bash
set -e

#This script sets up ipython notebook profiles and certs for users
#It requires a $courseShortName.usrpasswd file exist in current directory

#Configuration
courseShortName=cs3826
path=/home/course/$courseShortName
mkdir -p $path
minAccount=00
maxAccount=50
instructor=$courseShortName"00"
marker=$courseShortName"50"

#TODO echo configuration data

#Ensure we have a password file (created from previous script)
if [ ! -f ./$courseShortName.usrpasswd ];
then
  echo "No $courseShortName.usrpasswd file found."
  exit
fi

#Create .htaccess and .htpasswd for each user
while IFS=: read -r user pass;
do
  #Create notebooks dir
  mkdir -p $path/$user/notebooks
  chown $user:$user $path/$user/notebooks

  #Create ipython profile
  sudo su $user -c "ipython profile create"

  #Modify default ipython notebook file
  iprofile=$path/$user/.ipython/profile_default/ipython_notebook_config.py
  echo "# Configuration file for ipython-notebook." > $iprofile
  echo "c = get_config()" >> $iprofile
  echo "c.IPKernelApp.pylab = 'inline'  # if you want plotting support always" >> $iprofile
  echo "" >> $iprofile

  echo "# Notebook Config" >> $iprofile
  echo "c.NotebookApp.certfile = u'$path/$user/.ipython/myCert.pem'" >> $iprofile
  echo "c.NotebookApp.ip = '140.184.193.155'" >> $iprofile
  echo "c.NotebookApp.open_browser = False" >> $iprofile

  #Set ipython notebook password the same as user password
  echo "c.NotebookApp.password = u'$(python ipython_passwd.py $pass)'" >> $iprofile

  #Fix ipython notebook port (this is really hacky)
  echo "# It is a good idea to put it on a known, fixed port" >> $iprofile
  echo "c.NotebookApp.port = 89$(echo $user | cut -c 7-)" >> $iprofile

  #Create self-signed certificate so we can use https
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout $path/$user/.ipython/myCert.pem -out $path/$user/.ipython/myCert.pem \
    -subj "/C=CA/ST=Nova Scotia/L=Halifax/O=Saint Marys University/OU=CSCI 3826/CN=cs.smu.ca"

done < "$courseShortName.usrpasswd"
