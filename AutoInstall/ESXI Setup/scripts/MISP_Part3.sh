#!/bin/bash -x

echo "START SCRIPT 3"

##5 Set permissions
# Check if the permissions are set correctly using the following commands:
sudo chown -R www-data:www-data /var/www/MISP
sudo chmod -R 750 /var/www/MISP
sudo chmod -R g+ws /var/www/MISP/app/tmp
sudo chmod -R g+ws /var/www/MISP/app/files
sudo chmod -R g+ws /var/www/MISP/app/files/scripts/tmp

##6 Create database and user misp.
mysql -u root -p[misp] -e "create database misp; grant usage on *.* to misp@localhost identified by 'misp'; grant all privileges on misp.* to misp@localhost; flush privileges;"

# Import the empty MISP database from MYSQL.sql.
# Usage mysql -u [username] --password=[password] [databasename]
sudo -u www-data sh -c "mysql -u misp --password=misp misp < /var/www/MISP/INSTALL/MYSQL.sql"

##7 Configure apache
sudo cp /var/www/MISP/INSTALL/apache.misp.ubuntu /etc/apache2/sites-available/misp.conf

# Enable modules
sudo a2ensite misp
#sudo a2enmod rewrite

# Restart apache
sudo service apache2 reload

echo "END SCRIPT 3"
