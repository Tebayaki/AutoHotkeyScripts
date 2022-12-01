/*
f1::{
    CoordMode("ToolTip", "Screen")
    if hwnd := GetCaretPosEx(&x, &y, &w, &h) {
        ToolTip(WinGetClass(hwnd), x, y + h)
    }
    else {
        ToolTip()
    }
}
*/

GetCaretPosEx(&x := 0, &y := 0, &w := 0, &h := 0) {
    ; Plan A applies to standard win32 controls
    if tid := DllCall("GetWindowThreadProcessId", "ptr", hwndFore := WinExist("A"), "ptr", 0) {
        if A_PtrSize == 8 {
            guiInfo := Buffer(72), NumPut("uint", guiInfo.Size, guiInfo)
            if DllCall("GetGUIThreadInfo", "uint", tid, "ptr", guiInfo) {
                if hwndCaret := NumGet(guiInfo, 48, "ptr") {
                    w := NumGet(guiInfo, 64, "int") - NumGet(guiInfo, 56, "int")
                    h := NumGet(guiInfo, 68, "int") - NumGet(guiInfo, 60, "int")
                    DllCall("ClientToScreen", "ptr", hwndCaret, "ptr", guiInfo.Ptr + 56)
                    x := NumGet(guiInfo, 56, "int")
                    y := NumGet(guiInfo, 60, "int")
                    return hwndCaret
                }
                hwndFocus := NumGet(guiInfo, 16, 'ptr')
            }
        }
        else {
            guiInfo := Buffer(48), NumPut("uint", guiInfo.Size, guiInfo)
            if DllCall("GetGUIThreadInfo", "uint", tid, "ptr", guiInfo) {
                if hwndCaret := NumGet(guiInfo, 28, "ptr") {
                    w := NumGet(guiInfo, 40, "int") - NumGet(guiInfo, 32, "int")
                    h := NumGet(guiInfo, 44, "int") - NumGet(guiInfo, 36, "int")
                    DllCall("ClientToScreen", "ptr", hwndCaret, "ptr", guiInfo.Ptr + 32)
                    x := NumGet(guiInfo, 32, "int")
                    y := NumGet(guiInfo, 36, "int")
                    return hwndCaret
                }
                hwndFocus := NumGet(guiInfo, 12, 'ptr')
            }
        }
    }
    ; Plan B applies to windows with MSAA OBJID_CARET support, such as chrome
    if hOleacc := DllCall("LoadLibraryW", "str", "Oleacc.dll", "ptr") {
        hwndFocus := IsSet(hwndFocus) ? hwndFocus || hwndFore : hwndFore
        iid := Buffer(16), NumPut("int64", 0x11CF3C3D618736E0, iid), NumPut("int64", 0x719B3800AA000C81, iid, 8)
        if !DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwndFocus, "uint", 0xFFFFFFF8, "ptr", iid, "ptr*", &caretAcc := 0) && caretAcc {
            id := Buffer(24, 0), NumPut("ushort", 3, id)
            if !ComCall(22, caretAcc, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", id, "int") {
                ObjRelease(caretAcc)
                DllCall("FreeLibrary", "ptr", hOleacc)
                return hwndFocus
            }
            ObjRelease(caretAcc)
        }
        DllCall("FreeLibrary", "ptr", hOleacc)
    }
    ; Plan C applies to windows that implement IUIAutomationTextPattern2, such as UWP window
    iUIAutomation := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
    if !ComCall(8, iUIAutomation, "ptr*", &eleFocus := 0, "int") && eleFocus {
        if !ComCall(16, eleFocus, "int", 10024, "ptr*", &textPattern2 := 0, "int") && textPattern2 {
            if !ComCall(10, textPattern2, "int*", &isActive := 0, "ptr*", &textRange := 0, "int") && textRange && isActive {
                if !ComCall(10, textRange, "ptr*", &rects := 0, "int") && rects {
                    rects := ComValue(0x2005, rects)
                    if 3 <= rects.MaxIndex() {
                        x := rects[0], y := rects[1], w := rects[2], h := rects[3]
                        ObjRelease(textRange), ObjRelease(textPattern2), ObjRelease(eleFocus)
                        return hwndFocus
                    }
                }
                ObjRelease(textRange)
            }
            ObjRelease(textPattern2)
        }
        ; Plan D applies to windows that implement IUIAutomationTextPattern, such as Windows Terminal
        if !ComCall(16, eleFocus, "int", 10014, "ptr*", &textPattern := 0, "int") && textPattern {
            if !ComCall(5, textPattern, "ptr*", &textRangeArray := 0, "int") && textRangeArray {
                if !ComCall(3, textRangeArray, "int*", &length := 0, "int") && length {
                    if !ComCall(4, textRangeArray, "int", 0, "ptr*", &textRange := 0) && textRange {
                        if !ComCall(10, textRange, "ptr*", &rects := 0, "int") && rects {
                            rects := ComValue(0x2005, rects)
                            if 3 > rects.MaxIndex() {
                                ComCall(6, textRange, "int", 0, "int")    ; ExpandToEnclosingUnit(0)
                                ComCall(10, textRange, "ptr*", &rects := 0, "int")
                                rects := ComValue(0x2005, rects)
                                if 3 > rects.MaxIndex()
                                    goto end
                            }
                            x := rects[0], y := rects[1], w := rects[2], h := rects[3]
                            ObjRelease(textRange), ObjRelease(textRangeArray), ObjRelease(textPattern), ObjRelease(eleFocus)
                            return hwndFocus
                        }
                        end:
                        ObjRelease(textRange)
                    }
                }
                ObjRelease(textRangeArray)
            }
            ObjRelease(textPattern)
        }
        ObjRelease(eleFocus)
    }
    return x := y := w := h := 0
}