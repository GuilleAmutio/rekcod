#Requires -RunAsAdministrator

# Supress warnings
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

# Start dockerd service on Windows
Write-Host "Starting Docker for Windows..." -ForegroundColor Yellow
Start-Service docker

# Start WSL distro
Write-Host "Starting Docker for Linux..." -ForegroundColor Yellow
Start-Job -Name rekcod-wsl -ScriptBlock{ wsl -d rekcod-wsl }

Write-Host "Docker is up and ready! Happy coding!" -ForegroundColor Green