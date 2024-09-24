#!/bin/bash

server="9"
clients=("13")
devices=("${server[@]}" "${clients[@]}")
echo ${epoch}
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
	       'source /etc/profile; /root/run_hostapd.sh'
	sleep 3
	for client in "${clients[@]}"; do
		ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
			root@192.168.${client}.1 \
			'source /etc/profile; /root/wpa_sup.sh'
	done
	sleep 3
else
	echo "Everyone already connected"
fi

for client in "${clients[@]}"; do
	ssh -oHostKeyAlgorithms=ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa \
	       root@192.168.${client}.1 \
	       'source /etc/profile; /root/collect_csi.sh dummy 9999999' > out${client}
done
