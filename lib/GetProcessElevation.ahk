GetProcessElevation(pid) {
    if !hProcess := DllCall("OpenProcess", "uint", 0x1000, "int", 1, "uint", pid)
        throw OSError()
    if !DllCall("OpenProcessToken", "ptr", hProcess, "uint", 0x0002 | 0x0001 | 0x0008, "ptr*", &hToken := 0) {
        err := A_LastError, DllCall("CloseHandle", "ptr", hProcess)
        throw OSError(err)
    }
    if !DllCall("Advapi32\GetTokenInformation", "ptr", hToken, "uint", 20, "uint*", &tokenElevation := 0, "uint", 4, "uint*", 0) {
        err := A_LastError, DllCall("CloseHandle", "ptr", hProcess), DllCall("CloseHandle", "ptr", hToken)
        throw OSError(err)
    }
    DllCall("CloseHandle", "ptr", hProcess), DllCall("CloseHandle", "ptr", hToken)
    return tokenElevation
}