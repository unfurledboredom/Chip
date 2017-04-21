#!/bin/bash

#Copyright 2017 Aminur Rahman

networkInterface=wlan0
dateAndTime="$(date)"
currentMAC="$(ifconfig $networkInterface | grep HWaddr | awk '{print $5}')"

wget -q --spider http://google.com
if [ $? -eq 0 ]; then
    result=Online
    echo "$dateAndTime : Business as usual on MAC: $currentMAC" >> report.log
else
    result=Offline
    echo "$dateAndTime : Doesn't look good on MAC: $currentMAC" >> report.log
    outputprefix=output
    sleeptime=60s
    maxclients=50
    apMAC=`iwconfig wlan0 | grep "Access Point" | awk '{print $6}'`
    cp -f client_results old_clients
    rm $outputfileprefix*.csv &> /dev/null
    airodump-ng --bssid $apMAC wlan0 -w $outputprefix --output-format csv  &> /dev/$
    sleep $sleeptime
    kill $!
    grep -aA $maxclients 'MAC' `ls $outputprefix*.csv` \
     | grep "$1"                                  \
     | sed -e '/Station/d' -e 's/,//'        \
     | awk '{print $1}' > client_results
    newMAC="$(grep -Fxvf client_results old_clients)"
    if [ "$newMAC" = "$currentMAC" ]; then
        echo "$dateAndTime : Didn't find any good MACs" >> report.log
    else
        echo "$dateAndTime : Found New MAC: $newMAC" >> report.log
        /etc/init.d/networking stop
        ifconfig $networkInterface hw ether $newMAC
        /etc/init.d/networking start
        echo "$dateAndTime : New MAC Set. Rebooting System" >> report.log
        reboot -h now
    fi
fi