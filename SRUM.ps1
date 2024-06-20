#MIT License
#Copyright (c) 2024 dot-sys
$ErrorActionPreference = "SilentlyContinue"; 
Clear;
$SRUMPath = "C:\temp\dump\SRUM"
mkdir $SRUMPath -Force > $null; cd $SRUMPath;
if ((Read-Host "We will be downloading: `n- SrumECmd by Eric Zimmerman (https://github.com/EricZimmerman/Srum) `nThis will be fully local, no data will be collected.`nDo you agree to a PC Check and do you agree to download said tools? (Y/N)") -eq "Y") { "https://f001.backblazeb2.com/file/EricZimmermanTools/SrumECmd.zip" | ForEach-Object { $fileName = $_ -split '/' | Select-Object -Last 1; $filePath = "$SRUMPath\$fileName"; Invoke-WebRequest -Uri $_ -OutFile $filePath; if ($fileName -like '*.zip') { Expand-Archive -Path $filePath -DestinationPath $SRUMPath -Force } } } 
else {
	Clear;
    Write-Host "`n`n`nPC Check aborted by Player. Deleting File.`nThis may lead to consequences up to your servers admins.`n`n`n"
    & "$env:LOCALAPPDATA\temp\End.ps1"
	cd
	Start-Sleep -Seconds 5
	return
}

$windowsInstallDate = [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem).InstallDate).ToString('dd/MM/yyyy')
$sruDBCreationDate = (Get-Item "C:\Windows\System32\sru\SRUDB.dat").CreationTime.ToString('dd/MM/yyyy')
Write-Host "Windows Install at $windowsInstallDate"
Write-Host "SRUDB was created at $sruDBCreationDate"
Write-Host "`nDumping SRUM - This may take one minute!"

C:\temp\dump\SRUM\SrumECmd.exe -f "C:\Windows\System32\sru\SRUDB.dat" --csv "$SRUMPath\" | Out-Null

Remove-Item "$SRUMPath\SrumECmd.*" -r -force;
Remove-Item "$SRUMPath\*_SrumECmd_EnergyUsage_Output.csv" -force;
Remove-Item "$SRUMPath\*_SrumECmd_NetworkConnections_Output.csv" -force;
Remove-Item "$SRUMPath\*_SrumECmd_PushNotifications_Output.csv" -force;
Remove-Item "$SRUMPath\*_SrumECmd_vfuprov_Output.csv" -force;

Import-Csv -Path "$SRUMPath\*_SrumECmd_AppResourceUseInfo_Output.csv" | Where-Object { $_.'ExeInfo' -match '\.exe$' } |
Select-Object -Property 'Timestamp', 'ExeInfo', 'BackgroundBytesRead', 'BackgroundBytesWritten', 'ForegroundBytesRead', 'ForegroundBytesWritten' |
Sort-Object 'Timestamp' -Descending |
Export-Csv -Path "$SRUMPath\AppResourceUseInfo.csv" -Encoding utf8 -NoTypeInformation

Write-Host "`nDone! Opening Folder"
ii $SRUMPath
Start-Sleep -Seconds 5
Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt";
Set-Clipboard -Value $null;
cd\;
clear;
