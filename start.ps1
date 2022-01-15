#Requires -RunAsAdministrator

# Start dockerd service on Windows
Write-Output "Starting Docker for Windows..."
Start-Service docker

# Start WSL distro
Write-Output "Starting Docker for Linux..."
Start-Job -Name rekcod-wsl -ScriptBlock{ wsl -d rekcod-wsl }

## Create link to use from Windows
docker context create lin --docker host=tcp://127.0.0.1:2375

Write-Output "Docker is up and ready! Happy coding!"