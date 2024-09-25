#!/bin/bash

source devices.sh

cleanup() {
    echo "CTRL+C caught! Cleaning up..."
    
    for client in "${clients[@]}"; do
	ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
	       root@192.168.${client}.1 \
	       "ps | grep 'collect_csi' | grep -v 'grep' | sed 's/^[ \t]*//' | cut -d' ' -f1 | xargs kill"
    done
    exit 1
}

# Trap SIGINT (CTRL+C) and call cleanup function
trap cleanup SIGINT

for device in "${devices[@]}"; do
        epoch=$(date +%s)
	ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
		root@192.168.${device}.1 \
		"date -s '@$(date +%s)'"
done
for client in "${clients[@]}"; do
	echo $client
	connected=$(ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
		root@192.168.${client}.1 \
		'cat /sys/kernel/debug/ieee80211/phy0/wil6210/stations | grep connected | wc -l')
	if [ "$connected" -eq 0 ]; then
		break;
	fi
done

if [ "$connected" -eq 0 ]; then
	ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
	       root@192.168.${server}.1 \
	       '/root/run_hostapd.sh'
	sleep 3
	for client in "${clients[@]}"; do
		ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
			root@192.168.${client}.1 \
			'/root/wpa_sup.sh'
	done
	sleep 3
else
	echo "Everyone already connected"
fi

for client in "${clients[@]}"; do
	ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
	       root@192.168.${client}.1 \
	       '/root/collect_csi.sh dummy 9999999' > out${client} &
done
wait
