source /root/devid
wpa_supplicant -D nl80211  -i wlan0 -c /etc/wpa_supplicant.conf -B
ifconfig wlan0 192.168.100.${DEV_ID}
