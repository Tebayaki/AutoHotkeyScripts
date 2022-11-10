; HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Keyboard Layouts
CONST                         := CONST ?? {},
CONST.KLID_ChineseSimplifed   := "00000804",
CONST.KLID_US                 := "00000409",
CONST.KLID_Japanese           := "00000411"

SetImeStatus(flag, hwnd := GetFocusedWindow()) {
    if 0 !== hwnd := DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr")
        SendMessage(0x0283, 0x006, flag, hwnd)
}

GetImeStatus(hwnd := GetFocusedWindow()) {
    if 0 !== hwnd := DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr")
        return SendMessage(0x0283, 0x005, 0, hwnd)
    return 0
}

SetImeLayout(klid, hwnd := WinExist("A")) {
    return SendMessage(80, 1, DllCall("LoadKeyboardLayoutW", "str", klid, "uint", 1, "ptr"), hwnd)
}

GetImeLayout(hwnd := WinExist("A")) {
    return DllCall("GetKeyboardLayout", "uint", DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr", 0, "uint"), "ptr")
}

GetCurrentImeKLID() {
    DllCall("GetKeyboardLayoutNameW", "str", name := "00000000")
    return name
}

GetFocusedWindow() {
    if 0 == threadId := DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0)
        return 0
    guiThreadInfo := Buffer(72)
    NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    if !DllCall("GetGUIThreadInfo", "uint", threadId, "ptr", guiThreadInfo)
        return 0
    return NumGet(guiThreadInfo, 16, "ptr")
}
