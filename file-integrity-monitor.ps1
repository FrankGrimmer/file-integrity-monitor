# File Integrity Monitoring Tool - Frank Grimmer 2023

# Adding the ability to use Windows file browsing.
Add-Type -AssemblyName System.Windows.Forms

# Function for adding files to baseline file.
function Add-FileToBaseline {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath,
        [Parameter(Mandatory)]$targetFilePath
    )

    try {
        # Check if baseline file and target file exist.
        if ((Test-Path -Path $baselineFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop
        }
        # Check if the specified target file path exists.
        if ((Test-Path -Path $targetFilePath) -eq $false) {
            Write-Error -Message "$targetFilePath does not exist" -ErrorAction Stop
        }

        # Load the current baseline.
        $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","

        # Check if the target file path is already in the baseline.
        if ($targetFilePath -in $currentBaseline.path) {
            Write-Output "File path detected already in baseline file."
            do {
                # Prompt user to overwrite or not.
                $overwrite = Read-Host -Prompt "Path exists already in the baseline file, would you like to overwrite it? [Y/N]"
                if ($overwrite -in @('y', 'yes')) {
                    Write-Output "File path will be overwritten."

                    # Remove existing entry and add the new one.
                    $currentBaseline | Where-Object path -ne $targetFilePath | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation
                    
                    # Calculate the hash of the target file.
                    $hash = Get-FileHash -Path $targetFilePath
                    
                    # Append the file path and its hash to the baseline file.
                    "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Encoding "UTF8" -Append

                    Write-Output "Entry successfully added into baseline."
                
                } elseif ($overwrite -in @('n', 'no')) {
                    Write-Output "File path will not be overwritten."

                } else {
                    Write-Output "Invalid response, please enter Y to overwrite, or N to not overwrite"
                }
            } while ($overwrite -notin @('y', 'yes', 'n', 'no'))
        } else {

            # Add the new entry.
            $hash = Get-FileHash -Path $targetFilePath
            
            # Concatenate file path and its hash, and append to the baseline file.
            "$($targetFilePath),$($hash.hash)" | Out-File -FilePath $baselineFilePath -Encoding "UTF8" -Append

            Write-Output "Entry successfully added into baseline."
        }

        # Update the baseline file.
        $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","
        $currentBaseline | Export-Csv -Path $baselineFilePath -Delimiter "," -NoTypeInformation

    } catch {
        # If an exception occurs, writes an error message to the console.
        Write-Error $_.Exception.Message
    }
}

# Function to verify the files in the baseline file.
function Test-Baseline {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath
    )

    try {
        # Check if baseline file exists and has the correct extension.
        if ((Test-Path -Path $baselineFilePath) -eq $false) {
            Write-Error -Message "$baselineFilePath does not exist" -ErrorAction Stop
        }
        if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -ne ".csv") {
            Write-Error -Message "$baselineFilePath needs to be a .csv file." -ErrorAction Stop
        }

        # Load the baseline files.
        $baselineFiles = Import-Csv -Path $baselineFilePath -Delimiter ","

        # Iterate through each file in the baseline.
        foreach ($file in $baselineFiles) {
            if (Test-Path -Path $file.path) {
                $currentHash = Get-FileHash -Path $file.path
                if ($currentHash.Hash -eq $file.hash) {
                    Write-Output "$($file.path) hash is still the same."
                } else {
                    Write-Output "$($file.path) hash is different, something has changed."
                }

            } else {
                Write-Output "$($file.path) is not found."
            }
        }
        
    } catch {
        # If an exception occurs, writes an error message to the console.
        Write-Error $_.Exception.Message
    }

}

# Function to create a new baseline file.
function New-Baseline {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$baselineFilePath
    )

    try {
        # Check if baseline file already exists.
        if ((Test-Path -Path $baselineFilePath)) {
            Write-Error -Message "$baselineFilePath already exists with this name." -ErrorAction Stop
        }
        # Check if the baseline file has the correct file extension.
        if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -ne ".csv") {
            Write-Error -Message "$baselineFilePath needs to be a .csv file." -ErrorAction Stop
        }

        # Create a new baseline file.
        "path,hash" | Out-File -FilePath $baselineFilePath -Force

    } catch {
        # If an exception occurs, writes an error message to the console.
        Write-Error $_.Exception.Message
    }
}

# Setting the default baseline file path to null.
$baselineFilePath = ""

# Menu for user input.
Write-Host "File Integrity Monitoring Tool - Frank Grimmer 2023" -ForegroundColor Cyan
do {
    Write-Host "Please select one of the following options, or enter q to quit." -ForegroundColor Cyan
    Write-Host "Current baseline file:$($baselineFilePath)" -ForegroundColor DarkBlue
    Write-Host "1 - Select baseline file"  -ForegroundColor Cyan
    Write-Host "2 - Add files for monitoring" -ForegroundColor Cyan
    Write-Host "3 - Check files for changes" -ForegroundColor Cyan
    Write-Host "4 - Create a new baseline file" -ForegroundColor Cyan
    $entry = Read-Host -Prompt "Please enter a selection"

    switch ($entry) {
        "1"{
            # Allow user to browse for a baseline file.
            $inputFilePick = New-Object System.Windows.Forms.OpenFileDialog
            $inputFilePick.Filter = "CSV (*.csv) | *.csv"
            $inputFilePick.ShowDialog()
            $baselineFilePath = $inputFilePick.FileName
            
            # Check if the baseline file path is valid.
            if (test-path -Path $baselineFilePath) {
                # Check if the baseline file has the correct file extension.
                if ($baselineFilePath.Substring($baselineFilePath.Length - 4, 4) -eq ".csv") {
                
                } else {
                    # Invalid file extension, set baselineFilePath to empty and display an error message.
                    $baselineFIlePath = ""
                    Write-Host "Invalid file. Needs to be a .csv file."  -ForegroundColor Red
                }

            } else {
                # Invalid file extension, set baselineFilePath to empty and display an error message.
                $baselineFIlePath = ""
                Write-Host "Invalid file path for baseline."  -ForegroundColor Red
            }
        }
        "2"{
            # Allow user to browse for a target file to add to the baseline.
            $inputFilePick = New-Object System.Windows.Forms.OpenFileDialog
            $inputFilePick.ShowDialog()
            $targetFilePath = $inputFilePick.FileName
            Add-FileToBaseline -baselineFilePath $baselineFilePath -targetFilePath $targetFilePath
        }
        "3"{
            # Verify the files in the baseline.
            Verify-Baseline -baselineFilePath $baselineFilePath
        }
        "4"{
            # Allow user to create a new baseline file.
            $inputFilePick = New-Object System.Windows.Forms.SaveFileDialog
            $inputFilePick.Filter = "CSV (*.csv) | *.csv"
            $inputFilePick.ShowDialog()
            $newBaselineFilePath = $inputFilePick.FileName
            Create-Baseline -baselineFilePath $newBaselineFilePath
        }
        "q"{}
        "quit"{}
        default{
            Write-Output "Invalid Entry"
        }
    }

# Continues the loop as long as the user's entry is not 'q' or 'quit'.
} while ($entry -notin @('q', 'quit'))
