# Ivans Easy File Transfer Tool - PowerShell Version

#region Helper Functions for GUI Dialogs
function Get-FolderDialog {
    param(
        [string]$Description = "Select a folder",
        [string]$InitialDirectory = ""
    )

    # Load the assembly (only needs to be done once per session)
    # Use -ErrorAction SilentlyContinue to prevent an error if it's already loaded
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue

    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderBrowser.Description = $Description
    $FolderBrowser.ShowNewFolderButton = $true # Allow creating new folders in the dialog

    # Set initial directory if provided and exists
    if (-not [string]::IsNullOrEmpty($InitialDirectory) -and (Test-Path $InitialDirectory -PathType Container)) {
        $FolderBrowser.SelectedPath = $InitialDirectory
    } else {
        # Fallback to Desktop if initial directory is not valid or not provided
        $FolderBrowser.SelectedPath = [Environment]::GetFolderPath('Desktop')
    }

    $result = $FolderBrowser.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $FolderBrowser.SelectedPath
    } else {
        return $null # User cancelled
    }
}
#endregion

#region Core Script Functions
function Show-Welcome {
    Clear-Host
    $Host.UI.RawUI.WindowTitle = "Ivan's Easy File Transfer Tool"
    Write-Host "WELCOME TO IVAN'S EASY BACK UP" -ForegroundColor Green
    Write-Host ""
    Write-Host "THE PURPOSE OF THIS PROGRAM IS TO BACKUP A COMPUTER." -ForegroundColor Yellow
    Write-Host "THIS COPIES THE SPECIFIED SOURCE FOLDER AND SKIPS ANY EMPTY FOLDER AND ANY FILE MARKED AS 'HIDDEN'." -ForegroundColor Yellow
    Write-Host "THIS ALLOWS FOR A MORE PROFICIENT BACKUP THAT LEAVES SOME BLOATY FILES LIKE CACHE BEHIND." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "IF AT ANY TIME YOU WISH TO STOP THE BACKUP (OR THIS PROGRAM) PLEASE HOLD ctrl AND PRESS c (ctrl+c)" -ForegroundColor Red
    Write-Host ""
    Write-Host ""
    Pause-Script
}

function Show-ExitMessage {
    Clear-Host
    Write-Host "THANK YOU FOR USING IVANS EASY AND AWESOME BACKUP TOOL" -ForegroundColor Green
    Write-Host ""
    Write-Host ""
    Write-Host ""
    # ASCII Art (preserved as close as possible, PowerShell console might render slightly differently)
	Write-Host "                     ***********"
	Write-Host "                    **          **"
	Write-Host "       ***        **              **"
	Write-Host "      *   *      **                **"
	Write-Host "      *    *    **    **      **    **"
	Write-Host "      *    *   **    *  *    *  *    **"
	Write-Host "      *    *  **     *  *    *  *     **"
	Write-Host "     **    *                           **"
	Write-Host "     *    ******                       **"
	Write-Host "    **         * ********************  **"
	Write-Host "   **    *******  **   *  *  *    **   **"
	Write-Host "   *            *  **  *  *  *   **   **"
	Write-Host "   *     *******    ** *  *  *  **   **"
	Write-Host "   *            *    ***  *  * **   **"
	Write-Host "   *     ******* **   **********   **"
	Write-Host "   **          *   **             **"
	Write-Host "     **********      **         **"
	Write-Host "                       *********"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Pause-Script
    Clear-Host
    $Host.UI.RawUI.WindowTitle = "cmd.exe" # Reset title to default
    Exit # Exit the PowerShell script gracefully
}

function Pause-Script {
    Read-Host "Press Enter to continue..."
}

function Show-Drives {
    Clear-Host
    Write-Host "Below are all your available Drives" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Cyan
    Write-Host ""
    Get-PSDrive -PSProvider FileSystem | Format-Table Name, Root, Free, Used
    Write-Host ""
    Write-Host "++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Cyan
    Write-Host ""
    Pause-Script
}

function Set-Variables {
    param(
        [ref]$SourcePath,
        [ref]$DestinationPath,
        [ref]$UserName,
        [switch]$SetAll
    )

    Clear-Host
    Write-Host "What would you like to set?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Set SOURCE"
    Write-Host "2. Set DESTINATION"
    Write-Host "3. Set NAME"
    Write-Host "4. Set all of the above"
    Write-Host "5. Go back"
    Write-Host ""

    $choice2 = Read-Host "Please enter choice NUMBER here"

    if ($SetAll) { # If this function was called to set all
        Set-SourcePath -SourcePath $SourcePath
        Set-DestinationPath -DestinationPath $DestinationPath -UserName $UserName # Pass UserName for destination path
        Set-UserName -UserName $UserName
    }
    else {
        switch ($choice2) {
            "1" { Set-SourcePath -SourcePath $SourcePath }
            "2" { Set-DestinationPath -DestinationPath $DestinationPath -UserName $UserName }
            "3" { Set-UserName -UserName $UserName }
            "4" {
                Set-Variables -SetAll:$true -SourcePath $SourcePath -DestinationPath $DestinationPath -UserName $UserName
            }
            "5" { return } # Go back to main menu
            default {
                Write-Warning "INVALID CHOICE, LET'S TRY AGAIN"
                Pause-Script
                Set-Variables -SourcePath $SourcePath -DestinationPath $DestinationPath -UserName $UserName # Loop back
            }
        }
    }
    # Pause after setting variables unless going back or doing 'set all' and finishing
    if (-not $SetAll) {
        Pause-Script
    }
}

function Set-SourcePath {
    param(
        [ref]$SourcePath
    )
    Clear-Host
    Write-Host "Setting the SOURCE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "A folder selection dialog will now appear. Please select the folder you want to copy FROM."

    # Use the GUI folder dialog
    $selectedPath = Get-FolderDialog -Description "Select Source Folder" -InitialDirectory $SourcePath.Value

    if (-not [string]::IsNullOrEmpty($selectedPath)) {
        $SourcePath.Value = $selectedPath
        Write-Host "SOURCE IS SET TO:" -ForegroundColor Green
        Write-Host "$($SourcePath.Value)" -ForegroundColor Green
    }
    else {
        Write-Warning "No source folder selected or operation cancelled."
        # Keep current value or set to null if it was never set
        if ([string]::IsNullOrEmpty($SourcePath.Value)) { $SourcePath.Value = $null }
    }
}

function Set-DestinationPath {
    param(
        [ref]$DestinationPath,
        [ref]$UserName
    )
    Clear-Host
    Write-Host "Setting the DESTINATION" -ForegroundColor Yellow
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($UserName.Value)) {
        Write-Warning "A name is needed to create the backup folder structure. Let's set that now."
        Pause-Script
        Set-UserName -UserName $UserName
        Clear-Host
        Write-Host "Thank you, the name was set to $($UserName.Value)" -ForegroundColor Green
        Write-Host ""
    }

    Write-Host "A folder selection dialog will now appear. Please select the base folder where you want to save the backup."
    Write-Host "(e.g., a folder on an external drive, like 'D:\Backups')"

    # Determine the initial directory for the dialog.
    # Check if $DestinationPath.Value is not null or empty before trying to split it.
    $initialDestDir = ""
    if (-not [string]::IsNullOrEmpty($DestinationPath.Value) -and (Test-Path (Split-Path -Path $DestinationPath.Value -Parent -ErrorAction SilentlyContinue) -PathType Container -ErrorAction SilentlyContinue)) {
        $initialDestDir = Split-Path -Path $DestinationPath.Value -Parent
    }

    # Use the GUI folder dialog
    $selectedBasePath = Get-FolderDialog -Description "Select Destination Base Folder" -InitialDirectory $initialDestDir

    if (-not [string]::IsNullOrEmpty($selectedBasePath)) {
        # Construct the final destination path including the backup folder and user name
        $fullDestPath = Join-Path -Path $selectedBasePath -ChildPath "Backup for $($UserName.Value)\$($UserName.Value)"
        $DestinationPath.Value = $fullDestPath
        Write-Host "DESTINATION is set to $($DestinationPath.Value)" -ForegroundColor Green
        Write-Host "(This specific folder structure will be created if it doesn't exist during transfer.)" -ForegroundColor Yellow
        Write-Host ""
    }
    else {
        Write-Warning "No destination base folder selected or operation cancelled."
        # Keep current value or set to null if it was never set
        if ([string]::IsNullOrEmpty($DestinationPath.Value)) { $DestinationPath.Value = $null }
    }
}

function Set-UserName {
    param(
        [ref]$UserName
    )
    Clear-Host
    Write-Host "Setting the NAME" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Who's this transfer for? This name will be part of the backup folder structure."
    $user = Read-Host "Please enter a name"
    # Basic sanitization for folder names (remove invalid characters)
    $user = $user -replace '[\\/:*?"<>|]', '_'
    $UserName.Value = $user
    Write-Host "Name set to $($UserName.Value)" -ForegroundColor Green
}


function Show-Variables {
    Clear-Host
    if ([string]::IsNullOrWhiteSpace($script:SourcePath)) {
        Write-Host "SOURCE Undefined" -ForegroundColor Red
    }
    else {
        Write-Host "SOURCE is $($script:SourcePath)" -ForegroundColor Green
    }
    if ([string]::IsNullOrWhiteSpace($script:DestinationPath)) {
        Write-Host "DESTINATION Undefined" -ForegroundColor Red
    }
    else {
        Write-Host "DESTINATION is $($script:DestinationPath)" -ForegroundColor Green
    }
    if ([string]::IsNullOrWhiteSpace($script:UserName)) {
        Write-Host "NAME Undefined" -ForegroundColor Red
    }
    else {
        Write-Host "NAME is $($script:UserName)" -ForegroundColor Green
    }
    Pause-Script
}

function Start-FileTransfer {
    Clear-Host
    Write-Host "So you want to start this transfer already huh? Let me check some variables..." -ForegroundColor Cyan

    # Ensure variables are set, prompting if not
    # Use a loop to force setting if not set
    while ([string]::IsNullOrWhiteSpace($script:SourcePath)) {
        Write-Warning "SOURCE Undefined. Please set the SOURCE."
        Pause-Script
        Set-SourcePath -SourcePath ([ref]$script:SourcePath)
    }
    Write-Host "SOURCE is $($script:SourcePath)" -ForegroundColor Green

    while ([string]::IsNullOrWhiteSpace($script:UserName)) {
        Write-Warning "NAME Undefined. Please set the NAME."
        Pause-Script
        Set-UserName -UserName ([ref]$script:UserName)
    }
    Write-Host "NAME is $($script:UserName)" -ForegroundColor Green

    # Destination relies on UserName, so UserName must be set first.
    while ([string]::IsNullOrWhiteSpace($script:DestinationPath)) {
        Write-Warning "DESTINATION Undefined. Please set the destination."
        Pause-Script
        Set-DestinationPath -DestinationPath ([ref]$script:DestinationPath) -UserName ([ref]$script:UserName)
    }
    Write-Host "DESTINATION is $($script:DestinationPath)" -ForegroundColor Green


    Write-Host "Good job!!! Looks like we have everything." -ForegroundColor Green
    Write-Host "We are backing up '$($script:SourcePath)' to '$($script:DestinationPath)' for '$($script:UserName)'" -ForegroundColor Green
    Write-Host ""

    $yn = Read-Host "Is this correct? (y/n)"
    if ($yn -ne 'y') {
        Write-Host "That's ok, let's go back to the main menu." -ForegroundColor Red
        Pause-Script
        return # Go back to main menu
    }

    $yn2 = Read-Host "Are you sure? (y/n)"
    if ($yn2 -ne 'y') {
        Write-Host "That's ok, let's go back to the main menu." -ForegroundColor Red
        Pause-Script
        return # Go back to main menu
    }

    Clear-Host
    Write-Host "Awesome, let's back up some files!!!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Starting Transfer..." -ForegroundColor Yellow
    Pause-Script

    # Ensure the destination path exists before Robocopy
    try {
        # Create the full destination path if it doesn't exist
        New-Item -ItemType Directory -Path $script:DestinationPath -Force | Out-Null
    }
    catch {
        Write-Error "Failed to create destination directory: $($_.Exception.Message)"
        Pause-Script
        return
    }

    # Robocopy command
    # /S : Copy subdirectories, but skip empty ones. (This is generally what you want for "no bloat")
    # /XA:H : Exclude hidden files.
    # /NFL /NDL : No file list / No directory list (makes output cleaner)
    # /NJH /NJS : No Job Header / No Job Summary (makes output cleaner)
    # /LOG+:$logFilePath : Appends output to a log file.
    # /NP : No Progress indicator
    # /R:1 /W:1 : Retry 1 time, wait 1 second on failures.

    $logFilePath = Join-Path -Path $env:TEMP -ChildPath "IvanBackupLog_$((Get-Date).ToString('yyyyMMdd_HHmmss')).log"
    Write-Host "Transferring files. Please wait. A log of the operation will be saved to: $logFilePath" -ForegroundColor Cyan
    Start-Sleep -Seconds 2

    # Execute Robocopy and pipe output to Out-Null to keep console clean, as log handles details
    robocopy $script:SourcePath $script:DestinationPath /S /XA:H /NFL /NDL /NJH /NJS /LOG+:$logFilePath /NP /R:1 /W:1 | Out-Null

    Write-Host ""
    Write-Host "Transfer complete!!!" -ForegroundColor Green
    Write-Host "Check the log file for details: $logFilePath" -ForegroundColor Green
    Pause-Script
}
#endregion

# --- Main Program Flow ---
# Global script variables initialized to null
$script:SourcePath = $null
$script:DestinationPath = $null
$script:UserName = $null

Show-Welcome

while ($true) {
    Clear-Host
    $Host.UI.RawUI.ForegroundColor = 'White' # Reset color
    Write-Host "What would you like to do?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. View Available Drives"
    Write-Host "2. Set SOURCE, DESTINATION, and NAME"
    Write-Host "3. Show SOURCE, DESTINATION, and NAME"
    Write-Host "4. Start File Transfer"
    Write-Host "5. Exit"
    Write-Host ""

    $choice = Read-Host "Please enter choice NUMBER here"

    switch ($choice) {
        "1" { Show-Drives }
        "2" {
            # Pass script-level variables by reference to allow modification within functions
            Set-Variables -SourcePath ([ref]$script:SourcePath) -DestinationPath ([ref]$script:DestinationPath) -UserName ([ref]$script:UserName)
        }
        "3" { Show-Variables }
        "4" { Start-FileTransfer }
        "5" { Show-ExitMessage; break } # Exit the loop and script
        default {
            Write-Warning "INVALID CHOICE, LET'S TRY AGAIN"
            Pause-Script
        }
    }
}