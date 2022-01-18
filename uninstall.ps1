#!Requires -RunAsAdministrator

$RekcodInstallationPath = [System.Environment]::GetEnvironmentVariable('REKCOD')
$RekcodProfile = "${RekcodInstallationPath}\profile"
$FullControll = [System.Security.AccessControl.FileSystemRights]::FullControll
$Allow = [System.Security.AccessControl.AccessControlType]::Allow
$Account = "$env:UserDomain\$env:Username"

Write-Output 'We are sorry to see you go but allow us to leave your machine as clean as before rekcod.' -ForegroundColor Yellow

# Stop docker before uninstall
Stop-Service docker

# Unregister dockerd service
dockerd --unregister-service

# Unregister WSL distribution
Write-Output 'Removing WSL...' -ForegroundColor Yellow
wsl --unregister rekcod-wsl

# Remove powershell profile
Write-Output "Removing rekcod from your profile..." -ForegroundColor Yellow
New-Item -Type File -Path $PROFILE -Force
Get-Content "${RekcodProfile}\old-profile.ps1" >> $PROFILE

# Remove normal users access to docker
$Info = New-Object "System.IO.DirectoryInfo" -ArgumentList "\\.\pipe\docker_engine"
$AccessControl = $Info.GetAccesControl()
$Rule = New-Object "System.Security.AccessControl.FileSystemAccessRule" -ArgumentList $Account,$FullControll,$Allow
$AccessControl.RemoveAccessRule($Rule) > $null
$Info.SetAccessControl($AccessControl)

# Remove installation folder
Write-Output 'Removing rekcod folder...' -ForegroundColor Yellow
Remove-Item $RekcodInstallationPath -Recurse

# Get PATH variable
Write-Output 'Cleaning environment variables...' -ForegroundColor Yellow
$path = [System.Environment]::GetEnvironmentVariable(
    'PATH',
    'Machine'
)

# Remove unwanted elements
$path = ($path.Split(';') | Where-Object { $_ -ne "${RekcodInstallationPath}\docker" }) -join ';'

# Set it
[System.Environment]::SetEnvironmentVariable(
    'PATH',
    $path,
    'Machine'
)

# Remove REKCOD env variable
[Environment]::SetEnvironmentVariable("REKCOD", $null ,"Machine")

Write-Output 'Rekcod has been uninstalled. See you soon :)' -ForegroundColor Yellow