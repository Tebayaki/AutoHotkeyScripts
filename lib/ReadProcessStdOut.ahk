ReadProcessStdOut(cmd, stdin := "", encoding := "cp0") {
    sa := Buffer(24)
    NumPut("uint", sa.Size, sa)
    NumPut("ptr", 0, "uint", 1, sa, 8)

    if !DllCall("CreatePipe", "ptr*", &hReadPipeOut := 0, "ptr*", &hWritePipeOut := 0, "ptr", sa, "uint", 0)
        throw OSError()
    DllCall("SetHandleInformation", "ptr", hReadPipeOut, "uint", 1, "uint", 0)

    si := Buffer(104, 0)
    NumPut("uint", si.Size, si)
    NumPut("uint", 0x101, si, 60)
    ; NumPut("ushort", 5, si, 64) ; show window
    NumPut("ptr", hWritePipeOut, si, 88)

    if stdin !== "" {
        if !DllCall("CreatePipe", "ptr*", &hReadPipeIn := 0, "ptr*", &hWritePipeIn := 0, "ptr", sa, "uint", 0)
            throw OSError()
        DllCall("SetHandleInformation", "ptr", hWritePipeIn, "uint", 1, "uint", 0)
        NumPut("ptr", hReadPipeIn, si, 80)
    }

    if !DllCall("CreateProcessW", "ptr", 0, "str", cmd, "ptr", 0, "ptr", 0, "int", true, "uint", 0, "ptr", 0, "ptr", 0, "ptr", si, "ptr", pi := Buffer(24)) {
        DllCall("CloseHandle", "ptr", hWritePipeOut)
        DllCall("CloseHandle", "ptr", hReadPipeOut)
        throw OSError()
    }
    DllCall("CloseHandle", "ptr", NumGet(pi, "ptr"))
    DllCall("CloseHandle", "ptr", NumGet(pi, 8, "ptr"))
    DllCall("CloseHandle", "ptr", hWritePipeOut)

    if stdin !== "" {
        DllCall("CloseHandle", "ptr", hReadPipeIn)
        buf := Buffer(StrPut(stdin, encoding))
        StrPut(stdin, buf, encoding)
        if !DllCall("WriteFile", "ptr", hWritePipeIn, "ptr", buf, "uint", buf.Size, "uint*", &lpNumberOfBytesWritten := 0, "ptr", 0){
            DllCall("CloseHandle", "ptr", hWritePipeIn)
            throw OSError()
        }
        DllCall("CloseHandle", "ptr", hWritePipeIn)
    }

    stdout := ""
    while DllCall("ReadFile", "ptr", hReadPipeOut, "ptr", buf := Buffer(4096), "uint", buf.Size, "uint*", &lpNumberOfBytesRead := 0, "ptr", 0) && lpNumberOfBytesRead
        stdout .= StrGet(buf, lpNumberOfBytesRead, encoding)
    DllCall("CloseHandle", "ptr", hReadPipeOut)

    return stdout
}