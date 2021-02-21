$host.ui.RawUI.WindowTitle = "PASTA - Patch Air Saves and Title Anomaly"

Write-Output @"
                                                                                                888888
                                                                                               88t8S888
                                                                                              @88S8S8888
                                                                                              X888888888
                                                                                             S8888@888S
                                                                                            888888X88888
                                                                                            8888X8888888
            :                                                                               8@S88888888
            :;                                                                               8888SS88888
           :t;                                                                               88888%888888
          :  :;                                                                             88888888888888
         :;  :t;                                                                            @888888888888@8        8
         :    :;                         :                   ::::::::                       @8@X@X@X@@@X @@        8
        :      :;                        :;                 :t       :;;                    XXS8S8;8S8;8  XX       8
       :       :t                        :t                 :t         :;                   SS%8t;8.8:8.  8SX      @
      :;        :;                       :t                 :t         .;                  @%88888:8 8 8:  @S%     @
      :         S;8                      :t                 :t         :t                  %;8t88@8;888 8   X%%   %@
     :  S  ;%@SX8;8SSXX. X               :t                 :t        :t                  %8.8888888@.%8.8   Xt%8%%8
    :;            :;                     :t                 :t;;:::;;                   8t888S888:SX.888:8     tt8 8
   :t             :t;                    :t                 :t     :t                 ;;8888.888X8 8888 8888   .8. 8
   :               :;                    :t                 :t      :;             .8:888888888.888X88888@%:8      8
  :                :t;                   :t                 :t        :;           888S8888888%X88888@88.@888888   8
 :;                 :;;                  :t                 :t         :;          88; 8888888S8888@88888888888t   8
:t                   :t                  :t                 ;S          ttt        .8  ;@8@@X88888X88888888@88     8
                                                                                        S@X@8@@@   X8X@@8888@.%
                                                                                          t@SXX    %@XS8
                                                                                            :XS    :XS
"@

# File browser
[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()
$browse = New-Object System.Windows.Forms.FolderBrowserDialog
$browse.SelectedPath = "C:\KEY\AIR_SE"
$browse.ShowNewFolderButton = $false
$browse.Description = "Select a directory"

$loop = $true
while($loop) {
	if ($browse.ShowDialog() -eq "OK") {
		$loop = $false

		$path = $browse.SelectedPath

		$menu = "1 - Backup and patch`n"+
				"2 - Restore backups and unpatch`n"+
				"3 - About us`n"+
				"4 - Quit`n" +
				"Please make a choice"

		Do { # Loop through the menu
			$choice = Read-Host -Prompt "$menu"

			Write-Output ""

			switch ($choice) {
				1 { 
					# Check if .bak files are present
					# If not, check if GAMEEXE.ini and SAVEDATA folder are present
					# If not, it is wrong path, abort
					if ((Test-Path $path\GAMEEXE.ini.bak) -or (Test-Path $path\SAVEDATA.bak)) {
						Write-Output "Already patched!"
						Write-Output "To patch again use restore first or manually rename or remove GAMEEXE.ini.bak and SAVEDATA.bak folder."
					}
					elseif ((Test-Path $path\GAMEEXE.ini) -and (Test-Path $path\SAVEDATA)) {

						# Make a backup
						Copy-Item -Path $path\GAMEEXE.ini -Destination $path\GAMEEXE.ini.bak
						# Fill the title in .ini file with whitespaces
						# 127 characters is the max length, used to prevent randomness
						$124whitespaces = " "*124
						(Get-Content $path\GAMEEXE.INI) -replace "#CAPTION=`"Air(.*)`"","#CAPTION=`"Air$124whitespaces`"" | Set-Content $path\GAMEEXE.ini -Encoding ASCII
						# Encoding ASCII forces UTF7, making the file UTF8 without BOM
						# as long as there is no unsupported character
						# UTF8 option does make an UTF8-BOM on PowerShell (not core)

						Write-Output "GAMEEXE.INI is patched"

						# Hex-edit the title in each save file corresponding to the numbered slots
						# Don't touch read.sav, REALLIVE.sav and save999.sav
						# Make a backup
						Copy-Item -Path $path\SAVEDATA -Destination $path\SAVEDATA.bak -Recurse

						$i = 0
						$files = Get-ChildItem -Path $path\SAVEDATA | Where-Object Name -like save*.sav | Where-Object Name -ne save999.sav
						$files | ForEach-Object {

							# Position of the title
							$offset = 0x18
							[byte[]]$bytes = $_ | Get-Content -Encoding Byte -Raw

							$bytes[$offset]   = 0x41   # A
							$bytes[$offset+1] = 0x69   # i
							$bytes[$offset+2] = 0x72   # r

							1..124 | Foreach-Object{$bytes[$offset+2+$_] = 0x20} # 124 whitespaces

							$bytes[$offset+127] = 0x00 # NULL

							$_ | Set-Content -Value $bytes -Encoding Byte

							$i = $i+1
							Write-Progress -Activity "Patching save files" -Status "Progress:" -PercentComplete ($i/$files.count*100)
						}
						Write-Output "Save files are patched"

					}
					else {
						Write-Output "Something went wrong, Gao..."
						Write-Output "The files to patch are missing, aborting. This is probably not the right path. Look for AIR_SE folder."
					}
				}
				2 { # Restore

					if ((Test-Path $path\GAMEEXE.ini.bak)) {
						Remove-Item -Path $path\GAMEEXE.ini -ErrorAction Ignore
						Move-Item -Path $path\GAMEEXE.ini.bak -Destination $path\GAMEEXE.ini
						Write-Output "GAMEEXE.ini has been restored."
					}
					else {
						Write-Output "No GAMEEXE.ini.bak file backup present."
					}
					if (Test-Path $path\SAVEDATA.bak) {
						Remove-Item -Path $path\SAVEDATA -Recurse -ErrorAction Ignore
						Move-Item -Path $path\SAVEDATA.bak -Destination $path\SAVEDATA
						Write-Output "SAVEDATA folder has been restored."
					}
					else {
						Write-Output "No SAVEDATA.bak folder backup present."
					}
				}
				3 {
					Write-Output "Script made by @mashedmonk with help from @Sep7em"
					Write-Output "GitHub: https://github.com/mashedmonk/pasta"
					Write-Output "Please be free to come talk about the game or series at https://discord.gg/N8wTXEK"
					# Credits to https://code.adonline.id.au/folder-file-browser-dialogues-powershell/ for the folder selector
				}
				4 {} # Do nothing and quit
				Default {} # Do nothing and reload the menu
			}

			Write-Output ""
		} While ($choice -notin 4)

	}
	else {
		$res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
		if($res -eq "Cancel") {
			#Ends script
			return
		}
	}
}
$browse.Dispose()