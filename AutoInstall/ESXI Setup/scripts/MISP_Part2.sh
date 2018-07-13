#!/bin/bash -x

echo "START SCRIPT 2"

##3 MISP Code
# Download MISP using git in the /var/www/ directory, and change permissions.
sudo mkdir /var/www/MISP
sudo chown www-data:www-data /var/www/MISP
cd /var/www/MISP
sudo -u www-data git clone https://github.com/MISP/MISP.git /var/www/MISP
sudo -u www-data git checkout tags/$(git describe --tags `git rev-list --tags --max-count=1`)

# Make git ignore filesystem permission differences.
sudo -u www-data git config core.filemode false

# Install Mitre's STIX and its dependencies by running the following commands:
sudo apt-get install -y -qq python-dev python-pip libxml2-dev libxslt1-dev zlib1g-dev python-setuptools
cd /var/www/MISP/app/files/scripts
sudo -u www-data git clone https://github.com/CybOXProject/python-cybox.git
sudo -u www-data git clone https://github.com/STIXProject/python-stix.git
cd /var/www/MISP/app/files/scripts/python-cybox
sudo -u www-data git checkout v2.1.0.12
sudo python setup.py install
cd /var/www/MISP/app/files/scripts/python-stix
sudo -u www-data git checkout v1.1.1.4
sudo python setup.py install

# Install mixbox to accomodate the new STIX dependencies:
cd /var/www/MISP/app/files/scripts/
sudo -u www-data git clone https://github.com/CybOXProject/mixbox.git
cd /var/www/MISP/app/files/scripts/mixbox
sudo -u www-data git checkout v1.0.2
sudo python setup.py install

# Install support for STIX 2.0 (Python 3 is required)
sudo pip3 install -q stix2

##4 CakePHP
# CakePHP is included as a submodule of MISP, execute the following commands to let git fetch it:
cd /var/www/MISP
sudo -u www-data git submodule init
sudo -u www-data git submodule update

# Once done, install CakeResque along with its dependencies if you intend to use the built in background jobs:
cd /var/www/MISP/app
sudo -u www-data php composer.phar require kamisama/cake-resque:4.1.2
sudo -u www-data php composer.phar config vendor-dir Vendor
sudo -u www-data php composer.phar install

# Enable CakeResque with php-redis.
sudo phpenmod redis

# To use the scheduler worker for scheduled tasks, do the following:
sudo -u www-data cp -fa /var/www/MISP/INSTALL/setup/config.php /var/www/MISP/app/Plugin/CakeResque/Config/config.php

echo "END SCRIPT 2"
