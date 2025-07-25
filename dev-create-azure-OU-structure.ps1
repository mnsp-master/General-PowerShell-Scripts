$mnspver = "0.0.""

Clear-Host
$LogDir = @()
Write-Host ""
$LogDir = Read-Host "Path for Transcript log, e.g C:\Temp\createOUs" 
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