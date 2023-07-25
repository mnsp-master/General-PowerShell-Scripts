#############################
$CID="01155"
$workDir = "C:\Temp"
$DataDir="$WorkDir\$CID\Data"
$LogDir="$WorkDir\$CID\Logs"
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
$tempcsv="$DataDir\temp.csv"
$tempcsv2="$DataDir\temp2.csv"
$now = $(Get-Date -Format "dd MMMM yyyy HHHH:mm:s")


$mnspver = "0.0.0.0.0.1"
$hosts_csv = "$workDir\hosts.csv"
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

