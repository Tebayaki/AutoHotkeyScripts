/*
@define WH_FOREGROUNDIDLE 11
@define WH_GETMESSAGE 3
@define WH_JOURNALPLAYBACK 1
@define WH_JOURNALRECORD 0
@define WH_KEYBOARD 2
@define WH_KEYBOARD_LL 13
@define WH_MAX 14
@define WH_MAXHOOK WH_MAX
@define WH_MIN ( - 1 )
@define WH_MINHOOK WH_MIN
@define WH_MOUSE 7
@define WH_MOUSE_LL 14
@define WH_MSGFILTER ( - 1 )
@define WH_SHELL 10
@define WH_SYSMSGFILTER 6

@Example
#Persistent
hHook := SetLowLevelMouseHook(RegisterCallback("LowLevelMouseProc", "Fast"))
; UnhookWindowsHookEx(hHook) ; 移除钩子

LowLevelMouseProc(nCode, wParam, lParam) {
    Critical
    if (!nCode) {
        ; 在这里插入你的的代码
        static mouseInfo := new PMSLLHOOKSTRUCT(lParam)
        static actions := {0x0200: "WM_MOUSEMOVE", 0x0201: "WM_LBUTTONDOWN", 0x0202: "WM_LBUTTONUP", 0x0204: "WM_RBUTTONDOWN", 0x0205: "WM_RBUTTONUP", 0x0207: "WM_MBUTTONDOWN", 0x0208: "WM_MBUTTONUP",  0x020A: "WM_MOUSEWHEEL", 0x020E: "WM_MOUSEHWHEEL"}
        mouseInfo.Ptr := lParam
        CoordMode, ToolTip, Screen
        ToolTip, % actions[wParam] " " mouseInfo.time, % mouseInfo.x + 1, % mouseInfo.y + 1
    }
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)
}
*/

SetLowLevelMouseHook(lpfn) {
    return DllCall("SetWindowsHookEx", "int", 14, "ptr", lpfn, "ptr", 0, "uint", 0, "ptr")
}

SetLowLevelKeyboardHook(lpfn) {
    return DllCall("SetWindowsHookEx", "int", 13, "ptr", lpfn, "ptr", 0, "uint", 0, "ptr")
}

SetWindowsHookEx(idHook, lpfn, hmod, dwThreadId) {
    return DllCall("SetWindowsHookEx", "int", idHook, "ptr", lpfn, "ptr", hmod, "uint", dwThreadId, "ptr")
}

UnhookWindowsHookEx(hHook) {
    return DllCall("UnhookWindowsHookEx", "ptr", hHook)
}

CallNextHook(nCode, wParam, lParam) {
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)
}

class PMSLLHOOKSTRUCT {
    __New(lParam) {
        this.Ptr := lParam
    }
    pt {
        get {
            return NumGet(this.Ptr, "int64")
        }
    }
    x {
        get {
            return NumGet(this.Ptr, "int")
        }
    }
    y {
        get {
            return NumGet(this.Ptr, 4, "int")
        }
    }
    mouseData {
        get {
            return NumGet(this.Ptr, 8, "uint")
        }
    }
    flags {
        get {
            return NumGet(this.Ptr, 12, "uint")
        }
    }
    time {
        get {
            return NumGet(this.Ptr, 16, "uint")
        }
    }
    dwExtraInfo {
        get {
            return NumGet(this.Ptr, 24, "ptr")
        }
    }
}

class PKBDLLHOOKSTRUCT {
    __New(lParam) {
        this.Ptr := lParam
    }
    vkCode {
        get {
            return NumGet(this.Ptr, "uint")
        }
    }
    scanCode {
        get {
            return NumGet(this.Ptr, 4, "uint")
        }
    }
    flags {
        get {
            return NumGet(this.Ptr, 8, "uint")
        }
    }
    time {
        get {
            return NumGet(this.Ptr, 12, "uint")
        }
    }
    dwExtraInfo {
        get {
            return NumGet(this.Ptr, 16, "ptr")
        }
    }
}