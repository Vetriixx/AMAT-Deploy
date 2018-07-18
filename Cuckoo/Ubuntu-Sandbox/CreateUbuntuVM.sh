#!/bin/bash
# Create a Ubuntu VM from an iso using packer
# The scripts are based on scripts from boxcutter on github
# https://github.com/boxcutter
# Author: samwakel

# Check that we are not running as root (Virtual Box uses different directories as root and the outputted VM has the wrong permissions on the disk file)
if [ $(id -u) -eq 0 ]
	then
	echo "This script cannot be run as root as the output image will have the wrong permissions, and other issues with virtual box."
	exit
fi

# Check for an IP specified as an argument
if [[ $# -ne 1 ]]
	then
	echo "Please specify an IP address for the VM to have."
	echo "Example: 192.168.56.101."
	exit
fi

# Check if Packer exists in the current directory
if [ ! -f packer ]
	then
	wget https://releases.hashicorp.com/packer/1.2.0/packer_1.2.0_linux_amd64.zip
	unzip packer_1.2.0_linux_amd64.zip
	rm packer_1.2.0_linux_amd64.zip	
fi

# unregister the VM, as the .jsons don't unregister to save the disk. This will throw an error if the VM does not exist which is fine for our use case.
vboxmanage unregistervm ubuntu1604-desktop
# Then remove any remaining files from the VM
rm -rf ~/VirtualBox\ VMs/ubuntu1604-desktop
rm -rf output-ubuntu1604-desktop-virtualbox-iso

# Create a network configuraton from a template file
cp scripts/NetworkConfTemplate.sh scripts/NetworkConf.sh
sed -i "s/ip_address/$1/g" scripts/NetworkConf.sh

# Build the VM
./packer build -var-file=ubuntu1604-desktop-sandbox.json ubuntu-sandbox.json

# Remove temporary files
rm scripts/NetworkConf.sh

# Boot the VM
vboxmanage startvm ubuntu1604-desktop --type headless
echo "Waiting 5 minutes for VM to boot, then snapshotting"
sleep 300

# Make a snapshot
echo "Taking snapshot..."
vboxmanage snapshot ubuntu1604-desktop take SnapshotU64

# Power off the virtual machine
echo "Powering off the virtual machine"
vboxmanage controlvm ubuntu1604-desktop poweroff

