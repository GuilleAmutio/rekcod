#Requires -RunAsAdministrator

# Start dockerd service on Windows
Start-Service docker

# Start WSL distro
wsl -d rekcod-wsl --exec ./scripts/wsl-start.sh

## Create link to use from Windows
docker context create lin --docker host=tcp://127.0.0.1:2375
