#!/bin/bash

# Simple script to check if an IP is available or not
# Version 0.01 - Jon Morby 5th November 2022
#
# exit with 1 if an IP is found, 0 if success

# Variables
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:${PATH}

PING=/usr/bin/ping
NMAP=/usr/bin/nmap

DATE=`date +%b\ %d\ %H:%M:%S` # syslog format
APP=$(basename ${0})
LOG=${APP}.log
TIMEOUT=5
DEBUG=0
IPADDR=${1}

if [[ ! -f ${PING} ]];
then
	echo "${PING} not found"
	exit 1;
fi

if [[ ! -f ${NMAP} ]];
then
	echo "${NMAP} not found"
	echo "Please install with your package manager"
	echo "apt | rpm install nmap"
	exit 1;
fi

#### functions

function ip_found {
	msg="FAIL: IP ${IPADDR} seems to be in use, try another"
	echo "${DATE} ${APP} ${msg}" >> /var/log/${LOG}
	echo -e "\r\n\r\n${msg}"
	exit 1;
}

##### 

if [ -z ${1} ];
then
	echo -e "Usage:\r\n${0} IP.Add.re.ss\r\n\r\nExample:\r\n\r\n\t${0} 192.168.1.10\r\n"
	exit 1;
fi

# is this an IPv6 address?

if [[ ${1} == *":"* ]];
then
	ARGS="-6"
	PING="ping6"
fi

echo "Checking to see if IP address $1 is currently in use on the network"

if [ ${DEBUG} -eq "1" ]; then
	echo "DEBUG: ping"
fi

${PING} -q -c 4 ${1} &> /dev/null

if [ ${?} -eq "0" ];
then
	ip_found
	exit 1;
fi


RESULT=$( timeout ${TIMEOUT} nmap ${ARGS} ${1} | grep -c "Host is up" )

if [ ${DEBUG} -eq "1" ]; then
	echo "DEBUG: nmap"
fi

if [ ${RESULT} -eq "1" ];
then
	ip_found
	exit 1;
fi

if [ ${DEBUG} -eq "1" ]; then
	echo "DEBUG: ip neigh show"
fi

RESULT=$(ip ${ARGS} neigh show ${1} | grep -c ${IPADDR} )

if [ ${RESULT} -eq "1" ];
then
	msg="SUCCESS: IP ${IPADDR} is Probably available"
        echo "${DATE} ${APP} ${msg}" >> /var/log/${LOG}
	echo -e "\r\n\r\n${msg}"
	exit 0;
fi

#No Joy, Failure, IP is in use on the network
ip_found
exit 1
