#!/bin/sh
source /root/devid

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
    /root/millisleep $2
    echo -n -e '\xdc\x2c\x6e\xf3\x69\x91' | iw dev wlan0 vendor recv 0x001374 0x93 -

    # Save the measurement
    val=$(dmesg | tail -n1)
    val="["$(/root/millitime)"] "$(echo $val |cut -d']' -f2-)
    echo $val
    retval=$(echo $val | cut -d' ' -f 4 | cut -d',' -f1)
    retval=$(echo $val | tr -cd ',' | wc -c)

    if [[ "$retval" != 71 ]]; then
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
		    if [ "$elapsed_time" -ge $1 ]; then
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
    #if [[ $i -eq $1 ]]; then
    if [ "$elapsed_time" -ge $1 ]; then
      #echo "[CSI] We got $1 measurements"
      break
    fi
done
