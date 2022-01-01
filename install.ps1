#Requires -RunAsAdministrator

## TODO Keep everything clean after installation

#region Tools
#endregion

#region Windows
## TODO Allow user to select DestinationPath
## TODO Set alias for rekcod=docker and rekcod-compose=docker-compose
## TODO Check if dockerd is already installed 
curl.exe -o docker.zip -LO https://download.docker.com/win/static/stable/x86_64/docker-20.10.8.zip 
Expand-Archive docker.zip -DestinationPath C:\
Remove-Item docker.zip
[Environment]::SetEnvironmentVariable("Path", "$($env:path);C:\docker", [System.EnvironmentVariableTarget]::Machine)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
dockerd --register-service
#endregion

#region WSL
## TODO Set alias for rekcod=docker and rekcod-compose=docker-compose
## TODO Allow user to select WSL installation folder
## TODO Check WSL is already enabled

## Enable WSL
wsl --install -d Ubuntu-20.04
wsl --set-default-version 2

## Download wsl-install.sh script on the wsl distro script and execute it


## Download wsl-systemd.sh script on the wsl distro and execute it


## Restart WSL distro to start using systemd
wsl -t Ubuntu-20.04

## Check WSL distro uses systemd

## Download wsl-docker.sh script on the wsl distro and execute it

#endregion
