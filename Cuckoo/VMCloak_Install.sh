
#If the user wants to install a Windows VM, they must run the below vmcloak script following the below args:
#sudo ./VMCloak_Install.sh <VM ID> <VM TYPE> <VM IP> <ISO IMAGE DIRECT PATH>

# This script will attempt to create a Windows 7 VM with specific parameters. The VM will have some dependencies installed to it.
# Written by samwakel following VMCloak install docs.

# Check that the script was executed with sudo
if [ $(id -u) -ne 0 ]
	then
	echo "This script must be run as root to mount the installer image. Are you using sudo?"
	exit
fi

# Check that the correct amount of arguments exist
if [ $# -ne 4 ]
	then #print usage instructions
	echo "Usage: sudo ./VMCloak_Install.sh <VM ID> <VM TYPE> <VM IP> <ISO IMAGE>"
	echo "All parameters are required."
	echo
	echo "VM ID is a unique number for each VM. Re-using existing will create an error upon creation, then attempt to re-install the dependencies to the existing machine, which usually hangs the VM. Maybe use a for loop?"
	echo "Possible VM types: win7x86 win7x64. Errors will be thrown if this is incorrect."
	echo "VM IP, the IP entered here will be the IP the VM uses."
	echo "ISO IMAGE, path to the .iso image that will be used for installing the VM's OS. This ISO is not automatically downloaded, it must be provided."
	echo
	echo "Please be patient, the VM will reboot multiple times while being created."
	exit
fi

# Ensure the host-only network is up
vmcloak-vboxnet0

# Mount the Windows installer ISO for the VM to access on install, then install the OS.

# WINDOWS 7
if [ $2 = "win7x64" ]
	then
	echo "Mounting the ISO installer for 64bit Windows 7"
	sudo mkdir -p /mnt/win7x64
	sudo mount -o loop,ro $4 /mnt/win7x64

	echo "Creating the VM and installing 64bit Windows 7"
	vmcloak init --$2 seven$1 --ip $3

	echo "Unmounting the installer ISO for 64bit Windows 7"
	sudo umount /mnt/win7x64
fi
if [ $2 = "win7x86" ]
	then
	echo "Mounting the ISO installer for 32bit Windows 7"
	sudo mkdir -p /mnt/win7x86
	sudo mount -o loop,ro $4 /mnt/win7x86

	echo "Creating the VM and installing 32bit Windows 7"
	vmcloak init --$2 seven$1 --ip $3

	echo "Unmounting the installer ISO for 32bit Windows 7"
	sudo umount /mnt/win7x86
fi

# WINDOWS 8.1
if [ $2 = "win81x64" ]
	then
	echo "Mounting the ISO installer for 64bit Windows 8.1"
	sudo mkdir -p /mnt/win81x64
	sudo mount -o loop,ro $4 /mnt/win81x64

	echo "Creating the VM and installing 64bit Windows 8.1"
	vmcloak init --$2 eight$1 --ip $3

	echo "Unmounting the installer ISO for 64bit Windows 8.1"
	sudo umount /mnt/win81x64
fi
if [ $2 = "win81x86" ]
	then
	echo "Mounting the ISO installer for 32bit Windows 8.1"
	sudo mkdir -p /mnt/win81x86
	sudo mount -o loop,ro $4 /mnt/win81x86

	echo "Creating the VM and installing 32bit Windows 8.1"
	vmcloak init --$2 eight$1 --ip $3

	echo "Unmounting the installer ISO for 32bit Windows 8.1"
	sudo umount /mnt/win81x86
fi

# WINDOWS 10
if [ $2 = "win10x64" ]
	then
	echo "Mounting the ISO installer for 64bit Windows 10"
	sudo mkdir -p /mnt/win10x64
	sudo mount -o loop,ro $4 /mnt/win10x64

	echo "Creating the VM and installing 64bit Windows 10"
	vmcloak init --$2 ten$1 --ip $3

	echo "Unmounting the installer ISO for 64bit Windows 10"
	sudo umount /mnt/win10x64
fi
if [ $2 = "win10x86" ]
	then
	echo "Mounting the ISO installer for 32bit Windows 10"
	sudo mkdir -p /mnt/win10x86
	sudo mount -o loop,ro $4 /mnt/win10x86

	echo "Creating the VM and installing 32bit Windows 10"
	vmcloak init --$2 ten$1 --ip $3

	echo "Unmounting the installer ISO for 32bit Windows 10"
	sudo umount /mnt/win10x86
fi

# Install the dependencies to the VM.
# WINDOWS 7 - Some dependencies differ between 32bit and 64bit
if [ $2 = "win7x64" ]
	then
	echo "Installing dependencies for 64bit Windows 7"
	vmcloak install seven$1 adobe9 wic pillow:3.4.2 dotnet40 java7 chrome ie11 firefox:41.0.2 flash cuteftp removetooltips silverlight vcredist winrar:5.40 kb:2729094 kb:2731771 kb:2670838 kb:2786081 kb:2639308 kb:2834140 kb:2882822 kb:2888049 kb:2819745 kb:3109118 kb:2533623 modified #sysmon
	echo "Creating snapshot of 64bit Windows 7. The snapshot will be entitled: Snapshot$1"
	vmcloak snapshot seven$1 Snapshot$1 $3
	echo "Finished creating and configuring 64bit Windows 7"
fi
if [ $2 = "win7x86" ]
	then
	echo "Installing dependencies for 32bit Windows 7"
	vmcloak install seven$1 adobe9 wic pillow:3.4.2 dotnet40 java7 chrome ie11 firefox:41.0.2 flash cuteftp removetooltips silverlight vcredist winrar:5.40 kb:2729094 kb:2731771 kb:2670838 kb:2786081 kb:2639308 kb:2834140 kb:2882822 kb:2888049 kb:2533623 modified #kb:2819745 kb:3109118 sysmon
	echo "Creating snapshot of 32bit Windows 7. The snapshot will be entitled: Snapshot$1"
	vmcloak snapshot seven$1 Snapshot$1 $3
	echo "Finished creating and configuring 32bit Windows 7"
fi

# WINDOWS 8 - Same dependencies for 32bit and 64bit
if [ $2 = "win81x64" -o $2 = "win81x86" ]
	then
	echo "Installing dependencies for Windows 8.1"
	vmcloak install eight$1 adobe9 wic pillow:3.4.2 dotnet40 java7 chrome firefox:41.0.2 flash cuteftp removetooltips silverlight vcredist winrar:5.40 modified #sysmon
	echo "Creating snapshot of Windows 8.1. The snapshot will be entitled: Snapshot$1"
	vmcloak snapshot eight$1 Snapshot$1 $3
	echo "Finished creating and configuring Windows 8.1"
fi

# WINDOWS 10 - Same dependencies for 32bit and 64bit
if [ $2 = "win10x64" -o $2 = "win10x86" ]
	then
	echo "Installing dependencies for Windows 10"
	vmcloak install ten$1 adobe9 wic pillow:3.4.2 dotnet40 java7 chrome firefox:41.0.2 flash cuteftp removetooltips silverlight vcredist winrar:5.40 modified #sysmon
	echo "Creating snapshot of Windows 10. The snapshot will be entitled: Snapshot$1"
	vmcloak snapshot ten$1 Snapshot$1 $3
	echo "Finished creating and configuring Windows 10"
fi
