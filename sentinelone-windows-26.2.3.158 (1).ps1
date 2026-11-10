#Requires -RunAsAdministrator

$organization_key="aec604e08f48edc141f3b5517e347cd5ec409c28724890deac48a8783fe31881"
$agent_file_url="https://device-agent.app.us.guardz.com/api/device/agent-gateway/endpoint/installer/sentinel-one/2590810753353298174"
$agent_file_name="SentinelOneInstaller_windows_64bit_v26_2_3_158.exe"
$site_token="eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS1ncmR6LnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICJmNTYwYmVkOWVhYmExZmZkZjgxODFiN2M0MWQzYjM3NWZlZmU2N2JiODMzMzg1Zjg4MTc2MjIwM2JhZTY1ZmE5In0="

$tmp = [System.IO.Path]::GetTempPath()
$tmp_folder_random__path = (Join-Path $tmp (-join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})))
Write-Output "Creating temp directory" $tmp_folder_random__path 
New-Item  -ItemType "directory"  $tmp_folder_random__path
$agent_file_path = (Join-Path  $tmp_folder_random__path $agent_file_name)
if (-Not ($site_token.Length -gt 90)) {
    Write-Output "Site Tokens are generally 90 characters or longer and are ASCII encoded."
    exit 1
}
$ProgressPreference = 'SilentlyContinue'
$apiHeaders = @{"Authorization"="Bearer $organization_key"}
Write-Output "Downloading agent installer" $agent_file_name
$agent_signed_url = Invoke-RestMethod -Uri $agent_file_url -Headers $apiHeaders -Method Get
Invoke-RestMethod -Uri $agent_signed_url -OutFile $agent_file_path -Method Get 
Write-Output "Installing agent"
$p = Start-Process -FilePath $agent_file_path -ArgumentList "-t $site_token -q" -PassThru -NoNewWindow
$dummy = $p.Handle # Cache the handle
$p.WaitForExit()
Write-Output "Installing finished with status code: [$($p.ExitCode)]" 
Write-Output "Removing temp file."
Remove-Item -Path $agent_file_path -Force
