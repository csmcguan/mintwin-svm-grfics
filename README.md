# Spoofing Detection in GRFICSv2
Implementation of modbus spoofing attacks and detection using unsupervised machine learning.

## Setup
Instructions assume a linux setup.
### 1. Install VirtualBox
Install [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads) for your linux distribution.
**You may need to enable virtualization in BIOS**

### 2. Download and setup GRFICSv2
Download and import the [prebuilt VMs](https://github.com/Fortiphyd/GRFICSv2).
When importing each machine, set promiscuous mode in its network adapter configuration to **Allow All**.

### 3. Host-Only Networks
If you have trouble enabling host-only networks, add the following to /etc/vbox/networks.conf.
```
* 192.168.90.0/24
* 192.168.95.0/24
```

### 4. Verify Proper Setup
Navigate to the [simulation](192.168.95.10) in your browser and verify that the chemical plant is running. If so, you're all set. Shutdown the VMs.

### 5. Workstation Modifications
The Workstation VM is used to launch attacks. A few modifications are needed.
#### Disable Graphical Boot
* Boot the workstation VM
* Disable graphical boot
```
sudo systemctl enable multi-user.target --force
sudo systemctl set-default multi-user.target
```
* Power off the VM
#### Create a Bridged Network Interface
* Open the VM's settings and navigate to the Network Tab.
* Set Adapter 2 to "Bridged Adapter"
* Change Promiscuous Mode to "Allow All"
* Save changes and boot the VM
#### Install Guest Additions
* In the menu bar, navigate to Devices -> Insert Guest Additions CD image 
* Mount and install Guest Additions
```
sudo mkdir /mnt/cdrom
sudo mount /dev/cdrom /mnt/cdrom
sudo /mnt/cdrom/VBoxLinuxAdditions.run
```
* Reboot the VM.
#### Install Ettercap
```
sudo apt install -y ettercap-text-only
```
#### Create Shared Folder
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
#### Build Spoofing Attacks
* Navigate to the modbus-attacks folder and build the attacks
```
sh build.sh
```
#### Sudo Without Password
This is required to control the VM from the host machine
* Add the following line to /etc/sudoers
```
workstation ALL=(ALL) NOPASSWD:ALL
```
* Power off the VM
* Disable Bridge Adapter

### 6. ScadaBR Modifications
Data capture from the plc is handled by the ScadaBR VM. A few modifications are needed.
#### Create a Bridged Network Interface
* Open the VM's settings and navigate to the Network Tab.
* Set Adapter 2 to "Bridged Adapter"
* Change Promiscuous Mode to "Allow All"
* Save changes and boot the VM
* Open /etc/network/interfaces and add the following lines
```
# Bridged Interface
allow-hotplug enp0s8
iface enp0s8 inet dhcp
```
* Reboot the VM

#### Install Guest Additions
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
#### Create Shared Folder
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
#### Install Dependencies
* Install python3 and pip3
```
sudo apt install -y python3 python3-pip
```
* Install python modules (run inside data-capture directory)
```
pip3 install -r requirements.txt
```
#### Sudo Without Password
This is required to control the VM from the host machine
* Add the following line to /etc/sudoers
```
scadabr ALL=(ALL) NOPASSWD:ALL
```
* Power off VM
* Disable Bridge Adapter

### 7. Host Machine Dependencies
* Install python modules (run inside SpoofingDetection directory)
```
pip3 install -r requirements.txt
```

## Create Snapshot
This will create a snapshot of the ChemicalPlant and PLC VM in a state where the chemical process has stabilized.
```
bash create-snapshot.sh
```

## Capturing Attack Data
This will capture attack data for all 54 attacks. Each attack is run for a full cycle (1000 seconds). This will take about 15 hours to complete.
```
bash capture-attack-data.sh
```

## Capture Benign Data
This will capture 20 cycles (roughly 5.5 hours worth) of benign data to verify that the model does not induce any false positives.
```
bash capture-benign-data.sh
```

## Testing the model
This will test the model against all the attack and benign datasets.
```
python3 batch.py
```

## Detection Time
This will collect the detection time for each attack and log it to a file time.csv. Each attack is only run for a full cycle (1000 seconds).
```
bash detection-time.sh
```
You can also do the detection time for a single attack.
```
bash live-monitor.sh <attack number>
```
