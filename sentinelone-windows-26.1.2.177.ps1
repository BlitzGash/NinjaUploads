#Requires -RunAsAdministrator

$organization_key="8314cab1d28e09ca39502d1837c53beb7c165033744b913985b0178e50bd6415"
$agent_file_url="https://device-agent.app.us.guardz.com/api/device/agent-gateway/endpoint/installer/sentinel-one/2523909947733374289"
$agent_file_name="SentinelOneInstaller_windows_64bit_v26_1_2_177.exe"
$site_token="eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS1ncmR6LnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICI0MDE3NWFhOWNiM2FhNDI4ZjY3NWY0YTczNDVmZmExNTE1OTcxOGFiOTkwNzJkYWYyNWI3OTBhOGRmZDg1NjUyIn0="

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
