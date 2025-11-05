@echo off
for %%I in ("%~dp0..") do set "ACE=%%~fI"
cd "%ACE%"
echo Connect to this host:
echo   platform select remote-windows
echo.
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4,IPv6 | Where-Object {$_.SuffixOrigin -match 'Dhcp|Manual' -and $_.IPAddress -notlike '169.254.*' -and $_.IPAddress -notlike 'fe80::*'} | ForEach-Object {'  platform connect connect://'+$_.IPAddress+':1721'}"
echo.
bin\lldb-server.exe platform --listen "*:1721" --server
