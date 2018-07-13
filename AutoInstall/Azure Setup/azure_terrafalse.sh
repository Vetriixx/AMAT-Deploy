#!/bin/bash

#Create each Azure VM
./packer build AzureFameVM.json 
./packer build AzureCuckooVM.json 
./packer build AzureDionaeaVM.json 
./packer build AzureMastiffVM.json 
./packer build AzureMispVM.json 
./packer build AzureViperVM.json 

az vm create \
    --resource-group AMAT \
    --name MispVM \
    --image MISP \
    --admin-username misp \
    --generate-ssh-keys

az vm create \
    --resource-group AMAT \
    --name FameVM \
    --image FAME \
    --admin-username fame \
    --generate-ssh-keys

az vm create \
    --resource-group AMAT \
    --name ViperVM \
    --image VIPER \
    --admin-username viper \
    --generate-ssh-keys

az vm create \
    --resource-group AMAT \
    --name CuckooVM \
    --image CUCKOO \
    --admin-username cuckoo \
    --generate-ssh-keys

az vm create \
    --resource-group AMAT \
    --name MastiffVM \
    --image MASTIFF \
    --admin-username mastiff \
    --generate-ssh-keys

az vm create \
    --resource-group AMAT \
    --name DionaeaVM \
    --image DIONAEA \
    --admin-username dionaea \
    --generate-ssh-keys
