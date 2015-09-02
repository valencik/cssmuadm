#!/usr/bin/env bash
set -e

# This script locks student submission directories based on an input schedule file

schedule=$1

if [ $# != 1 ]; then
    echo "Usage: This program takes 1 argument, the path to the schedule file."
    echo "./$0 <schedule-file>"
    exit 1;
fi

if [ ! -r "$schedule" ]; then
    echo "ERROR: Unable to read schedule, $schedule"
    exit 1;
fi

# Check if the current date is in the schedule file
currentDate=$(date +%F)
line=$(grep "$currentDate" "$schedule")

if [ -z "$line" ]; then
    echo "ERROR: Current date does not match any date in $schedule"
    exit 1;
fi

week=$(echo "$line"|sed s/^.*://)
echo "Locking down week $week ..."

# Remove student permissions from submission directory
for i in $(seq -w 1 49); do
    submission=/home/course/csc355/csc355"$i"/public_html/submissions/submission"$week"
    chown csc355admin:www-data "$submission"
    chmod 550 "$submission"
done
