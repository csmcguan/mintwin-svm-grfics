#!/bin/bash

# handle ctrl+c
function close()
{
  VBoxManage controlvm ScadaBR poweroff
  VBoxManage controlvm pfSense poweroff
  VBoxManage controlvm plc_2 poweroff
  VBoxManage controlvm ChemicalPlant poweroff
  exit 1
}

trap close INT

SCADAUSR="scadabr"
SCADAPASS="scadabr"

echo "+==============================="
echo "| Starting VMs..."
echo "+==============================="

# restore state
VBoxManage snapshot ScadaBR restore initialized
VBoxManage snapshot pfSense restore initialized
VBoxManage snapshot ChemicalPlant restore initialized
VBoxManage snapshot plc_2 restore initialized

# startup vms
VBoxManage startvm ScadaBR --type headless
VBoxManage startvm pfSense --type headless
VBoxManage startvm ChemicalPlant --type headless
VBoxManage startvm plc_2 --type headless

# make sure VMs are booted
sh ./util/check-booted.sh ScadaBR

echo "+==============================="
echo "| Capturing Training Data"
echo "+==============================="

# capture data
(VBoxManage guestcontrol ScadaBR run	\
--username $SCADAUSR			\
--password $SCADAPASS			\
-- /usr/bin/timeout 1000 /usr/bin/python3 	\
/home/scadabr/data-capture/capture-from-plc.py training-data.csv) 2> /dev/null &

sleep 1000

echo "+==============================="
echo "| Stopping VMs..."
echo "+==============================="

VBoxManage controlvm ScadaBR poweroff
VBoxManage controlvm pfSense poweroff
VBoxManage controlvm plc_2 poweroff
VBoxManage controlvm ChemicalPlant poweroff
