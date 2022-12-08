/*
@WH_FOREGROUNDIDLE 11
@WH_GETMESSAGE 3
@WH_JOURNALPLAYBACK 1
@WH_JOURNALRECORD 0
@WH_KEYBOARD 2
@WH_KEYBOARD_LL 13
@WH_MAX 14
@WH_MAXHOOK WH_MAX
@WH_MIN ( - 1 )
@WH_MINHOOK WH_MIN
@WH_MOUSE 7
@WH_MOUSE_LL 14
@WH_MSGFILTER ( - 1 )
@WH_SHELL 10
@WH_SYSMSGFILTER 6

@Example
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
SetWindowsHookEx(idHook, lpfn, hmod, dwThreadId) => DllCall("SetWindowsHookEx", "int", idHook, "ptr", lpfn, "ptr", hmod, "uint", dwThreadId, "ptr")

UnhookWindowsHookEx(hHook) => DllCall("UnhookWindowsHookEx", "ptr", hHook)

SetLowLevelMouseHook(lpfn) => DllCall("SetWindowsHookEx", "int", 14, "ptr", lpfn, "ptr", 0, "uint", 0, "ptr")

SetLowLevelKeyboardHook(lpfn) => DllCall("SetWindowsHookEx", "int", 13, "ptr", lpfn, "ptr", 0, "uint", 0, "ptr")

CallNextHook(nCode, wParam, lParam) => DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)

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