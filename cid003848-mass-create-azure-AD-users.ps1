$mnspver = "0.0.31"
Clear-Host

$LogDir = @()
$LogDir = "$PSScriptRoot\Logs"

#Remove-variable -name "FieldMatch01"
#Remove-variable -name "FieldString"


#set variables from local file
Get-Content "$PSScriptRoot\variables.txt" | Where-Object {$_.length -gt 0} | Where-Object {!$_.StartsWith("#")} | ForEach-Object { 
$var = $_.Split('=',2).Trim() 
    try {
        New-Variable -Scope Script -Name $var[0] -Value $var[1] }
        catch {
            Write-warning "Variable already exists"
        }
}

Write-Host "MNSP Version:" $mnspver
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
Start-Transcript -Path $transcriptlog -Force -NoClobber -Append
clear-host

#get-variable

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
    #$VerifiedUserData = Get-Content -path $tempcsv4 | convertFrom-csv | where { $_.$FieldMatch01 -like '$FieldString' } #import where field like $FieldMatch01
    #$VerifiedUserData = Get-Content -path $tempcsv4 | convertFrom-csv | where-object { 
#    $_.$FieldMatch01 -like $FieldString -and 
#    $_.$Fieldmatch02 -match '^[0-9]+$' #Numeric values only - excludes - R N1 N2 etc

    $VerifiedUserData = import-csv -path $tempcsv4 | where-object { $_.$FieldMatch01 -eq $FieldString -and $_.$Fieldmatch02 -match '^[0-9]+$' }
}
catch {
    Write-Error "Failed to import CSV from '$tempcsv4'. Error: $($_.Exception.Message)"
    exit 1 # Exit the script if CSV import fails
}

Write-Host "School to process: $FieldMatch01 : $FieldString "
Write-Host "Number of records matching selection criteria:" $VerifiedUserData.count
DashedLine

foreach ($user in $VerifiedUserData) {
    
    $FirstName = $User."FirstName"
    $LastName = $User."LastName"
    $Email = $User."Email20Chars"
    $ArborID = $User."Arbor Student ID"
    $DestOU = [int] $user."NC Year(s) for today" #set var as interger
    $MISid = $user."Arbor Student ID" # DEV 
    $MISidComplete = "$MISsitePrefix-$MISid" #concatenate sitename hyphen and MIS id number e.g: SCH-292 students

    #add leading zero if required: to create consitent OUs YEAR07 not YEAR7: 
        if ( $DestOU -le 9) {
            Write-host "Target Year group less than or equal to 9..."
            $UpdatedDestOU = @()
            $UpdatedDestOU = $($MISsitePrefix + "-Year" + "0" + $DestOU)
            } else {
            $UpdatedDestOU = $($MISsitePrefix+ "-Year" + $DestOU)
            }

    Write-Host "Processing user:"
    Write-Host "Firstname: $FirstName"
    Write-Host "Lastname: $LastName"
    Write-Host "Email: $Email"
    Write-Host "Arbor ID: $MISid"
    Write-Host "SalamanderID:" $MISidComplete
    Write-Host "Destination OU:" $UpdatedDestOU
    DashedLine


}

Stop-Transcript
