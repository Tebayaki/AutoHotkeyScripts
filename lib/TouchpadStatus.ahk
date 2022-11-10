; GetTouchpadStatus require run as admin
GetTouchpadStatus() => RegRead("HKEY_USERS\S-1-5-21-3441713403-2967228695-3848367287-1001\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad\Status", "Enabled", "")
SetTouchpadStatus(flag) => GetTouchpadStatus() == flag && Send("#^{f24}")
ToggleTouchpadStatus() => Send("#^{f24}")