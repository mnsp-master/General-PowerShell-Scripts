$mnspver = "0.0.4"
Clear-Host
.\variables.ps1 #get var values from local file

$LogDir = @()

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

Write-Host "gsheet Student number column heading:" $FieldMatch01

Stop-Transcript