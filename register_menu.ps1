New-Item -Path "Registry::HKCR\.ahk" -Value "AutoHotkeyScript" -Force
New-Item -Path "Registry::HKCR\.ahk\PersistantHandler" -Value "{5e941d80-bf96-11cd-b579-08002b30bfeb}" -Force
New-Item -Path "Registry::HKCR\.ahk\ShellNew" -Force
Set-ItemProperty -Path "Registry::HKCR\.ahk\ShellNew" -Name "NullFile" -Value ""
New-Item -Path "Registry::HKCR\AutoHotkeyScript" -Value "AutoHotkey Script" -Force
Set-ItemProperty -Path "Registry::HKCR\AutoHotkeyScript" -Name "AppUserModelID" -Value "AutoHotkey.AutoHotkey"
New-Item -Path "Registry::HKCR\AutoHotkeyScript\DefaultIcon" -Value "C:\PROGRA~1\AutoHotkey\AutoHotkey64.exe,1" -Force
New-Item -Path "Registry::HKCR\AutoHotkeyScript\Shell" -Force
New-Item -Path "Registry::HKCR\AutoHotkeyScript\Shell\Open" -Value "Run script" -Force
Set-ItemProperty -Path "Registry::HKCR\AutoHotkeyScript\Shell\Open" -Name "AppUserModelID" -Value "AutoHotkey.AutoHotkey"
Set-ItemProperty -Path "Registry::HKCR\AutoHotkeyScript\Shell\Open" -Name "FriendlyAppName" -Value "AutoHotkey"
New-Item -Path "Registry::HKCR\AutoHotkeyScript\Shell\Open\Command" -Value '"C:\PROGRA~1\AutoHotkey\AutoHotkey64.exe" "%1" "%*"' -Force
New-Item -Path "Registry::HKCR\AutoHotkeyScript\Shell\RunAs" -Force
Set-ItemProperty -Path "Registry::HKCR\AutoHotkeyScript\Shell\RunAs" -Name "AppUserModelID" -Value "AutoHotkey.AutoHotkey"
Set-ItemProperty -Path "Registry::HKCR\AutoHotkeyScript\Shell\RunAs" -Name "HasLUAShield" -Value ""
New-Item -Path "Registry::HKCR\AutoHotkeyScript\Shell\RunAs\Command" -Value '"C:\PROGRA~1\AutoHotkey\AutoHotkey64.exe" "%1" "%*"' -Force