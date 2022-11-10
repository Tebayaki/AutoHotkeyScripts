/*
@Require AutoHotkey V2.0+
@Version 0.3
@Description 按住CapsLock，可在窗口的任意位置用鼠标左键拖动窗口，用滚轮调整窗口大小, 用中键（取消）置顶窗口
*/

CapsLock & LButton:: {
    if !hwnd := GetMousePosRelativeToHoveredWindow(&cursorXToWin, &cursorYToWin)
        return
    if !WinActive(hwnd)
        SetWinDelay(-1), WinActivate(hwnd)
    pLowLevelMouseProc := CallbackCreate(lowLevelMouseProc, "F")
    hHook := DllCall("SetWindowsHookEx", "int", 14, "ptr", pLowLevelMouseProc, "ptr", 0, "uint", 0, "ptr")
    lowLevelMouseProc(nCode, wParam, lParam) {
        Critical
        if 0 == nCode {
            if 0x0200 == wParam
                DllCall("SetWindowPos", "ptr", hwnd, "ptr", 0, "int", NumGet(lParam, "int") - cursorXToWin, "int", NumGet(lParam, 4, "int") - cursorYToWin, "int", 0, "int", 0, "uint", 1)
            else if 0x0202 == wParam {
                DllCall("UnhookWindowsHookEx", "ptr", hHook)
                CallbackFree(pLowLevelMouseProc)
            }
        }
        return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)
    }
}

CapsLock & WheelUp::
CapsLock & WheelDown:: {
    if !hwnd := GetMousePosRelativeToHoveredWindow(&cursorXToWin, &cursorYToWin)
        return
    if !WinActive(hwnd)
        SetWinDelay(-1), WinActivate(hwnd)
    WinGetPos(&winX, &winY, &winW, &winH, hwnd)
    cursorXRatioToWin := cursorXToWin / winW
    cursorYRatioToWin := cursorYToWin / winH
    winWHRatio := winW / winH
    newWinW := winW + A_ScreenWidth * (A_ThisHotkey == "CapsLock & WheelUp" ? 0.07 : -0.07)
    newWinH := newWinW / winWHRatio
    newWinX := winX - (newWinW - winW) * cursorXRatioToWin
    newWinY := winY - (newWinH - winH) * cursorYRatioToWin
    DllCall("SetWindowPos", "ptr", hwnd, "ptr", 0, "int", newWinX, "int", newWinY, "int", newWinW, "int", newWinH, "uint", 0)
}

CapsLock & MButton:: {
    if (MouseGetPos(,, &hwnd), hwnd)
        WinSetAlwaysOnTop(-1, hwnd)
}

GetMousePosRelativeToHoveredWindow(&x, &y) {
    DllCall("GetCursorPos", "int64*", &cursorPt := 0)
    childHwnd := DllCall("WindowFromPoint", "int64", cursorPt, "ptr")
    if 0 == hwnd := DllCall("GetAncestor", "ptr", childHwnd, "uint", 2, "ptr")
        return
    WinGetPos(&winX, &winY, , , hwnd)
    x := (cursorPt & 0xffffffff) - winX
    y := (cursorPt >> 32) - winY
    return hwnd
}