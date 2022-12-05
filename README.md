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
Navigate to the [simulation](http://192.168.95.10) in your browser and verify that the chemical plant is running. If so, you're all set. Shutdown the VMs.

### 5. Workstation Modifications
Follow the instructions in the README.md file in the modbus-attacks directory.

### 6. ScadaBR Modifications
Follow the instructions in the README.md file in the data-capture directory.

### 7. Host Machine Dependencies
Install python modules (run inside SpoofingDetection directory)
```
pip3 install -r requirements.txt
```
## Create Snapshot
This will create a snapshot of all VMs in a state where the chemical process has stabilized. Each time the machines are booted, the state is restored to this snapshot.
```
bash create-snapshot.sh
```
## Capturing Training Data
This will capture a full cycle (1000 seconds) of benign data.
```
bash capture-training-data.sh
```
## Training the Model
This will train the model using the training data previously captured.
```
python3 train.py
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
