Dim oShell
Set oShell = WScript.CreateObject ("WSCript.shell")
oShell.run "cmd /C 1.bat",0
Set oShell = Nothing