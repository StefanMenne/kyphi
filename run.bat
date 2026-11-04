@echo off
rem Startet Kyphi. Neue oder geaenderte Assets werden vorher importiert.
setlocal EnableDelayedExpansion
cd /d "%~dp0"

rem Godot finden: Umgebungsvariable GODOT, PATH oder winget-Installation
if not defined GODOT (
	for %%G in (godot.exe) do if not "%%~$PATH:G"=="" set "GODOT=%%~$PATH:G"
)
if not defined GODOT (
	for /d %%D in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_*") do (
		for %%F in ("%%D\Godot_v4.7*_win64.exe") do set "GODOT=%%F"
	)
)
if not defined GODOT (
	echo Godot 4.7 nicht gefunden. Installieren mit:
	echo   winget install --id GodotEngine.GodotEngine
	echo oder Pfad zur exe in der Umgebungsvariable GODOT setzen.
	exit /b 1
)

rem Import, wenn noch nie importiert oder Dateien in assets/game neuer als der Marker sind
set "marker=.godot\last_import"
set "need_import="
if not exist "%marker%" (
	set "need_import=1"
) else (
	for /f %%N in ('powershell -NoProfile -Command "$m=(Get-Item '%marker%').LastWriteTime; @(Get-ChildItem assets,game -Recurse -File | Where-Object LastWriteTime -gt $m).Count"') do (
		if not "%%N"=="0" set "need_import=1"
	)
)
if defined need_import (
	"%GODOT%" --headless --path . --import >nul 2>&1
	if not exist .godot mkdir .godot
	type nul > "%marker%"
)

"%GODOT%" --path . %*
