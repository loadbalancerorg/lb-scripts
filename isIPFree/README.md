# isIpFree

Simple script to run on a Linux box, Loadbalancer, Windows under WSL or similar

Requires nmap arping bash and ping to function

`$ apt-get install nmap arping bash iputils-ping`

Once installed simply call as follows

`isIPFree.sh 192.168.1.1`

and it will tell you if the specified IP address can be detected on the network (this is more than just a ping check and detects firewalled servers too)
