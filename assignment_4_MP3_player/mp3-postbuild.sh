#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \.
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

#These options will be passed after build to change shell prompt to "MP3_SHELL>"
#We will use sed command to replace desired line in bashrc file
#The desired line is the one starting with "PS1", we will use regex to change everything after PS1
sed -i 's/PS1=.*/PS1="MP3_Shell>"/' ${TARGET_DIR}/etc/profile

##These lines will be added to rcs file to enable our daemon scripts
sed -i 's/done/ /' 	   ${TARGET_DIR}/etc/init.d/rcS
echo   "checkForDevices.sh &" 		>> ${TARGET_DIR}/etc/init.d/rcS
echo   "findMP3Players.sh &" 		>> ${TARGET_DIR}/etc/init.d/rcS
echo   "buttonsScript.sh &" 		>>${TARGET_DIR}/etc/init.d/rcS
echo   "soundMixer.sh &" 		>>${TARGET_DIR}/etc/init.d/rcS
echo   "done"		  		>>${TARGET_DIR}/etc/init.d/rcS

#These lines will be added to the config.txt file so that sound will be enabled, we will use echo to write it to the file along with the ">>" modifier to append to the file
#The first line enables sound in general on the Pi
#The second line calls the driver of the soundcard that would be used
echo "dtparam=audio=on" 		>> ${BINARIES_DIR}/rpi-firmware/config.txt
#echo "modprobe snd-bcm2835" 		>> ${BINARIES_DIR}/rpi-firmware/config.txt

#Create these symbolic links and give them permissions
ln -s ${TARGET_DIR}/usr/sbin/checkForDevices.sh 		${TARGET_DIR}/etc/init.d/S03checkForDevices_Link
ln -s ${TARGET_DIR}/usr/sbin/findMP3Files.sh 			${TARGET_DIR}/etc/init.d/S04findMP3Files_Link
ln -s ${TARGET_DIR}/usr/sbin/buttonsScript.sh 			${TARGET_DIR}/etc/init.d/S05buttonsScript_Link
ln -s ${TARGET_DIR}/usr/sbin/soundMixer.sh 			${TARGET_DIR}/etc/init.d/S06soundMixer_Link

chmod 755 ${TARGET_DIR}/etc/init.d/S03checkForDevices_Link
chmod 755 ${TARGET_DIR}/etc/init.d/S04findMP3Files_Link
chmod 755 ${TARGET_DIR}/etc/init.d/S05buttonsScript_Link
chmod 755 ${TARGET_DIR}/etc/init.d/S06soundMixer_Link
