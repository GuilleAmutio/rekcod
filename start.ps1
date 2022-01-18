#Requires -RunAsAdministrator

# Start dockerd service on Windows
Write-Output "Starting Docker for Windows..."
Start-Service docker

# Start WSL distro
Write-Output "Starting Docker for Linux..."
Start-Job -Name rekcod-wsl -ScriptBlock{ wsl -d rekcod-wsl }

Write-Output "Docker is up and ready! Happy coding!"