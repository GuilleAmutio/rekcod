# Supress warnings
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

# Require admin to start
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Variables
$FullControl = [System.Security.AccessControl.FileSystemRights]::FullControl
$Allow = [System.Security.AccessControl.AccessControlType]::Allow
$Account = "$env:UserDomain\$env:Username"

# Start dockerd service on Windows
Write-Host "Starting Docker for Windows..." -ForegroundColor Yellow
Start-Service docker

# Start WSL distro
Write-Host "Starting Docker for Linux..." -ForegroundColor Yellow
Start-Job -Name rekcod-wsl -ScriptBlock{ wsl -d rekcod-wsl }

Write-Host "Docker is up and ready! Happy coding!" -ForegroundColor Green

# Allow non-admin users to use Docker
$Info = New-Object "System.IO.DirectoryInfo" -ArgumentList "\\.\pipe\docker_engine"
$AccessControl = $Info.GetAccessControl()
$Rule = New-Object "System.Security.AccessControl.FileSystemAccessRule" -ArgumentList $Account,$FullControl,$Allow
$AccessControl.AddAccessRule($Rule)
$Info.SetAccessControl($AccessControl)