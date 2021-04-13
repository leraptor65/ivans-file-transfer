@echo off
color 4F
title Ivans Easy File Transfer Tool
cls
goto MAIN

:MAIN
:: Some useful variables
set /a boolALL = 0
set /a boolSOURCE = 0
set /a boolDESTINATION = 0
set /a boolNAME = 0
set /a fromDESTINATION = 0

echo WELCOME TO IVAN'S EASY BACK UP
echo:
echo THE PURPOSE OF THIS PROGRAM IS TO BACKUP A COMPUTER.
echo THIS COPIES THE "USERS" FOLDER AND SKIPS ANY EMPTY FOLDER AND ANY FILE MARKED AS "HIDDEN".
echo THIS ALLOWS FOR A MORE PROFICIENT BACKUP THAT LEAVES ALL THE BLOATY FILES LIKE CACHE BEHIND.
echo:
echo IF AT ANY TIME YOU WISH TO STOP THE BACKUP (OR THIS PROGRAM) PLEASE HOLD ctrl AND PRESS c (ctrl+c)
echo:
echo:
pause
goto options

:end
cls
echo THANK YOU FOR USING IVANS EASY AND AWESOME BACKUP TOOL
echo:
echo:
echo:
echo                     ***********
echo                    **          **
echo       ***        **              **
echo      *   *      **                **
echo      *    *    **    **      **    **
echo      *    *   **    *  *    *  *    **
echo      *    *  **     *  *    *  *     **
echo     **    *                           **
echo     *    ******                       **
echo    **         * ********************  **
echo   **    *******  **   *  *  *    **   **
echo   *            *  **  *  *  *   **   **
echo   *     *******    ** *  *  *  **   **
echo   *            *    ***  *  * **   **
echo   *     ******* **   **********   **
echo   **          *   **             **
echo     **********      **         **
echo                       *********
echo:
echo:
echo:
pause
echo:
cls
title %comspec%
color 07
cmd.exe
@echo on

:options
cls
echo What would you like to do?
echo:
echo 1.  View Available Drives
echo 2.  Set SOURCE, DESTINATION, and NAME
echo 3.  Show SOURCE, DESTINATION, and NAME
echo 4.  Start File Transfer
echo 5.  Exit
echo:
set /p CHOICE="Please enter choice NUMBER here: "
if "%CHOICE%" == "1" (
    goto showDrives
) else if "%CHOICE%" == "2" (
    goto setVar
) else if "%CHOICE%" == "3" (
    goto showVar
) else if "%CHOICE%" == "4" (
    goto startTransfer
) else if "%CHOICE%" == "5" (
    goto end
) else (
    echo INVALID CHOICE, LETS TRY AGAIN
    pause
    goto options
)

:showDrives
cls
echo Below are all your available Drives
echo:
echo ++++++++++++++++++++++++++++++++++++++++++++
echo:
wmic logicaldisk get deviceid, volumename
:: description
echo:
echo ++++++++++++++++++++++++++++++++++++++++++++
echo:
pause
cls
REM EXIT /B 0
goto options

:setVar
cls
echo Would you like to
echo:
echo 1. Set SOURCE
echo 2. Set DESTINATION
echo 3. Set NAME
echo 4. Set all of the above
echo 5. Go back
echo:
set /p CHOICE2="Please enter choice NUMBER here: "
if "%CHOICE2%" == "1" (
    goto setSOURCE
) else if "%CHOICE2%" == "2" (
    goto setDESTINATION
) else if "%CHOICE2%" == "3" (
    goto setNAME
) else if "%CHOICE2%" == "4" (
    goto setALL
) else if "%CHOICE2%" == "5" (
    goto options
)
) else (
    echo INVALID CHOICE, LETS TRY AGAIN
    pause
    goto  setVar
)

    :setSOURCE
    cls
    echo Setting the SOURCE
    echo:
    echo Which drive are you copying from? (Typically it's C)
    set /p SRC="Please enter source drive LETTER here: "
    :: if defined SRC if "%SRC:~1,1%"=="" ( 
    set SRCPATH=%SRC%:\Users
    if exist "%SRCPATH%" (
        echo SOURCE IS SET TO 
        echo %SRCPATH%
    ) else (
        echo %SRCPATH% 
        echo does not exist
        pause
        goto setSOURCE
    )
    set /a boolSOURCE = 1
    pause
    if "%boolALL%" == "1" (goto endss) else (goto  setVar)

    :setDESTINATION
    cls
    echo Setting the DESTINATION
    echo:
    if "%boolNAME%" == "0" (
        echo We are going to need a name first, let us do that now
        pause
        set /a fromDESTINATION = 1
        goto setNAME
        :backfromNAME
        set /a fromDESTINATION = 0
        cls
        echo Thank you, the name was set to %USR%
    )
    echo:
    echo What drive are you backing up to? 
    echo      (backing up to a flash drive or external hard drive?)
    set /p DEST="Please enter destination drive LETTER here: "
    if not exist "%DEST%:\" (
        echo Sorry, %DEST% does not exist!
        pause
        goto setDESTINATION
    )
    set DESTPATH=%DEST%:\"Backup for %USR%\%USR%"
    echo DESTINATION is set to %DESTPATH%
    echo:
    set /a boolDESTINATION = 1
    pause
    if "%boolALL%" == "1" (goto endsd) else (goto  setVar)
        
    :setNAME
    echo Setting the NAME
    echo:
    echo Who's this transfer for?
    set /p USR="Please enter a name: "
    echo Name set to %USR%
    set /a boolNAME = 1
    pause
    if "%fromDESTINATION%" == "1" (goto backfromNAME)
    if "%boolALL%" == "1" (goto endsn) else (goto  setVar)

    :setALL
    set /a boolALL = 1
    goto setSOURCE
    :endss
    goto setDESTINATION
    :endsd
    goto setNAME
    :endsn
    pause
    set /a boolALL = 0
    goto options

:showVar
if "%boolSOURCE%" == "0" (
    echo SOURCE Undefined
) else (
    echo SOURCE is %SRCPATH%
)
if "%boolDESTINATION%" == "0" (
    echo DESTINATION Undefined
) else (
    echo DESTINATION is %DESTPATH%
)
if "%boolNAME%" == "0" (
    echo NAME Undefined
) else (
    echo NAME is %USR%
)
pause
cls
goto options

:startTransfer
echo So you want to start this transfer already huh? Let me check some variables
if "%boolSOURCE%" == "0" (
    echo SOURCE Undefined
    echo Please set the SOURCE
    pause
    goto setSOURCE
) else (
    echo SOURCE is %SRCPATH%
)
if "%boolDESTINATION%" == "0" (
    echo DESTINATION Undefined
    echo Please set the destination
    pause
    goto setDESTINATION
) else (
    echo DESTINATION is %DESTPATH%
)
if "%boolNAME%" == "0" (
    echo NAME Undefined
    echo Please set the NAME
    pause
    goto setNAME
) else (
    echo NAME is %USR%
)
echo Good job!!! Looks like we have everything.
echo We are backing up %SRCPATH% to %DESTPATH% for %USR%
echo:
set /p yn="Is this correct? (y/n) "
if "%yn%" == "y" (
    set /p yn2="Are you sure? (y/n) "
    if "%yn2%" == "y" (
        goto ready
    ) else (
        goto notready
    )
) else (
    goto notready
)
:notready
cls
echo That's ok, lets go back to the main menu.
pause
goto options
:ready
cls
echo Awesome, lets backup up some files!!!
echo:
echo Starting Transfer
pause
@echo on
:: xcopy
@echo off
echo:
pause
echo Transfer complete!!! 
pause
cls
goto end