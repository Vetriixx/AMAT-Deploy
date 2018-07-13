# Prerequisites

#### Prerequisites for ESXi deployment:

- Download Packer 1.1.0 &amp; Packer VSphere Plugin into the MasterInstall directory
  - [https://github.com/martezr/packer-builder-vsphere/releases/download/v1.5/packer-builder-vsphere-iso.linux](https://github.com/martezr/packer-builder-vsphere/releases/download/v1.5/packer-builder-vsphere-iso.linux)
  - [https://releases.hashicorp.com/packer/1.1.0/packer\_1.1.0\_linux\_amd64.zip](https://releases.hashicorp.com/packer/1.1.0/packer_1.1.0_linux_amd64.zip)
- Extract "packer" into the MasterInstall directory 
- Install sshpass on the Ubuntu machine which will be used to connect to ESXi for deployment of VMs
    - sudo apt-get install sshpass

- Modify the variables.json file to contain the correct IP, Datastore, username &amp; password of your ESXi machine. As shown in &quot;Packer Configuration&quot; section below
- Modify the Network.conf file to contain the correct network settings for your deployment.
    - Can be automatically done using "NetworkConf.sh"   
- Don&#39;t change the default VM usernames. Defaults are the name of each VM e.g. Fame machine User:Pass &quot;fame:fame&quot;
- Edit the &quot;tools\_upload\_path&quot; variable of each VM JSON file to the local ESXi path
- Edit each VM.json in the "provisioners" section to contain the correct path to the install scripts e.g.
        {     
        "type": "file",
        "source": "**/home/user/Desktop/**AMAT-Deploy/FAME/Modules",
        "destination": "/home/fame"
         },
- Edit the ESXi.sh file to contain the correct IP and credentials of the ESXi machine

#### Prerequisites for Azure deployment:
- Install the Azure CLI for your OS
    - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

# Documentation
This deployment was run using an Ubuntu 16.04 Desktop to run the deployment script.

# VSphere Configuration

ESXi requires certain configurations to allow packer to connect over SSH and deploy the VMs.

## Enable SSH

To enable SSH, connect to the ESXi machine via the web portal and select the &quot;Manage&quot; option from the left-hand pane, navigate to the &quot;Services&quot; option and then select and start &quot;TSM-SSH&quot;.

## Enable &quot;Guest IP Hack&quot;

The Guest IP Hack is required for packer to receive the Guest VM IPs from ESXi. First, SSH into the ESXi machine

	Example (Use your user and IP settings):	
	ssh amat@10.1.1.1

Next, run the following command:

	esxcli system settings advanced set -o /Net/GuestIPHack -i 1

## Enable VNC

Packer requires VNC connectivity to access the VMs, which is enabled by modifying the firewall.

SSH into the ESXi Machine (Refer to the example in Enable &quot;Guest IP Hack&quot;) and perform all of the following instructions in the SSH session:

First, eneter the following commands which modify the firewall permissions to allow for configuration:

	chmod 644 /etc/vmware/firewall/service.xml

	chmod +t /etc/vmware/firewall/service.xml

Second, open "/etc/vmware/firewall/service.xml" in a text editor

	Example:
	vi /etc/vmware/firewall/service.xml

and append the following text, before the final "</ConfigRoot>":

	<service id="1000">
	  <id>packer-vnc</id>
	  <rule id="0000">
	    <direction>inbound</direction>
	    <protocol>tcp</protocol>
	    <porttype>dst</porttype>
	    <port>
	      <begin>5900</begin>
	      <end>6000</end>
	    </port>
	  </rule>
	  <enabled>true</enabled>
	  <required>true</required>
	</service>


After modification, restore the original permission settings:

	chmod 444 /etc/vmware/firewall/service.xml

	esxcli network firewall refresh

# Packer Configuration

Packers uses JSON and .sh files to connect and deploy various VMs. The variables.json file located inside the MasterInstall folder contains the variables required to connect to the host for deployment.

Example:

	{
	  "esxi_host": "10.1.1.1",
	  "esxi_datastore": "datastore",
	  "esxi_username": "amat",
	  "esxi_password": "password"
	}

Each VM JSON file (e.g. FameVM.json) located inside the MasterInstall folder contains the variables which define the settings for the VM deployment e.g. CPUs, RAM, Disk Size, VM Name etc.

Each VM JSON file is split into several sections as shown below:

	builders: Disk Size, VM Name, OS Type, ISO Location, SSH Details, preseed file location

	remote_type: ESXi, AWS, EC2 variables

	vmx_data: CPU, RAM, Network and virtualisation settings

	provisioners: Install Scripts

The .cfg files inside the preseed folder contain the settings for the installation of the VM. The .cfg files which are used in this deployment are based on the Ubuntu Server 14 &amp; 16 templates. Other templates are available from packer which require minimal modification for personalised deployment.

# ESXi Deployment

After completing all the prerequisite steps, run the &quot;ESXi.sh&quot; script, which is located in the &quot;MasterInstall&quot; directory, and wait.

# Azure Configuration
Perform the following Azure command to create a resource group for the management of the AMAT Azure resources.
>az group create --name myResourceGroup --location eastus

Perform the following Azure command to create a virtual network in the resource group
Edit the command to suit your desired virtual network:
>azure network vnet create --vnet TestVNet -e 192.168.0.0 -i 16 -n FrontEnd -p 192.168.1.0 -r 24 -l "Central US"

Perform the following Azure commands to receive the required credential details, which will be used by Packer
>az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
az account show --query "{ subscription_id: id }"

Example output format:
>{
    "client_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
    "client_secret": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
    "tenant_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
}
{
"subscription_id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
}

## Packer Configuration
In "/AMAT-Deploy-master/AutoInstall/MasterInstall/AzureVariables", replace the placeholder information with the received credentials and the name of the created resource group.

## Azure Deployment
Change the resource group in "/AMAT-Deploy-master/AutoInstall/MasterInstall/azure.sh" to be the same as the resource group you created, the run the "azure.sh" script and wait.

# Known Issues
MISP module does not get recognised by the FAME framework. For now, the module has been appended to the Cuckoo module.

MISP module does not properly identify the threat level. Always returns &quot;unidentified threat level&quot;

# Notes
## Azure
You cannot set a static private IP address during the creation of a VM in the Resource Manager deployment mode by using the Azure portal. You must create the VM first, then set its private IP to be static.

Microsoft instructions for changing IP:
https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-static-private-ip-arm-pportal

The "/AMAT-Deploy-master/AutoInstall/MasterInstall/scripts/Network.conf" file is only used to supply the IP address for the services to communicate with eachother. It is not used to staticly set the IP of each VM. The "/AMAT-Deploy-master/AutoInstall/MasterInstall/scripts/Azure_Network_Conf.sh" script is used to change the IPs for Network.conf. The IPs set in the Azure web portal need to match the IPs set in Network.conf.
## Credentials
Fame web portal login credentials
	User: fame@fame.fame
	Pass: fame

Viper web portal login credentials
	User: viper
	Pass: viper
MISP web port login credentials
    User: admin@admin.test
    Pass: admin
Cuckoo web portal login credentials
	User: 
