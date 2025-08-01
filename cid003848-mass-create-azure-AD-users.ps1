$mnspver = "0.0.18"
Clear-Host

$LogDir = @()
$LogDir = "$PSScriptRoot\Logs"

Remove-variable -name "FieldMatch01"
Remove-variable -name "FieldString"


#set variables from local file
Get-Content "$PSScriptRoot\variables.txt" | Where-Object {$_.length -gt 0} | Where-Object {!$_.StartsWith("#")} | ForEach-Object { 
$var = $_.Split('=',2).Trim() 
New-Variable -Scope Script -Name $var[0] -Value $var[1] 
}

Write-Host "MNSP Version:" $mnspver
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
Start-Transcript -Path $transcriptlog -Force -NoClobber -Append
clear-host

get-variable

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

# --- Import School Student Data from CSV ---
try {
    $VerifiedUserData = Get-Content -path $tempcsv4 | convertFrom-csv | where { $_.$FieldMatch01 -like '$FieldString' } #import where field like $FieldMatch01
}
catch {
    Write-Error "Failed to import CSV from '$tempcsv4'. Error: $($_.Exception.Message)"
    exit 1 # Exit the script if CSV import fails
}

Write-Host "$VerifiedUserData = Get-Content -path $tempcsv4 | convertFrom-csv | where { $_.$FieldMatch01 -like '$FieldString' }"
Write-Host "School to process:" $FieldMatch01
Write-Host "Number of records matching selection criteria:" $VerifiedUserData.count

Stop-Transcript
