@echo off
setlocal enabledelayedexpansion
title New PC Setup

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin...
	powershell -Command "Start-Process cmd.exe -ArgumentList '/k \"%~s0\"' -Verb RunAs"
    exit /b
)

echo [DEBUG] RUNNING AS ADMIN

:MAIN

:: Force working directory back to where the script lives
cd /d "%~dp0"

echo [MAIN]
::Display art
echo.
setlocal DisableDelayedExpansion
type "%~dp0textArt.txt"
endlocal

:: Updates timezone to EST
echo Updating Time Zone to EST
tzutil /s "Eastern Standard Time"

:: Opens Windows Update and auto "Checking for Updates" 
echo Updating Windows and MS Store apps.
start ms-settings:windowsupdate-action


::Initializes Winget and updates all apps that are Winget or MS Store
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Winget not found - skipping app updates.
    echo Please install App Installer from the Microsoft Store manually.
) else (
    echo Initializing winget...
    winget source reset --force >nul 2>&1
    winget source update >nul 2>&1
    echo Running background updates...
    start "" /min cmd /c "winget upgrade --all --silent --accept-package-agreements --accept-source-agreements"
	start "" /min cmd /c "winget upgrade --all --source msstore --silent --accept-package-agreements --accept-source-agreements"
)
echo.


:: Setting boot drive var && decryption
set "BOOT_DRIVE=%SystemDrive%"

echo ===================================================
echo     	   Bitlocker Decryption             
echo ===================================================

choice /C YN /M "Disable Bitlocker?"
set "CHOICE=!errorlevel!"
if "!CHOICE!"=="2" (
    echo SKIPPING DECRYPTION
) else (
	manage-bde -off %BOOT_DRIVE%
    echo Decryption starting in the background.
	echo Drive %BOOT_DRIVE% Decrypting...
)

echo.

:: Launch Control Panel to remove bloatware

choice /C YN /M "Remove/Check for Bloatware"
set "CHOICE=!errorlevel!"
if "!CHOICE!"=="2" (
    echo Declined.
) else (
    echo Launching Control Panel
    start appwiz.cpl
)

echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo     MICROSOFT 365 ^& ONE NOTE LANGUAGE REMOVAL             
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
choice /C YN /M "Scan XML and uninstall M365 Language Nodes?"
set "CHOICE=!errorlevel!"
if "!CHOICE!"=="2" (
    echo M365 and OneNote Language removal skipped.
) else (
    if exist "%~dp0setup.exe" (
        if exist "%~dp0uninstall_langs.xml" (
            echo Running Office Deployment Tool to strip languages...
			start /wait "" "%~dp0setup.exe" /configure "%~dp0uninstall_langs.xml"
            echo M365 Language removal task completed.
        ) else (
            echo [ERROR] uninstall_langs.xml not found in script directory! Skipping debloating!
        )
    ) else (
        echo [ERROR] setup.exe not found! Skipping debloating!
    )
)
echo.

echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
echo            SOFTWARE INSTALLATION MENU             
echo ///////////////////////////////////////////////////
echo.
echo Select the applications you want to install by the given ID numbers.
echo.
echo For multiple at once, seperate numbers by a space.
echo.

:: APP LIST **DO NOT TOUCH**
:: Format: "Proper Name|Install ID or File path|File type(FILE/WINGET)"
set "App[1]=Google Chrome|Google.Chrome|WINGET"
set "App[2]=Mozilla FireFox|Mozilla.Firefox|WINGET"
set "App[3]=Adobe Acrobat Reader (64 Bit)|Adobe.Acrobat.Reader.64-bit|WINGET"
set "App[4]=Zoom|Zoom.Zoom|WINGET"
set "App[5]=Webroot|\Installers\wsabbs2.exe|FILE"
set "App[6]=VLC Media Player|VideoLAN.VLC|WINGET"
set "App[7]=Steam|Valve.Steam|WINGET"
set "App[8]=Discord|Discord.Discord|WINGET"
set "MaxApps=8"

::Print List
for /L %%I in (1,1,%MaxApps%) do (
	for /f "tokens=1,3 delims=|" %%A in ("!App[%%I]!") do (
		echo [%%I] %%A
	)
)
echo.
echo.

::User Input/Output

set "AGENT_INPUT="
set /p "AGENT_INPUT=Enter your choices (or press Enter to exit):"

if "%AGENT_INPUT%"=="" (
	echo Exiting...
	goto END
)
echo.
echo ===================================================
echo                  INSTALLATING...              
echo ===================================================
echo.

:: Reading selection via Loop

for %%S in (!AGENT_INPUT!) do (
    set "VALID=0"
    if %%S GEQ 1 if %%S LEQ %MaxApps% set "VALID=1"
    if "!VALID!"=="1" (
        for /f "tokens=1,2,3 delims=|" %%B in ("!App[%%S]!") do (
            echo.
            echo [%%S] %%B
            choice /C YN /M "Install %%B?"
			set "CHOICE=!errorlevel!"
            if "!CHOICE!"=="2" (
                echo Skipped.
            ) else (
                echo Installing %%B...
                if /i "%%D"=="FILE" (
                    start /wait "" "%~dp0%%C" /silent /qn
                )
                if /i "%%D"=="WINGET" (
                    winget install --id %%C --silent --accept-package-agreements --accept-source-agreements
                )
            )
        )
    ) else (
        echo Selection '%%S' is not a valid selection.
    )
)


:END

choice /C YN /M "Restart in 1 Hour?"
set "CHOICE=!errorlevel!"
if "!CHOICE!"=="2" (
    echo RESTART DECLINED
) else (
	echo Timer started
	shutdown /r /t 3600
)
echo.
echo 				All processes have finished.
echo [It is your duty to verify Bitlocker Completion "manage-bde -status C:" for reference]
pause
