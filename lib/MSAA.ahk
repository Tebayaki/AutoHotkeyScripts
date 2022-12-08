#DllLoad "Oleacc"

AccessibleObjectUnderCursor(&childId := 0) {
    DllCall("GetCursorPos", "Int64*", &pt := 0)
    DllCall("Oleacc\AccessibleObjectFromPoint", "int64", pt, "ptr*", &pacc := 0, "ptr", varChild := Buffer(24), "HRESULT")
    childId := NumGet(varChild, 8, "int")
    DllCall("OleAut32\VariantClear", "ptr", varChild)
    return ComObjFromPtr(pacc)
}

AccessibleObjectFromPoint(x, y, &childId := 0) {
    DllCall("Oleacc\AccessibleObjectFromPoint", "int64", x | y << 32, "ptr*", &pacc := 0, "ptr", varChild := Buffer(24), "HRESULT")
    childId := NumGet(varChild, 8, "int")
    DllCall("OleAut32\VariantClear", "ptr", varChild)
    return ComObjFromPtr(pacc)
}

/*
@OBJID_ALERT ( ( LONG ) 0xFFFFFFF6 )
@OBJID_CARET ( ( LONG ) 0xFFFFFFF8 )
@OBJID_CLIENT ( ( LONG ) 0xFFFFFFFC )
@OBJID_CURSOR ( ( LONG ) 0xFFFFFFF7 )
@OBJID_HSCROLL ( ( LONG ) 0xFFFFFFFA )
@OBJID_MENU ( ( LONG ) 0xFFFFFFFD )
@OBJID_NATIVEOM ( ( LONG ) 0xFFFFFFF0 )
@OBJID_QUERYCLASSNAMEIDX ( ( LONG ) 0xFFFFFFF4 )
@OBJID_SIZEGRIP ( ( LONG ) 0xFFFFFFF9 )
@OBJID_SOUND ( ( LONG ) 0xFFFFFFF5 )
@OBJID_SYSMENU ( ( LONG ) 0xFFFFFFFF )
@OBJID_TITLEBAR ( ( LONG ) 0xFFFFFFFE )
@OBJID_VSCROLL ( ( LONG ) 0xFFFFFFFB )
@OBJID_WINDOW ( ( LONG ) 0x00000000 )
*/
AccessibleObjectFromWindow(hwnd, objectId := 0) {
    DllCall("ole32\CLSIDFromString", "str", "{618736E0-3C3D-11CF-810C-00AA00389B71}", "ptr", clsid := Buffer(16), "HRESULT")
    DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwnd, "uint", objectId, "ptr", clsid, "ptr*", &pacc := 0, "HRESULT")
    return ComObjFromPtr(pacc)
}

AccessibleObjectFromEvent(hwnd, objectId, childIdIn, &childIdOut := 0) {
    DllCall("Oleacc\AccessibleObjectFromEvent", "ptr", hwnd, "uint", objectId, "uint", childIdIn, "ptr*", &pacc := 0, "ptr", varChild := Buffer(24), "HRESULT")
    childIdOut := NumGet(varChild, 8, "int")
    DllCall("OleAut32\VariantClear", "ptr", varChild)
    return ComObjFromPtr(pacc)
}

AccessibleChildren(paccContainer, iChildStart := 0, cChildren := 0) {
    DllCall("Oleacc\AccessibleChildren", "ptr", paccContainer, "int", iChildStart, "int", cChildren, "ptr", rgvarChildren := Buffer(24 * cChildren), "int*", &cObtained := 0, "HRESULT")
    if cObtained {
        ret := []
        loop cObtained {
            offset := (A_Index - 1) * 24
            vt := NumGet(rgvarChildren, offset, "ushort")
            if vt == 9 {
                ret.Push(ComObjFromPtr(NumGet(rgvarChildren, offset + 8, "ptr")))
            }
            else {
                ret.Push(NumGet(rgvarChildren, offset + 8, "int"))
            }
        }
        return ret
    }
}

WindowFromAccessibleObject(pacc) {
    DllCall("Oleacc\WindowFromAccessibleObject", "ptr", pacc, "ptr*", &hwnd := 0, "HRESULT")
    return hwnd
}