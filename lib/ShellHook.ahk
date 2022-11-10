CONST                               := CONST ?? {},
CONST.HSHELL_WINDOWCREATED          := 1,
CONST.HSHELL_WINDOWDESTROYED        := 2,
CONST.HSHELL_ACTIVATESHELLWINDOW    := 3,
CONST.HSHELL_WINDOWACTIVATED        := 4,
CONST.HSHELL_GETMINRECT             := 5,
CONST.HSHELL_REDRAW                 := 6,
CONST.HSHELL_TASKMAN                := 7,
CONST.HSHELL_LANGUAGE               := 8,
CONST.HSHELL_SYSMENU                := 9,
CONST.HSHELL_ENDTASK                := 10,
CONST.HSHELL_ACCESSIBILITYSTATE     := 11,
CONST.HSHELL_APPCOMMAND             := 12,
CONST.HSHELL_WINDOWREPLACED         := 13,
CONST.HSHELL_WINDOWREPLACING        := 14,
CONST.HSHELL_MONITORCHANGED         := 16,
CONST.HSHELL_HIGHBIT                := 0x8000,
CONST.HSHELL_RUDEAPPACTIVATED       := 0x8004,
CONST.HSHELL_FLASH                  := 0x8006

RegisterShellHookCallback(function, maxThreads := 1) {
    OnMessage(DllCall("RegisterWindowMessage", "str", "ShellHook"), function, maxThreads)
    if maxThreads
        return DllCall("RegisterShellHookWindow", "ptr", A_ScriptHwnd)
}

UnRegisterShellHook() => DllCall("DeregisterShellHookWindow", "ptr", A_ScriptHwnd)