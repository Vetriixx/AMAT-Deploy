#!/bin/bash
#Author: Gareth Clarson - Vetriixx & Tarun Patel
#AutoDeploy Script

#Check if script was run as root
if [ $EUID -ne 0 ]; then
	echo 'This script must be run as root!'
	exit 1
fi

	./packer build -var-file variables.json FameVM.json
	./packer build -var-file variables.json CuckooVM.json
	./packer build -var-file variables.json ViperVM.json
	./packer build -var-file variables.json MastiffVM.json
	./packer build -var-file variables.json MispVM.json
	./packer build -var-file variables.json DionaeaVM.json
	
	#Test vm for testing (obvs)
	#./packer build -var-file variables.json test.json




	#Turns on machine in order (need to alter autovm script to include all vms once all done)
	sshpass -p "JungleButtPirat3s" scp ./autovm_poweron.sh amat@192.168.58.45:~
	sshpass -p "JungleButtPirat3s" ssh -o StrictHostKeyChecking=no amat@192.168.58.45 'sh autovm_poweron.sh'

		
exit 0
