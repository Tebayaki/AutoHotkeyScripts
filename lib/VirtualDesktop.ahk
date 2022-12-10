class VirtualDesktop {
    static Current => ((ComCall(6, this.IVirtualDesktopManagerInternal, "ptr*", &currentDesktop := 0)), this(currentDesktop))

    static Count => (ComCall(3, this.IVirtualDesktopManagerInternal, "int*", &count := 0), count)

    static GetAt(index) {
        ComCall(7, this.IVirtualDesktopManagerInternal, "ptr*", desktops := ComValue(13, 0))
        ComCall(4, desktops, "uint", index, "ptr", this.IID_IVirtualDesktop, "ptr*", &desktop := 0)
        return VirtualDesktop(desktop)
    }

    static Create() => (ComCall(10, this.IVirtualDesktopManagerInternal, "ptr*", &newDesktop := 0), VirtualDesktop(newDesktop))

    Id => (ComCall(4, this, "ptr", id := Buffer(16)), id.ToString := (_) => (DllCall('ole32\StringFromGUID2', "ptr", _, "ptr", buf := Buffer(78), "int", 39), StrGet(buf)), id)

    Left => (ComCall(8, VirtualDesktop.IVirtualDesktopManagerInternal, "ptr", this, "uint", 3, "ptr*", &leftDesktop := 0), VirtualDesktop(leftDesktop))

    Right => (ComCall(8, VirtualDesktop.IVirtualDesktopManagerInternal, "ptr", this, "uint", 4, "ptr*", &rightDesktop := 0), VirtualDesktop(rightDesktop))

    Visible => VirtualDesktop.Current.Equals(this)

    Index {
        get {
            thisId := this.Id, thisIdH := NumGet(thisId, "int64"), thisIdL := NumGet(thisId, 8, "int64")
            loop VirtualDesktop.Count {
                id := VirtualDesktop.GetAt(A_Index - 1).Id
                if NumGet(id, "int64") == thisIdH && NumGet(id, 8, "int64") == thisIdL
                    return A_Index - 1
            }
        }
    }

    Show() => ComCall(9, VirtualDesktop.IVirtualDesktopManagerInternal, "ptr", this)

    Remove(fallbackDesktop?) => ComCall(11, VirtualDesktop.IVirtualDesktopManagerInternal, "ptr", this, "ptr", fallbackDesktop ?? VirtualDesktop.GetAt(0))

    HasWindow(hwnd) {
        ComCall(4, VirtualDesktop.IVirtualDesktopManager, "ptr", hwnd, "ptr", id1 := Buffer(16))
        return NumGet(id1, "int64") == NumGet(id2 := this.Id, "int64") && NumGet(id1, 8, "int64") == NumGet(id2, 8, "int64")
    }

    ObtainWindow(hwnd) => ComCall(5, VirtualDesktop.IVirtualDesktopManager, "ptr", hwnd, "ptr", this.Id)

    Equals(desktop) => NumGet(id1 := this.Id, "int64") == NumGet(id2 := desktop.Id, "int64") && NumGet(id1, 8, "int64") == NumGet(id2, 8, "int64")

    static __New() {
        iServiceProvider := ComObject("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{6D5140C1-7436-11CE-8034-00AA006009FA}")
        this.IVirtualDesktopManagerInternal := ComObjQuery(iServiceProvider, "{C5E0CDCA-7B6E-41B2-9FC4-D93975CC467B}", "{F31574D6-B682-4CDC-BD56-1827860ABEC6}")
        this.IVirtualDesktopManager := ComObject("{AA509086-5CA9-4C25-8F95-589D3C07B48A}", "{A5CD92FF-29BE-454C-8D04-D82879FB3F1B}")
        NumPut("int64", 0x43fcbe7eff72ffdd, "int64", 0xe4881e6881ad039c, iid := Buffer(16))
        this.IID_IVirtualDesktop := iid
    }
    __New(ptr) {
        if !this.Ptr := ptr
            throw Error("Invalid pointer")
    }
    __Delete() => ObjRelease(this.Ptr)
}