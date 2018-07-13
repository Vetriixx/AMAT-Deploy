#!/bin/bash

filepath="~/cuckoo-modified/VMCloak"

sudo bash $filepath/VMCloak_Install.sh 764 win7x64 192.168.56.101 $filepath/ISOs/win7x64.iso
#sudo bash /VMCloak_Install.sh 732 win7x86 192.168.56.102 ./ISOs/win7x32.iso
sudo bash $filepath/VMCloak_Install.sh 864 win81x64 192.168.56.103 $filepath/ISOs/win81x64.iso
#sudo bash VMCloak_Install.sh 832 win81x86 192.168.56.104 ./ISOs/win81x32.iso
sudo bash $filepath/VMCloak_Install.sh 1064 win10x64 192.168.56.105 $filepath/ISOs/win10x64.iso 
#sudo bash VMCloak_Install.sh 1031 win10x86 192.168.56.106 ISOs/win10x64.iso 
