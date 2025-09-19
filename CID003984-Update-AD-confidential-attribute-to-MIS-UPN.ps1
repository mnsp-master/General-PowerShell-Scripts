$mnspver = "0.0.8"
Clear-Host

$RootDir = "N:\PS1s\TID43264" # update as required
$LogDir = @()
$DataDir = @()
$LogDir =  "$RootDir\Logs"
$DataDir = "$RootDir\Data"
$tempcsv1 = "$DataDir\temp1.csv" #update as required

Write-Host "MNSP Version:" $mnspver
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"
$ADattribs = ("EmployeeNumber","SamAccountName","userPrincipalName","mail","HomeDirectory","DisplayName","CN","GivenName","Name","sn","distinguishedName","ObjectGUID","mnspAdminNumber")

$MISIDprefix = "MEN" #update as required to school short name: FGS, MEN etc...

Start-Transcript -Path $transcriptlog -Force -NoClobber -Append
clear-host

function DashedLine {
Write-host "-----------------------------------------------------------`n"
}

Write-Host "MNSP version number:" $mnspver

#Import user Data from CSV
try {
    $userdata = Import-Csv -Path $tempcsv1 -ErrorAction Stop
}
catch {
    Write-Error "Failed to import CSV from '$tempcsv1'. Error: $($_.Exception.Message)"
    exit 1 # Exit the script if CSV import fails
}

Write-host "Number of records to process:" $userdata.count

DashedLine

foreach ($user in $userdata){
    $MISIDsuffix = @()
    $MISIDsuffix = $($user.'Arbor Student ID')
    $MISID =  @()
    $MISID = $MISIDprefix + "-" + $MISIDsuffix
    $UPN = $($user.UPN)
    $User = $($user.Name)
    Write-Host "Processing using data:"
    Write-Host "Name  :" $User
    Write-Host "UPN   :" $UPN
    Write-Host "MIS ID:" $MISID
    Write-Host "`n"
    
    # Check for empty MISID
    if ($MISIDsuffix) {
        Write-Host "Searching for AD user with EmployeeNumber '$MISID'..."
        $userToProcess = Get-ADUser -Filter "EmployeeNumber -like '$MISID'" -Properties *

        # Check if user was found in AD
        if ($userToProcess) {
            Write-Host "AD attributes of user found:"
            $userToProcess | select-object $ADattribs
            
            # Check for missing UPN before attempting to update AD
            if ($UPN) {
                write-host "PS to process: Set-ADUser -Identity $($UserToProcess.ObjectGUID) -replace @{mnspAdminNumber="$UPN"}"
                
                try {
                    Set-ADUser -Identity $($UserToProcess.ObjectGUID) -replace @{mnspAdminNumber="$UPN"} -verbose -whatif ## Comment Whatif to Action
                } catch {
                    Write-Error "Failed to update user. Error: $($_.Exception.Message)"
                }
            } else {
                Write-Warning "!! SKIPPING ATTRIBUTE UPDATE !! - No UPN found for user '$User'. Skipping AD attribute update."
            }
        } else {
            # This block handles the "user not found" scenario
            Write-Warning "!! SKIPPING USER !! - User not found in AD for MIS ID: $MISID"
        }
        DashedLine
        
    } else { #null check for empty MISID
        Write-Warning "!! SKIPPING USER !! - NO MIS ID found for user"
        Dashedline
    }
}


Stop-Transcript