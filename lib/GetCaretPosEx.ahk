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
    guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48), NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    hwndFocus := DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr") || WinExist()
    ; Plan A applies to windows with MSAA OBJID_CARET support, such as chrome
    static hOleacc := DllCall("LoadLibraryW", "str", "Oleacc.dll", "ptr")
    iid := Buffer(16), NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, iid)
    if !DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwndFocus, "uint", 0xFFFFFFF8, "ptr", iid, "ptr*", &caretAcc := 0) && caretAcc {
        id := Buffer(24, 0), NumPut("ushort", 3, id)
        if !ComCall(22, caretAcc, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", id, "int") {
            ObjRelease(caretAcc)
            return hwndFocus
        }
        ObjRelease(caretAcc)
    }
    ; Plan B applies to windows that implement IUIAutomationTextPattern2, such as UWP window
    static iUIAutomation := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
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
        ; Plan C applies to windows that implement IUIAutomationTextPattern, such as Windows Terminal
        if !ComCall(16, eleFocus, "int", 10014, "ptr*", &textPattern := 0, "int") && textPattern {
            if !ComCall(5, textPattern, "ptr*", &textRangeArray := 0, "int") && textRangeArray {
                if !ComCall(3, textRangeArray, "int*", &length := 0, "int") && length {
                    if !ComCall(4, textRangeArray, "int", 0, "ptr*", &textRange := 0, "int") && textRange {
                        if !ComCall(9, textRange, "int", 40015, "ptr", varIsReadOnly := Buffer(24), "int") && !NumGet(varIsReadOnly, 8, "int") {
                            if !ComCall(10, textRange, "ptr*", &rects := 0, "int") && rects {
                                rects := ComValue(0x2005, rects)
                                if 3 > rects.MaxIndex() {
                                    if ComCall(6, textRange, "int", 0, "int") || ComCall(10, textRange, "ptr*", &rects := 0, "int") || !rects    ; ExpandToEnclosingUnit(0)
                                        goto end
                                    rects := ComValue(0x2005, rects)
                                    if 3 > rects.MaxIndex()
                                        goto end
                                }
                                x := rects[0], y := rects[1], w := rects[2], h := rects[3]
                                ObjRelease(textRange), ObjRelease(textRangeArray), ObjRelease(textPattern), ObjRelease(eleFocus)
                                return hwndFocus
                            }
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