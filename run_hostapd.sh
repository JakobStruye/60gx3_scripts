source /root/devid
killall hostapd
hostapd -B /etc/hostapd.conf
ifconfig wlan0 192.168.100.${DEV_ID}
