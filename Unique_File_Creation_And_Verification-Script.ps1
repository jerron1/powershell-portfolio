<#
# Self-study resolution for team file creation + verification project


# This script will create a .CSV that exports properties of specific processes to a file with the time & date of the script initialization to the filename.
# It will also verify if a file with the same name exists & prompt the user to delete that file before continuing or stop the script.
# Upon exporting the file, it will be validated whether it was created within a set timeframe from the start of the script being ran.

# 10/09/2026 21:25 Jerron Brown
#>

# Get the current time & format it to append to filename
$CurrentTime = Get-Date
$FormattedCurrentTime = Get-Date $CurrentTime -Format "yyyyMMdd_HHmm" # Add ff if you want seconds
$FilePath = "C:\ClassFiles-JB\Export\Variable_Export_of_Specific_Processes" + "_" + $FormattedCurrentTime + "_" + ".csv" # First string of $FilePath must be custom to your environment

# Declare a variable that grabs local machine's processes as a source data set (Runs after since I interpret line 1 as start of the script)
$GetProcess = Get-Process

# Filter the source data set for specific processes ($SpecificProcesses could be a text file that I grab from in the future)
$SpecificProcesses = "notepad", "calculator", "calculatorapp", "charmap"
$GetFilteredProcesses = $GetProcess | Where-Object {$_.ProcessName -in $SpecificProcesses} | Select-Object -Property *

# Verify whether file exists already, delete if true and create new one
$TestPathSpecificProcExportCSV = Test-Path -Path $FilePath -PathType Leaf
# Copilot helped fix do loop to reprompt for initial verification
if ($TestPathSpecificProcExportCSV) {

    Write-Host "A file already exists and will be deleted. A new file will be made for this script."

    do {
        $FileExistQ = Read-Host "Would you like to proceed? [Y] yes or [N] no ..."

        if ($FileExistQ -in @("y","yes")) {
            Write-Host "Deleting the file and proceeding to verify and export." -ForegroundColor Green -BackgroundColor Black
            Remove-Item -Path $FilePath
        }
        elseif ($FileExistQ -in @("n","no")) {
            Write-Host "Stopping the script." -ForegroundColor Red -BackgroundColor Black
            return
        }
        else {
            Write-Host "Sorry, I didn't get that. Please enter 'y'/'yes' or 'n'/'no'." -ForegroundColor Blue -BackgroundColor Black
        }

    } until ($FileExistQ -in @("y","yes","n","no"))
}

# Check again if it exists, exports & continues if it's not
$TestPathSpecificProcExportCSV = Test-Path -Path $FilePath -PathType Leaf 
if ($TestPathSpecificProcExportCSV -eq $false) {
    # Export $GetFilteredProcesses to a .CSV file
    $GetFilteredProcesses | Export-Csv -Path $FilePath

    # If the file exists, place it in a file to get creation time for comparison
    $GetItemFile = Get-Item -Path $FilePath
    # Create timeframe and find difference between script start and file creation
    $Timeframe = New-TimeSpan -Seconds 30
    $TimeDifference = (Get-Date $GetItemFile.CreationTime) - (Get-Date $CurrentTime)
    
    if ($TimeDifference -lt $Timeframe) {
            Write-Host "Export of all processes details completed.  " -ForegroundColor Yellow -BackgroundColor Black -NoNewline
            Write-Host ($GetFilteredProcesses).Count "processes exported." -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "The file was exported within the 30 second time frame successfully." -ForegroundColor Green -BackgroundColor Black
        }
        elseif ($TimeDifference -gt $Timeframe) {
            Write-Host "Export of all processes details completed.  " -ForegroundColor Yellow -BackgroundColor Black -NoNewline
            Write-Host ($GetFilteredProcesses).Count "processes exported." -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "The file was not exported within the specified time frame." -ForegroundColor Red -BackgroundColor Black
        }
        else {
            Write-Host "The file was not exported."
        }
    
    
}

Start-Sleep -Seconds 5
