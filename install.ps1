#Requires -RunAsAdministrator

# Supress warnings
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '')]
param()

##############################
#            MENU            #
##############################

# region variables
$RekcodInstallationPath = "C:\rekcod"
$Answer = "N"
$TmpPath
#endregion

##############################
#            MENU            #
##############################

#region usermenu
# Introduction about rekcod and ask user for installation path telling the default path
Write-Host @"
Welcome to rekcod installation wizard!
rekcod is a tool developed to guide the installation of docker for Windows and Linux container.
This tool uses a WSL distribution based on Ubuntu-20.04 and the binary of Docker for Windows.
"@ -ForegroundColor Blue
do {
    Write-Host 'The default installation path is '$RekcodInstallationPath'' -ForegroundColor Magenta
    $Answer = Read-Host -Prompt 'Would you like to change it? Default is no (Y/N)'

    if($Answer -ne "Y" -and $Answer -ne "N" ) {
        Write-Host 'Please, choose yes (Y) or no (N)' -ForegroundColor Yellow
    }
    elseif($Answer -eq "Y") {
        do {
            Write-Host 'Write the absolute path for rekcod installation. The path MUST exists.' -ForegroundColor Magenta
            $TmpPath = Read-Host -Prompt 'Please, select where rekcod will be installed'

            Write-Host 'Rekcod will be installed in '$TmpPath'' -ForegroundColor Magenta
            $Answer = Read-Host -Prompt 'Is this correct? (Y/N)'

            if($Answer -ne "Y" -and $Answer -ne "N" ) {
                Write-Host 'Please, choose yes (Y) or no (N)'
            }
            elseif($Answer -eq "Y") {
                if (-not (Test-Path $TmpPath)) {
                    Write-Host 'The path indicated does not exist. Please, select a valid one.' -ForegroundColor Red
                    $Answer = "N"
                }
                else {
                    $RekcodInstallationPath = $TmpPath + "/rekcod"
                    Write-Host 'Path is valid. Rekcod will be installed at '$RekcodInstallationPath'' -ForegroundColor Green
                }
            }
        } while ($Answer -ne "Y")
    }
} while ($Answer -ne "Y" -and $Answer -ne "N")

if (-not (Test-Path $RekcodInstallationPath)){
    mkdir $RekcodInstallationPath
}

# Set installation folder as an env variable
[Environment]::SetEnvironmentVariable("REKCOD", "${RekcodInstallationPath}", [System.EnvironmentVariableTarget]::Machine)

# Set the path to the profile
$RekcodProfile = "${RekcodInstallationPath}\profile"

#endregion

##############################
#           WINDOWS          #
##############################

#region windows

## Docker CLI
Write-Host 'Installing Docker for Windows...' -ForegroundColor Blue
Invoke-WebRequest "https://download.docker.com/win/static/stable/x86_64/docker-20.10.8.zip" -OutFile "docker.zip"
Expand-Archive docker.zip -DestinationPath $RekcodInstallationPath
Remove-Item docker.zip
[Environment]::SetEnvironmentVariable("Path", "$($env:path);$RekcodInstallationPath\docker", [System.EnvironmentVariableTarget]::Machine)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
dockerd --register-service

## docker-compose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $RekcodInstallationPath\docker\docker-compose.exe

Write-Host 'Docker for Windows was installed successfully.' -ForegroundColor Green

#endregion

##############################
#             WSL            #
##############################

#region wsl

## Create WSL distro
Write-Host 'Installing WSL distro for Linux containers...' -ForegroundColor Blue

## Download rekcod distro
mkdir ${RekcodInstallationPath}/tools
Invoke-WebRequest "https://github.com/GuilleAmutio/rekcod/releases/download/v0.1.1-alpha/rekcod-wsl.tar" -Outfile "${RekcodInstallationPath}\tools\rekcod-wsl.tar"

### Copy scripts and files
Copy-Item ./profile/ $RekcodInstallationPath -Recurse
Copy-Item ./wsl-scripts/ $RekcodInstallationPath -Recurse
Copy-Item ./pwsh-scripts/ $RekcodInstallationPath -Recurse
Copy-Item uninstall.ps1 $RekcodInstallationPath
Copy-Item rekcod-start.ps1 $RekcodInstallationPath
Copy-Item rekcod-stop.ps1 $RekcodInstallationPath
Copy-Item rekcod-switch.ps1 $RekcodInstallationPath

wsl --import rekcod-wsl $RekcodInstallationPath ${RekcodInstallationPath}\tools\rekcod-wsl.tar
wsl --set-version rekcod-wsl 2

## Call wsl-install.sh script from inside the WSl distro
Write-Host 'Installing WSL distro...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./wsl-scripts/wsl-install.sh

## Call wsl-systemd.sh script from inside the WSl distro
Write-Host 'Enabling systemd...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./wsl-scripts/wsl-systemd.sh

## Restart WSL distro to start using systemd
wsl -t rekcod-wsl

## Call wsl-expose.sh script from inside the WSL distro
Write-Host 'Creating service to expose Docker...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./wsl-scripts/wsl-expose.sh

## Call wsl-service.sh script from inside the WSL distro
Write-Host 'Enabling service to expose Docker...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./wsl-scripts/wsl-service.sh

## Call wsl-docker.sh script from inside the WSl distro
Write-Host 'Installing Docker in WSL...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./wsl-scripts/wsl-docker.sh

Write-Host 'WSL distro with Docker was installed successfully.' -ForegroundColor Green
wsl -t rekcod-wsl

#endregion

##############################
#        Configuration       #
##############################

#region configuration

## Check if a Microsoft profile exist
if (!(Test-Path -Path $PROFILE))
{
    New-Item -Type File -Path $PROFILE -Force
}

## Copy the content of the profile into a temporary profile
Copy-Item $PROFILE "$RekcodProfile\old-profile.ps1"

## Add the rekcod profile
Write-Host "" >> $PROFILE
Get-Content "${RekcodProfile}\rekcod-profile.ps1" >> $PROFILE

## Load the new profile
. $PROFILE

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Create link to use Linux from Windows
docker context create lin --docker host=tcp://127.0.0.1:2375

## Create link to use Windows. Instead of using the default one
docker context create win --docker host=npipe:////./pipe/docker_engine
docker context use win

#endregion

Write-Host 'Rekcod installation has finished.' -ForegroundColor Green