#!/bin/bash -x
# Author: samwakel
#
# These scripts will install and configure MISP on a fresh install of Ubuntu Server 16.04.
# The scripts will also update the operating system after installing OpenSSH Server.
# OpenSSH-server is listed as a base requirement on the MISP documentation.
#
# The commands in these scripts are based upon the MISP install documentation for 16.04 and 14.04
# The numbered steps are based upon the original steps of install.
# https://github.com/MISP/MISP/blob/2.4/INSTALL/INSTALL.ubuntu1604.txt
# Some commands have been altered for automation purposes.
# All dependencies required by these scripts are installed automatically.
#
# These scripts must be run as root.
#
# There is no exception handling.

# Install haveged to generate random numbers to speed up the GPG creation process.
sudo apt-get install -y -qq haveged

# Generate a GPG encryption key. We're doing this last in case it takes a very long time and does not finish in an acceptable time frame.
# MISP seems to run correctly without it, but the docs suggest that it is required for something.
sudo -u www-data mkdir /var/www/MISP/.gnupg
# Don't change the timeout because if it times out then it will not output the gpg key.
echo "Generating GPG key, this can take anywhere between a few seconds to multiple days."
GPG_KEY=$(expect -c "
set timeout 10
spawn sudo -u www-data gpg --homedir /var/www/MISP/.gnupg --gen-key
expect \"Your selection?\"
send \"\r\"
expect \"What keysize do you want? (2048)\"
send \"\r\"
expect \"Key is valid for? (0)\"
send \"\r\"
expect \"Is this correct? (y/N)\"
send \"y\r\"
expect \"Real name:\"
send \"ubuntumisp\r\"
expect timeout
send  \"\r\"
expect \"Comment:\"
send \"\r\"
expect timeout
send \"o\r\"
expect \"Enter passphrase:\"
send \"\r\"
expect \"Repeat passphrase:\"
send \"\r\"
set timeout -1
expect eof
")
sudo haveged -n 1.5G -f /dev/null & echo "$GPG_KEY$"

# And export the public key to the webroot.
echo "exporting GPG key"
echo "misp" | sudo -S sh -c "gpg --homedir /var/www/MISP/.gnupg --export --yes > /var/www/MISP/app/webroot/gpg.asc"
echo "finished exporting GPG key"
exit
