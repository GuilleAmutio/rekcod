#Requires -RunAsAdministrator

# Stop current containers
docker kill $(docker ps -q)

# Shutdown WSL distro
wsl -t rekcod-wsl

# Stop dockerd service
Stop-Service docker
