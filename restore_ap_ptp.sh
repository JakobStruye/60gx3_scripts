#!/bin/bash
server=$1
client=$2
sleep 1
while true; do
  line=$(tail -n1 "out${client}")
  #echo "cli${client} ${line}"
    if [[ $(echo "$line" | tr -cd ',' | wc -c) == 71 ]]; then
      bad=0
  else
      bad=1
  fi
  if [ "$bad" -eq 1 ]; then
    echo "isdown $server"
    sleep 10
    line=$(tail -n1 "out${client}")
    echo "cli${client} ${line}"
    if [[ $(echo "$line" | tr -cd ',' | wc -c) == 71 ]]; then
        bad=0
    else
        bad=1
    fi
    if [ "$bad" -eq 1 ]; then
      echo "restoring $server"
      ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
               root@192.168.${server}.1 \
             "/root/run_hostapd.sh"
             sleep 120
    fi
  fi
  sleep 1
done
