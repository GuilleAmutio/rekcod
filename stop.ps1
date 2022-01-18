#Requires -RunAsAdministrator

Write-Output "Stopping all Docker containers"

# Stop current containers for Windows and Linux
docker ps -q | ForEach-Object { docker stop $_ }
docker -c lin stop $(docker ps -aq)

# Shutdown WSL distro
Stop-Job -Name rekcod-wsl
wsl -t rekcod-wsl

# Stop dockerd service
Stop-Service docker

Write-Output "Docker is stopped. See you soon!"