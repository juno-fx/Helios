#!/bin/sh
# Originally sourced from Juno's internal Polaris.
# Original Author: @ddesmond
# Modified by: @aldmbmtl

timeout=$(($IDLE_TIME * 60 * 1000))
echo "Idle Detection running..." >>/tmp/idle-detect.log
echo "Configured timeout: $IDLE_TIME" >>/tmp/idle-detect.log

shift
triggered=false

while true; do
	to_sleep=$(((timeout - $(xssstate -i)) / 1000))
	if [ $to_sleep -le 0 ]; then
		$triggered || /bin/bash /etc/helios/idle.d/custom.sh
		triggered=true
	else
		triggered=false
		sleep $to_sleep
	fi
done
