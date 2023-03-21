#!/bin/bash

TIMEOUT=1000

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
# Command Line Parameters
# VIRTUAL_IP=${1}
# VIRTUAL_PORT=${2}
REAL_IP=${3}
REAL_PORT=${4}

RESULT=$(echo $'\v'\<PerformSelfTest\/\>$'\x1c'$'\r' | nc -w ${TIMEOUT} -v ${REAL_IP} ${REAL_PORT})


if grep 'WS_CONNECTION valid="Y"' ${RESULT};
    then 
        exit 0
    else
        exit 1
fi
