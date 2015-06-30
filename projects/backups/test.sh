#!/bin/sh
hostname=$1
echo "This is for testing only! It will delete ALL rsync tasks, users and groups."
echo "You've been warned."
echo -n "Do you want to continue y[n]: "
read answer
if [ $answer='y' ]; then
echo "You are brave... let's continue!"
# Delete all rsync tasks, users and groups
python3 py_freeNAS.py -H ${hostname} -co config_rsync_tasks.yml -dat t -dau t -dag t

# Test creating, updating and deleting [at the end there will be one rsync task, one user, and one group]
python3 py_freeNAS.py -H ${hostname} -co config_rsync_tasks.yml -c t -up t -d t
python3 py_freeNAS.py -H ${hostname} -co config_users.yml -c t -up t -d t
python3 py_freeNAS.py -H ${hostname} -co config_groups.yml -c t -up t -d t

fi