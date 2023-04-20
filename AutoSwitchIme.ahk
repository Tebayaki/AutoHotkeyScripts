#Include <ShellHook>
#Include <IME>

Persistent
RegisterShellHookCallback(ShellMessageHandler)

ShellMessageHandler(wParam, lParam, *) {
    try {
        if wParam == CONST.HSHELL_RUDEAPPACTIVATED {
            if lParam !== 0 {
                if WinGetClass(lParam) == "ApplicationFrameWindow" {
                    try
                        SetImeStatus(false, ControlGetHwnd("Windows.UI.Core.CoreWindow1", lParam))
                    catch
                        SetImeStatus(false, lParam)
                }
                else {
                    SetImeStatus(false, lParam)
                }
            }
            else {
                SetImeStatus(false)
            }
        }
        else if wParam == CONST.HSHELL_WINDOWDESTROYED || wParam == 54 {
            if lParam !== 0 && WinGetClass(lParam) == "Windows.UI.Core.CoreWindow" {
                loop 10 {
                    if GetImeStatus(lParam) {
                        SetImeStatus(false, lParam)
                        return
                    }
                    Sleep(20)
                }
            }
        }
    }
}