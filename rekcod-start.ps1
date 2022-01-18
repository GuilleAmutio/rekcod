# Variable
$RekcodInstallationPath = [System.Environment]::GetEnvironmentVariable('REKCOD')

# Start dockerd service on Windows
Write-Host "Starting Docker for Windows..." -ForegroundColor Yellow

# Start WSL distro
Write-Host "Starting Docker for Linux..." -ForegroundColor Yellow

# Call script
powershell -File ${RekcodInstallationPath}\pwsh-scripts\pwsh-start.ps1

Write-Host "Docker is up and ready! Happy coding!" -ForegroundColor Green

# Allow non-admin users to use Docker
$Info = New-Object "System.IO.DirectoryInfo" -ArgumentList "\\.\pipe\docker_engine"
$AccessControl = $Info.GetAccessControl()
$Rule = New-Object "System.Security.AccessControl.FileSystemAccessRule" -ArgumentList $Account,$FullControl,$Allow
$AccessControl.AddAccessRule($Rule)
$Info.SetAccessControl($AccessControl)