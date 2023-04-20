ReloadAhk(ahkWinTitle) => PostMessage(0x111, 65303, , , ahkWinTitle)

EditAhk(ahkWinTitle) => PostMessage(0x111, 65304, , , ahkWinTitle)

SuspendAhk(ahkWinTitle) => PostMessage(0x111, 65305, , , ahkWinTitle)

PauseAhk(ahkWinTitle) => PostMessage(0x111, 65306, , , ahkWinTitle)

StopAhk(ahkWinTitle) => PostMessage(0x111, 65307, , , ahkWinTitle)

KillAhk(ahkWinTitle) => DllCall("SendMessageTimeoutW", "ptr", hwnd := WinGetID(ahkWinTitle), "uint", 0x111, "ptr", 65307, "ptr", 0, "uint", 0, "uint", 1000, "uint*", 0) || A_LastError == 1460 && WinKill(hwnd)

StopAllAhk() {
    DetectHiddenWindows(true)
    for hwnd in WinGetList("ahk_class AutoHotkey")
        if A_ScriptHwnd !== hwnd
            PostMessage(0x111, 65307,,, hwnd)
}

KillAllAhk() {
    DetectHiddenWindows(true)
    for hwnd in WinGetList("ahk_class AutoHotkey")
        if A_ScriptHwnd !== hwnd
            DllCall("SendMessageTimeoutW", "ptr", hwnd, "uint", 0x111, "ptr", 65307, "ptr", 0, "uint", 0, "uint", 1000, "uint*", 0) || A_LastError == 1460 && WinKill(hwnd)
}
