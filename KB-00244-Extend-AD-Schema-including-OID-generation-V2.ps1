#MNSP Version 1.0.8

Clear-Host
$LogDir = @()
Write-Host ""
$LogDir = Read-Host "Path for Transcript log, e.g D:\Temp\ADschemaExtension" 
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"

Write-Host "Checking for $LogDir"

If(!(test-path -PathType container $LogDir))
{
      Write-Warning "$LogDir does not exist exiting script..."
      throw
}

Start-Transcript -Path $transcriptlog -Force -NoClobber -Append

#generate OID
$OID = "REPLACE_THIS"

$Prefix = "1.2.840.113556.1.8000.2554"
$GUID = [System.Guid]::NewGuid().ToString()
$GUIDPart = @()
$GUIDPart += [UInt64]::Parse($GUID.SubString(0,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(4,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(9,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(14,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(19,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(24,6), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(30,6), "AllowHexSpecifier")
$OID = [String]::Format("{0}.{1}.{2}.{3}.{4}.{5}.{6}.{7}", $Prefix, $GUIDPart[0], $GUIDPart[1], $GUIDPart[2], $GUIDPart[3], $GUIDPart[4], $GUIDPart[5], $GUIDPart[6])
Write-Host $OID -ForegroundColor Green

Start-sleep 5

# get AD schema path
$adSchema = (Get-ADRootDSE).schemaNamingContext
Write-Host "AD Schema Path:" $adSchema

# get user schema
$userSchema = Get-ADObject -SearchBase $adSchema -Filter "Name -eq 'User'"
Write-Host "user schema" $userSchema

# set the short name for custom attribute with no spaces
$attributeName = "mnspAdminNumber"
Write-Host "AttributeName" $attributeName

# set the short description for custom attribute
$attributeDesc = "MNSP Admin Number"
Write-Host "Attribute Description:" $attributeDesc

# paste the OID generated earlier

# oMSyntax is "64" for String (Unicode). Refer this link for other types: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/7cda533e-d7a4-4aec-a517-91d02ff4a1aa
$oMSyntax = 64

# attributeSyntax is "2.5.5.12" for String (Unicode). Refer this link for other types: https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/7cda533e-d7a4-4aec-a517-91d02ff4a1aa
$attributeSyntax = "2.5.5.12"

# set the indexable value to "1" if you want AD to index this attribute. set this only if you would be querying this AD attribute a lot.
$indexable = 0

# set whether string is multivalued True/false. Refer to his link: https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/cf133d47-b358-4add-81d3-15ea1cff9cd9
$singleValued = "TRUE"

# build custom attributes hashtable
$adAttributes = @{
    lDAPDisplayName = $attributeName;
    adminDescription = $attributeDesc;
    attributeId = $OID;
    oMSyntax = $oMSyntax;
    attributeSyntax = $attributeSyntax;
    isSingleValued = $singleValued;
    searchflags = $indexable
}
Write-Host "Custom attributes hashtable:" $adAttributes


if ($OID -eq "REPLACE_THIS") {
    throw "OID value incorrect - exiting" ## needs better QOS ###
}

# create the custom attribute in AD schema
Write-Host "PS to execute: New-ADObject -Name $attributeName -Type attributeSchema -Path $adSchema -OtherAttributes $adAttributes -verbose"
New-ADObject -Name $attributeName -Type attributeSchema -Path $adSchema -OtherAttributes $adAttributes -verbose

# add the custom attribute to user class
Write-Host "PS to execute: $userSchema | Set-ADObject -Add @{mayContain = $attributeName} -verbose"
$userSchema | Set-ADObject -Add @{mayContain = $attributeName} -verbose

Stop-Transcript
