$mnspver = "0.0.76"
Clear-Host

$LogDir = @()
$LogDir = "$PSScriptRoot\Logs"

$ADattribs = ("EmployeeID","EmployeeNumber","SamAccountName","userPrincipalName","mail","DisplayName","CN","GivenName","Name","sn","distinguishedName","ObjectGUID","mnspAdminNumber")

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

#Import School Student Data from CSV
try {
    $VerifiedUserData = import-csv -path $tempcsv4 | where-object { $_.$FieldMatch01 -eq $FieldString -and $_.$Fieldmatch02 -match '^[0-9]+$' }
}
catch {
    Write-Error "Failed to import CSV from '$tempcsv4'. Error: $($_.Exception.Message)"
    exit 1 # Exit the script if CSV import fails
}

Write-Host "School to process: $FieldMatch01 : $FieldString "
Write-Host "Number of records matching selection criteria:" $VerifiedUserData.count
Write-Host "MIS Site Prefix:" $MISsitePrefix


#prepare user details capture csv
Write-Host "emptying $tempcsv2 of any existing data..."
Clear-Content $tempcsv2
sleep 1
$UserInfoCSVheader | out-file -filepath $tempcsv2 -Append #create blank csv with simple header

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
    $UPN = $user."UPN"
    $samAccountName = $Email.Split('@')[0]

    #add leading zero if required: to create consitent OUs YEAR07 not YEAR7: 
        if ( $DestOU -le 9) {
            #Write-host "Target Year group less than or equal to 9..."
            $UpdatedDestOU = @()
            $UpdatedDestOU = $($MISsitePrefix + "-Year" + "0" + $DestOU)
            } else {
            $UpdatedDestOU = $($MISsitePrefix+ "-Year" + $DestOU)
            }
    $FullOuPath = "OU=" + $UpdatedDestOU + "," + $ADBaseDN

    #password generator...
        $pwd = @()
        try {
        $pwd = $(Invoke-WebRequest -Uri $pwdUrl -UseBasicParsing)
        $Password = $($pwd.content)
        }
            catch {
            Write-Error "No Webserver, or pwd received"
            $password = $pwdFailsafe
        }

    Write-Host "Processing user: $DisplayName"
    Write-Host "Firstname: $FirstName"
    Write-Host "Lastname: $LastName"
    Write-Host "Email: $Email"
    Write-Host "saMaccountName: $samAccountName"
    Write-Host "Arbor ID: $MISid"
    Write-Host "LDAP EmployeeID: $MISidComplete"
    Write-Host "UPN: $UPN"
    Write-Host "Destination OU: $UpdatedDestOU"
    Write-Host "Full OU Path: $FullOuPath"
    Write-Host "Password: $password"  
    
    $PlainPassword = $Password
    $password = ConvertTo-SecureString -AsPlainText $password -Force
    
    #Confirm if user already exists...
    Write-Host "Checking if proposed user already exists (using AD attribute: EmployeeID (MIS ID))"
    
    $UserToProcess = @()
    $UserToProcess = $(Get-ADUser -Filter "EmployeeID -Like '$MISidComplete'" -Properties * | select-object $ADattribs)

    if ( -not $UserToProcess) {

    #create AD user
   
                $aduserProps = @{
                    Name = $DisplayName
                    UserPrincipalName = $Email
                    SamAccountName = $SamAccountName
                    GivenName = $FirstName
                    Surname = $LastName
                    DisplayName = $DisplayName
                    Path = $FullOuPath
                    AccountPassword = $password
                    EmailAddress = $Email
                    EmployeeID = $MISidComplete
                    enabled = $true
                }

            Write-Host "Proceeding with User: $email Creation..."
            new-aduser @aduserProps #-whatif

            start-sleep 2
            
            #confirm created user attribs
            $ProcessedUser = $(Get-ADUser -Filter "EmployeeID -Like '$MISidComplete'" -Properties * | select-object $ADattribs)
            
            if ($ProcessedUser) {
                #set UPN
                Write-Host "Set-ADUser -Identity $samAccountName -Add @{mnspAdminNumber="$UPN"} -verbose"
                Set-ADUser -Identity $samAccountName -Add @{mnspAdminNumber="$UPN"} -verbose #-whatif ## Comment Whatif to Action - set UPN
                
                Write-Host "Processed user details:"
                $ProcessedUser

                #capture initial credentials
                "$firstname,$lastname,$DisplayName,$Email,$SamAccountName,$PlainPassword" | out-file -filepath $tempcsv2 -Append 

                } else {
                Write-Warning "No user found with employeeID: '$MISidComplete'"
                }
            
        DashedLine
    } else {
        Write-Warning "User: $email already exists skipping user creation..."

    }
}

Stop-Transcript

<#

<#
#Import School Data from CSV
try {
    $OUdata = Import-Csv -Path $tempcsv1 -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to import CSV from '$tempcsv1'. Error: $($_.Exception.Message)"
        exit 1 # Exit the script if CSV import fails
}

$VerifiedUserData = Get-Content -path $tempcsv4 | convertFrom-csv | where { $_.$FieldMatch01 -like '$FieldString' } #import where field like $FieldMatch01
    $VerifiedUserData = Get-Content -path $tempcsv4 | convertFrom-csv | where-object { 
    $_.$FieldMatch01 -like $FieldString -and 
    $_.$Fieldmatch02 -match '^[0-9]+$' #Numeric values only - excludes - R N1 N2 etc

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

#>