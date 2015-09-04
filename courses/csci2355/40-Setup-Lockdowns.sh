#!/usr/bin/env bash
set -e

#This script creates the cron job to lockdown student submission files.
#It requires a $courseShortName.usrpasswd file exist in current directory

#Configuration
courseShortName=csc355
path=/home/course/$courseShortName
minAccount=01
maxAccount=49
instructor=$courseShortName"00"
marker=$courseShortName"50"
numberSubmissions=12
lockdownSchedule=$path/lockdown/lockdownSchedule

#TODO echo configuration data

#Copy lockdown scripts to course lockdown folder
mkdir -p $path/lockdown
cp lockdown/lockdown.sh $path/lockdown/
cp lockdown/lockdownSchedule $lockdownSchedule
chown $instructor:$instructor $path/lockdown/*

#Ensure lockdown cronjob exists
crontab -u $instructor -l | grep -F \
    "59 23 * * Sun sudo $path/lockdown/lockdown.sh $lockdownSchedule"
grepReturn=$?
if [ $grepReturn -eq 0 ]
then
    echo "Cronjob exists"
else
    echo "Creating lockdown cronjob!"
    crontab -u $instructor -l > tmpCrontab.log
    echo "59 23 * * Sun sudo $path/lockdown/lockdown.sh $lockdownSchedule" >> tmpCrontab.log
    crontab -u $instructor tmpCrontab.log
fi

#Add lockdown script exceptions to sudoers list for csc35500
if [ -f /etc/sudoers.d/csc355.conf ]
then
    echo "CSC355 sudoers exception exists"
else
    echo "Creating sudoers exception!"
    echo "Cmnd_Alias  LOCKDOWN355=$path/lockdown/lockdown.sh, $path/lockdown/unlock.sh, $path/lockdown/lock.sh" >> /etc/sudoers.d/csc355
    echo "csc35500 ALL = (root) NOPASSWD: LOCKDOWN355" >> /etc/sudoers.d/csc355
fi
