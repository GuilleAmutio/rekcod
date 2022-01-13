#Requires -RunAsAdministrator

# Stop current containers for Windows and Linux
docker ps -q | % { docker stop $_ }
docker -c lin stop $(docker ps -aq)

# Shutdown WSL distro
wsl -t rekcod-wsl

# Stop dockerd service
Stop-Service docker
