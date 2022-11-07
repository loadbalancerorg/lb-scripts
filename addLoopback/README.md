# addLoopback.ps1

In order to run this script you may receive a warning about the script not being digitally signed.  To overcome this, execute the following command before running the script.

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

This command sets the execution policy to bypass for only the current PowerShell session after the window is closed, the next PowerShell session will open running with the default execution policy. “Bypass” means nothing is blocked and no warnings, prompts, or messages will be displayed.

This script also makes use of NuGet tools and will require an automatic library installation

Options

switch | Description
----- | -----
-ip4|An IPv4 address to add to the loopback interface
-ip6|An IPv6 address to add to the loopback interface
-print|Add the MS Client options for print and file sharing
-ethernet|The name of the Ethernet interface (defaults to Ethernet0)
-help|Display help information
    
