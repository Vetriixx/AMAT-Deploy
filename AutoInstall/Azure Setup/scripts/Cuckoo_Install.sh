#!/bin/bash
#Author: Gareth Clarson - Vetriixx
#Following the cuckoo documentation

#Automation of cuckoo install
#1. Preparing the hostonly
function dependencies_install
{	
	#Update
	echo -e '\e[35m[+] APT Update \e[0m'
	apt-get update -y >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] APT Update Complete \e[0m" 

	#install python
	echo -e "\e[95m[+] Installing Dependencies....\e[0m" 
	echo -e '\e[93m    [+] 10% Complete... \e[0m'
	sudo apt-get install git mongodb libffi-dev build-essential python-django python python-dev python-pip -y >/dev/null 2>&1
	echo -e '\e[93m    [+] 30% Complete... \e[0m'
	sudo apt-get install python-pil python-sqlalchemy python-bson python-dpkt python-jinja2 python-magic python-pymongo python-gridfs -y >/dev/null 2>&1
	echo -e '\e[93m    [+] 50% Complete... \e[0m'
	sudo apt-get install python-libvirt python-bottle python-pefile python-chardet tcpdump -y >/dev/null 2>&1
	echo -e '\e[93m    [+] 70% Complete... \e[0m'
	apt-get install mongodb python python-dev python-pip python-m2crypto swig -y >/dev/null 2>&1
	echo -e '\e[93m    [+] 90% Complete... \e[0m'
	apt-get install libvirt-dev upx-ucl libssl-dev unzip p7zip-full libgeoip-dev libjpeg-dev -y >/dev/null 2>&1
	echo -e '\e[93m    [+] 100% Complete! \e[0m'
	apt-get install mono-utils ssdeep libfuzzy-dev libimage-exiftool-perl openjdk-8-jre-headless -y >/dev/null 2>&1

	#Additional dependencies for malheur
	apt-get install uthash-dev libtool libconfig-dev libarchive-dev autoconf automake checkinstall -y >/dev/null 2>&1

	#Upgrade pip
	pip install --upgrade pip >/dev/null 2>&1

	#To generate PDF reports
	apt-get install wkhtmltopdf xvfb xfonts-100dpi -y >/dev/null 2>&1

	echo -e "\e[92m[\xE2\x9C\x94] Dependencies Install Complete \e[0m" 

	#Copy default configs
	echo -e '\e[93m    [+] Copy Configuration Files \e[0m'
	 
	 #Configure TCPDump:
	echo -e "\e[95m[+] Configuring TCPDump.... \e[0m" 
	sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Configuration Complete \e[0m" 

	 #Install Yara
	echo -e "\e[95m[+] Installing Yara.... \e[0m" 
	sudo apt-get install autoconf libtool libjansson-dev libmagic-dev libssl-dev -y >/dev/null 2>&1
	wget https://github.com/plusvic/yara/archive/v3.4.0.tar.gz -O yara-3.4.0.tar.gz >/dev/null 2>&1
	tar -zxf yara-3.4.0.tar.gz >/dev/null 2>&1
	cd yara-3.4.0 >/dev/null 2>&1
	./bootstrap.sh >/dev/null 2>&1
	./configure --with-crypto --enable-cuckoo --enable-magic >/dev/null 2>&1
	make >/dev/null 2>&1
	sudo make install >/dev/null 2>&1
	 
	 
	#Build Yara-python ext
	cd yara-python >/dev/null 2>&1
	python setup.py build >/dev/null 2>&1
	sudo python setup.py install >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Install complete \e[0m" 

	 
	#Installing Pydeep
	#"Depends on SSDeep 2.8+"
	echo -e "\e[95m[+] Installing Pydeep.... \e[0m" 
	 wget http://sourceforge.net/projects/ssdeep/files/ssdeep-2.13/ssdeep-2.13.tar.gz/download -O ssdeep-2.13.tar.gz >/dev/null 2>&1
	 tar -zxf ssdeep-2.13.tar.gz >/dev/null 2>&1
	 cd ssdeep-2.13 >/dev/null 2>&1
	 ./configure 2>&1
	 make >/dev/null 2>&1
	 sudo make install >/dev/null 2>&1
	 pip install pydeep >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Install complete \e[0m" 

	 
	#     Installing Volatility
	echo -e "\e[95m[+] Installing Volatility.... \e[0m" 
	 pip install openpyxl >/dev/null 2>&1
	 pip install ujson >/dev/null 2>&1
	 pip install pycrypto >/dev/null 2>&1
	 pip install distorm3 >/dev/null 2>&1
	 pip install pytz >/dev/null 2>&1
	 git clone https://github.com/volatilityfoundation/volatility.git >/dev/null 2>&1
	 cd volatility >/dev/null 2>&1
	 python setup.py build >/dev/null 2>&1
	 python setup.py install >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Install complete \e[0m" 

 }

#install 
function cuckoo_dep_install
{
	sudo pip install requests -y >/dev/null 2>&1
	git clone https://github.com/rthalley/dnspython >/dev/null 2>&1
	cd dnspython/
	python setup.py install -y >/dev/null 2>&1
	sudo pip install dnspython >/dev/null 2>&1

}

function cuckoo_install
{
	cd /home/cuckoo >/dev/null 2>&1
	echo -e "\e[95m[+] Installing Cuckoo Modified.... \e[0m" 
	wget https://github.com/spender-sandbox/cuckoo-modified/archive/master.zip >/dev/null 2>&1
	unzip master.zip >/dev/null 2>&1
	sudo rm master.zip
	sudo chmod -R 757 /home/cuckoo/cuckoo-modified-master
	sudo rm -r /home/cuckoo/cuckoo-modified-master/conf
	sudo rm -r /home/cuckoo/cuckoo-modified-master/utils

	sudo mv -r /home/cuckoo/conf /home/cuckoo/cuckoo-modified-master
	sudo mv -r /home/cuckoo/utils /home/cuckoo/cuckoo-modified-master # conf files
	
	pip install -r /home/cuckoo/cuckoo-modified-master/requirements.txt
	sudo utils/community.py --force --rewrite --all

	apt-get install virtualbox -y >/dev/null 2>&1
	# add a sudo mv -> cuckoomodified
	#Creating a service that binds the vbox ip automatically without having to run vbox first. 
		cat <<EOT >> /home/cuckoo/cuckoo-modified-master/bind_ip.sh
			#!/bin/bash
			VBoxManage hostonlyif create
			VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
EOT

		sudo cat <<EOT >> /etc/systemd/system/vmbind_ip.service

			[Unit]
			Description=Binds the ip 192.168.56.1 for vbox

			[Service]
			Type=simple
			WorkingDirectory=/home/cuckoo/cuckoo-modified-master/
			ExecStart=/bin/bash /home/cuckoo/cuckoo-modified-master/bind_ip.sh
			TimeoutSec=infinity

			[Install]
			WantedBy=multi-user.target
EOT

	sudo chmod 744 /home/cuckoo/cuckoo-modified-master/bind_ip.sh
	sudo chmod 664 /etc/systemd/system/vmbind_ip.service
	sudo systemctl enable vmbind_ip.service
	sudo systemctl start vmbind_ip.service
	echo -e "\e[92m[\xE2\x9C\x94] Install complete \e[0m" 
}

# systemctl status inetsim.service 
# systemctl status vmbind_ip.service 


#If the user wants to install a Windows VM, they must run the below vmcloak script following the below args:
#./VMCloak.sh <VM ID> <VM TYPE> <VM IP> <ISO IMAGE DIRECT PATH>
function vmcloak_install
{
	echo -e "\e[95m[+] Installing VMCloak.... \e[0m" 
	mkdir /home/cuckoo/cuckoo-modified-master/VMCloak
	mkdir /home/cuckoo/cuckoo-modified-master/VMCloak/ISOs
	

	sudo apt install -y -qq virtualbox
	sudo apt-get install -y -qq build-essential libssl-dev libffi-dev
	sudo apt-get install -y -qq python-dev genisoimage
	
	sudo pip install -q vmcloak
	sudo rm /usr/local/lib/python2.7/dist-packages/VMCloak-0.4.5a2-py2.7.egg/vmcloak/data/bootstrap/agent.py
	sudo rm /usr/local/lib/python2.7/dist-packages/VMCloak-0.4.5a2-py2.7.egg/vmcloak/data/bootstrap/agent.py

	sudo rm /usr/local/lib/python2.7/dist-packages/VMCloak-0.4.5a2-py2.7.egg/vmcloak/data/bootstrap/agent.py


	sudo cp /home/cuckoo/cuckoo-modified-master/agent/agent.py /usr/local/lib/python2.7/dist-packages/VMCloak-0.4.5a2-py2.7.egg/vmcloak/data/bootstrap/agent.py
	
	sudo mv /home/cuckoo/VMCloak_Install.sh home/cuckoo/cuckoo-modified-master/VMCloak


	echo -e "\e[92m[\xE2\x9C\x94] VMCloak Install Complete! \e[0m" 
}


function inetsim_install
{
	echo -e "\e[95m[+] Installing Inetsim.... \e[0m" 
	#Made by Yaroslav + intergrated by Vetriixx - Following Inetsim install Procedures

	sudo bash home/cuckoo/inetsimscript.sh

	#Start Inetsim in the background
	sudo cat <<EOT >> /etc/systemd/system/inetsim.service

		[Unit]
		Description=Inetsim Service

		[Service]
		Type=simple
		WorkingDirectory=/home/cuckoo/inetsim-1.2.7
		ExecStart=/bin/bash /home/cuckoo/inetsim-1.2.7/inetsim
		TimeoutSec=infinity

		[Install]
		WantedBy=multi-user.target
EOT
	sudo chmod 744 /home/cuckoo/inetsim-1.2.7/inetsim.sh
	sudo chmod 664 /etc/systemd/system/inetsim.service
	sudo systemctl enable inetsim.service
	sudo systemctl start inetsim.service

	echo -e "\e[92m[\xE2\x9C\x94] Install complete \e[0m" 
}


function startup_script
{

echo -e '\e[35m[+] Creating Startup Script for Cuckoo \e[0m'

	#Install gunicorn
	pip install gunicorn >/dev/null 2>&1

	#Copy default startup script
	if [ "$machine" = 'virtualbox' ]; then
		echo -e '\e[96m    [+] Startup Script Set for VirtualBox \e[0m'
	else
		echo -e '\e[93m    [+] Startup Script Set for KVM \e[0m'
		cp /tmp/kvm-configs/cuckooboot /usr/sbin/cuckooboot
	fi

	chmod +x  /usr/sbin/cuckooboot

	#Modify startup script to fit cuckoo install location
	sed -i -e "s@CUCKOO_PATH="/home/cuckoo"@CUCKOO_PATH="$cuckoo_path/cuckoo"@" /usr/sbin/cuckooboot
	#Add startup crontab entries
	(crontab -l -u cuckoo; echo "46 * * * * /usr/sbin/etupdate")| crontab -u cuckoo -
	(crontab -l -u cuckoo; echo "@reboot /usr/sbin/routetor")| crontab -u cuckoo -
	(crontab -l -u cuckoo; echo "@reboot /usr/sbin/cuckooboot")| crontab -u cuckoo -

echo -e '\e[35m[+] Installation Complete! \e[0m'

}

#Check if script was run as root
if [ $EUID -ne 0 ]; then
	echo 'This script must be run as root!'
	exit 1
fi
	dependencies_install
	cuckoo_dep_install
	cuckoo_install
	vmcloak_install
	inetsim_install

	echo -e '\e[35m[+] Final Installation Complete! \e[0m'


exit 0
