$mnspver = "0.0.13"
Clear-Host
$LogDir = @()
$LogDir = "$env:USERPROFILE\Documents\PS1s\$CID\Logs"
Write-Host ""
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"

function DashedLine {
Write-host "-----------------------------------------------------------`n"
}

Write-Host $(Get-Date)
Write-Host "MNSP Version" $mnspver

Write-Host "Checking for $LogDir"

If(!(test-path -PathType container $LogDir))
{
      Write-Warning "$LogDir does not exist creating..."
      New-Item $LogDir -ItemType Directory -Verbose
}

Start-Transcript -Path $transcriptlog -Force -NoClobber -Append

ChildOUs = Import-csv -path $tempcsv1

foreach ($ChildOU in $ChildOUs) {
    try {
        Get-ADOrganizationalUnit -identity $fullOUpath -ErrorAction Stop
        Write-Host "The OU '$childOU' exists under '$ParentOU'"
    }
    catch {
        Write-Host "The OU '$ChildOU' does not exist under '$parentOU' or an error occurred: $($_.Exception.Message)"
        
    }
}
Stop-Transcript