#!/bin/bash

echo "+==============================="
echo "| Starting VMs..."
echo "+==============================="

# startup vms
VBoxManage startvm ScadaBR --type headless
VBoxManage startvm pfSense --type headless
VBoxManage startvm workstation --type headless
VBoxManage startvm ChemicalPlant --type headless
VBoxManage startvm plc_2 --type headless
sleep 90m

VBoxManage snapshot ScadaBR take initialized --live
VBoxManage snapshot pfSense take initialized --live
VBoxManage snapshot workstation take initialized --live
VBoxManage snapshot ChemicalPlant take initialized --live
VBoxManage snapshot plc_2 take initialized --live

echo "+==============================="
echo "| Stopping VMs..."
echo "+==============================="

VBoxManage controlvm ScadaBR poweroff
VBoxManage controlvm pfSense poweroff
VBoxManage controlvm workstation poweroff
VBoxManage controlvm plc_2 poweroff
VBoxManage controlvm ChemicalPlant poweroff
