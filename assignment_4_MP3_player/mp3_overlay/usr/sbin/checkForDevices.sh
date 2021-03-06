#!/bin/bash

#This script will check for storage devices connected to the MP3 Player and mount new ones
#It will be called periodically as a background task
#We will run it through the init.d

#First, check for current devices and save them in "availableDevices" file:
#lsblk 			-> List information about block devices.
#-p   			-> print complete device path 
#--output		-> output columns
#KNAME 			-> internal kernel device name 
#grep 			-> Search for PATTERN in each FILE.
#-o 			-> show only the part of a line matching PATTERN
#/dev/sd.*		-> regex to find any storage device connected
# > ./availableDevices 	-> save the output of this operation in a file named availableDevices
while :
do

	echo Hakuna Matata
	#We will make the file that is going to be used to hold devices ID manually so that we can give it desired permission	s
	touch availableDevices.txt
	chmod 777 availableDevices.txt
	lsblk -p --output KNAME | grep -o /dev/sd.* > ./availableDevices.txt

	#check for number of lines inside file and save it in variable so that we can use it to loop over devices
	# We will use wc command which counts words or lines in file depending on the choice
	#Then we will pipe it with the awk command because the wc command returns the line numbers and a suffix
	#of file name, so we use awk to print the first variable of the wc command which is the lines number

	linesNumber=`wc -l availableDevices.txt | awk '{print $1}'`

	#Now we will make a for loop to mount each of the devices found and saved in the file
	for (( iterator=0; iterator<=$linesNumber; iterator++ ))
	do
		#To mount a volume, first we need to create a folder for it in the /media if it doesn't exist
		#Check using if condition whether the mount point directory is available or not
		if [ -d "/media/device$iterator" ]
		then
			echo Directory /media/device$iterator Exists
		else
			mkdir "/media/device"$iterator
		fi
	#After creating the folder, we will mount the media. We will use 'sed' command to copy the name
	#of the medium from the file to the terminal
	#We will suppress the output to /dev/null because sometimes already mounted media will be tried
	#to be mounted again, although this won't do anything wrong, it will throw error
# mount		-> Mount a filesystem.
# sed		-> returns the device name from availableDevices file
# -n		-> inputs the number of the required line
# 'p'		-> returns what is written in the selected line
# 2>/dev/null   -> trashes any returned errors
		mount -r `sed -n ''$iterator'p' availableDevices.txt` "/media/device"$iterator 2>/dev/null
		echo device$iterator mounted successfully
	done
	cp availableDevices.txt /usr/sbin
	sleep 5
done
