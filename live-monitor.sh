#!/bin/bash

close() {
  DISPLAY=$(ps aux | grep display.py | grep -v grep | awk '{ print $2 }') 
  if [ ! -z $DISPLAY ]; then
    kill $DISPLAY
  fi
  VBoxManage controlvm workstation poweroff
  VBoxManage controlvm ScadaBR poweroff
  VBoxManage controlvm pfSense poweroff
  VBoxManage controlvm plc_2 poweroff
  VBoxManage controlvm ChemicalPlant poweroff
  rm ./util/monitor-true.csv ./util/monitor-pred.csv ./data-capture/log/live.csv 2> /dev/null

  exit 1
}

trap close INT

SCADAUSR=scadabr
SCADAPASS=scadabr
WORKSTNUSR=workstation
WORKSTNPASS=password
CHECK_SCADABR_UP="VBoxManage guestcontrol ScadaBR run   \
--username $SCADAUSR                    \
--password $SCADAPASS                   \
-- /bin/echo Done!"
CHECK_WORKSTN_UP="VBoxManage guestcontrol workstation run   \
--username $WORKSTNUSR  \
--password $WORKSTNPASS \
-- /bin/echo Done!"

ATKNUM=$1

echo "actual,time" > ./util/monitor-true.csv

# restore state
VBoxManage snapshot ScadaBR restore initialized
VBoxManage snapshot workstation restore initialized
VBoxManage snapshot pfSense restore initialized
VBoxManage snapshot ChemicalPlant restore initialized
VBoxManage snapshot plc_2 restore initialized

# start vms
VBoxManage startvm ScadaBR --type headless
VBoxManage startvm workstation --type headless
VBoxManage startvm pfSense --type headless
VBoxManage startvm ChemicalPlant --type headless
VBoxManage startvm plc_2 --type headless

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

# capture data
touch ./data-capture/log/live.csv 
(VBoxManage guestcontrol ScadaBR run	\
--username $SCADAUSR               	\
--password $SCADAPASS                 	\
-- /usr/bin/python3			\
/home/scadabr/data-capture/capture-from-plc.py live.csv) 2> /dev/null &

# predict
python3 ./util/live-predict.py ./data-capture/log/live.csv &

sleep 5
# display
python3 ./util/display.py &

SECONDS=0
START=$(date +%s)
while [ $SECONDS -lt 30 ]; do
  TIME=$(($(date +%s)-START))
  echo "1, $TIME" >> ./util/monitor-true.csv
  sleep 0.1
done

# launch attack
(VBoxManage guestcontrol workstation run      	\
--quiet                                     	\
--username $WORKSTNUSR                      	\
--password $WORKSTNPASS                     	\
--timeout 5000                              	\
-- /usr/bin/sudo                            	\
/usr/bin/timeout 1005                       	\
/usr/bin/ettercap -T -i enp0s3 -F           	\
/home/workstation/modbus-attacks/build/attack$ATKNUM.ef	\
-q -M arp /192.168.95.2// /192.168.95.10-15//) 2> /dev/null &

ATKSTART=$(($(date +%s)-START))
sleep 2

echo "Attack started at time: $ATKSTART"

while [ $(wc -l < time.csv) -ne $((10#$ATKNUM+1)) ] && [ $(($(date +%s)-START)) -lt 1000 ]; do
  TIME=$(($(date +%s)-START))
  echo "0, $TIME" >> ./util/monitor-true.csv
  sleep 0.1
done

# kill active guest sessions
SCADABR=$(ps aux | grep "VBoxManage guestcontrol ScadaBR" | grep -v grep | awk '{ print $2 }') 
WORKSTN=$(ps aux | grep "VBoxManage guestcontrol workstation" | grep -v grep | awk '{ print $2 }') 
if [ ! -z $SCADABR ]; then
  kill $SCADABR
fi
if [ ! -z $WORKSTN ]; then
  kill $WORKSTN
fi

VBoxManage controlvm workstation poweroff
VBoxManage controlvm ScadaBR poweroff
VBoxManage controlvm pfSense poweroff
VBoxManage controlvm plc_2 poweroff
VBoxManage controlvm ChemicalPlant poweroff
DISPLAY=$(ps aux | grep display.py | grep -v grep | awk '{ print $2 }') 
PREDICT=$(ps aux | grep live-predict.py | grep -v grep | awk '{ print $2 }') 
if [ ! -z $DISPLAY ]; then
  kill $DISPLAY
fi 
if [ ! -z $PREDICT ]; then
  kill $PREDICT
fi 
rm ./util/monitor-true.csv ./util/monitor-pred.csv ./data-capture/log/live.csv 2> /dev/null
