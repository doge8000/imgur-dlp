@echo off
SET SELFPATH=%~dp0
SET SELFPATH=%SELFPATH:~0,-1%

powershell -ExecutionPolicy bypass %SELFPATH%\imgur-dlp-main.ps1 %*
