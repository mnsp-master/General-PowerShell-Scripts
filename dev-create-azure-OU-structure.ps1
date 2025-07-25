$mnspver = "0.0.5"
$CID = "C03830"
Clear-Host
$LogDir = @()
$LogDir = "$env:USERPROFILE\PS1s\$CID\Logs"
Write-Host ""
$transcriptlog = "$LogDir\$(Get-date -Format yyyyMMdd-HHmmss)_transcript.log"

function DashedLine {
Write-host "-----------------------------------------------------------`n"
}

Write-Host $(Get-Date)
Write-Host "MNSP Version" $mnspver

Write-Host "Checking for $LogDir"

If(!(test-path -PathType container $LogDir))
{
      Write-Warning "$LogDir does not exist exiting script..."
      throw
}

Start-Transcript -Path $transcriptlog -Force -NoClobber -Append

Stop-Transcript