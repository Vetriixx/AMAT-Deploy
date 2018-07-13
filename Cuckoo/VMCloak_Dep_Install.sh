#!/bin/bash
# Author: samwakel following the VMCloak documentation
# Installs VMCloak, VirtualBox and their dependencies

# Install Dependencies
echo "Installing VMCloak and it's dependencies"
sudo apt-get install -y -qq virtualbox python-pip build-essential libssl-dev libffi-dev python-dev genisoimage git
sudo -H pip -q install -U pytest pytest-xdist

# Install vmcloak from git because the pip version is outdated
git clone https://github.com/jbremer/vmcloak
cd vmcloak
sudo python setup.py install

# Ensure the hostonly network adapter is up.
vmcloak-vboxnet0
sudo ip link set vboxnet0 up
