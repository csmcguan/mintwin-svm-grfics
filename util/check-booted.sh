#!/bin/bash

SCADAUSR="scadabr"
SCADAPASS="scadabr"
WORKSTNUSR="workstation"
WORKSTNPASS="password"

CHECK_SCADA_UP="VBoxManage guestcontrol ScadaBR run   \
--username $SCADAUSR  \
--password $SCADAPASS \
-- /bin/echo Done!"
CHECK_WORKSTN_UP="VBoxManage guestcontrol workstation run   \
--username $WORKSTNUSR  \
--password $WORKSTNPASS \
-- /bin/echo Done!"

for MACHINE in "$@"; do
  case $MACHINE in
    "ScadaBR")
      echo "Verifying that ScadaBR VM has booted..."
      while : ; do
        $CHECK_SCADA_UP 2> /dev/null && break
        sleep 5
      done
      ;;
    "workstation")
      echo "Verifying that workstation VM has booted..."
      while : ; do
        $CHECK_WORKSTN_UP 2> /dev/null && break
        sleep 5
      done
      ;;
    *)
      echo "Verifying that ScadaBR VM has booted..."
      while : ; do
        $CHECK_SCADA_UP 2> /dev/null && break
        sleep 5
      done
      echo "Verifying that workstation VM has booted..."
      while : ; do
        $CHECK_WORKSTN_UP 2> /dev/null && break
        sleep 5
      done
      ;;
  esac
done
