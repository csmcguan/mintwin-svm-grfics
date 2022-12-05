# ScadaBR VM Modifications
Data capture from the plc is handled by the ScadaBR VM. A few modifications are needed.
## Create a Bridged Network Interface
* Open the VM's settings and navigate to the Network Tab.
* Set Adapter 2 to "Bridged Adapter"
* Change Promiscuous Mode to "Allow All"
* Save changes and boot the VM
* Open /etc/network/interfaces and add the following lines
```
## Bridged Interface
allow-hotplug enp0s8
iface enp0s8 inet dhcp
```
* Reboot the VM
## Install Guest Additions
* Update the system
```
sudo apt update && sudo apt clean && sudo apt full-upgrade -y
```
* Reboot the VM
* Install required dependencies
```
sudo apt install -y make gcc linux-headers-$(uname -r)
```
* In the menu bar, navigate to Devices > Shared Folders > Shared Folder Settings
* Mount and install Guest Additions
```
sudo mkdir /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom
sudo /mnt/cdrom/VBoxLinuxAdditions.run
```
* Reboot the VM
## Create Shared Folder
* Add scadabr to vboxsf group
```
sudo usermod -aG vboxsf scadabr
```
* Create the following directory
```
mkdir /home/scadabr/data-capture
```
* In the menu bar, navigate to Devices > Shared Folders > Shared Folder Settings
* Add a new shared folder
* Choose the data-capture folder on the host machine as the source
* Check "Auto-mount"
* Set the mount point as /home/scadabr/data-capture
* Check "Make Permanent"
* Reboot the VM
## Install Dependencies
* Install python3 and pip3
```
sudo apt install -y python3 python3-pip
```
* Install python modules (run inside data-capture directory)
```
pip3 install -r requirements.txt
```
## Sudo Without Password
This is required to control the VM from the host machine
* Add the following line to /etc/sudoers
```
scadabr ALL=(ALL) NOPASSWD:ALL
```
* Power off VM
* Disable Bridge Adapter

## 7. Host Machine Dependencies
* Install python modules (run inside SpoofingDetection directory)
```
pip3 install -r requirements.txt
```
