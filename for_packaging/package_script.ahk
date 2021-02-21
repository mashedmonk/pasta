; Extract the files to temp folder first
; .ps1 and .ico file should be in the same directory as .ahk file to be able to package
FileCreateDir, %A_Temp%\pasta
FileInstall, pasta.ps1, %A_Temp%\pasta\pasta.ps1, 1
FileInstall, pasta.ico, %A_Temp%\pasta\pasta.ico, 1
; Create a shortcut to launch the script to be able to set an icon in title bar and taskbar
FileCreateShortcut, C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe, %A_Temp%\pasta\pasta.lnk, , -NoProfile -ExecutionPolicy Bypass -file %A_Temp%\pasta\pasta.ps1, My Description, %A_Temp%\pasta\pasta.ico, i
; Wait for the script is closed before cleaning the temp folder
RunWait, %A_Temp%\pasta\pasta.lnk
FileRemoveDir, %A_Temp%\pasta, 1