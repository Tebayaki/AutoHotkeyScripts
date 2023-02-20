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

; RunWithProcessToken("winlogon.exe", "cmd /k whoami")
RunWithProcessToken(pidOrName, cmd, workingDir := A_WorkingDir, option := "Normal", &outputVarPid := 0, wait := false) {
    hProcess := hTokenTargetProcess :=  hTokenDuplicate := 0
    DllCall("Ntdll\RtlAdjustPrivilege", "uint", 0x14, "char", 1, "char", 0, "ptr*", 0)
    if !hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 1, "uint", ProcessExist(pidOrName))
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
        NumPut("uint", pStartInfo.Size, pStartInfo, 0), NumPut("ptr", StrPtr("winsta0\default"), pStartInfo, 16), NumPut("uint", 1, pStartInfo, 60)
        switch option, "Off" {
            case "Hide":
                nCmdShow := 0
            case "Min":
                nCmdShow := 2
            case "Max":
                nCmdShow := 3
            default:
                nCmdShow := 1
        }
        NumPut("ushort", nCmdShow, pStartInfo, 64)
        if !DllCall("Advapi32\CreateProcessWithTokenW", "ptr", hTokenDuplicate, "uint", 0, "ptr", 0, "str", cmd, "uint", 0x00000010, "ptr", 0, "str", workingDir, "ptr", pStartInfo, "ptr", pProcessInfo)
            throw OSError()
        DllCall("CloseHandle", "ptr", NumGet(pProcessInfo, 8, "ptr"))
        hNewProcess := NumGet(pProcessInfo, "ptr")
        outputVarPid := NumGet(pProcessInfo, 16, "uint")
        if wait {
            ProcessWaitClose(outputVarPid)
            DllCall("GetExitCodeProcess", "ptr", hNewProcess, "uint*", &exitCode := 0)
        }
        DllCall("CloseHandle", "ptr", hNewProcess)
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
    return exitCode ?? ""
}