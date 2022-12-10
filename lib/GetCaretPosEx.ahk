/*
f1::{
    CoordMode("ToolTip", "Screen")
    if hwnd := GetCaretPosEx(&x, &y, &w, &h)
        ToolTip(WinGetClass(hwnd), x, y + h)
    else
        ToolTip()
}
*/
GetCaretPosEx_(&x?, &y?, &w?, &h?) {
    x := h := w := h := 0
    static iUIAutomation := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
    if ComCall(8, iUIAutomation, "ptr*", eleFocus := ComValue(13, 0), "int") || !eleFocus.Ptr
        goto useAccLocation
    if !ComCall(16, eleFocus, "int", 10002, "ptr*", valuePattern := ComValue(13, 0), "int") && valuePattern.Ptr
        if !ComCall(5, valuePattern, "int*", &isReadOnly := 0) && isReadOnly
            return 0
    useAccLocation:
    ; use IAccessible::accLocation
    guiThreadInfo := Buffer(A_PtrSize == 8 ? 72 : 48), NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    hwndFocus := DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr") || WinExist()
    static hOleacc := DllCall("LoadLibraryW", "str", "Oleacc.dll", "ptr")
    NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, iid := Buffer(16))
    if !DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwndFocus, "uint", 0xFFFFFFF8, "ptr", iid, "ptr*", accCaret := ComValue(13, 0), "int") && accCaret.Ptr {
        NumPut("ushort", 3, varChild := Buffer(24, 0))
        if !ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", varChild, "int")
            return hwndFocus
    }
    if !eleFocus
        return 0
    ; use IUIAutomationTextPattern2::GetCaretRange
    if ComCall(16, eleFocus, "int", 10024, "ptr*", textPattern2 := ComValue(13, 0), "int") || !textPattern2.Ptr
        goto useGetSelection
    if ComCall(10, textPattern2, "int*", &isActive := 0, "ptr*", caretTextRange := ComValue(13, 0), "int") || !caretTextRange.Ptr || !isActive
        goto useGetSelection
    if !ComCall(10, caretTextRange, "ptr*", &rects := 0, "int") && rects && (rects := ComValue(0x2005, rects, 1)).MaxIndex() >= 3 {
        x := rects[0], y := rects[1], w := rects[2], h := rects[3]
        return hwndFocus
    }
    useGetSelection:
    ; use IUIAutomationTextPattern::GetSelection
    if textPattern2.Ptr
        textPattern := textPattern2
    else if ComCall(16, eleFocus, "int", 10014, "ptr*", textPattern := ComValue(13, 0), "int") || !textPattern.Ptr
        return 0
    if ComCall(5, textPattern, "ptr*", selectionRangeArray := ComValue(13, 0), "int") || !selectionRangeArray.Ptr
        return 0
    if ComCall(3, selectionRangeArray, "int*", &length := 0, "int") || length <= 0
        return 0
    if ComCall(4, selectionRangeArray, "int", 0, "ptr*", selectionRange := ComValue(13, 0), "int") || !selectionRange.Ptr
        return 0
    if ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects
        return 0
    rects := ComValue(0x2005, rects, 1)
    if rects.MaxIndex() < 3 {
        if ComCall(6, selectionRange, "int", 0, "int") || ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects
            return 0
        rects := ComValue(0x2005, rects, 1)
        if rects.MaxIndex() < 3
            return 0
    }
    x := rects[0], y := rects[1], w := rects[2], h := rects[3]
    return hwndFocus
}