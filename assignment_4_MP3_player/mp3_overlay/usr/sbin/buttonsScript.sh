#!/bin/bash

button1_state=0  #connected on gpio pin 2
button2_state=0	 #connected on gpio pin 3
button3_state=0  #connected on gpio pin 4
button4_state=0  #connected on gpio pin 14
led_state=0	 #connected on gpio pin 26

#Checking if the pins are configured before 
if [ ! -d /sys/class/gpio/gpio2 ] ; then
	echo "2" >  /sys/class/gpio/export
	echo "in" >  /sys/class/gpio/gpio2/direction
fi

if [ ! -d /sys/class/gpio/gpio3 ] ; then
	echo "3" > /sys/class/gpio/export
	echo "in" > /sys/class/gpio/gpio3/direction
fi

if [ ! -d /sys/class/gpio/gpio4 ] ; then
	echo "4" >  /sys/class/gpio/export
	echo "in" >  /sys/class/gpio/gpio4/direction
fi

if [ ! -d /sys/class/gpio/gpio18 ] ; then
	echo "18" > /sys/class/gpio/export
	echo "in" >  /sys/class/gpio/gpio18/direction
fi

if [ ! -d /sys/class/gpio/gpio26 ] ; then
	echo "26" >  /sys/class/gpio/export
	echo "out" >  /sys/class/gpio/gpio26/direction
fi


#This variable will be used to point at a specific song, buttons controls will apply to it
desiredSongNumber=1
#This variable will contain the variable name according to desiredSongNumber Variable
desiredSongName=" "
#This variable will hold the status of play/pause, zero means pause, 1 means play
currentStatus=1
#This variable will tell us if a song has already been started before or not (A process is running in the background), zero means no, 1 means it is running
processStarted=0
#This variable will hold the return of operation checking for a process running in the background
processRunning=" "
while :
do

	

	#First thing we will do is to check if ffplay process is running, if it is not running, check that processStarted flag is 0 to avoid any messing with the logic
	#Check for processes running and see if there is an ffplay process running and store it in a variable
	processRunning=$(ps | grep ffplay)
	#check if the processRunning variable has anything named ffplay, if it is then assign 1 to processStarted, otherwise keep it at zero
	if [[ $processRunning =~ "ffplay" ]];
	then
		#Set process started value to 1 because this means the process is in the background already
		processStarted=1
	else
		#Process is not running, set processStarted to 0
		processStarted=0
	fi

	#Now we will choose song depending on the number chosen by the user using buttons (by default, it will be equal to one)
	desiredSongName=$( head -n $desiredSongNumber availableFiles.txt )
	
	# previous <<
	if [ $(cat /sys/class/gpio/gpio2/value) -eq 1 ] ; then 
		#Say Previous
		aplay /usr/sbin/espeak_commands/previous
		#Check if we reached song number 1, if we did so, then keep the number at one. If not, then decrement
		if [ $desiredSongNumber -eq 1 ]
		then
			desiredSongNumber=1
		else
			desiredSongNumber=$((desiredSongNumber-1))
			#Stop any song currently playing
			killall -KILL ffplay
			sleep 0.2
			#Select chosen song
			desiredSongName=$( head -n $desiredSongNumber availableFiles.txt )
			#Play song
			ffplay -nodisp -autoexit $desiredSongName  >/dev/null 2>&1 &
		fi
		#We will sleep for a bit to prevent bouncing
		sleep 0.3
	fi

	 # play/pause script (will be executed if play/pause button is pressed)
	if [ $(cat /sys/class/gpio/gpio3/value) -eq 1 ] ; then
		#Check if a process has already been started in the background, if not then create a new process
		if [ $processStarted -eq 0 ] 
		then
			#Say Play
			aplay /usr/sbin/espeak_commands/play
			sleep 0.5
			#Run desired file using ffplay
			killall -KILL ffplay
			ffplay -nodisp -autoexit $desiredSongName  >/dev/null 2>&1 &
			#Change process started flag
			processStarted=1
		#if a process is already running
		else
			#If we are in pause, resume play			
			if [ $currentStatus -eq 0 ] 	
			then
				#Say Play and wait for half a second
				aplay /usr/sbin/espeak_commands/play
				sleep 0.5				
				#Continue suspended process				
				killall -CONT ffplay
				#Change flag
				currentStatus=1
			#If we are playing, pause and change flag			
			else
				#Say Pause and wait for half a second
				aplay /usr/sbin/espeak_commands/pause
				sleep 0.5
				killall -STOP ffplay
				currentStatus=0
			fi
		fi
		#We will sleep for a bit to prevent bouncing
		sleep 1
	fi
	
	# next >>
	if [ $(cat /sys/class/gpio/gpio4/value) -eq 1 ] ; then
		#Say Next
		aplay /usr/sbin/espeak_commands/next 
		#Check the total number of songs
		totalSongsNumber=$( wc -l availableFiles.txt | awk "{print $1}" ) 
		#Check if we reached the maximum number of songs, if we did so, then keep the number at one. If not, then decrement
		if [ $desiredSongNumber -eq $totalSongsNumber ]
		then
			desiredSongNumber=$totalSongsNumber
		else
			desiredSongNumber=$((desiredSongNumber+1))
			#Stop any song currently playing
			killall -KILL ffplay
			sleep 0.2
			#Select chosen song
			desiredSongName=$( head -n $desiredSongNumber availableFiles.txt )
			#Play song
			ffplay -nodisp -autoexit $desiredSongName  >/dev/null 2>&1 &
			
		fi
		sleep 0.3
	fi
	# random
	#This function will work using a bash command called shuf, which chooses a number within a range specified
	if [ $(cat /sys/class/gpio/gpio18/value) -eq 1 ] ; then 
		#Say Random
		aplay /usr/sbin/espeak_commands/random
		#Calculate total number of songs
		totalSongsNumber=$( wc -l availableFiles.txt | awk "{print $1}" ) 
		#Choose a random song number
		desiredSongNumber=$(desiredSongNumber+2)
		if [ $desiredSongNumber -ge $totalSongsNumber ]
		then
			desiredSongNumber=1
		fi
		#Stop any song currently playing
		killall -KILL ffplay
		sleep 0.2
		#Select chosen song
		desiredSongName=$( head -n $desiredSongNumber availableFiles.txt )
		#Play song
		ffplay -nodisp -autoexit $desiredSongName  >/dev/null 2>&1 &
		sleep 0.3
	fi


<< 'MULTILINE-COMMENT'
	#Lamp Script
	if [ $(cat /sys/class/gpio/gpio2/value) -eq 1 ] || [ $(cat /sys/class/gpio/gpio3/value) -eq 1 ] || [ $(cat /sys/class/gpio/gpio4/value) -eq 1 ] || [ $(cat /sys/class/gpio/gpio18/value) -eq 1 ] ; then
	#TOGGLE BUTTON STATE
		if [ $button1_state -eq 0 ] 
		then
		button1_state=1
		sleep 0.3
		else
		button1_state=0
		sleep 0.3
		fi
	fi

	if [ $button1_state -eq 1 ] ; then
			echo "1" > /sys/class/gpio/gpio26/value
			else
			echo "0" > /sys/class/gpio/gpio26/value
	fi

MULTILINE-COMMENT
done


