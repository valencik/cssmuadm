This guide (a work in progress) will outline the procedures for setting up
the csc355 course acounts, files, and databases.

1. Archive last year’s accounts (if there’s space somewhere).
2. Don’t bother to archive last year’s databases.
3. Clear out the old accounts and databases (except for 00, 49 and 50).
4. Set new passwords on accounts 01 to 48, avoiding (as usual) any troublesome characters.

Remember that the same password has to go in three places:
- account
- database
- website

5. 00 and 50 must have read access to the other accounts.
6. All accounts must run csc35500/public/355_bashrc upon login.
7. Every account must have the public_html and htpasswd directories set up.
8. Run script to add csc35550’s htaccess to all accounts.
9. Set up schedule file and crontab to lock/unlock directories.
10. Check scripts for local/global lock/unlock.

Scripts run so far:
1. endofyear-destroy.sh
2. rebuild-from-skel.sh
3. generate-user-pass-file.sh
4. generate-shadow-file.sh csc355users.pass
5. cat csc355users.shadow >> /etc/shadow
6. make-sql-databases-script.sh csc355users.pass
7. mysql -u root -p < csc355users.sql


#New portitions

Student home folders are owned by www-data with group owner as the student.
This is recursively set on the whole home directory with two exceptions:
- ~/htpasswd has file permissions 550
- ~/public_html/submissions/.htaccess has file permissions 550

# TODO
- create the 01..12 directories in public_html for student work directories
- php script needs to include database configuration, make user root dir called **dbinclude**
