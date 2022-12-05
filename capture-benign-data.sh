#!/bin/bash

# handle ctrl+c
function close()
{
  VBoxManage controlvm ScadaBR poweroff
  VBoxManage controlvm workstation poweroff
  VBoxManage controlvm pfSense poweroff
  VBoxManage controlvm plc_2 poweroff
  VBoxManage controlvm ChemicalPlant poweroff
  exit 1
}

trap close INT

SCADAUSR="scadabr"
SCADAPASS="scadabr"
CHECK_SCADABR_UP="VBoxManage guestcontrol ScadaBR run   \
--username $SCADAUSR                    \
--password $SCADAPASS                   \
-- /bin/echo Done!"


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

echo "Verifying that ScadaBR VM has booted..."
while : ; do
  $CHECK_SCADABR_UP 2> /dev/null && break
  sleep 5
done

echo "+==============================="
echo "| Beginning Benign Data Capture"
echo "+==============================="

for BENIGN in $(seq -f "%02g" 0 50); do
  echo "[*] Capturing Benign: $BENIGN"

  # capture data
  (VBoxManage guestcontrol ScadaBR run	\
    --username $SCADAUSR			\
    --password $SCADAPASS			\
    -- /usr/bin/timeout 1000 /usr/bin/python3 	\
    /home/scadabr/data-capture/capture-from-plc.py benign$BENIGN.csv) 2> /dev/null &
    
    sleep 1000
done

echo "+==============================="
echo "| Stopping VMs..."
echo "+==============================="

VBoxManage controlvm ScadaBR poweroff
VBoxManage controlvm pfSense poweroff
VBoxManage controlvm plc_2 poweroff
VBoxManage controlvm ChemicalPlant poweroff
