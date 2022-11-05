#!/bin/bash
# Version 0.1 - Unknown
# Version 0.2 - Basic half open check with some logging / debug options based on one of the WHI health checks
#               Jon Morby - solutions@loadbalancer.org
# Version 0.3 - Neil Stone <support@loadbalancer.org.> - Improvements on real server port handling
# Version 0.4 - Jon Morby - <solutions@loadbalancer.org> - Tidy up date formatting

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

### Variables
DEBUG=1
DATE=`date +%b\ %d\ %H:%M:%S` # syslog format
APP=$(basename ${0})
LOG=${APP}.log
RIP="${3}"    # $3 represents the real server IP address as passed by the load balancer
TIMEOUT="3"   # Timeout for checking each port

if [ "${4}" == "0" ] || [ -z "${4}" ]; then
    HALF_OPEN_RPT="${2}"
else
    HALF_OPEN_RPT="${4}"
fi

### Shouldn't need to edit below here

for port in ${HALF_OPEN_RPT}; do
        timeout ${TIMEOUT} nmap -sS -p ${port} ${RIP} 2>&1 | grep -q 'open'
        ec=${?}
        if [ ${ec} -ne "0" ]; then
            if [ ${DEBUG} -eq "1" ]; then
                echo "${DATE} ${APP} Fail: ${RIP}:${port} (${ec})" >> /tmp/${LOG}
            fi
                exit ${ec}
        fi
done

if [ ${DEBUG} -eq "1" ]; then
        echo "${DATE} ${APP} Success: ${RIP}:${port} (${ec})" >> /tmp/${LOG}
fi

exit 0
