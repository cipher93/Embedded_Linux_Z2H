#!/bin/bash

#This is a simple safe delete program done as part of college project for bash scripting training
#Instead of deleting the files, it puts them compressed in a directory called trash in the home directory of user
#Done by: Mahmoud Hamdy Mohamed Hassan - ITI - Intake 40

#First thing, check if directory for trash exists
if [[ -d ~/trash ]]
then
	echo 'Directory exists, deleted files using this script will be moved to it. Please enter your password if prompted'
#If directory doesn't exist, then create the directory in home directory
else
	echo 'Directory not available, creating one now. Please enter your password if prompted'
	cd ~
	mkdir trash
fi

#The first thing that will happen when calling the function is to check trash folder
#We will create a for loop to go over files in a folder
for filename in ~/trash/*;
	do
		#If the time that a file was last modified is more than 48 hours, it will be deleted
		#Check time elapsed since last modification and store it in a variable called elapsed time
		elapsedTime=$(($(date +%H) - $(date +%H -r ${filename})))
		echo $elapsedTime
		#If time is greater than 48 hours, delete it
		if [ $elapsedTime -gt 48 ]
		then
			#Remove file that is over 48 hours in the folder using rm command
			rm $filename
		fi
done



#Check if no arguments are passed to the user, if no arguments are passed, then display warning to user and exit
if [ $# = 0 ] #This line means that there are no arguments passed, where '$#' is a symbol meaning the number of passed arguments, which should be equal to zero
then
	echo No arguments passed, exiting application
else
	#Now we will make a for loop that will iterate over the passed argument
	for argument in "$@" #The symbol at the end means the passed arguments
	do
		#Check if file/folder exists using test command, -e checks for existence regardless of type (folder/file)
		if [ -e "$argument" ]
		then
			echo $argument exists
			#Now that the file/folder exists, time to determine its type
			#First check if it is a file using test, -f means that it is a file
			if test -f "$argument"
			then
				echo $argument is a file
				#Now that we are sure that it is a file, check if it is compressed or not. If it is compressed, move it to trash directly
				if gzip -t -q $argument 2>/dev/null #Redirect resulting message from this to /dev/null to prevent ambiguity
				then
					echo "File is compressed"
					#Now move the compressed file to trash folder
					mv $argument ~/trash
					echo File moved to trash successfully
				else
					echo "File is not compressed"
					#Since file is not compressed, compress it
					gzip $argument
					echo File was compressed successfully
					#Now move the compressed file to trash folder
					mv $argument.gz ~/trash
					echo File moved to trash successfully
				fi

			#If it is not a file, then check if it is a folder using -d, which checks for existance of directories
			elif test -d "$argument"
			then
				echo $argument is a folder
				#Now archive and compress the folder in the trash folder
				#Options explanation: -c: compress, -z: using gzip, -f: to a file of the following name
				tar -czf $argument.tar.gz $argument
				echo Folder Compressed Successfully
				#Delete directory compressed and move compressed folder to trash
				rm -r $argument
				mv $argument.tar.gz ~/trash
				echo Folder moved to trash successfully
			fi
		#if the check failed, then it means nothing with this name was found
		else
			echo File/Folder not found
		fi
		
	done
fi



