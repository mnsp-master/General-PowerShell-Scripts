#MNSP Version 1.0.1

# get AD schema path
$adSchema = (Get-ADRootDSE).schemaNamingContext

# get user schema
$userSchema = Get-ADObject -SearchBase $adSchema -Filter "Name -eq 'User'"

# set the short name for custom attribute with no spaces
$attributeName = "mnspAdminNumber"

# set the short description for custom attribute
$attributeDesc = "MNSP Admin Number"

# paste the OID generated earlier
$OID = "REPLACE_THIS"

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

if ($OID -eq "REPLACE_THIS") {
    throw "You need to update OID value - exiting"
}


# create the custom attribute in AD schema
New-ADObject -Name $attributeName -Type attributeSchema -Path $adSchema -OtherAttributes $adAttributes
# add the custom attribute to user class
$userSchema | Set-ADObject -Add @{mayContain = $attributeName} -verbose