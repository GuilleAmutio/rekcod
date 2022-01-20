# Supress warnings
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

# Require admin to start
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Start-Service docker

# Start WSL distro
Start-Job -Name rekcod-wsl -ScriptBlock{ wsl -d rekcod-wsl }

# Allow non-admin users to use Docker
Add-AccountToDockerAccess "$env:UserDomain\$env:Username"