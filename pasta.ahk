#Requires AutoHotkey >=2.0

;@Ahk2Exe-SetProductVersion 2.0.0.0

; The script needs to be compiled as 32 bit .exe to be able to run it on both architectures

ExitFunc(*) {
	DirDelete(A_Temp "\pasta", 1)
}

gi := "github.png"
ti := "twitter.png"
di := "discord.png"
bg := "bg.png"
if (A_IsCompiled = 1) {
	;No need for a tray icon
	A_IconHidden := true
	; Extract the files to temp folder first
	DirCreate(A_Temp "\pasta")
	bg := A_Temp "\pasta\" bg
	FileInstall "bg.png", bg, 1
	gi := A_Temp "\pasta\" gi
	FileInstall "github.png", gi, 1
	ti := A_Temp "\pasta\" ti
	FileInstall "twitter.png", ti, 1
	di := A_Temp "\pasta\" di
	FileInstall "discord.png", di, 1

	OnExit ExitFunc
}

ico := "pasta.ico"
if FileExist(ico) {
	TraySetIcon "pasta.ico"
}

GameDir := ""
SelectGameDir() {
	NewDir := FileSelect("D","C:\KEY\AIR_SE","Open")
	if (NewDir != "") {
		TextBoxGameDir.Value := NewDir
		global GameDir := NewDir

		if (CheckBoxPatchIni.Value = 1) or (CheckBoxMoreSaveSlots.Value = 1) {
			BtnPatchv1.Enabled := true
			BtnPatchv2.Enabled := true
		}
		BtnRestore.Enabled := true
	}
}

Backup() {
	if (CheckBoxPatchIni.Value = 1) or (CheckBoxMoreSaveSlots.Value = 1) {
		FileCopy GameDir "\GAMEEXE.INI", GameDir "\GAMEEXE.INI.bak"
	}
	if (CheckBoxConvertSavedata.Value = 1) {
		DirCopy GameDir "\SAVEDATA", GameDir "\SAVEDATA.bak"
	}
	MsgBox("Backup done.","Information",64)
}

HexEditSave(save, version) {
	oFile := FileOpen(save,"rw")
	offset := 24

	oFile.Pos := offset
	oFile.WriteUChar(65) ; 0x41 A

	oFile.Pos := offset+1
	oFile.WriteUChar(105) ; 0x69 i

	oFile.Pos := offset+2
	oFile.WriteUChar(114) ; 0x72 r

	; # Fill the title in .ini file with NULL or whitespaces
	; # 127 characters is the max length, used to prevent randomness
	Loop 124 {
		oFile.Pos := offset+2+A_Index

		if version = "v1" {
			oFile.WriteUChar(32) ; 0x20 124 whitespaces
		}
		if version = "v2" {
			oFile.WriteUChar(0)  ; 0x00 124 NULL
		}
	}

	oFile.Pos := offset+127
	oFile.WriteUChar(0) ; 0x00 NULL
}

Patch(version) {

	if FileExist(GameDir "\GAMEEXE.INI.bak") or DirExist(GameDir "\SAVEDATA.bak") {
		MsgBox("Already patched!`nTo patch again use restore first or manually rename or remove GAMEEXE.INI.bak and SAVEDATA.bak folder.","Information",64)
	}
	else if (FileExist(GameDir "\GAMEEXE.INI") and ((CheckBoxPatchIni.Value = 1) or (CheckBoxMoreSaveSlots.Value = 1))) or (DirExist(GameDir "\SAVEDATA") and (CheckBoxConvertSavedata.Value = 1)) {

		if (CheckBoxBackup.Value = 1) {
			Backup
		}
		else {
			if A_Args.Length = 0 {
				; Ask if GUI
				Res := MsgBox("No backup will be created. Are you sure you want to proceed?","Question",33)
			}
			else {
				; Force if CLI
				Res := "OK"
			}
		}
		if ((CheckBoxBackup.Value = 1) or Res = "OK") {

			if ((CheckBoxPatchIni.Value = 1) or (CheckBoxMoreSaveSlots.Value = 1)) {
				; Patch
				IniContent := FileRead(GameDir "\GAMEEXE.INI")
				if (CheckBoxPatchIni.Value = 1) {
					if version = "v1" {
						IniContent := RegExReplace(IniContent, '#CAPTION=".+"', '#CAPTION="Air                                                                                                                            "')
					}
					if version = "v2" {
						IniContent := RegExReplace(IniContent, '#CAPTION=".+"', '#CAPTION="Air"')
					}

					; Force default encoding of the title
					IniContent := RegExReplace(IniContent, '#NAME_ENC=[0-9]', '#NAME_ENC=0')
				}
				if (CheckBoxMoreSaveSlots.Value = 1) {
					IniContent := RegExReplace(IniContent, '#SAVE_CNT=[0-9]{3}', '#SAVE_CNT=256')
				}
				FileDelete(GameDir "\GAMEEXE.INI")
				FileAppend(IniContent,GameDir "\GAMEEXE.INI")
				MsgBox("GAMEEXE.INI is patched","Information",64)
			}

			if (CheckBoxConvertSavedata.Value = 1) {
				; Convert savedata
				Loop Files, GameDir "\SAVEDATA\*.sav"
				{
					; # Hex-edit the title in each save file corresponding to the numbered slots
					; # Don't touch read.sav, REALLIVE.sav and save999.sav
					if RegExMatch(A_LoopFileName, "save(?:[0-8][0-9][0-9]|99[0-8]).sav")
						HexEditSave(A_LoopFilePath, version)
				}
				MsgBox("Save files are patched","Information",64)
			}

		}

	}
	else {
		MsgBox("Something went wrong, Gao...`nThe files to patch are missing, aborting.`nThis is probably not the right path.`nLook for AIR_SE folder.","Warning",48)
	}

}

Restore() {
	if FileExist(GameDir "\GAMEEXE.INI.bak") {
		if FileExist(GameDir "\GAMEEXE.INI") {
			FileDelete GameDir "\GAMEEXE.INI"
		}
		FileMove GameDir "\GAMEEXE.INI.bak", GameDir "\GAMEEXE.INI"
		MsgBox("GAMEEXE.INI file backup restored.","Information",64)
	}
	else {
		MsgBox("No GAMEEXE.INI.bak file backup present.","Information",64)
	}

	if DirExist(GameDir "\SAVEDATA.bak") {
		if DirExist(GameDir "\SAVEDATA") {
			DirDelete GameDir "\SAVEDATA", 1
		}
		DirMove GameDir "\SAVEDATA.bak", GameDir "\SAVEDATA"
		MsgBox("SAVEDATA.bak folder backup restored.","Information",64)
	}
	else {
		MsgBox("No SAVEDATA.bak folder backup present.","Information",64)
	}
}

BtnSelect_Click(*) {
	; OwnDialogs to block user clicks until all popup are closed
	MyGui.Opt("+OwnDialogs")
	SelectGameDir
}

CheckBoxPatchIni_Click(*){
	if (CheckBoxPatchIni.Value = 0) {
		CheckBoxConvertSavedata.Value := 0
		CheckBoxConvertSavedata.Enabled := false
	}
	else {
		CheckBoxConvertSavedata.Value := 1
		CheckBoxConvertSavedata.Enabled := true
	}
	if (GameDir != "") {
	if (CheckBoxPatchIni.Value = 0) and (CheckBoxMoreSaveSlots.Value = 0)   {
		BtnPatchv1.Enabled := false
		BtnPatchv2.Enabled := false
		;BtnRestore.Enabled := false
	}
	else {
		BtnPatchv1.Enabled := true
		BtnPatchv2.Enabled := true
		;BtnRestore.Enabled := true
	}
}
}

CheckBoxMoreSaveSlots_Click(*){
	if (GameDir != "") {
	if (CheckBoxPatchIni.Value = 0) and (CheckBoxMoreSaveSlots.Value = 0)  {
		BtnPatchv1.Enabled := false
		BtnPatchv2.Enabled := false
		;BtnRestore.Enabled := false
	}
	else {
		BtnPatchv1.Enabled := true
		BtnPatchv2.Enabled := true
		;BtnRestore.Enabled := true
	}
}
}

Patch_v2_Click(*) {
	; OwnDialogs to block user clicks until all popup are closed
	MyGui.Opt("+OwnDialogs")
	Patch("v2")
}

Patch_v1_Click(*) {
	; OwnDialogs to block user clicks until all popup are closed
	MyGui.Opt("+OwnDialogs")
	Patch("v1")
}

Restore_Click(*) {
	; OwnDialogs to block user clicks until all popup are closed
	MyGui.Opt("+OwnDialogs")

	Restore
}

BtnGithub_Click(*) {
	Run("https://mashedmonk.github.io/pasta")
}

BtnTwitter_Click(*) {
	Run("https://twitter.com/Sep717")
}

BtnDiscord_Click(*) {
	Run("https://discord.gg/N8wTXEK")
}

MyGui := Gui(,"PASTA - Patch AIR Saves and Title Anomaly (v2)")
MyGui.SetFont("s8")

; Need to set the picture resolution the same as the Window in order to scale properly in case of high DPI
if FileExist(bg) {
	MyGui.Add("Picture", "x0 y0 w640 h480", bg)
}

MyGui.Add("Text","xm ym+232 Section BackgroundTrans","This patch is meant to fix a recurring bug affecting save files visibility in AIR.")

MyGui.Add("Text","xs y+10 Section BackgroundTrans","Select the game installation directory:")
BtnSelect := MyGui.Add("Button", "Default w80", "Select")
BtnSelect.OnEvent("Click", BtnSelect_Click)
TextBoxGameDir := MyGui.Add("Edit","x+m w320 ReadOnly",)

MyGui.Add("Text","xs Section BackgroundTrans","Backup the configuration and/or save files if modified:")
CheckBoxBackup := MyGui.Add("Checkbox","Checked w13 h13")
MyGui.Add("Text","x+2 BackgroundTrans","Make a backup before patching.")

MyGui.Add("Text","Section BackgroundTrans xs","Apply the patch:")
CheckBoxPatchIni := MyGui.Add("Checkbox","Checked w13 h13")
CheckBoxPatchIni.OnEvent("Click", CheckBoxPatchIni_Click)
MyGui.Add("Text","x+2 BackgroundTrans","Patch the game.")
CheckBoxConvertSavedata := MyGui.Add("Checkbox","Checked x+50 w13 h13")
MyGui.Add("Text","x+2 BackgroundTrans","Convert existing save files.")

MyGui.Add("Text","Section BackgroundTrans xs","Add more savegame slots:")
CheckBoxMoreSaveSlots := MyGui.Add("Checkbox","Checked w13 h13")
CheckBoxMoreSaveSlots.OnEvent("Click", CheckBoxMoreSaveSlots_Click)
MyGui.Add("Text","x+2 BackgroundTrans","Allow to create up to 256 savegame files instead of 100.")

BtnPatchv1 := MyGui.Add("Button", "xs w130 Disabled", "Patch")
BtnPatchv1.OnEvent("Click", Patch_v2_Click)
BtnPatchv2 := MyGui.Add("Button", "w130 x+m Disabled", "Patch (alternate fix)")
BtnPatchv2.OnEvent("Click", Patch_v1_Click)
BtnRestore := MyGui.Add("Button", "w130 x+m Disabled", "Restore")
BtnRestore.OnEvent("Click", Restore_Click)

if FileExist(gi) {
	BtnGithub := MyGui.Add("Picture", "BackgroundTrans xs+268 w-1 h21", gi)
}
else {
	BtnGithub := MyGui.Add("Text", "BackgroundTrans xs+268", "Github")
}
BtnGithub.OnEvent("Click", BtnGithub_Click)
if FileExist(ti) {
	BtnTwitter := MyGui.Add("Picture", "BackgroundTrans  x+m w-1 h21", ti)
}
else {
	BtnTwitter := MyGui.Add("Text", "BackgroundTrans x+m", "Twitter")
}
BtnTwitter.OnEvent("Click", BtnTwitter_Click)
if FileExist(di) {
	BtnDiscord := MyGui.Add("Picture", "BackgroundTrans x+m w-1 h21", di)
}
else {
	BtnDiscord := MyGui.Add("Text", "BackgroundTrans x+m", "Discord")
}
BtnDiscord.OnEvent("Click", BtnDiscord_Click)

; If the defaut path exists, select it
if DirExist("C:\KEY\AIR_SE") {
	TextBoxGameDir.Value := "C:\KEY\AIR_SE"
	GameDir := "C:\KEY\AIR_SE"
	BtnPatchv1.Enabled := true
	BtnPatchv2.Enabled := true
	BtnRestore.Enabled := true
}

MyGui.MarginX := 0
MyGui.MarginY := 0

if A_Args.Length = 0 {
	; GUI
	MyGui.Show("w640 h480")
}
else if A_Args.Length = 6 {
	; CLI
	if DirExist(A_Args[1]) {
		GameDir := A_Args[1]
	}
	else {
		MsgBox("The path " A_Args[1] " does not exist.", "Error", 16)
		ExitApp
	}
	if (A_Args[3] = 0) {
		CheckBoxBackup.Value := 0
	}
	if (A_Args[4] = 0) {
		CheckBoxPatchIni.Value := 0
	}
	if (A_Args[5] = 0) {
		CheckBoxConvertSavedata.Value := 0
	}
	if (A_Args[6] = 0) {
		CheckBoxMoreSaveSlots.Value := 0
	}
	if (A_Args[2] = 0) {
		Restore
	}
	else if (A_Args[2] = 1) {
		; Alternate fix
		Patch("v1")
	}
	else if (A_Args[2] = 2) {
		Patch("v2")
	}
}
else {
	MsgBox("This script requires exactly 6 parameters but it received " A_Args.Length ".", "Error", 16)
}