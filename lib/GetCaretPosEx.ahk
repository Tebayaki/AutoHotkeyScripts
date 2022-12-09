/*
f1::{
    CoordMode("ToolTip", "Screen")
    if hwnd := GetCaretPosEx(&x, &y, &w, &h)
        ToolTip(WinGetClass(hwnd), x, y + h)
    else
        ToolTip()
}
*/

GetCaretPosEx(&x?, &y?, &w?, &h?) {
    eleFocus := valuePattern := textPattern2 := caretTextRange := textPattern := selectionRangeArray := selectionRange := accCaret := x := y := w := h := hwndCaret := 0
    guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48), NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    hwndFocus := DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr") || WinExist()

    static iUIAutomation := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
    if ComCall(8, iUIAutomation, "ptr*", &eleFocus := 0, "int") || !eleFocus
        goto planC
    ; Check read only property
    if !ComCall(16, eleFocus, "int", 10002, "ptr*", &valuePattern := 0, "int") && valuePattern
        if !ComCall(5, valuePattern, "int*", &isReadOnly := 0) && isReadOnly
            goto cleanUp
    ; Plan A applies to windows that implement IUIAutomationTextPattern2, such as UWP window
    if ComCall(16, eleFocus, "int", 10024, "ptr*", &textPattern2 := 0, "int") || !textPattern2
    || ComCall(10, textPattern2, "int*", &isActive := 0, "ptr*", &caretTextRange := 0, "int") || !caretTextRange || !isActive
    || ComCall(10, caretTextRange, "ptr*", &rects := 0, "int") || !rects || (rects := ComValue(0x2005, rects, 1)).MaxIndex() < 3
        goto planB
    x := rects[0], y := rects[1], w := rects[2], h := rects[3], hwndCaret := hwndFocus
    goto cleanUp
    ; Plan B applies to windows that implement IUIAutomationTextPattern, such as Windows Terminal
    planB:
    if ComCall(16, eleFocus, "int", 10014, "ptr*", &textPattern := 0, "int") || !textPattern
    || ComCall(5, textPattern, "ptr*", &selectionRangeArray := 0, "int") || !selectionRangeArray
    || ComCall(3, selectionRangeArray, "int*", &length := 0, "int") || !length
    || ComCall(4, selectionRangeArray, "int", 0, "ptr*", &selectionRange := 0, "int") || !selectionRange
    || ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects
        goto planC
    rects := ComValue(0x2005, rects, 1)
    if rects.MaxIndex() < 3 && ComCall(6, selectionRange, "int", 0, "int") || ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects || (rects := ComValue(0x2005, rects, 1)).MaxIndex() < 3
        goto planC
    x := rects[0], y := rects[1], w := rects[2], h := rects[3], hwndCaret := hwndFocus
    goto cleanUp
    ; Plan C applies to windows that implement IAccessible, such as vscode
    planC:
    static hOleacc := DllCall("LoadLibraryW", "str", "Oleacc.dll", "ptr")
    NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, iid := Buffer(16))
    if !DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwndFocus, "uint", 0xFFFFFFF8, "ptr", iid, "ptr*", &accCaret := 0, "int") && accCaret {
        NumPut("ushort", 3, id := Buffer(24, 0))
        if !ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", id, "int")
            hwndCaret := hwndFocus
    }
    cleanUp:
    for p in [eleFocus, valuePattern, textPattern2, caretTextRange, textPattern, selectionRangeArray, selectionRange, accCaret]
        (p && ObjRelease(p))
    return hwndCaret
}