Migrating Moodle to a new VM
============================

Put the site in Maintenance mode via the Site Admin menus.

> Site Administration - Server - Maintenance Mode


Backup the moodle database.

```bash
mysqldump -u root --password=mySecretPassword -C -Q -e --create-options moodle > moodle-database-jan052015.sql
```


Copy the Moodle data files to the new VM.

```
rsync -avzh /srv cssmuadm@192.168.0.1:~
```


Do not forget to reset permissions and ownership on data files and program files.

I simply started with a new copy of the moodle program files and then copied the old config.php into /var/www/moodle
