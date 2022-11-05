## AddLoopback.ps1 by Jon Morby
## (C) Copyright 2022
## All Rights Reserved
##
## Version Info
## 0.01 - Initial version (beta)
##

param(
    [Parameter(Mandatory=$false)][String] $ip4,
    [Parameter(Mandatory=$false)][String] $ip6,
    [Parameter(Mandatory=$false)][switch] $print,
    [Parameter(Mandatory=$false)][switch] $help
    )

#Requires -RunAsAdministrator
$Version = '0.01 beta'
$scriptName = $MyInvocation.MyCommand


function showUsage {
    showWelcome

    Write-Host "Usage: $scriptName parameters
    
    -ip <IP>        ip address for loopback adapter
    -print          enable printer support
    
    Examples: 
        $scriptName -ip4 192.168.1.1 -print
        $scriptName -ip4 192.168.1.1
        $scriptName -ip6 2001:0db8:85a3:0000:0000:8a2e:0370:7334

    
    "

    Exit 1
}

function showWelcome  {
    Write-Host "
Powershell tool to add loopback adapter to a Windows Server. 
Version $Version   
    "
}

# The name for the loopback adapter interface that will be created.
$loopback_name = 'Loopback'

# The name for the servers main network interface. This will be updated to allow weak host send/recieve which is most likely required for the traffic to work for the loopback interface.
$primary_interface = 'Ethernet'

if ($help) {
    showUsage
    Exit 0
}

if (!$ip4 -and !$ip6) {
    $ip4 = $(Read-Host "Enter IP address for Loopback Interface")
}

if ($ip4) {

# The IPv4 address that you would like to assign to the loopback interface along with the prefix length (eg. if the IP is routed to the server usually you would set the prefix length to 32).
    $loopback_ipv4 = $ip4
    $loopback_ipv4_length = '32'
}

if ($ip6) {

# The IPv6 address that you would like to assign to the loopback interface along with the prefix length (eg. if the IP is routed to the server usually you would set the prefix length to 128). If you are not adding an IPv6 address do not set these variables.
    $loopback_ipv6 = $ip6
    $loopback_ipv6_length = '128'
}

Install-Module -Name LoopbackAdapter -MinimumVersion 1.2.0.0 -Force
Import-Module -Name LoopbackAdapter

New-LoopbackAdapter -Name $loopback_name -Force

$interface_loopback = Get-NetAdapter -Name $loopback_name
$interface_main = Get-NetAdapter -Name $primary_interface

Set-NetIPInterface -InterfaceIndex $interface_loopback.ifIndex -InterfaceMetric "254" -WeakHostReceive Enabled -WeakHostSend Enabled -DHCP Disabled
Set-NetIPInterface -InterfaceIndex $interface_main.ifIndex -WeakHostReceive Enabled 
Set-NetIPAddress -InterfaceIndex $interface_loopback.ifIndex -SkipAsSource $True
Get-NetAdapter $loopback_name | Set-DNSClient -RegisterThisConnectionsAddress $False

if ($ip4) {
    # Set the IPv4 address
    New-NetIPAddress -InterfaceAlias $loopback_name -IPAddress $loopback_ipv4 -PrefixLength $loopback_ipv4_length -AddressFamily ipv4
}

if ($ip6) {
    # Set the IPv6 address - Uncomment this if required
    New-NetIPAddress -InterfaceAlias $loopback_name -IPAddress $loopback_ipv6 -PrefixLength $loopback_ipv6_length -AddressFamily ipv6
}

#Turn off all bindings on the loopback interface 
Disable-NetAdapterBinding -Name $loopback_name 

if ($ip4) {
    # add ipv4 support back in
    Enable-NetAdapterBinding -Name $loopback_name -ComponentID ms_tcpip
}
if ($ip6) {
    # add ipv6 support back in
    Enable-NetAdapterBinding -Name $loopback_name -ComponentID ms_tcpip6
}


if ($print) {
    # add in support for file and printer sharing as we're in a print environment

    Enable-NetAdapterBinding -Name $loopback_name -ComponentID ms_msclient
    Enable-NetAdapterBinding -Name $loopback_name -ComponentID ms_server
}

#Disable-NetAdapterBinding -Name $loopback_name -ComponentID ms_msclient
#Disable-NetAdapterBinding -Name $loopback_name -ComponentID ms_pacer
#Disable-NetAdapterBinding -Name $loopback_name -ComponentID ms_server
#Disable-NetAdapterBinding -Name $loopback_name -ComponentID ms_lltdio
#Disable-NetAdapterBinding -Name $loopback_name -ComponentID ms_rspndr

