#!/bin/bash
source devices.sh
sleep 1
while true; do
  allbad=1
  for client in "${clients[@]}"; do
    line=$(tail -n1 "out${client}")
    echo "cli${client} ${line}"
    if [[ "$line" == *"AOA"* ]]; then
        allbad=0
        break
    fi
  done
  echo "allbad ${allbad}"
  if [ "$allbad" -eq 1 ]; then
    echo "restoring"
    ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
               root@192.168.${server}.1 \
             "/root/run_hostapd.sh"
             sleep 10
  fi
  sleep 1
done
