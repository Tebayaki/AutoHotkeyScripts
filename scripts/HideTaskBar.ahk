HideTaskbar(true)

HideTaskbar(flag) {
    appBarData := Buffer(A_PtrSize == 8 ? 48 : 36), NumPut("uint", appBarData.Size, appBarData)
    NumPut("ptr", WinExist("ahk_class Shell_TrayWnd"), appBarData, A_PtrSize)
    NumPut("ptr", flag ? 1 : 2, appBarData, appBarData.Size - A_PtrSize)
    DllCall("Shell32\SHAppBarMessage", "uint", 10, "ptr", appBarData)
}