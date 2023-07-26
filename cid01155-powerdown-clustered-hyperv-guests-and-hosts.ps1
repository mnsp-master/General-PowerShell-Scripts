$mnspver = "0.0.0.0.1.1"
$CID="01155"
$WorkDir = "C:\Temp\MNSP"
$DataDir="$WorkDir\C$CID\Data"
$LogDir="$WorkDir\C$CID\Logs"
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
$now = $(Get-Date -Format "dd MMMM yyyy HHHH:mm:s")
$hosts_csv = "$DataDir\hosts.csv"

if ( Test-Path $LogDir ) {
    } else {
        Write-Host "$logDir not exist, creating..."
        New-Item -Path $LogDir -ItemType Directory -verbose
    }

if ( Test-Path $DataDir ) {
    } else {
        Write-Host "$DataDir not exist, creating..."
        New-Item -Path $DataDir -ItemType Directory -verbose
    }

start-transcript -path $transcriptlog

#Clear-Content $hosts_csv

#$clusterNodesCSV = Get-ClusterNode | Export-Csv -path $hosts_csv
$clusterNodes = Import-csv -Path $hosts_csv # dev process limit to csv contents

#$clusterNodes = Get-ClusterNode | sort -Descending # production dynamically get all hosts in cluster

foreach ($clusterNode in $clusterNodes) {
        Write-Host "Opening Remote Session to host: " $($clusterNode.Name)
        $HostRemoteSession = New-PSSession -ComputerName $($clusterNode.Name)
        Get-PSSession
        Write-Host "-----------------------------------------------`n"

        Write-Host "Finding all running VM guests on host: " $($clusterNode.Name)
        Invoke-Command -Session $HostRemoteSession -ScriptBlock {
            $RunningVMs = @()
            $RunningVMs = $(Get-VM | where state -eq 'Running')
            #$RunningVMs
            start-sleep 1

                foreach ($RunningVM in $RunningVMs) {
                Write-Host "Stop-VM -name $($RunningVM.name) -Force -verbose -Confirm:$false -Verbose"
                Write-Host "-----------------------------------------------`n"
                }
            }
            start-sleep 1
        Remove-PSSession -Id $HostRemoteSession.Id
}

Stop-transcript


<#
#running VMs check/wait...
do
{
    Write-Host (Get-Date)": Checking Virtual Machine Power State on $($clusterNode.Name)"
    $RunningVMsChk = Get-VM | Where-Object -Property State -eq "Running"
    if ($RunningVMsChk)
    {
        Start-Sleep -Seconds 10
    }
}
until ($null -eq $RunningVMs)

Restart-Computer -Force
#>