#Requires -RunAsAdministrator

# All TODOs
## TODO Keep everything clean after installation
## TODO Check every download and execution works as expected
## TODO Check if dockerd is already installed before install
## TODO Check WSL is already enabled
## TODO Check the distro is in version 2
## TODO Specify which WSL distro should execute the commands. Something like 'wsl -d rekcod-wsl --exec echo "Hello world"
## TODO Write-Host for each step with a yellow color
## TODO Clear console for each menu iteration
## !BUG Docker is only started and managed from an admin prompt. Check behaviour and user-groups. Create one if necessary

# Variables
$RekcodInstallationPath = "C:/rekcod"
$Answer = "N"
$TmpPath

# Introduction about rekcod and ask user for installation path telling the default path
Write-Host @"
Welcome to rekcod installation wizard!
rekcod is a tool developed to guide the installation of docker for Windows and Linux container.
This tool uses a WSL distribution based on Ubuntu-20.04 and the binary of Docker for Windows.
"@
do {
    Write-Host 'The default installation path is '$RekcodInstallationPath''
    $Answer = Read-Host -Prompt 'Would you like to change it? Default is no (Y/N)'
    
    if($Answer -ne "Y" -and $Answer -ne "N" ) {
        Write-Host 'Please, choose yes (Y) or no (N)'
    }
    elseif($Answer -eq "Y") {
        do {
            Write-Host 'Write the absolute path for rekcod installation. The path MUST exists.'
            $TmpPath = Read-Host -Prompt 'Please, select where rekcod will be installed'

            Write-Host 'Rekcod will be installed in '$TmpPath''
            $Answer = Read-Host -Prompt 'Is this correct? (Y/N)'

            if($Answer -ne "Y" -and $Answer -ne "N" ) {
                Write-Host 'Please, choose yes (Y) or no (N)'
            }
            elseif($Answer -eq "Y") {
                if (-not (Test-Path $TmpPath)) {
                    Write-Host 'The path indicated does not exist. Please, select a valid one.'
                    $Answer = "N"
                }
                else {
                    $RekcodInstallationPath = $TmpPath + "/rekcod"
                    Write-Host 'Path is valid. Rekcod will be installed at '$RekcodInstallationPath''                    
                }
            }
        } while ($Answer -ne "Y")
    }
} while ($Answer -ne "Y" -and $Answer -ne "N")

### Select folder to install
if (-not (Test-Path $RekcodInstallationPath)){
    mkdir $RekcodInstallationPath
}

#region Windows

## Docker CLI
curl.exe -o docker.zip -LO https://download.docker.com/win/static/stable/x86_64/docker-20.10.8.zip 
Expand-Archive docker.zip -DestinationPath $RekcodInstallationPath
Remove-Item docker.zip
[Environment]::SetEnvironmentVariable("Path", "$($env:path);$RekcodInstallationPath\docker", [System.EnvironmentVariableTarget]::Machine)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
dockerd --register-service

## docker-compose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $RekcodInstallationPath\docker\docker-compose.exe

#endregion

#region WSL

## Create WSL distro

### Copy scripts and files
Copy-Item ./scripts/ $RekcodInstallationPath -Recurse
Copy-Item uninstall.ps1 $RekcodInstallationPath
Copy-Item start.ps1 $RekcodInstallationPath
Copy-Item stop.ps1 $RekcodInstallationPath

wsl --import rekcod-wsl $RekcodInstallationPath tools/rekcod-wsl.tar 
wsl --set-version rekcod-wsl 2

## Call wsl-install.sh script from inside the WSl distro
wsl --exec ./scripts/wsl-install.sh

## Call wsl-systemd.sh script from inside the WSl distro
wsl --exec ./scripts/wsl-systemd.sh

## Restart WSL distro to start using systemd
wsl -t rekcod-wsl

## Call wsl-docker.sh script from inside the WSl distro
wsl --exec ./scripts/wsl-docker.sh

#endregion

#region Configuration

## Set 'rekcod-start' as an alias for the start.ps1 script
Set-Alias rekcod-start $RekcodInstallationPath\start.ps1

## Set 'rekcod-off' as an alias for the stop.ps1 script
Set-Alias rekcod-shutdown $RekcodInstallationPath\stop.ps1

## Set 'rekcod' as an alias for 'docker'
Set-Alias rekcod docker

## Set 'rekcod-compose' as and alias for 'docker-compose'
Set-Alias rekcod-compose docker-compose

#endregion

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")