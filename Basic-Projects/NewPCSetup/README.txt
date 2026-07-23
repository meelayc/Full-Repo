This is a script that is intended to be run from a flash drive after setting up a local account on a new Windows 11 Computers.
It does the following:
- Prompt to disable Bitlocker
- Run windows updates
- Run Microsoft Store & Winget updates
- Uninstall extra languages from Office 365 (Requires XML file provided and "setup.exe" from the Microsoft Office Deployment Tool)
- Offers to install apps from Winget, Can install from install files but those need to be added to a folder named "Installers"
- Updates time zone to whichever is set
- Launches control panel to manually uninstall bloatware/unwanted apps
- Prompts to restart in 1 hour, ideally to let updates complete and then restart to finalize without actively checking the device