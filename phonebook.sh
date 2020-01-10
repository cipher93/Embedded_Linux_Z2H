#!/bin/bash

#This is a simple phonebook program done as part of college project for bash scripting training
#Done by: Mahmoud Hamdy Mohamed Hassan - ITI - Intake 40

#First thing, check if directory for phonebook exists
if [[ -d /etc/phonebook ]]
then
	echo 'Directory exists, moving to it and opening database file. Please enter your password if prompted'
	cd /etc/phonebook
#If directory doesn't exist, then create the directory in etc/phonebook
else
	echo 'Directory not available, creating one now. Please enter your password if prompted'
	cd /etc
	sudo mkdir phonebook
	cd /etc/phonebook
fi
#Create the file or open it if it exists
sudo touch phoneDB.txt
#Give permissions for making changes to file
sudo chmod -R 777 /etc/phonebook;


#Check if no arguments are passed to the user, if no arguments are passed, then print all values in file of database on screen
if [ $# = 0 ] #This line means that there are no arguments passed, where '$#' is a symbol meaning the number of passed arguments, which should be equal to zero
then
	cat phoneDB.txt

#In case an argument is passed, go through these lines according to the passed line
else
	#If passed argument is '-e', delete everything inside the file
	if [ $1 = '-e' ]
	then
	>phoneDB.txt #This lines means to replace everything inside the file with empty line
	
	#If passed argument is '-v', then show everything inside the file
	elif [ $1 = '-v' ]
	then
		cat phoneDB.txt
	
	#If passed argument is '-s', then search for the contact by name
	elif [ $1 = '-s' ]
	then
		#-i option makes the grep ignore case sensitivity, -w is for exact match
		if ! grep -i -w $2 phoneDB.txt
		then
			echo 'Nothing found'
		fi
	#If passed argument is '-d', then delete selected contact
	elif [ $1 = '-d' ]
	then
		#Pass the line to delete into a variable
		lineToDelete=$2
		#Now check if user entered data, if he didn't enter data, then show this to him
		if [ -z "$lineToDelete" ]
		then
			echo Nothing entered to delete
		#If data is entered, find exact match to delete first
		else
			#First, check how many matches will be found, if more than one match is found, terminate and tell the user to be more specifec
			#put the output of grep in a variable to make it easier
			#-i option makes the grep ignore case sensitivity, -w is for exact match, -c to find number of matches
			numOfMatches=$(grep -i -w -c $2 phoneDB.txt)
			#If number of matches is more that 1, then terminate and tell the user to be more specific
			if  [ "$numOfMatches" -gt 1 ]
			then
				echo More than one match is found, please repeat search and be more specific
			#Now that only one match is found, delete it
			else
				#here we will use command called 'sed' to delete the line, it is like grep but has more options. The 'd' modifier inside the command is used to delete
				#-i used with sed is to delete from the source file, and -e is to prevent the sed from creating temporary files while editing
				#the\<\> modifier is used to delete exact match
				#We used double quotes because single quotes prevent dereference of variables
				sed -i -e  "/\<${lineToDelete}\>/d" phoneDB.txt
				echo Only one match was found and deleted successfully
			fi
		fi
	#If passed argument is '-i', then insert a new contact
	elif [ $1 = '-i' ]
	then
		#Prompt user to enter name and save it in variable called newName
		read -p "Please enter contact name (When entering full name, add it between: " newName
		#check if name already exists in the phonebook, if name exists, ask user if he wants to add a new number
		#In case name exists in more than one entry just exit the application
		numOfMatches=$(grep -i -w -c $newName phoneDB.txt)
		if  [ "$numOfMatches" -gt 1 ]
		then
			grep -i "${newName}" phoneDB.txt
			echo 'Name found in more than one entry, please enter a more specific name'
		else	
			if grep -i "${newName}" phoneDB.txt
			then
				echo 'Name already exists in the above entries.'
				read -p 'Would you like to add a new number to it [Y\N]?' userChoice
			
				#Now according to user input, either add another number or get output
				#If user enters 'y' or 'Y', allow him to enter new number
				if [ $userChoice = 'y' ] || [ $userChoice = 'Y' ]
				then
					read -p 'Please enter the new number you want= ' newNumber
					#Now we will use sed to append the number to line
					#-i used with sed is to delete from the source file, and -e is to prevent the sed from creating temporary files while editing
					#the\<\> modifier is used to delete exact match
					#We used double quotes because single quotes prevent dereference of variables
					#/s means to subsitute, and /$ means replace end of line
					sed -i -e  "/\<${newName}\>/s/$/ ${newNumber}/" phoneDB.txt 
				#If user enters anything else, exit program
				elif [ $userChoice = 'n' ] || [ $userChoice = 'N' ]
				then
					echo 'You choose to exit. Exiting program'
				else
					echo 'Unknown input. Exiting program'
				fi
			#If name does not exist, take number from user and save them in the file
			else
				read -p 'Please enter the number: ' newNumber
				#append the entered data to the file using the echo command and redirecting to the file
				echo $newName $newNumber >> phoneDB.txt
			fi
		fi
	fi
fi

#At the end of script, revert permissions of folder to normal
sudo chmod -R 755 /etc/phonebook;



