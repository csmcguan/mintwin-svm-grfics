#!/bin/bash

close()
{
  VBoxManage controlvm ScadaBR poweroff
  VBoxManage controlvm workstation poweroff
  VBoxManage controlvm pfSense poweroff
  VBoxManage controlvm plc_2 poweroff
  VBoxManage controlvm ChemicalPlant poweroff
  PROC=$(ps aux | grep live-monitor.sh | grep -v grep | awk '{ print $2 }')
  if [ ! -z $PROC ]; then
    kill $PROC
  fi
  exit 1
}

trap close INT

# start with a fresh file
if [ -f time.csv ]; then
  rm time.csv
fi

touch time.csv

for ATKNUM in $(seq -f "%02g" 0 53); do
  echo "[*] Performing detection time for attack $ATKNUM"
  sh live-monitor.sh $ATKNUM 
  PROC=$(ps aux | grep live-monitor.sh | grep -v grep | awk '{ print $2 }')
  if [ ! -z $PROC ]; then
    kill $PROC
  fi
  sleep 30
done
