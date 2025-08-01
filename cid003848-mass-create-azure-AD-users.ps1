$mnspver = "0.0.2"
Clear-Host
$CID = "" #Change ID e.g: C09826
$LogDir = @()
$LogDir = "$env:USERPROFILE\Documents\PS1s\$CID\Logs"
$tempcsv1 = "$env:USERPROFILE\Documents\PS1s\$CID\Data\tempcsv1.csv"
Write-Host "MNSP Version:" $mnspver
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
Start-Transcript -Path $transcriptlog -Force -NoClobber -Append
clear-host

function DashedLine {
Write-host "-----------------------------------------------------------`n"
}

# --- Import School Data from CSV ---
try {
    $OUdata = Import-Csv -Path $tempcsv1 -ErrorAction Stop
}
catch {
    Write-Error "Failed to import CSV from '$tempcsv1'. Error: $($_.Exception.Message)"
    exit 1 # Exit the script if CSV import fails
}



Stop-Transcript