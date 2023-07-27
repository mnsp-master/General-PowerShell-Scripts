clear-host
Get-Date
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

$OutFile = "C:\Temp\MNSP\cid01155-powerdown-clustered-hyperv-guests-and-hosts.ps1"
$GitRawSource = "https://raw.githubusercontent.com/mnsp-master/General-PowerShell-Scripts/main/cid01155-powerdown-clustered-hyperv-guests-and-hosts.ps1"
Remove-Item $OutFile -Force

Invoke-WebRequest -Uri $GitRawSource -OutFile $OutFile -Headers @{"Cache-Control"="no-cache"} -Verbose

Get-Content -Path $OutFile | select -First 5
