#!/bin/bash

source devices.sh
for device in "${devices[@]}"; do
	echo "Rebooting" $device
	ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
	       root@192.168.${device}.1 \
	     "reboot"
done
