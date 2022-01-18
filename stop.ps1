# Supress warnings
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

# Require admin to stop
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Write-Host "Stopping Docker..."

# Shutdown WSL distro
Stop-Job -Name rekcod-wsl
wsl -t rekcod-wsl

# Stop dockerd service
Stop-Service docker

Write-Host "Docker is stopped. See you soon!" -ForegroundColor Green
