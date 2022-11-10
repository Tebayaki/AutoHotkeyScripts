ToolHelpFindProcessByName(name) {
    if !snapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x2, "uint", 0, "ptr")
        return
    entry := PROCESSENTRY32W()
    res := DllCall("Process32FirstW", "ptr", snapshot, "ptr", entry)
    while res {
        if entry.szExeFile = name {
            res := entry
            break
        }
        res := DllCall("Process32NextW", "ptr", snapshot, "ptr", entry)
    }
    DllCall("CloseHandle", "ptr", snapshot)
    return res
}

ToolHelpFindModuleByName(moduleName, pid := 0) {
    if !snapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x18, "uint", pid, "ptr")
        return
    entry := MODULEENTRY32W()
    res := DllCall("Module32FirstW", "ptr", snapshot, "ptr", entry)
    while res {
        if entry.szModule = moduleName {
            res := entry
            break
        }
        res := DllCall("Module32NextW", "ptr", snapshot, "ptr", entry)
    }
    DllCall("CloseHandle", "ptr", snapshot)
    return res
}

ToolHelpEnumProcess() {
    snapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x2, "uint", 0, "ptr")
    _processEntry := PROCESSENTRY32W()
    enum.__Delete := (_) => DllCall("CloseHandle", "ptr", snapshot)
    return enum(&processEntry) => DllCall(A_Index == 1 ? "Process32FirstW" : "Process32NextW", "ptr", snapshot, "ptr", processEntry := _processEntry)
}

ToolHelpEnumModule(pid := 0) {
    snapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x18, "uint", pid, "ptr")
    _moduleEntry := MODULEENTRY32W()
    enum.__Delete := (_) => DllCall("CloseHandle", "ptr", snapshot)
    return enum(&moduleEntry) => DllCall(A_Index == 1 ? "Module32FirstW" : "Module32NextW", "ptr", snapshot, "ptr", moduleEntry := _moduleEntry)
}

ToolHelpEnumThread() {
    snapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x4, "uint", 0, "ptr")
    _threadEntry := THREADENTRY32()
    enum.__Delete := (_) => DllCall("CloseHandle", "ptr", snapshot)
    return enum(&threadEntry) => DllCall(A_Index == 1 ? "Thread32First" : "Thread32Next", "ptr", snapshot, "ptr", threadEntry := _threadEntry)
}

class PROCESSENTRY32W {
    __New() {
        this.Buffer := Buffer(568)
        this.Ptr := this.Buffer.Ptr
        this.Size := this.Buffer.Size
        NumPut("uint", this.Size, this, 0)
    }
    cntUsage => NumGet(this, 4, "uint")
    th32ProcessID => NumGet(this, 8, "uint")
    th32DefaultHeapID => NumGet(this, 16, "uptr")
    th32ModuleID => NumGet(this, 24, "uint")
    cntThreads => NumGet(this, 28, "uint")
    th32ParentProcessID => NumGet(this, 32, "uint")
    pcPriClassBase => NumGet(this, 36, "int")
    dwFlags => NumGet(this, 40, "uint")
    szExeFile => StrGet(this.Ptr + 44)
}

class MODULEENTRY32W {
    __New() {
        this.Buffer := Buffer(1080)
        this.Ptr := this.Buffer.Ptr
        this.Size := this.Buffer.Size
        NumPut("uint", this.Size, this, 0)
    }
    th32ModuleID => NumGet(this, 4, "uint")
    th32ProcessID => NumGet(this, 8, "uint")
    GlblcntUsage => NumGet(this, 12, "uint")
    ProccntUsage => NumGet(this, 16, "uint")
    modBaseAddr => NumGet(this, 24, "ptr")
    modBaseSize => NumGet(this, 32, "uint")
    hModule => NumGet(this, 40, "ptr")
    szModule =>  StrGet(this.Ptr + 48)
    szExePath => StrGet(this.Ptr + 560)
}

class THREADENTRY32 {
    __New() {
        this.Buffer := Buffer(28)
        this.Ptr := this.Buffer.Ptr
        this.Size := this.Buffer.Size
        NumPut("uint", this.Size, this, 0)
    }
    th32ThreadID => NumGet(this, 8, "uint")
    th32OwnerProcessID => NumGet(this, 12, "uint")
    tpBasePri => NumGet(this, 16, "uint")
}