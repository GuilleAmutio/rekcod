#Requires -RunAsAdministrator

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
## TODO Check WSL is already enabled
## Enable WSL
wsl --install -d Ubuntu-20.04
wsl --set-default-version 2

## Basic configuration
wsl --exec sudo apt get update
wsl --exec sudo apt upgrade -y

## Configure WSL distro to use systemd
wsl --exec sudo apt install -yqq fontconfig daemonize

# The command below has a problem when running from Windows
wsl --exec sudo echo "SYSTEMD_PID=$(ps -efw | grep '/lib/systemd/systemd --system-unit=basic.target$' | grep -v unshare | awk '{print $2}')
 
if [ -z "$SYSTEMD_PID" ]; then
   sudo /usr/bin/daemonize /usr/bin/unshare --fork --pid --mount-proc /lib/systemd/systemd --system-unit=basic.target
   SYSTEMD_PID=$(ps -efw | grep '/lib/systemd/systemd --system-unit=basic.target$' | grep -v unshare | awk '{print $2}')
fi
 
if [ -n "$SYSTEMD_PID" ] && [ "$SYSTEMD_PID" != "1" ]; then
    exec sudo /usr/bin/nsenter -t $SYSTEMD_PID -a su - $LOGNAME
fi" > /etc/profile.d/00-wsl2-systemd.sh

wsl -t Ubuntu-20.04
## Install Dockerd runtime
wsl --exec sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
wsl --exec curl -fsSL https://download.docker.com/linux/ubuntu/gpg | wsl --exec sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# OUT FILE ISSUE
# wsl --exec echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | wsl --exec sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
wsl --exec sudo apt-get update

# These packages MUST be marked as hold to prevent updates without previous testing
wsl --exec sudo apt-get install -y docker-ce docker-ce-cli containerd.io

## Configure WSL to launch dockerd on startup
wsl --exec sudo systemctl enable docker.service
wsl --exec sudo systemctl enable containerd.service
#endregion
