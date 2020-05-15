#!/bin/bash

#This script will be used to find the MP3 files inside the drives
#It will use regex to find files with .mp3 extension

touch availableFiles.txt
chmod 777 availableFiles.txt
while :
do
	#check for number of lines inside file and save it in variable so that we can use it to loop over devices
	# We will use wc command which counts words or lines in file depending on the choice
	#Then we will pipe it with the awk command because the wc command returns the line numbers and a suffix
	#of file name, so we use awk to print the first variable of the wc command which is the lines number
	
	linesNumber=`ls /media | wc -l `
	linesNumber=$((linesNumber+2))
	
	#Now we will make a for loop to mount each of the devices found and saved in the file
	
	for (( iterator=2; iterator<=$linesNumber; iterator++ ))
	do
	
  
	#	if ! [[ $status =~ "No" ]]
	#	then
			if [[ $iterator == 2 ]]		
			then
				find "/media/device$iterator" -name "*.mp3" > ./availableFiles.txt 2>/dev/null
			
			else
				find "/media/device$iterator" -name "*.mp3" >> ./availableFiles.txt 2>/dev/null

			fi
	#	fi
		
	done
	sleep 5

done
