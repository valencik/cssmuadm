#!/usr/env/bash -e
#This script installs required software for hosting a Moodle server

apt-get update
apt-get --assume-yes upgrade

#Set local time to Halifax
timedatectl set-timezone America/Halifax

#Install Apache2, PHP5, MySQL if they do not exist
MYSQL_ROOT_PASS="mySecretPassword"
if [ ! -f /etc/apache2/apache2.conf ];
then
  #Install Apache2 and PHP5
  apt-get --assume-yes --quiet install apache2 apache2-utils
  apt-get --assume-yes --quiet install php5 libapache2-mod-php5
  service apache2 restart

  #Enable necessary apache2 mods
  a2enmod php5
fi

#Ensure MySQL is installed
if command -v mysql 1>/dev/null;
then
  echo "MySQL is already installed."
else
  #Load debconf with password to avoid interaction during install
  echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS" | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS" | debconf-set-selections
  
  #Make sure loopback device has IP (needed for mysql install)
  ip addr add 127.0.0.1 dev lo
  
  #Install MySQL
  apt-get --assume-yes --quiet install mysql-server
fi

#Install PHP extensions and drivers require by Moodle
apt-get --assume-yes --quiet install php5-mysql
apt-get --assume-yes --quiet install curl libcurl3 libcurl3-dev php5-curl
apt-get --assume-yes --quiet install php5-gd php5-intl php5-xmlrpc

#Install aspell and grahviz (Moodle needs their path info)
apt-get --assume-yes --quiet install aspell
apt-get --assume-yes --quiet install graphviz

#Install git so we can clone Moodle from repo
apt-get --assume-yes install git

#Install Moodle from git repo
if [ ! -d /var/www/moodle ];
then
  moodleAdminPass=topSecretMoodleAdminPassword123

  mkdir -p /var/www/moodle
  #Clone the latest commit on the stable branch only
  git clone --depth=1 -b MOODLE_29_STABLE --single-branch git://git.moodle.org/moodle.git /var/www/moodle
  
  #Create Moodle Data
  mkdir -p /srv/moodledata
  chmod 0770 /srv/moodledata
  chown www-data:www-data /srv/moodledata

  #Create Moodle database
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="CREATE DATABASE moodle DEFAULT CHARACTER SET UTF8 COLLATE utf8_unicode_ci;"
  mysql --user="root" --password="$MYSQL_ROOT_PASS" \
    --execute="GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,CREATE TEMPORARY TABLES,DROP,INDEX,ALTER ON moodle.* TO moodleuser@localhost IDENTIFIED BY 'changethismoodlepassword57i9n890fh4l82';"

  #Install Moodle
  chown -R www-data /var/www/moodle
  sudo -u www-data /usr/bin/php /var/www/moodle/admin/cli/install.php      \
  --lang=en --wwwroot=http://moodle.cs.smu.ca --dataroot=/srv/moodledata   \
  --dbtype=mysqli --adminpass=$moodleAdminPass --chmod=0770                \
  --dbpass=$MYSQL_ROOT_PASS --fullname="CS Moodle" --shortname="Moodle"    \
  --agree-license --non-interactive
  
  #Secure Moodle files
  chown -R root /var/www/moodle
  chmod -R 0755 /var/www/moodle
  find /var/www/moodle -type f -exec chmod 0644 {} \;

  #Enable Moodle site in Apache2
  if [ -h /etc/apache2/site-enabled/Moodle.conf ];
  then
    echo "Moodle site already enabled in Apache2"
  else
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/Moodle.conf
    sed -i '/<VirtualHost \*:80>/,/<\/VirtualHost>/s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/moodle/' \
    /etc/apache2/sites-available/Moodle.conf
    rm /etc/apache2/sites-enabled/000-default.conf
    ln -s /etc/apache2/sites-available/Moodle.conf /etc/apache2/sites-enabled/Moodle.conf
    service apache2 restart
  fi

  #Increase PHP upload limits
  sed -i 's/upload_max_filesize = .*M/upload_max_filesize = 1024M/' /etc/php5/apache2/php.ini
  sed -i 's/post_max_size = .*M/post_max_size = 1024M/' /etc/php5/apache2/php.ini
  sed -i 's/emory_limit = .*M/emory_limit = 1200M/' /etc/php5/apache2/php.ini

  #Setup cron job to run every minute
  crontab -l 2>/dev/null > tempCron
  if [ grep moodle/admin/cli/cron.php tempCron ];
  then
    echo "Moodle cron job already exists"
  else
    echo "Adding Moodle's cron.php to cron job set for every minute."
    echo "* * * * *    /usr/bin/php /var/www/moodle/admin/cli/cron.php >/dev/null" >> tempCron
    crontab tempCron
  fi
  rm tempCron

fi
