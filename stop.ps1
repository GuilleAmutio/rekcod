#Requires -RunAsAdministrator

Write-Output "Stopping Docker..."

# Shutdown WSL distro
Stop-Job -Name rekcod-wsl
wsl -t rekcod-wsl

# Stop dockerd service
Stop-Service docker

Write-Output "Docker is stopped. See you soon!" -ForegroundColor Green