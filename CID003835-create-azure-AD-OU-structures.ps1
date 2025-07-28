$mnspver = "0.0.21"
Clear-Host
$CID = "" #Change ID e.g: C09826
$LogDir = @()
$LogDir = "$env:USERPROFILE\Documents\PS1s\$CID\Logs"
$tempcsv1 = "$env:USERPROFILE\Documents\PS1s\$CID\Data\tempcsv1.csv"
Write-Host "MNSP Version:" $mnspver
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"

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

$BaseDN = "OU=Primary Schools,OU=Students,OU=MNSP,DC=mnsp,DC=org,DC=uk"
$parentOUPath = "OU=Primary Schools,OU=Students,OU=MNSP,DC=mnsp,DC=org,DC=uk"



foreach ($School in $OUdata ) {

        $SSN = $($School.SchoolShortName)
        Write-Host "School Short Name:" $SSN

        $LeafOUs = @(
        "$SSN-Year01",
        "$SSN-Year02",
        "$SSN-Year03"
        # "$SSN-Year04",
        # "$SSN-Year05",
        # "$SSN-Year06",
        # "$SSN-GenericStudents",
        # "$SSN-StudentOffBoarding"
        )

        $ParentOU = $($school.Parent)
        Write-Host "ParentOU:" $ParentOU
        $ParentOUPath = 'OU=' + $ParentOU + ',' + $BaseDN
        Write-Host "ParentOU Path:" $ParentOUPath
        $fullOuDn = "OU=$ouName," + $BaseDN

        #----check for and create Parent OU's----
        try {
            $existingOU = @()
            #Write-Host "$existingOu = Get-ADOrganizationalUnit -Identity $ParentOUPath -ErrorAction Stop"
            $existingOu = Get-ADOrganizationalUnit -Identity $ParentOUPath -ErrorAction Stop
            Write-Host "The OU '$ParentOU' already exists at '$parentOUPath'." -ForegroundColor Green
            Write-Host "Distinguished Name: $($existingOu.DistinguishedName)"
            DashedLine
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "The OU '$ParentOU' does not exist at '$parentOUPath'. Creating it now..."

            try {
                # Create the new OU
                $newOu = New-ADOrganizationalUnit -Name $ParentOU -Path $BaseDN -PassThru #-WhatIf
                Write-Host "Successfully created OU: '$($newOu.Name)'"
                Write-Host "Distinguished Name: $($newOu.DistinguishedName)"
                Write-Host "Path: $($newOu.CanonicalName)"
                DashedLine
            }
            Catch {
                # Catch any errors during the creation process
                Write-Error "Failed to create OU '$ParentOU' at '$BaseDN'. Error: $($_.Exception.Message)"
                DashedLine
            }
        }
        catch {
            # Catch any other unexpected errors during the initial Get-ADOrganizationalUnit check
            Write-Error "An unexpected error occurred while checking for OU '$fullOuDn'. Error: $($_.Exception.Message)"
            DashedLine
      }


        #----check for and create leaf OU's----
        foreach ($ouName in $LeafOUs) {

            $fullOuDn = "OU=$ouName," + $parentOUPath

            Write-Host "Checking for existence of OU: '$fullOuDn'..."

                try {
                    # Attempt to get the OU. If it doesn't exist, this will throw an error.
                    $existingOu = Get-ADOrganizationalUnit -Identity $fullOuDn -ErrorAction Stop

                    Write-Host "The OU '$ouName' already exists at '$parentOUPath'." -ForegroundColor Green
                    Write-Host "Distinguished Name: $($existingOu.DistinguishedName)"
                    DashedLine

                }
                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
                    Write-Warning "The OU '$ouName' does not exist at '$parentOUPath'. Creating it now..."

                    try {
                        # Create the new OU
                        $newOu = New-ADOrganizationalUnit -Name $ouName -Path $parentOUPath -PassThru #-WhatIf

                        Write-Host "Successfully created OU: '$($newOu.Name)'"
                        Write-Host "Distinguished Name: $($newOu.DistinguishedName)"
                        Write-Host "Path: $($newOu.CanonicalName)"
                        DashedLine
                    }
                    catch {
                        # Catch any errors during the creation process
                        Write-Error "Failed to create OU '$ouName' at '$parentOUPath'. Error: $($_.Exception.Message)"
                        DashedLine
                    }
                }
                catch {
                    # Catch any other unexpected errors during the initial Get-ADOrganizationalUnit check
                    Write-Error "An unexpected error occurred while checking for OU '$fullOuDn'. Error: $($_.Exception.Message)"
                    DashedLine
            }


        }
}



Stop-Transcript