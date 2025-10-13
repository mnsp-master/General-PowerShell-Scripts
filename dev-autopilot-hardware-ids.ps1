$mnspver = "0.0.1"
Clear-Host
$TID = "T03830" #Ticket ID e.g: T09826
$LogDir = @()
$LogDir = "$env:USERPROFILE\Documents\PS1s\$TID\Logs"
$tempcsv1 = "$env:USERPROFILE\Documents\PS1s\$TID\Data\tempcsv1.csv"
Write-Host "MNSP Version:" $mnspver
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
Start-Transcript -Path $transcriptlog -Force -NoClobber -Append
clear-host




function DashedLine {
Write-host "-----------------------------------------------------------`n"
}

<#
$hostnames = "C:\temp\autopilot_hosts.csv"
$hosts = Import-Csv -Path $hostnames
#>

$hosts = ("MNSP-005288","MNSP-005289","MNSP-008625","MNSP-006046")

foreach ($HostName in $Hosts) {
    DashedLine
    Write-Host "Attempting connection to host: $Hostname"
    if (Test-Connection -ComputerName $HostName -Quiet) {
    Write-Host "Connection successful..."
    Get-WindowsAutoPilotInfo.ps1 -ComputerName $HostName -outputfile C:\temp\autopilot1.csv -Append
    DashedLine

    } else {
    
    Write-Warning "Could not connect to host: $Hostname"
    DashedLine
    }

}

stop-transcript

    <#
    $SrvStatus = get-service -Name WinRM -ComputerName $HostName
    $srvStatus.Status
    if ($srvStatus.Status -ne "Running") {
        Write-Host "Service Stopped - Starting..."
        Invoke-Command -ComputerName $HostName -ScriptBlock {Start-Service -Name WinRM}
        }
        #>
