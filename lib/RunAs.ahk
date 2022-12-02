RunAsAdmin()

RunAsAdmin() {
    if !A_IsAdmin && !(DllCall("GetCommandLine", "str") ~= " /restart(?!\S)") {
        try Run('*RunAs "' (A_IsCompiled ? A_ScriptFullPath '" /restart' : A_AhkPath '" /restart "' A_ScriptFullPath '"'))
        ExitApp
    }
}

RunAsSystem() {
    try {
        if "SYSTEM" = A_UserName
            return
        if A_IsAdmin
            if A_IsCompiled
                RunWithProcessToken(ProcessExist("winlogon.exe"), A_AhkPath " /restart")
            else
                RunWithProcessToken(ProcessExist("winlogon.exe"), A_AhkPath " /restart " A_ScriptFullPath)
        else if !(DllCall("GetCommandLine", "str") ~= " /restart(?!\S)")
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

RunAsUser() {
    if A_IsAdmin {
        if "" != AhkPathReg := RegRead("HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers", A_AhkPath)
            RegDelete("HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers", A_AhkPath)
        if A_IsCompiled
            RunWithProcessToken(ProcessExist("explorer.exe"), A_ScriptFullPath " /restart")
        else
            RunWithProcessToken(ProcessExist("explorer.exe"), A_AhkPath " /restart `"" A_ScriptFullPath "`"")
        if "" != AhkPathReg
            RegWrite(AhkPathReg, "REG_SZ", "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers", A_AhkPath)
        ExitApp
    }
}

; RunWithProcessToken(ProcessExist("winlogon.exe"), "cmd /k whoami")
RunWithProcessToken(pid, cmd) {
    hProcess := hTokenTargetProcess :=  hTokenDuplicate := 0
    DllCall("Ntdll\RtlAdjustPrivilege", "uint", 0x14, "char", 1, "char", 0, "ptr*", 0)
    if !hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 1, "uint", pid)
        throw OSError()
    try {
        if !DllCall("OpenProcessToken", "ptr", hProcess, "uint", 0x0002 | 0x0008, "ptr*", &hTokenTargetProcess)
            throw OSError()
        if !DllCall("Advapi32\ImpersonateLoggedOnUser", "ptr", hTokenTargetProcess)
            throw OSError()
        DllCall("Advapi32\RevertToSelf")
        if !DllCall("Advapi32\DuplicateTokenEx", "ptr", hTokenTargetProcess, "uint", 0x0080 | 0x0100 | 0x0008 | 0x0002 | 0x0001, "ptr", 0, "uint", 2, "uint", 1, "ptr*", &hTokenDuplicate, "int")
            throw OSError()
        pStartInfo := Buffer(104, 0), pProcessInfo := Buffer(24)
        NumPut("uint", pStartInfo.Size, pStartInfo, 0), NumPut("ptr", StrPtr("winsta0\default"), pStartInfo, 16), NumPut("ushort", 1, pStartInfo, 64)
        if !DllCall("Advapi32\CreateProcessWithTokenW", "ptr", hTokenDuplicate, "uint", 0, "ptr", 0, "wstr", cmd, "uint", 0x00000010, "ptr", 0, "ptr", 0, "ptr", pStartInfo, "ptr", pProcessInfo)
            throw OSError()
        DllCall("CloseHandle", "ptr", NumGet(pProcessInfo, 0, "ptr"))
        DllCall("CloseHandle", "ptr", NumGet(pProcessInfo, 8, "ptr"))
    }
    catch as e {
        throw e
    }
    finally {
        if hTokenDuplicate
            DllCall("CloseHandle", "ptr", hTokenDuplicate)
        if hTokenTargetProcess
            DllCall("CloseHandle", "ptr", hTokenTargetProcess)
        if hProcess
            DllCall("CloseHandle", "ptr", hProcess)
    }
    return NumGet(pProcessInfo, 16, "uint")
}