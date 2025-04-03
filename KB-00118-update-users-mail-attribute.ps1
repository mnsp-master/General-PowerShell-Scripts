#MNSP IT version: 1.0.1

$CID="C00639" #change ID - update as required
$root = "N:" # base drive letter for data/log folders - update as required

$baseou = "OU=####,OU=Students,OU=####,OU=Establishments,DC=#####,DC=#####" #update accordingly

$props = @("distinguishedName","sAMAccountname","mail") # AD properties to include in users array

$domain = "myschool.com" # mail domain to set - update as required.

#create required folder paths...
If(!(test-path -PathType container $DataDir))
{
      New-Item -ItemType Directory -Path $DataDir
}

If(!(test-path -PathType container $LogDir))
{
      New-Item -ItemType Directory -Path $LogDir
}

#begin logging all output...
Start-Transcript -Path $transcriptlog -Force -NoClobber -Append

#get all users in targetted OU and children...
$users = Get-ADUser -SearchBase $baseou -filter * -properties $props | select $props

#process all users in user array...
foreach ( $user in $users ) {

Write-host "Processing user        : " $user.sAMAccountname
Write-host "Proposed email address : " ($user.sAMAccountname + '@' + $domain).ToLower()

#set each user's mail attribute in array by concatenating samaccountname + @ + $domain and lowercase the lot...
#comment/uncomment the next line to do a dry/production run...
#Set-ADUser -EmailAddress ($user.sAMAccountname + '@' + $domain).ToLower() -Identity $user.sAMAccountname -verbose

#sleep 60

Write-host "--------------------------------------------------------------`n"

}


#create a csv of current users, handy if you need to capture current status, ahead of or after production run...
$users | Export-Csv -Path $DataDir\$(Get-date -Format yyyyMMdd-HHmmss).csv

Stop-Transcript
