#!/bin/bash
echo Please enter the network settings of your malware analysis environment.
echo Note: These settings are not validated!
echo Incorrect settings will prevent the environment from deploying!  
echo

echo Enter MISP VM IP Address
read MISP_IP
sudo sed -i s/misp_address="[^"][^"]*"/misp_address='"'$MISP_IP'"'/ > sudo ./Network.conf

echo Enter FAME VM IP Address
read FAME_IP
sudo sed -i s/fame_address="[^"][^"]*"/fame_address='"'$FAME_IP'"'/ > sudo ./Network.conf

echo Enter Cuckoo VM IP Address
read Cuckoo_IP
sudo sed -i s/cuck_address="[^"][^"]*"/cuck_address='"'$Cuckoo_IP'"'/ > sudo ./Network.conf

echo Enter Honeypot VM IP Address
read Honeypot_IP
sudo sed -i s/hp_address="[^"][^"]*"/hp_address='"'$Honeypot_IP'"'/ > sudo ./Network.conf

echo Enter Viper VM IP Address
read Viper_IP
sudo sed -i s/vip_address="[^"][^"]*"/vip_address='"'$Viper_IP'"'/ > sudo ./Network.conf

echo Enter Mastiff VM IP Address
read Mastiff_IP
sudo sed -i s/mas_address="[^"][^"]*"/mas_address='"'$Mastiff_IP'"'/ > sudo ./Network.conf
