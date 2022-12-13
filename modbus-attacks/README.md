# Workstation VM Modifications
The Workstation VM is used to launch attacks. A few modifications are needed.
## Disable Graphical Boot
* Boot the workstation VM
* Disable graphical boot
```
sudo systemctl enable multi-user.target --force
sudo systemctl set-default multi-user.target
```
* Power off the VM
## Create a Bridged Network Interface
* Open the VM's settings and navigate to the Network Tab.
* Set Adapter 2 to "Bridged Adapter"
* Change Promiscuous Mode to "Allow All"
* Save changes and boot the VM
## Install Guest Additions
* In the menu bar, navigate to Devices > Insert Guest Additions CD image 
* Mount and install Guest Additions
```
sudo mkdir /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom
sudo /mnt/cdrom/VBoxLinuxAdditions.run
```
* Reboot the VM.
## Install Ettercap
```
sudo apt install -y ettercap-text-only
```
## Create Shared Folder
* Add workstation to vboxsf group
```
sudo usermod -aG vboxsf workstation
```
* Create the following directory
```
mkdir /home/workstation/modbus-attacks
```
* In the menu bar, navigate to Devices > Shared Folders > Shared Folder Settings
* Add a new shared folder
* Choose the modbus-attacks folder on the host machine as the source
* Check "Auto-mount"
* Set the mount point as /home/workstation/modbus-attacks
* Check "Make Permanent"
* Reboot the VM
## Build Spoofing Attacks
* Navigate to the modbus-attacks folder and build the attacks
```
sh build.sh
```
## Sudo Without Password
This is required to control the VM from the host machine
* Add the following line to /etc/sudoers
```
workstation ALL=(ALL) NOPASSWD:ALL
```
* Power off the VM
* Disable Bridge Adapter
