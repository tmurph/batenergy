#!/usr/bin/env bash

FILE=/tmp/batenergy.dat

state=$1
sleep_type=$2

now=`date +'%s'`

read energy_now < /sys/class/power_supply/BAT0/energy_now #μWh
read energy_full < /sys/class/power_supply/BAT0/energy_full # μWh
read online < /sys/class/power_supply/AC/online

echo "Processing '${SYSTEMD_SLEEP_ACTION}' sleep action."
echo "Called with '${state}', '${sleep_type}'."
(($online)) && echo "Currently on mains." || echo "Currently on battery."

case ${state} in
("pre")
	echo ${now} > ${FILE}
	echo ${energy_now} >> ${FILE}
        echo "Going to sleep with ${energy_now} µWh ($((${energy_now} * 100 / ${energy_full}))% of ${energy_full})"
	;;
("post")
	exec 3<>${FILE}
	read prev <&3
	read energy_prev <&3
	rm ${FILE}
	time_diff=$((${now} - ${prev})) # seconds
	days=$((${time_diff} / (3600*24)))
	hours=$((${time_diff} % (3600*24) / 3600))
	minutes=$((${time_diff} % 3600 / 60))
	echo "Waking after sleeping for ${days} days, ${hours} hours, ${minutes} minutes"
        echo "Woke up with ${energy_now} µWh ($((${energy_now} * 100 / ${energy_full}))% of ${energy_full})"
	energy_diff=$(((${energy_now} - ${energy_prev}) / 1000)) # mWh
	avg_rate=$((${energy_diff} * 3600 / ${time_diff})) # mW
	energy_diff_pct=$(bc <<< "scale=1;${energy_diff} * 100 / (${energy_full} / 1000)") # %
	avg_rate_pct=$(bc <<< "scale=2;${avg_rate} * 100 / (${energy_full} / 1000)") # %/h
	echo "Battery energy change of ${energy_diff_pct}% (${energy_diff} mWh) at an average rate of ${avg_rate_pct}%/h (${avg_rate} mW)"
	;;
esac
