#Requires -RunAsAdministrator

# Supress warnings
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

Write-Host "Stopping Docker..."

# Shutdown WSL distro
Stop-Job -Name rekcod-wsl
wsl -t rekcod-wsl

# Stop dockerd service
Stop-Service docker

Write-Host "Docker is stopped. See you soon!" -ForegroundColor Green
