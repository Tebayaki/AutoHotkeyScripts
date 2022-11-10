CONST                     := CONST ?? {},
CONST.WH_MSGFILTER        := -1,
CONST.WH_JOURNALRECORD    := 0,
CONST.WH_JOURNALPLAYBACK  := 1,
CONST.WH_KEYBOARD         := 2,
CONST.WH_GETMESSAGE       := 3,
CONST.WH_CALLWNDPROC      := 4,
CONST.WH_CBT              := 5,
CONST.WH_SYSMSGFILTER     := 6,
CONST.WH_MOUSE            := 7,
CONST.WH_DEBUG            := 9,
CONST.WH_SHELL            := 10,
CONST.WH_FOREGROUNDIDLE   := 11,
CONST.WH_CALLWNDPROCRET   := 12,
CONST.WH_KEYBOARD_LL      := 13,
CONST.WH_MOUSE_LL         := 14

/*
Persistent
SetLowLevelMouseHook(CallbackCreate(WindowsHookProc))
WindowsHookProc(nCode, wParam, lParam) {
    if 0 == nCode {
        mouseStatus := PMSLLHOOKSTRUCT(lParam)
        ToolTip mouseStatus.time, mouseStatus.x, mouseStatus.y
    }
    return CallNextHook(nCode, wParam, lParam)
}
*/

SetWindowsHookEx(idHook, lpfn, hmod, dwThreadId) {
    return DllCall("SetWindowsHookEx", "int", idHook, "ptr", lpfn, "ptr", hmod, "uint", dwThreadId, "ptr")
}

UnhookWindowsHookEx(hHook) {
    return DllCall("UnhookWindowsHookEx", "ptr", hHook)
}

SetLowLevelMouseHook(lpfn) {
    return DllCall("SetWindowsHookEx", "int", CONST.WH_MOUSE_LL, "ptr", lpfn, "ptr", 0, "uint", 0, "ptr")
}

SetLowLevelKeyboardHook(lpfn) {
    return DllCall("SetWindowsHookEx", "int", CONST.WH_KEYBOARD_LL, "ptr", lpfn, "ptr", 0, "uint", 0, "ptr")
}

CallNextHook(nCode, wParam, lParam) {
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)
}

class PKBDLLHOOKSTRUCT {
    __New(lParam) => this.Ptr := lParam
    vkCode => NumGet(this.Ptr, "uint")
    scanCode => NumGet(this.Ptr, 4, "uint")
    flags => NumGet(this.Ptr, 8, "uint")
    time => NumGet(this.Ptr, 12, "uint")
    dwExtraInfo => NumGet(this.Ptr, 16, "ptr")
}

class PMSLLHOOKSTRUCT {
    __New(lParam) => this.Ptr := lParam
    pt => NumGet(this.Ptr, "int64")
    x => NumGet(this.Ptr, "int")
    y => NumGet(this.Ptr, 4, "int")
    mouseData => NumGet(this.Ptr, 8, "uint")
    flags => NumGet(this.Ptr, 12, "uint")
    time => NumGet(this.Ptr, 16, "uint")
    dwExtraInfo => NumGet(this.Ptr, 24, "ptr")
}