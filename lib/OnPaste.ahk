gExcludesHwnds := GetClipboardFormatListenerList() ; 阻止一些剪贴板工具窗口触发
; ; 粘贴后显示一个msgbox
; f1::OnPaste(A_Clipboard, () => MsgBox("剪贴板文字已被获取"), gExcludesHwnds)

; ; 粘贴后自动还原剪贴板
; f2::{
;     old := A_Clipboard
;     OnPaste("剪贴板已还原", () => A_Clipboard := old, gExcludesHwnds)
;     Send("^v")
; }

OnPaste(str, callback := unset, excludes := unset) {
    OnMessage(0x0305, WM_RENDERFORMAT, 0) ; 确保回调被更新
    OnMessage(0x0305, WM_RENDERFORMAT)
    DllCall("OpenClipboard", "ptr", A_ScriptHwnd)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint", 1, "ptr", 0, "ptr")
    DllCall("CloseClipboard")

    WM_RENDERFORMAT(*) {
        ; 很多剪贴板工具会自动读取剪贴板并触发这段代码, 没有很好的方法精确排除这些窗口
        if IsSet(excludes) && excludes.Has(DllCall("GetOpenClipboardWindow", "ptr"))
            return 0
        hGlobal := DllCall("GlobalAlloc", "uint", 0x0042, "uptr", StrPut(str, "cp0"), "ptr")
        StrPut(str, DllCall("GlobalLock", "ptr", hGlobal, "ptr"), "cp0")
        DllCall("GlobalUnlock", "ptr", hGlobal)
        DllCall("SetClipboardData", "uint", 1, "ptr", hGlobal, "ptr")
        DllCall("ReplyMessage", "ptr", 0)
        IsSet(callback) && callback()
        OnMessage(0x0305, WM_RENDERFORMAT, 0)
        return 0
    }
}

GetClipboardFormatListenerList(){
    tmp := A_Clipboard
    listeners := Map()
    OnMessage(0x0305, WM_RENDERFORMAT)
    DllCall("OpenClipboard", "ptr", A_ScriptHwnd)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint", 1, "ptr", 0, "ptr")
    DllCall("CloseClipboard")
    Sleep(250)
    OnMessage(0x0305, WM_RENDERFORMAT, 0)
    A_Clipboard := tmp
    return listeners
    WM_RENDERFORMAT(*) => listeners[DllCall("GetOpenClipboardWindow", "ptr")] := 0
}