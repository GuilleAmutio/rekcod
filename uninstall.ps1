#!Requires -RunAsAdministrator

$RekcodInstallationPath = [System.Environment]::GetEnvironmentVariable('REKCOD')

# Stop docker before uninstall
./stop.ps1

# Unregister dockerd service
dockerd --unregister-service

# Unregister WSL distribution
wsl --unregister rekcod-wsl

## TODO Remove powershell profile

# Remove installation folder
Remove-Item $RekcodInstallationPath -Recurse

# Get PATH variable
$path = [System.Environment]::GetEnvironmentVariable(
    'PATH',
    'Machine'
)
# Remove unwanted elements
$path = ($path.Split(';') | Where-Object { $_ -ne "${RekcodInstallationPath}/docker" }) -join ';'
# Set it
[System.Environment]::SetEnvironmentVariable(
    'PATH',
    $path,
    'Machine'
)

# Remove REKCOD env variable
[Environment]::SetEnvironmentVariable("REKCOD", $null ,"Machine")