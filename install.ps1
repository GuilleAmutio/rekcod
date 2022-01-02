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
## TODO Use variables for paths

## Create WSL distro

### Select folder to install
mkdir C:/rekcod
mkdir C:/rekcod/scripts

### Copy scripts and files
Copy-Item scripts/ C:/rekcod/scripts
Copy-Item uninstall.ps1 C:/rekcod

wsl --import rekcod-wsl C:/rekcod tools/rekcod-wsl.tar
wsl --set-version rekcod-wsl 2

## Download wsl-install.sh script on the wsl distro script and execute it
wsl --exec ./scripts/wsl-install.sh

## Download wsl-systemd.sh script on the wsl distro and execute it
wsl --exec ./scripts/wsl-systemd.sh

## Restart WSL distro to start using systemd
wsl -t rekcod-wsl

## Download wsl-docker.sh script on the wsl distro and execute it
wsl --exec ./scripts/wsl-docker.sh

#endregion

#region Configuration

## Set 'rekcod' as an alias for the start.ps1 script


## Set 'rekcod off' as an alias for the stop.ps1 script


#endregion