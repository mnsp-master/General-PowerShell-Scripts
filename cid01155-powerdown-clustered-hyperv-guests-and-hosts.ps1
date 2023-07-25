#############################
$CID="01155"
$WorkDir = "C:\Temp"
$DataDir="$WorkDir\C$CID\Data"
$LogDir="$WorkDir\C$CID\Logs"
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
$now = $(Get-Date -Format "dd MMMM yyyy HHHH:mm:s")
$mnspver = "0.0.0.0.0.1"
$hosts_csv = "$DataDir\hosts.csv"

if ( Test-Path $LogDir ) {
    } else {
        Write-Host "$logDir not exist, creating..."
        New-Item -Path $LogDir -ItemType Directory -verbose
    }

if ( Test-Path $DataDir ) {
    } else {
        Write-Host "$logDir not exist, creating..."
        New-Item -Path $LogDir -ItemType Directory -verbose
    }

start-transcriptlog -path $transcriptlog

Clear-Content $hosts_csv

$clusterNodesCSV = Get-ClusterNode | Export-Csv -path $hosts_csv
$clusterNodes = Import-csv -Path $hosts_csv # dev process limit to csv contents

#$clusterNodes = Get-ClusterNode | sort -Descending # production dynamically get all hosts in cluster

foreach ($clusterNode in $clusterNodes) {
Write-Host "Finding all running VM guests on host: " $clusterNode

        $HostRemoteSession = New-PSSession -ComputerName $clusterNode
        Get-PSSession
        Invoke-Command -Session $HostRemoteSession -ScriptBlock {
            $RunningVMs = @()
            $RunningVMs = $(Get-VM | where state -eq 'Running')
            #$RunningVMs
            start-sleep 1

                foreach ($RunningVM in $RunningVMs) {
                Write-Host "Stop-VM -name $($RunningVM.name) -Verbose"
                Write-Host "-----------------------------------------------`n"
                }
            }
            start-sleep 1
        Remove-PSSession -Id $HostRemoteSession.Id
}

   if (Test-Path -path $SimsInstancesCSV ) {

        Write-Host "$SimsInstancesCSV exists, deleting..."
        Remove-Item -Path $SimsInstancesCSV -Force
    }


Stop-transcript
