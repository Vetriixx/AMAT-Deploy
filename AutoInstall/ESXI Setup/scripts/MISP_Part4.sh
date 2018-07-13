#!/bin/bash -x

echo "START SCRIPT 4"

##8 Rotate logs
# MISP saves the stdout and stderr of its workers in /var/www/MISP/app/tmp/logs
# To rotate these logs install the supplied logrotate script:
echo "Configuring log rotation"
sudo cp /var/www/MISP/INSTALL/misp.logrotate /etc/logrotate.d/misp

##9 configure MISP
# There are 4 sample configuration files in /var/www/MISP/app/Config that need to be copied
sudo -u www-data cp -a /var/www/MISP/app/Config/bootstrap.default.php /var/www/MISP/app/Config/bootstrap.php
sudo -u www-data cp -a /var/www/MISP/app/Config/database.default.php /var/www/MISP/app/Config/database.php
sudo -u www-data cp -a /var/www/MISP/app/Config/core.default.php /var/www/MISP/app/Config/core.php
sudo -u www-data cp -a /var/www/MISP/app/Config/config.default.php /var/www/MISP/app/Config/config.php

# Configure the fields in the newly created files. Using sed for automation.
echo "Configuring the database"
sudo sed -i 's/db login/misp/g' /var/www/MISP/app/Config/database.php
sudo sed -i 's/db password/misp/g' /var/www/MISP/app/Config/database.php

# Make sure the file permissions are still OK
echo "Checking permissions are OK"
sudo chown -R www-data:www-data /var/www/MISP/app/Config
sudo chmod -R 750 /var/www/MISP/app/Config

# We sometimes get permission errors with the MISP folder in /var/www/MISP. Let's fix that just in case.
sudo chmod -R 777 /var/www/MISP

# Make the background workers start on boot.
sudo chmod +x /var/www/MISP/app/Console/worker/start.sh
sudo ex -sc '13i|sudo -u www-data bash /var/www/MISP/app/Console/worker/start.sh' -cx /etc/rc.local
# And manually start the workers right now
#sudo -u www-data bash /var/www/MISP/app/Console/worker/start.sh

# Restart apache2 for the final time.
sudo service apache2 reload
sudo service apache2 restart

echo "END SCRIPT 4"
