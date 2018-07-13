#!/bin/bash -x

echo "START SCRIPT 1"

##1 Configure the minimal Ubuntu install.
# Install OpenSSH as required by the documentation.
sudo apt-get install -y -qq openssh-server

# Update the operating system.
sudo apt-get update -y -qq
sudo apt-get upgrade -y -qq

# Install postfix with the config set to: "Satellite system".
sudo debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Satellite system'"
sudo apt-get install -y -qq postfix
sudo postconf -e 'relayhost = example.com'
sudo postfix reload

##2 Install LAMP & dependencies.
# Installing dependencies.
sudo apt-get install -y -qq curl gcc git gnupg-agent make python openssl redis-server sudo vim zip

# Stop mysql.
sudo service mysql stop

# Installing MariaDB has questions, automating the process.
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password password misp"
sudo debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password misp"
sudo apt-get install -y -qq mariadb-client mariadb-server

# Secure the install, use aptitude's expect to run the install unattended.
sudo apt install -y -qq aptitude
sudo aptitude -y install expect
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"$MYSQL\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")
echo "$SECURE_MYSQL"

# Install Apache2.
sudo apt-get install -y -qq apache2 apache2-doc apache2-utils

# Enable modules, settings, but do not configure SSL.
sudo a2dismod status
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2dissite 000-default

# Install PHP and dependencies.
sudo apt-get install -y -qq libapache2-mod-php php php-cli php-crypt-gpg php-dev php-json php-mysql php-opcache php-readline php-redis php-xml

# Apply all changes.
sudo systemctl restart apache2

echo "END SCRIPT 1"
