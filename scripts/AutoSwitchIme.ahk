#Include <ShellHook>
#Include <IME>

Persistent
RegisterShellHookCallback(ShellMessageHandler)

ShellMessageHandler(wParam, lParam, *) {
    try {
        if wParam == 0x8004 {
            if lParam !== 0 {
                if WinGetClass(lParam) == "ApplicationFrameWindow" {
                    try
                        IME.SetInputMode(false, ControlGetHwnd("Windows.UI.Core.CoreWindow1", lParam))
                    catch
                        IME.SetInputMode(false, lParam)
                }
                else {
                    IME.SetInputMode(false, lParam)
                }
            }
            else {
                IME.SetInputMode(false)
            }
        }
        else if wParam == 2 || wParam == 54 {
            if lParam !== 0 && WinGetClass(lParam) == "Windows.UI.Core.CoreWindow" {
                loop 10 {
                    if IME.GetInputMode(lParam) {
                        IME.SetInputMode(false, lParam)
                        return
                    }
                    Sleep(20)
                }
            }
        }
    }
}