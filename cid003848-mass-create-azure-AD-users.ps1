$mnspver = "0.0.43"
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
Write-Host "MIS Site Prefix:" $MISsitePrefix
DashedLine

foreach ($user in $VerifiedUserData) {
    
    $DisplayName = $user."Name"
    $FirstName = $User."FirstName"
    $LastName = $User."LastName"
    $Email = $User."Email20Chars"
    $ArborID = $User."Arbor Student ID"
    $DestOU = [int] $user."NC Year(s) for today" #set var as interger
    $MISid = $user."Arbor Student ID" # DEV 
    $MISidComplete = "$MISsitePrefix-$MISid" #concatenate sitename hyphen and MIS id number e.g: SCH-292 students
    $samAccountName = $Email.Split('@')[0]

    #add leading zero if required: to create consitent OUs YEAR07 not YEAR7: 
        if ( $DestOU -le 9) {
            #Write-host "Target Year group less than or equal to 9..."
            $UpdatedDestOU = @()
            $UpdatedDestOU = $($MISsitePrefix + "-Year" + "0" + $DestOU)
            } else {
            $UpdatedDestOU = $($MISsitePrefix+ "-Year" + $DestOU)
            }
    $FullOuPath = $UpdatedDestOU + "," + $ADBaseDN

        $pwd = $(Invoke-WebRequest -Uri $pwdUrl -UseBasicParsing)
            #$pwd.Content
            #$pwd.StatusCode
            if ($pwd.StatusCode -eq 200) {
            #Write-Host "proceed with pwd reservation"
            $password = $($pwd.Content)
            #Write-Host "Password: " $password
            } else {
            Write-Error "No Webserver, or pwd received"
            $password = $pwdFailsafe
            }

    Write-Host "Processing user: $DisplayName"
    Write-Host "Firstname: $FirstName"
    Write-Host "Lastname: $LastName"
    Write-Host "Email: $Email"
    Write-Host "Arbor ID: $MISid"
    Write-Host "LDAP EmployeeID: $MISidComplete"
    Write-Host "Destination OU: $UpdatedDestOU"
    Write-Host "Full OU Path: $FullOuPath"
    Write-Host "Password: $password"  
    
    $password = ConvertTo-SecureString -AsPlainText $password -Force
    
    #create AD user
   
                $aduserProps = @{
                    Name = $DisplayName
                    UserprincipalName = $Email
                    GivenName = $FirstName
                    Surname = $LastName
                    DisplayName = $DisplayName
                    path = $FullOuPath
                    AccountPassword = $password
                    EmailAddress = $Email
                    EmployeeID = $MISidComplete
                    enabled = $true
                }

            Write-Host "New AD user Properties:" $aduserProps
            new-aduser @aduserProps -WhatIf

            Set-ADUser -Identity $aduser -Add @{mnspAdminNumber="$UPN"} -verbose -whatif ## Comment Whatif to Action

        DashedLine
}

Stop-Transcript
