GetWindowRealPos(hwnd, &x?, &y?, &w?, &h?){
    if res := !DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd, "uint", 9, "ptr", rect := Buffer(16), "uint", 16)
        x := NumGet(rect, "int"), y := NumGet(rect, 4, "int"), w := NumGet(rect, 8, "int") - x, h := NumGet(rect, 12, "int") - y
    return res
}