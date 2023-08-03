# consider adding live migration of Prinmary DC to last host to be shutdown - DNS/name resolution
# Move-ClusterVirtualMachineRole -Name "Virtual Machine1" -Node node2
$mnspver = "0.0.0.0.1.9.4"
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

<#
#### dev process limit to csv contents ####
#$clusterNodesCSV = Get-ClusterNode | Export-Csv -path $hosts_csv
$clusterNodes = Import-csv -Path $hosts_csv 
#>

$clusterNodes = Get-ClusterNode | sort -Descending # production dynamically get all hosts in cluster

foreach ($clusterNode in $clusterNodes) {
        $Node = @()
        $Node = $($clusterNode.Name)
        Write-Host "Opening Remote Session to host: " $Node
        $HostRemoteSession = New-PSSession -ComputerName $Node
        Get-PSSession
        Write-Host "-----------------------------------------------`n"

        Write-Host "Finding all running VM guests on host: " $Node
        Invoke-Command -Session $HostRemoteSession -ScriptBlock {
            $RunningVMs = @()
            $RunningVMs = $(Get-VM | where state -eq 'Running')
            #$RunningVMs
            start-sleep 1

                #shutdown all running VM's...
                foreach ($RunningVM in $RunningVMs) {
                Stop-VM -name $($RunningVM.name) -Force -Confirm:$false -Verbose
                Write-Host "-----------------------------------------------`n"
                }

                #running VMs check/wait...
                    do
                    {
                        Write-Host (Get-Date)": Checking Virtual Machine Power State on $Node"
                        $RunningVMsChk = Get-VM | Where-Object -Property State -eq "Running"
                        if ($RunningVMsChk)
                        {
                            Get-Date
                            Write-Host "VM's still running sleeping for 30 Seconds..."
                            Start-Sleep -Seconds 30
                        }
                    }
                    until ($null -eq $RunningVMsChk)
                Start-sleep 20
            }
            start-sleep 1
        Remove-PSSession -Id $HostRemoteSession.Id

        Write-Host "Shutting down host: " $Node
        #Stop-computer -ComputerName $Node -force
}

Stop-transcript


<#
#>
