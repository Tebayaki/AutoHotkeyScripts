#DllLoad "Oleacc"
/*
https://learn.microsoft.com/en-us/windows/win32/api/oleacc/nn-oleacc-iaccessible

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

@ROLE_SYSTEM_TITLEBAR ( 0x1 )
@ROLE_SYSTEM_MENUBAR ( 0x2 )
@ROLE_SYSTEM_SCROLLBAR ( 0x3 )
@ROLE_SYSTEM_GRIP ( 0x4 )
@ROLE_SYSTEM_SOUND ( 0x5 )
@ROLE_SYSTEM_CURSOR ( 0x6 )
@ROLE_SYSTEM_CARET ( 0x7 )
@ROLE_SYSTEM_ALERT ( 0x8 )
@ROLE_SYSTEM_WINDOW ( 0x9 )
@ROLE_SYSTEM_CLIENT ( 0xa )
@ROLE_SYSTEM_MENUPOPUP ( 0xb )
@ROLE_SYSTEM_MENUITEM ( 0xc )
@ROLE_SYSTEM_TOOLTIP ( 0xd )
@ROLE_SYSTEM_APPLICATION ( 0xe )
@ROLE_SYSTEM_DOCUMENT ( 0xf )
@ROLE_SYSTEM_PANE ( 0x10 )
@ROLE_SYSTEM_CHART ( 0x11 )
@ROLE_SYSTEM_DIALOG ( 0x12 )
@ROLE_SYSTEM_BORDER ( 0x13 )
@ROLE_SYSTEM_GROUPING ( 0x14 )
@ROLE_SYSTEM_SEPARATOR ( 0x15 )
@ROLE_SYSTEM_TOOLBAR ( 0x16 )
@ROLE_SYSTEM_STATUSBAR ( 0x17 )
@ROLE_SYSTEM_TABLE ( 0x18 )
@ROLE_SYSTEM_COLUMNHEADER ( 0x19 )
@ROLE_SYSTEM_ROWHEADER ( 0x1a )
@ROLE_SYSTEM_COLUMN ( 0x1b )
@ROLE_SYSTEM_ROW ( 0x1c )
@ROLE_SYSTEM_CELL ( 0x1d )
@ROLE_SYSTEM_LINK ( 0x1e )
@ROLE_SYSTEM_HELPBALLOON ( 0x1f )
@ROLE_SYSTEM_CHARACTER ( 0x20 )
@ROLE_SYSTEM_LIST ( 0x21 )
@ROLE_SYSTEM_LISTITEM ( 0x22 )
@ROLE_SYSTEM_OUTLINE ( 0x23 )
@ROLE_SYSTEM_OUTLINEITEM ( 0x24 )
@ROLE_SYSTEM_PAGETAB ( 0x25 )
@ROLE_SYSTEM_PROPERTYPAGE ( 0x26 )
@ROLE_SYSTEM_INDICATOR ( 0x27 )
@ROLE_SYSTEM_GRAPHIC ( 0x28 )
@ROLE_SYSTEM_STATICTEXT ( 0x29 )
@ROLE_SYSTEM_TEXT ( 0x2a )
@ROLE_SYSTEM_PUSHBUTTON ( 0x2b )
@ROLE_SYSTEM_CHECKBUTTON ( 0x2c )
@ROLE_SYSTEM_RADIOBUTTON ( 0x2d )
@ROLE_SYSTEM_COMBOBOX ( 0x2e )
@ROLE_SYSTEM_DROPLIST ( 0x2f )
@ROLE_SYSTEM_PROGRESSBAR ( 0x30 )
@ROLE_SYSTEM_DIAL ( 0x31 )
@ROLE_SYSTEM_HOTKEYFIELD ( 0x32 )
@ROLE_SYSTEM_SLIDER ( 0x33 )
@ROLE_SYSTEM_SPINBUTTON ( 0x34 )
@ROLE_SYSTEM_DIAGRAM ( 0x35 )
@ROLE_SYSTEM_ANIMATION ( 0x36 )
@ROLE_SYSTEM_EQUATION ( 0x37 )
@ROLE_SYSTEM_BUTTONDROPDOWN ( 0x38 )
@ROLE_SYSTEM_BUTTONMENU ( 0x39 )
@ROLE_SYSTEM_BUTTONDROPDOWNGRID ( 0x3a )
@ROLE_SYSTEM_WHITESPACE ( 0x3b )
@ROLE_SYSTEM_PAGETABLIST ( 0x3c )
@ROLE_SYSTEM_CLOCK ( 0x3d )
@ROLE_SYSTEM_SPLITBUTTON ( 0x3e )
@ROLE_SYSTEM_IPADDRESS ( 0x3f )
@ROLE_SYSTEM_OUTLINEBUTTON ( 0x40 )

@STATE_SYSTEM_NORMAL ( 0 )
@STATE_SYSTEM_UNAVAILABLE ( 0x1 )
@STATE_SYSTEM_SELECTED ( 0x2 )
@STATE_SYSTEM_FOCUSED ( 0x4 )
@STATE_SYSTEM_PRESSED ( 0x8 )
@STATE_SYSTEM_CHECKED ( 0x10 )
@STATE_SYSTEM_MIXED ( 0x20 )
@STATE_SYSTEM_INDETERMINATE ( STATE_SYSTEM_MIXED )
@STATE_SYSTEM_READONLY ( 0x40 )
@STATE_SYSTEM_HOTTRACKED ( 0x80 )
@STATE_SYSTEM_DEFAULT ( 0x100 )
@STATE_SYSTEM_EXPANDED ( 0x200 )
@STATE_SYSTEM_COLLAPSED ( 0x400 )
@STATE_SYSTEM_BUSY ( 0x800 )
@STATE_SYSTEM_FLOATING ( 0x1000 )
@STATE_SYSTEM_MARQUEED ( 0x2000 )
@STATE_SYSTEM_ANIMATED ( 0x4000 )
@STATE_SYSTEM_INVISIBLE ( 0x8000 )
@STATE_SYSTEM_OFFSCREEN ( 0x10000 )
@STATE_SYSTEM_SIZEABLE ( 0x20000 )
@STATE_SYSTEM_MOVEABLE ( 0x40000 )
@STATE_SYSTEM_SELFVOICING ( 0x80000 )
@STATE_SYSTEM_FOCUSABLE ( 0x100000 )
@STATE_SYSTEM_SELECTABLE ( 0x200000 )
@STATE_SYSTEM_LINKED ( 0x400000 )
@STATE_SYSTEM_TRAVERSED ( 0x800000 )
@STATE_SYSTEM_MULTISELECTABLE ( 0x1000000 )
@STATE_SYSTEM_EXTSELECTABLE ( 0x2000000 )
@STATE_SYSTEM_ALERT_LOW ( 0x4000000 )
@STATE_SYSTEM_ALERT_MEDIUM ( 0x8000000 )
@STATE_SYSTEM_ALERT_HIGH ( 0x10000000 )
@STATE_SYSTEM_PROTECTED ( 0x20000000 )
@STATE_SYSTEM_VALID ( 0x7fffffff )
*/
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

AccessibleObjectFromWindow(hwnd, objectId := 0) {
    iid := Buffer(16), NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, iid)
    DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwnd, "uint", objectId, "ptr", iid, "ptr*", &pacc := 0, "HRESULT")
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