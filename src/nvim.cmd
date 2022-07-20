@echo off

set exe=%~dp0bin\nvim-qt.exe

reg delete "HKCR\*\shell\nvim" /f
reg delete "HKCU\Software\Classes\Directory\Background\shell\nvim" /f

set file=\"%exe%\" \"%%1\"
reg add "HKCR\*\shell\nvim" /v Icon /d "%exe%,0" /f
reg add "HKCR\*\shell\nvim" /ve /d "Open with Vim" /f
reg add "HKCR\*\shell\nvim\command" /ve /d "%file%" /f

set dir=\"%exe%\" .
reg add "HKCU\Software\Classes\Directory\Background\shell\nvim" /v Icon /d "%exe%,0" /f
reg add "HKCU\Software\Classes\Directory\Background\shell\nvim" /ve /d "Open with Vim" /f
reg add "HKCU\Software\Classes\Directory\Background\shell\nvim\command" /ve /d "%dir%" /f
