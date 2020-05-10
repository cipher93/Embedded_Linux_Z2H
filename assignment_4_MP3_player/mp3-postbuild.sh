#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

#These options will be passed after build to change shell prompt to "MP3_SHELL>"
#We will use sed command to replace desired line in bashrc file
#The desired line is the one starting with "PS1", we will use regex to change everything after PS1
sed -i 's/PS1=.*/PS1="MP3_Shell>"/' ${TARGET_DIR}/etc/profile

##These lines will be added to rcs file to enable our daemon scripts
sed '5i\ checkForDevices &' ${TARGET_DIR}/etc/init.d/rcS
sed '6i\ findMP3Players &' ${TARGET_DIR}/etc/init.d/rcS



