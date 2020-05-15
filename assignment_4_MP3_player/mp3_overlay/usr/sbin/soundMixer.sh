#!/bin/sh

#Activate the sound card
modprobe snd-bcm2835

while :
do
	#This variable will check whether something is connected to HDMI or not
	status=$(tvservice -n 2>&1)
	comparator='No Device'
	echo "$status"
	#If no device is present, let audio get out from jack
	if [[ $status =~ "No" ]];
	then
		echo "Using Headphones"
		sleep 2 && amixer cset numid=3 1 >/dev/null 2>&1
	#If a device is found, let the audio get out from HDMI Port	
	else
	then
		echo "Using HDMI"
		sleep 2 && amixer cset numid=3 2 >/dev/null 2>&1
	fi
done
