#!/bin/sh
source /root/devid
echo "" > $1

# Reset the interface
#ip link set dev wlan0 down
#ip link set dev wlan0 up

# Reset the supplicant
#killall wpa_supplicant

# Connect 
#wpa_supplicant -D nl80211  -i wlan0 -c /etc/wpa_supplicant.conf -B

## This will help to check if we cannot connect
i=0
connected=0

while true ; do  # Loop until connected
    break
    connected=$(cat /sys/kernel/debug/ieee80211/phy0/wil6210/stations | grep connected | wc -l)
                                             
    if [[ $connected -eq 1 ]]; then
     break
    fi

    i=$((i+1))

    # Break after a certain number of measurements
    if [[ $i -eq 10 ]]; then
      echo "[AoA] We cannot connect after 10 seconds"
      echo "Unreachable" > /tmp/aoa_measurements.txt
      exit
    fi

    sleep 1
done

#echo "[CSI] We are connected now"

# A counter
i=0
starttime=$(date +%s)

while true ; do  # Loop until interval has elapsed.

    connected=$(cat /sys/kernel/debug/ieee80211/phy0/wil6210/stations | grep connected | wc -l)
#18:FD:74:45:73:03 
#18:FD:74:45:73:4E  
    # Get AoA
    /root/millisleep $3
    echo -n -e '\x18\xFD\x74\x45\x73\x4E' | iw dev wlan0 vendor recv 0x001374 0x93 -

    # Save the measurement
    touch $1
    chmod 777 $1
    val=$(dmesg | tail -n1)
    echo $val >> $1
    echo $val
    retval=$(echo $val | cut -d' ' -f 5 | cut -d',' -f1)
    if [[ "$retval" != 0 ]]; then
	    while true; do
	    	#reconnect
           	 ip link set dev wlan0 down
	   	 ip link set dev wlan0 up
           	 killall wpa_supplicant
            	 wpa_supplicant -D nl80211  -i wlan0 -c /etc/wpa_supplicant.conf -B
           	 ifconfig wlan0 192.168.100.${DEV_ID}

		 reconnect_start=$(date +%s)
                 while true; do
            		current_time=$(date +%s)
            		elapsed_time=$(( current_time - reconnect_start ))

            		if [ "$elapsed_time" -ge 3 ]; then
                		break  # Break the inner loop if 1 second has passed
            		fi	
		 	connected=$(cat /sys/kernel/debug/ieee80211/phy0/wil6210/stations | grep connected | wc -l)
            		if [[ $connected -eq 1 ]]; then
                	    break  # Break the inner loop if connected
            		fi
            		#sleep 0.1  # Sleep for a short period to avoid busy waiting
                 done 
	        if [[ $connected -eq 1 ]]; then
                    break  # Successfully connected, exit outer loop
                fi	 
		 nowtime=$(date +%s)
		 elapsed_time=$(( nowtime - starttime ))
		    if [ "$elapsed_time" -ge $2 ]; then
			    exit
		    fi
	     done
    fi

    i=$((i+1))
    ## Break when no connected
    #if [[ $connected -eq 0 ]]; then
    #  echo "[CSI] We got " $i "measurements" 
    #  break
    #fi

    nowtime=$(date +%s)
    elapsed_time=$(( nowtime - starttime ))
    # Break after a certain number of measurements
    #if [[ $i -eq $2 ]]; then
    if [ "$elapsed_time" -ge $2 ]; then
      #echo "[CSI] We got $2 measurements"
      break
    fi
done
