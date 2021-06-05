#!/bin/bash
#Program made to automate PMKID cracking

#Get color
RED="$(tput setaf 1 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
NO_COLOR="$(tput sgr0 2>/dev/null || echo '')"

#CLient addresses
SERVER=""
NFS_CLIENT=" "

#Get Server &user input from user on first startup
if [ -z "$SERVER" && -z "$NFS_CLIENT" ];
then
	read -p "Enter Server IPv4 " SERVER
	read -p "Enter NFS mount point" NFS_CLIENT

	#Write changes to file 
	sudo sed -i " 10c\SERVER\=\"$Server\" " hashcat-cluster.sh
	sudo sed -i " 11c\SERVER\=\"$NFS_CLIENT\" " hashcat-cluster.sh

	echo -e " ${GREEN} Written data to script\n Please reastart program ${NO_COLOR}"
	exit 0

echo "Please make sure NFS share, is mounted.."
fi

#Check if server is running, with NFS share
if ! [[ $( sudo nmap ${SERVER} | grep "NFS" ) ]];
then
	echo "Xerxes is down, please check server, and rerun script."
	sleep 1 
	exit 3
fi


#Check if udp server, is running on the server
if ! [[ $( sudo nmap -p 8888 localhost | grep "^8888/udp closed") ]];
then
	echo "UDP server down on Xerxes, please restart it, and rerun script"
	sleep 1
	echo "Exiting.."
	exit 3
fi	


#Variable used to grab password lists
FILE=1

read -p "Enter capture file: " CAPTURE


while [ $X -le 1 ];
do


	sudo cp ${NFS_CLIENT}${FILE}.txt .
	sudo hashcat -m 16800 $CAPTURE -a 0 --kernel-accel=1 -w 4 --force ${FILE}.txt | tee log${FILE}.txt
										#Save output to log

	#Send notification to Server, when wordlist exhausted
	sudo echo "${FILE} file cracked at ${DATE} " >> /dev/udp/192.168.1.97/8888
	sudo cp log* /mnt/nfs-share/

	sudo rm log*
	sudo rm ${FILE}.txt

	let FILE++
	
	#Set a maximum to 5 wordlists
	if [ $FILE -eq 5 ];
	then
		X=2
	fi
done


exit 0
