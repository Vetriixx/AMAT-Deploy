#!/bin/bash
#Author: Gareth Clarson - Vetriixx
#Following the cuckoo documentation

#Automation of cuckoo install


#Preparing the hostonly
function update
{
	echo -e '\e[95m[+] APT Update \e[0m'
	apt-get update -y >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] APT Update complete!\e[0m"
}

function dependencies
{	
	#install python
	echo -e "\e[95m[+] Installing Dependencies....\e[0m" 
	echo -e "\e[95m[+] Installing the Python and MongoDB libraries....\e[0m" 
	sudo apt-get install git mongodb libffi-dev build-essential python-django python python-dev python-pip -y >/dev/null 2>&1
	sudo apt-get install python-pil python-sqlalchemy python-bson python-dpkt python-jinja2 python-magic python-pymongo python-gridfs -y >/dev/null 2>&1
	sudo apt-get install python-libvirt python-bottle python-pefile python-chardet tcpdump -y >/dev/null 2>&1
	apt-get install mongodb python python-dev python-pip python-m2crypto swig -y >/dev/null 2>&1
	apt-get install libvirt-dev upx-ucl libssl-dev unzip p7zip-full libgeoip-dev libjpeg-dev -y >/dev/null 2>&1
	apt-get install mono-utils ssdeep libfuzzy-dev libimage-exiftool-perl openjdk-8-jre-headless -y >/dev/null 2>&1

	#Additional dependencies for malheur
	apt-get install uthash-dev libtool libconfig-dev libarchive-dev autoconf automake checkinstall -y >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Installing the Python and MongoDB libraries Completed! \e[0m" 


	#Upgrade pip
	echo -e "\e[95m[+] Upgrading PIP....\e[0m" 
	pip install --upgrade pip >/dev/null 2>&1
	pip install distorm3 >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Upgrade Complete! \e[0m" 

	#To generate PDF reports
	apt-get install wkhtmltopdf xvfb xfonts-100dpi -y >/dev/null 2>&1

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
	echo -e "\e[92m[\xE2\x9C\x94] Yara Install Complete! \e[0m" 

	 
	#Installing Pydeep
	#"Depends on SSDeep 2.8+"
	echo -e "\e[95m[+] Installing Pydeep.... \e[0m" 
	 wget http://sourceforge.net/projects/ssdeep/files/ssdeep-2.13/ssdeep-2.13.tar.gz/download -O ssdeep-2.13.tar.gz >/dev/null 2>&1
	 tar -zxf ssdeep-2.13.tar.gz >/dev/null 2>&1
	 cd ssdeep-2.13 >/dev/null 2>&1
	 ./configure >/dev/null 2>&1
	 make >/dev/null 2>&1
	 sudo make install >/dev/null 2>&1
	 pip install pydeep >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Pydeep Install complete!\e[0m" 

	 
	#Installing Volatility
	echo -e "\e[95m[+] Installing Volatility.... \e[0m" 
	 sudo pip install openpyxl >/dev/null 2>&1
	 sudo pip install ujson >/dev/null 2>&1
	 sudo pip install pycrypto >/dev/null 2>&1
	 sudo pip install distorm3 >/dev/null 2>&1
	 sudo pip install pytz >/dev/null 2>&1
	 git clone https://github.com/volatilityfoundation/volatility.git >/dev/null 2>&1
	 cd volatility >/dev/null 2>&1
	 python setup.py build >/dev/null 2>&1
	 python setup.py install >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] Volatility Install complete!\e[0m" 


	#Installing dnspython
	echo -e "\e[95m[+] Installing dnspythong.... \e[0m"
	 sudo pip install requests -y >/dev/null 2>&1
	 git clone https://github.com/rthalley/dnspython >/dev/null 2>&1
	 cd dnspython/
	 python setup.py install -y >/dev/null 2>&1
	 sudo pip install dnspython >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] dnspython Install complete!\e[0m" 

	#Installing Virtualbox
	echo -e "\e[95m[+] Installing Virtualbox.... \e[0m"
     apt-get install virtualbox -y >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] virtualbox Install complete! \e[0m" 

	echo -e "\e[92m[\xE2\x9C\x94] Dependencies Install Complete! \e[0m" 
 }


function config
{
	echo -e '\e[95m[+] Copy Configuration Files \e[0m'
	 source /tmp/Network.conf
	 cat /etc/network/interfaces | sudo sed -i s/dhcp/static/ > sudo /etc/network/interfaces; echo -e "     address $cuck_address\n     netmask $cuck_netmask\n     network $cuck_network\n     broadcast $cuck_broadcast\n     gateway $cuck_gateway\n     dns-nameservers $cuck_dns" | sudo tee -a /etc/network/interfaces
	echo -e "\e[92m[\xE2\x9C\x94] Copy complete!\e[0m"

	#Configure TCPDump:
	echo -e "\e[95m[+] Configuring TCPDump.... \e[0m" 
	 sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump >/dev/null 2>&1
	echo -e "\e[92m[\xE2\x9C\x94] TCPDump Configured! \e[0m"

}


function cuckoo
{
	echo -e "\e[95m[+] Installing Cuckoo Modified.... \e[0m"
	cd ~
	
	#downloading git
	wget https://github.com/spender-sandbox/cuckoo-modified/archive/master.zip >/dev/null 2>&1
	unzip master.zip >/dev/null 2>&1
	rm master.zip
	
	#renaming
	mv ~/cuckoo-modified-master ~/cuckoo-modified

	#changing the permissions
	sudo chmod -R 757 ~/cuckoo-modified

	#removing old configs
	sudo rm -r ~/cuckoo-modified/conf
	sudo rm -r ~/cuckoo-modified/utils

	#moving premade configs
	sudo mv ~/conf/ ~/cuckoo-modified
	sudo mv ~/utils/ ~/cuckoo-modified
	sudo mv ~/linux/ ~/cuckoo-modified/analyzer
	sudo chmod -R 757 ~/cuckoo-modified


	#editing exsisting configs
	sed -i "190s/(self.target)/(self.target.replace(\"'\",\"\"))/" ~/cuckoo-modified/analyzer/linux/analyzer.py
	sed -i "305s/if/elif/" ~/cuckoo-modified/modules/processing/network.py
	sed -i "322s/^query[\"type\"] = \"SRV\"/else: \
	query[\"type\"] = \"None\"/" ~/cuckoo-modified/modules/processing/network.py
	
	sed -i "11s/8000/8001/" ~/cuckoo-modified/lib/cuckoo/common/constants.py
	sed -i "1178s/8000/8001/" ~/cuckoo-modified/analyzer/windows/analyzer.py

	source /tmp/Network.conf
	echo -e "address $cuck_address\n" | sudo sed -i "512s/192.168.56.121/$cuck_address/" ~/cuckoo-modified/utils/api.py


	#installing requirements.txt
	sudo pip install -r ~/cuckoo-modified/requirements.txt >/dev/null 2>&1
	
	sudo python ~/cuckoo-modified/utils/community.py --force --rewrite --all >/dev/null 2>&1

	echo -e "\e[92m[\xE2\x9C\x94] Cuckoo Install Completed! \e[0m"

}



function bind_ip
{
	echo -e "\e[95m[+] Creating a service that binds the vbox ip automatically without having to run vbox first... \e[0m"  
	cat <<EOT >> /home/cuckoo/cuckoo-modified/bind_ip.sh
		#!/bin/bash
		VBoxManage hostonlyif create
		VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
EOT

	sudo cat <<EOT >> /etc/systemd/system/vmbind_ip.service

		[Unit]
		Description=Binds the ip 192.168.56.1 for vbox

		[Service]
		Type=simple
		WorkingDirectory=/home/cuckoo/cuckoo-modified/
		ExecStart=/bin/bash /home/cuckoo/cuckoo-modified/bind_ip.sh
		TimeoutSec=infinity

		[Install]
		WantedBy=multi-user.target
EOT

	sudo chmod 744 /home/cuckoo/cuckoo-modified/bind_ip.sh >/dev/null 2>&1
	sudo chmod 664 /etc/systemd/system/vmbind_ip.service >/dev/null 2>&1

	sudo systemctl enable vmbind_ip.service >/dev/null 2>&1
	sudo systemctl start vmbind_ip.service >/dev/null 2>&1
	
	echo -e '\e[92m[\xE2\x9C\x94] Bind Complete! \e[0m'
}



function vmcloak
{
	echo -e "\e[35m[+] Installing VMCloak.... \e[0m" 
	mkdir ~/cuckoo-modified/VMCloak
	mkdir ~/cuckoo-modified/VMCloak/ISOs
	
	sudo mv ~/InstallMultipleVMs.sh ~/cuckoo-modified/VMCloak
	sudo mv ~/VMCloak_Dep_Install.sh ~/cuckoo-modified/VMCloak
	sudo mv ~/VMCloak_Install.sh ~/cuckoo-modified/VMCloak

	sudo bash ~/cuckoo-modified/VMCloak/VMCloak_Dep_Install.sh

	sudo bash ~/cuckoo-modified/VMCloak/InstallMultipleVMs.sh

	sudo rm /usr/local/lib/python2.7/dist-packages/VMCloak-0.4.5-py2.7.egg/vmcloak/data/win10/autounattend.xml
	sudo mv ~/autounattend.xml /usr/local/lib/python2.7/dist-packages/VMCloak-0.4.5-py2.7.egg/vmcloak/data/win10/


	echo -e "\e[92m[\xE2\x9C\x94] VMCloak Install Complete! \e[0m" 
}


function inetsim
{
	echo -e "\e[95m[+] Installing Inetsim.... \e[0m" 
	#Made by Yaroslav + intergrated by Vetriixx - Following Inetsim install Procedures

	sudo bash ~/inetsimscript.sh >/dev/null 2>&1

	#Start Inetsim in the background
	sudo cat <<EOT >> /etc/systemd/system/inetsim.service

	[Unit]
	Description=Inetsim Service

	[Service]
	Type=simple
	WorkingDirectory=/home/cuckoo/inetsim-1.2.7
	ExecStart=/home/cuckoo/inetsim-1.2.7/inetsim
	TimeoutSec=infinity
	StandardOutput=tty
	Restart=on-failure

	[Install]
	WantedBy=multi-user.target
EOT
	sudo chmod 744 ~/inetsim-1.2.7/inetsim >/dev/null 2>&1
	sudo chmod 664 /etc/systemd/system/inetsim.service >/dev/null 2>&1
	sudo systemctl enable inetsim.service >/dev/null 2>&1
	sudo systemctl start inetsim.service >/dev/null 2>&1

	echo -e "\e[92m[\xE2\x9C\x94] Install complete!\e[0m" 
}


function cuckooService
{

	echo -e "\e[95m[+] Creating a Cuckoo service.... \e[0m" 
	sudo cat <<EOT >> /etc/systemd/system/cuckoo.service

    [Unit]
    Description=Run cuckoo.py in the background as a Service

    [Service]
    Type=simple
    WorkingDirectory=/home/cuckoo/cuckoo-modified/
    ExecStart=/home/cuckoo/cuckoo-modified/cuckoo.py
    TimeoutSec=infinity


	[Install]
    WantedBy=multi-user.target

EOT
	sudo chmod 744 ~/cuckoo-modified/cuckoo.py >/dev/null 2>&1
	sudo chmod 664 /etc/systemd/system/cuckoo.service >/dev/null 2>&1
	sudo systemctl enable cuckoo.service >/dev/null 2>&1
	sudo systemctl start cuckoo.service >/dev/null 2>&1

	echo -e "\e[92m[\xE2\x9C\x94] Service Configuration Complete!\e[0m" 
}


function cuckooAPIService
{

	echo -e "\e[95m[+] Creating a CuckooAPI service.... \e[0m" 
	sudo cat <<EOT >> /etc/systemd/system/cuckooAPI.service

	[Unit]
	Description=Run API.py in the background as a Service

	[Service]
	Type=simple
	WorkingDirectory=/home/cuckoo/cuckoo-modified/utils
	ExecStart=/home/cuckoo/cuckoo-modified/utils/api.py
	TimeoutSec=infinity
	StandardOutput=tty
	Restart=on-failure

	[Install]
	WantedBy=multi-user.target
EOT
	sudo chmod 744 ~/cuckoo-modified/utils/api.py >/dev/null 2>&1
	sudo chmod 664 /etc/systemd/system/cuckooAPI.service >/dev/null 2>&1
	sudo systemctl enable cuckooAPI.service >/dev/null 2>&1
	sudo systemctl start cuckooAPI.service >/dev/null 2>&1

	echo -e "\e[92m[\xE2\x9C\x94] Service Configuration Complete!\e[0m" 
}


#Check if script was run as root
if [ $EUID -ne 0 ]; then
	echo 'This script must be run as root!'
	exit 1
fi
	update
	echo -e '\e[93m    [+] 10% Complete... \e[0m'

	dependencies
	echo -e '\e[93m    [+] 25% Complete... \e[0m'

	config
	echo -e '\e[93m    [+] 50% Complete... \e[0m'

	cuckoo
	echo -e '\e[93m    [+] 75% Complete... \e[0m'

	bind_ip
	echo -e '\e[93m    [+] 80% Complete... \e[0m'

	vmcloak
	inetsim
	echo -e '\e[93m    [+] 90% Complete! \e[0m'

	cuckooService
	cuckooAPIService	
	echo -e '\e[93m	   [+] 100% Complete! \e[0m'

	
exit 0

