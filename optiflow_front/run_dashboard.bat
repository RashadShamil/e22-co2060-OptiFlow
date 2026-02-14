@echo off
echo checking for developer mode...
start ms-settings:developers
echo Please enable Developer Mode if not already enabled, then press any key to continue.
pause

echo Getting dependencies...
C:\flutter\bin\flutter.bat pub get

echo Running Dashboard...
C:\flutter\bin\flutter.bat run -d windows
pause
