#Requires -RunAsAdministrator

# All TODOs
## TODO Clear console for each action. Keep it clean!
## !BUG Docker is only started and managed from an admin prompt. Check behaviour and user-groups. Create one if necessary

# Variables
$RekcodInstallationPath = "C:\rekcod"
$Answer = "N"
$TmpPath
$FullControll = [System.Security.AccessControl.FileSystemRights]::FullControll
$Allow = [System.Security.AccessControl.AccessControlType]::Allow
$Account = "$env:UserDomain\$env:Username"

##############################
#            MENU            #
##############################

#region usermenu
# Introduction about rekcod and ask user for installation path telling the default path
Write-Output @"
Welcome to rekcod installation wizard!
rekcod is a tool developed to guide the installation of docker for Windows and Linux container.
This tool uses a WSL distribution based on Ubuntu-20.04 and the binary of Docker for Windows.
"@ -ForegroundColor Blue
do {
    Write-Output 'The default installation path is '$RekcodInstallationPath'' -ForegroundColor Magenta
    $Answer = Read-Host -Prompt 'Would you like to change it? Default is no (Y/N)'

    if($Answer -ne "Y" -and $Answer -ne "N" ) {
        Write-Output 'Please, choose yes (Y) or no (N)' -ForegroundColor Yellow
    }
    elseif($Answer -eq "Y") {
        do {
            Write-Output 'Write the absolute path for rekcod installation. The path MUST exists.' -ForegroundColor Magenta
            $TmpPath = Read-Host -Prompt 'Please, select where rekcod will be installed'

            Write-Output 'Rekcod will be installed in '$TmpPath'' -ForegroundColor Magenta
            $Answer = Read-Host -Prompt 'Is this correct? (Y/N)'

            if($Answer -ne "Y" -and $Answer -ne "N" ) {
                Write-Output 'Please, choose yes (Y) or no (N)'
            }
            elseif($Answer -eq "Y") {
                if (-not (Test-Path $TmpPath)) {
                    Write-Output 'The path indicated does not exist. Please, select a valid one.' -ForegroundColor Red
                    $Answer = "N"
                }
                else {
                    $RekcodInstallationPath = $TmpPath + "/rekcod"
                    Write-Output 'Path is valid. Rekcod will be installed at '$RekcodInstallationPath'' -ForegroundColor Green
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

#region Windows

## Docker CLI
Write-Output 'Installing Docker for Windows...' -ForegroundColor Blue
curl.exe -o docker.zip -LO https://download.docker.com/win/static/stable/x86_64/docker-20.10.8.zip
Expand-Archive docker.zip -DestinationPath $RekcodInstallationPath
Remove-Item docker.zip
[Environment]::SetEnvironmentVariable("Path", "$($env:path);$RekcodInstallationPath\docker", [System.EnvironmentVariableTarget]::Machine)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
dockerd --register-service

## docker-compose
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $RekcodInstallationPath\docker\docker-compose.exe

Write-Output 'Docker for Windows was installed successfully.' -ForegroundColor Green

#endregion

##############################
#             WSL            #
##############################

#region WSL

## Create WSL distro
Write-Output 'Installing WSL distro for Linux containers...' -ForegroundColor Blue

## Download rekcod distro
mkdir ${RekcodInstallationPath}/tools
Invoke-WebRequest "https://github.com/GuilleAmutio/rekcod/releases/download/v0.1.1-alpha/rekcod-wsl.tar" -Outfile "${RekcodInstallationPath}\tools\rekcod-wsl.tar"

### Copy scripts and files
Copy-Item ./profile/ $RekcodInstallationPath -Recurse
Copy-Item ./scripts/ $RekcodInstallationPath -Recurse
Copy-Item uninstall.ps1 $RekcodInstallationPath
Copy-Item start.ps1 $RekcodInstallationPath
Copy-Item stop.ps1 $RekcodInstallationPath

wsl --import rekcod-wsl $RekcodInstallationPath ${RekcodInstallationPath}\tools\rekcod-wsl.tar
wsl --set-version rekcod-wsl 2

## Call wsl-install.sh script from inside the WSl distro
Write-Output 'Installing WSL distro...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./scripts/wsl-install.sh

## Call wsl-systemd.sh script from inside the WSl distro
Write-Output 'Enabling systemd...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./scripts/wsl-systemd.sh

## Restart WSL distro to start using systemd
wsl -t rekcod-wsl

## Call wsl-expose.sh script from inside the WSL distro
Write-Output 'Creating service to expose Docker...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./scripts/wsl-expose.sh

## Call wsl-service.sh script from inside the WSL distro
Write-Output 'Enabling service to expose Docker...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./scripts/wsl-service.sh

## Call wsl-docker.sh script from inside the WSl distro
Write-Output 'Installing Docker in WSL...' -ForegroundColor Yellow
wsl -d rekcod-wsl --exec ./scripts/wsl-docker.sh

Write-Output 'WSL distro with Docker was installed successfully.' -ForegroundColor Green
wsl -t rekcod-wsl

#endregion

##############################
#        Configuration       #
##############################

#region Configuration

## Check if a Microsoft profile exist
if (!(Test-Path -Path $PROFILE))
{
    New-Item -Type File -Path $PROFILE -Force
}

## Copy the content of the profile into a temporary profile
Copy-Item $PROFILE "$RekcodProfile\old-profile.ps1"

## Add the rekcod profile
Write-Output "" >> $PROFILE
Get-Content "${RekcodProfile}\rekcod-profile.ps1" >> $PROFILE

## Load the new profile
. $PROFILE

## Grant normal users access to docker
$Info = New-Object "System.IO.DirectoryInfo" -ArgumentList "\\.\pipe\docker_engine"
$AccessControl = $Info.GetAccesControl()
$Rule = New-Object "System.Security.AccessControl.FileSystemAccessRule" -ArgumentList $Account,$FullControll,$Allow
$AccessControl.AddAccessRule($Rule)
$Info.SetAccessControl($AccessControl)

#endregion

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
