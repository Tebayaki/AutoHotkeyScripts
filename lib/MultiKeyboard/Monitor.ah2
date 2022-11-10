mainWin := Gui()
checkBoxs := Map()
for keyboard in GetKeyboardList() {
    btnCopyID := mainWin.Add("Button", "Section x10 h20 w35", "ID")
    btnCopyName := mainWin.Add("Button", "ys h20 w35", "Name")
    btnCopyID.__ID := keyboard.ID
    btnCopyName.__Name := keyboard.Name
    btnCopyID.OnEvent("Click", (_, *) => (A_Clipboard := _.__ID, ToolTip("Copied: " _.__ID), SetTimer(() => ToolTip(), -1000)))
    btnCopyName.OnEvent("Click", (_, *) => (A_Clipboard := _.__Name, ToolTip("Copied: " _.__Name), SetTimer(() => ToolTip(), -1000)))
    checkBox := checkBoxs[keyboard.ID] := mainWin.Add("Checkbox", "ys yp+5", keyboard.ID ": " keyboard.Name)
}
keyboardLV := mainWin.Add("ListView", "R20 w800 x10", ["Key", "ID", "Name"])
keyboardLV.ModifyCol(1, 100)
keyboardLV.ModifyCol(2, 50)
keyboardLV.ModifyCol(3, 650)
mainWin.Show()

buf := Buffer(16)
NumPut("ushort", 0x1, "ushort", 0x6, "uint", 0x100, "ptr", A_ScriptHwnd, buf)
DllCall("RegisterRawInputDevices", "ptr", buf, "uint", 1, "uint", buf.Size)
OnMessage(0x00FF, WM_INPUT_Proc)

WM_INPUT_Proc(wParam, lParam, msg, hwnd) {
    buf := Buffer(40)
    if (DllCall("GetRawInputData", "ptr", lParam, "uint", 0x10000003, "ptr", buf, "uint*", 40, "uint", 24, "uint") != 40)
        return
    hDevice := NumGet(buf, 8, "uint")
    if checkBoxs.Get(hDevice, "").Value {
        vk := GetKeyName(Format("vk{:x}", NumGet(buf, 30, "ushort")))
        isDown := (NumGet(buf, 26, "ushort") & 1) ? "↑" : "↓"
        VarSetStrCapacity(&deviceName, szName := 256)
        DllCall("GetRawInputDeviceInfo", "ptr", hDevice, "uint", 0x20000007, "str", deviceName, "uint*", szName, "uint")
        row := keyboardLV.Add(, vk " " isDown, hDevice, deviceName)
        keyboardLV.Modify(row, "Vis")
    }
}

GetKeyboardList() {
    DllCall("GetRawInputDeviceList", "ptr", 0, "uint*", &cnt := 0, "uint", 16, "uint")
    devices := Buffer(16 * cnt)
    DllCall("GetRawInputDeviceList", "ptr", devices, "uint*", &cnt, "uint", 16, "uint")
    VarSetStrCapacity(&deviceName, szName := 256)
    keyboardList := []
    loop cnt {
        if NumGet(devices, 16 * (A_Index - 1) + 8, "uint") !== 1	;RIM_TYPEKEYBOARD
            continue
        hDevice := NumGet(devices, 16 * (A_Index - 1), "ptr")
        DllCall("GetRawInputDeviceInfo", "ptr", hDevice, "uint", 0x20000007, "str", deviceName, "uint*", szName, "uint")
        keyboardList.Push({ ID: hDevice, Name: deviceName })
    }
    return keyboardList
}