/*
f1::
    CoordMode, ToolTip, Screen
    if (hwnd := GetCaretPosEx(x, y, w, h)) {
        WinGetClass, classname, ahk_id %hwnd%
        ToolTip, %classname%, x, y + h
    }
    else {
        ToolTip
    }
return
*/
GetCaretPosEx(byref x = 0, byref y = 0, byref w = 0, byref h = 0) {
    x := y := w := h := hwnd := 0
    static iUIAutomation, hOleacc, IID_IAccessible, guiThreadInfo, init
    if !init {
        init := true
        try
            iUIAutomation := ComObjCreate("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
        hOleacc := DllCall("LoadLibrary", "str", "Oleacc.dll", "ptr")
        VarSetCapacity(IID_IAccessible, 16), NumPut(0x11CF3C3D618736E0, IID_IAccessible, "int64"), NumPut(0x719B3800AA000C81, IID_IAccessible, 8, "int64")
        VarSetCapacity(guiThreadInfo, size := (A_PtrSize == 8 ? 72 : 48)), NumPut(size, guiThreadInfo, "uint")
    }
    if !iUIAutomation || DllCall(NumGet(NumGet(iUIAutomation + 0), 8 * A_PtrSize), "ptr", iUIAutomation, "ptr*", eleFocus) || !eleFocus
        goto useAccLocation
    ; Check read only property
    if !DllCall(NumGet(NumGet(eleFocus + 0), 16 * A_PtrSize), "ptr", eleFocus, "int", 10002, "ptr*", valuePattern) && valuePattern
        if !DllCall(NumGet(NumGet(valuePattern + 0), 5 * A_PtrSize), "ptr", valuePattern, "int*", isReadOnly) && isReadOnly
            goto cleanUp
    ; Plan A applies to windows that implement IAccessible, such as chrome
    useAccLocation:
    if DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", &guiThreadInfo)
        hwndFocus := NumGet(guiThreadInfo, A_PtrSize == 8 ? 16 : 12, "ptr")
    if !hwndFocus
        hwndFocus := WinExist()
    if hOleacc && !DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwndFocus, "uint", 0xFFFFFFF8, "ptr", &IID_IAccessible, "ptr*", accCaret) && accCaret {
        VarSetCapacity(id, 24, 0), NumPut(3, id, "ushort")
        if !DllCall(NumGet(NumGet(accCaret + 0), 22 * A_PtrSize), "ptr", accCaret, "int*", x, "int*", y, "int*", w, "int*", h, "ptr", &id) {
            hwnd := hwndFocus
            goto cleanUp
        }
    }
    if iUIAutomation && eleFocus {
        ; use IUIAutomationTextPattern2::GetCaretRange
        if DllCall(NumGet(NumGet(eleFocus + 0), 16 * A_PtrSize), "ptr", eleFocus, "int", 10024, "ptr*", textPattern2, "int") || !textPattern2
        || DllCall(NumGet(NumGet(textPattern2 + 0), 10 * A_PtrSize), "ptr", textPattern2, "int*", isActive, "ptr*", caretTextRange) || !caretTextRange || !isActive
        || DllCall(NumGet(NumGet(caretTextRange + 0), 10 * A_PtrSize), "ptr", caretTextRange, "ptr*", rects) || !rects || (rects := ComObject(0x2005, rects, 1)).MaxIndex() < 3
            goto useGetSelection
        x := rects[0], y := rects[1], w := rects[2], h := rects[3], hwnd := hwndFocus
        goto cleanUp
        useGetSelection:
        ; use IUIAutomationTextPattern::GetSelection
        if DllCall(NumGet(NumGet(eleFocus + 0), 16 * A_PtrSize), "ptr", eleFocus, "int", 10014, "ptr*", textPattern) || !textPattern
        || DllCall(NumGet(NumGet(textPattern + 0), 5 * A_PtrSize), "ptr", textPattern, "ptr*", selectionRangeArray) || !selectionRangeArray
        || DllCall(NumGet(NumGet(selectionRangeArray + 0), 3 * A_PtrSize), "ptr", selectionRangeArray, "int*", length) || !length
        || DllCall(NumGet(NumGet(selectionRangeArray + 0), 4 * A_PtrSize), "ptr", selectionRangeArray, "int", 0, "ptr*", selectionRange) || !selectionRange
        || DllCall(NumGet(NumGet(selectionRange + 0), 10 * A_PtrSize), "ptr", selectionRange, "ptr*", rects) || !rects
            goto useGUITHREADINFO
        rects := ComObject(0x2005, rects, 1)
        if rects.MaxIndex() < 3 && DllCall(NumGet(NumGet(selectionRange + 0), 6 * A_PtrSize), "ptr", selectionRange, "int", 0)
        || DllCall(NumGet(NumGet(selectionRange + 0), 10 * A_PtrSize), "ptr", selectionRange, "ptr*", rects) || !rects || (rects := ComObject(0x2005, rects, 1)).MaxIndex() < 3
            goto useGUITHREADINFO
        x := rects[0], y := rects[1], w := rects[2], h := rects[3], hwnd := hwndFocus
        goto cleanUp
    }
    useGUITHREADINFO:
    if hwndCaret := NumGet(guiThreadInfo, A_PtrSize == 8 ? 48 : 28, "ptr") {
        VarSetCapacity(clientRect, 16)
        if DllCall("GetWindowRect", "ptr", hwndCaret, "ptr", &clientRect) {
            offset := A_PtrSize == 8 ? 56 : 32
            w := NumGet(guiThreadInfo, offset + 8, "int") - NumGet(guiThreadInfo, offset, "int")
            h := NumGet(guiThreadInfo, offset + 12, "int") - NumGet(guiThreadInfo, offset + 4, "int")
            DllCall("ClientToScreen", "ptr", hwndCaret, "ptr", &guiThreadInfo + offset)
            x := NumGet(guiThreadInfo, offset, "int")
            y := NumGet(guiThreadInfo, offset + 4, "int")
            hwnd := hwndCaret
        }
    }
    cleanUp:
    for _, p in [eleFocus, valuePattern, textPattern2, caretTextRange, textPattern, selectionRangeArray, selectionRange, accCaret]
        (p && ObjRelease(p))
    return hwnd
}