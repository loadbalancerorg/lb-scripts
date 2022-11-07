# Addloopback.ps1

In order to run this script you may receive a warning about the script not being digitally signed.  To overcome this, execute the following command before running the script.

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

This command sets the execution policy to bypass for only the current PowerShell session after the window is closed, the next PowerShell session will open running with the default execution policy. “Bypass” means nothing is blocked and no warnings, prompts, or messages will be displayed.

This script also makes use of NuGet tools and will require an automatic library installation
