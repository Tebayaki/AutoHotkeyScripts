/*
HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Keyboard Layouts
@Chinese  00000804
@English  00000409
@Japanese 00000411
*/
SetImeLayout(klid, hwnd := WinExist("A")) => SendMessage(80, 1, DllCall("LoadKeyboardLayoutW", "str", klid, "uint", 1, "ptr"), hwnd)

GetImeLayout(hwnd := WinExist("A")) => DllCall("GetKeyboardLayout", "uint", DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr", 0, "uint"), "ptr")

GetCurrentImeKLID() => (DllCall("GetKeyboardLayoutNameW", "str", name := "00000000"), name)

SetImeStatus(flag, hwnd?) {
    guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48), NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    hwnd := hwnd ?? DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr") || WinExist()
    return DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x6, "ptr", flag, "uint", 0, "uint", 300, "ptr*", 0)
}

GetImeStatus(hwnd?) {
    guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48), NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    hwnd := hwnd ?? DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr") || WinExist()
    DllCall("SendMessageTimeoutW", "ptr", DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", hwnd, "ptr"), "uint", 0x283, "ptr", 0x5, "ptr", 0, "uint", 0, "uint", 300, "ptr*", &res := 0)
    return res
}