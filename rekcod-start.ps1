# Supress warnings
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

# Variable
$RekcodInstallationPath = [System.Environment]::GetEnvironmentVariable('REKCOD')

# Start dockerd service on Windows
Write-Host "Starting Docker for Windows..." -ForegroundColor Yellow

# Start WSL distro
Write-Host "Starting Docker for Linux..." -ForegroundColor Yellow

# Call script
powershell -File ${RekcodInstallationPath}\pwsh-scripts\pwsh-start.ps1

Write-Host "Docker is up and ready! Happy coding!" -ForegroundColor Green