/*
ControlGetPos(&x, &y, &w, &h, "MSTaskListWClass1", "ahk_class ahk_class Shell_TrayWnd")
frame := DrawRectFrame(x, y, w, h, 3, "Red")
loop 5 {
    Sleep(300)
    frame.Hide()
    Sleep(300)
    frame.Show()
}
frame.Destroy()
*/

DrawRectFrame(x, y, w, h, thinness := 3, color := 0xFFFFFF, transparence := 255) {
    hRgnOutter := DllCall("CreateRectRgn", "int", 0, "int", 0, "int", w + 2 * thinness, "int", h + 2 * thinness, "ptr")
    hRgnInner := DllCall("CreateRectRgn", "int", thinness, "int", thinness, "int", w + thinness, "int", h + thinness, "ptr")
    hRgnFrame := DllCall("CreateRectRgn", "int", 0, "int", 0, "int", 0, "int", 0, "ptr")
    if 1 < DllCall("CombineRgn", "ptr", hRgnFrame, "ptr", hRgnOutter, "ptr", hRgnInner, "int", 3) {
        frame := Gui("-DPIScale -Caption +Disabled +ToolWindow +AlwaysOnTop +E0x08000000 +E0x00080000 +E0x00000020")
        DllCall("SetWindowRgn", "ptr", frame.Hwnd, "ptr", hRgnFrame, "int", true)
        DllCall("SetLayeredWindowAttributes", "ptr", frame.Hwnd, "uint", 0, "uchar", transparence, "uint", 2)
        frame.BackColor := color
        frame.Show("NoActivate x" x - thinness " y" y - thinness " w" w + 2 * thinness " h" h + 2 * thinness)
    }
    DllCall("DeleteObject", "ptr", hRgnOutter), DllCall("DeleteObject", "ptr", hRgnInner), DllCall("DeleteObject", "ptr", hRgnFrame)
    return IsSet(frame) ? {Destroy: (_) => frame.Destroy(), Show: (_) => frame.Show("NoActivate"), Hide: (_) => frame.Hide()} : ""
}