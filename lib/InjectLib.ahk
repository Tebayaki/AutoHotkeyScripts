; InjectLib(WinGetPID("ahk_class Notepad"), "dllname.dll")
; EjectLib(WinGetPID("ahk_class Notepad"), "dllname.dll")

InjectLib(pid, filepath) {
    try {
        process_handle := remote_buf := thread_handle := 0
        if !process_handle := DllCall("OpenProcess", "uint", 0x42a, "int", false, "uint", pid, "ptr")
            throw OSError()
        if !remote_buf := DllCall("VirtualAllocEx", "ptr", process_handle, "ptr", 0, "ptr", bytes := StrPut(filepath), "uint", 0x1000, "uint", 0x4, "ptr")
            throw OSError()
        if !DllCall("WriteProcessMemory", "ptr", process_handle, "ptr", remote_buf, "str", filepath, "ptr", bytes, "ptr", 0)
            throw OSError()
        if !load_library := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32", "ptr"), "astr", "LoadLibraryW", "ptr")
            throw OSError()
        if !thread_handle := DllCall("CreateRemoteThread", "ptr", process_handle, "ptr", 0, "uint", 0, "ptr", load_library, "ptr", remote_buf, "uint", 0, "ptr", 0)
            throw OSError()
        DllCall("WaitForSingleObject", "ptr", thread_handle, "uint", -1, "uint")
    } catch as e {
        throw e
    } finally {
        if remote_buf
            DllCall("VirtualFreeEx", "ptr", process_handle, "ptr", remote_buf, "uptr", 0, "uint", 0x8000)
        if thread_handle
            DllCall("CloseHandle", "ptr", thread_handle)
        if process_handle
            DllCall("CloseHandle", "ptr", process_handle)
    }
    return true
}

EjectLib(pid, filename) {
    try {
        mod_base := 0
        if !snapshot_handle := DllCall("CreateToolhelp32Snapshot", "uint", 0x18, "uint", pid, "ptr")
            throw OSError()
        mod_entry := Buffer(1080), NumPut("uint", mod_entry.Size, mod_entry)
        if !DllCall("Module32FirstW", "ptr", snapshot_handle, "ptr", mod_entry)
            throw OSError()
        while DllCall("Module32NextW", "ptr", snapshot_handle, "ptr", mod_entry) {
            if StrGet(mod_entry.Ptr + 48) = filename {
                mod_base := NumGet(mod_entry, 24, "ptr")
                break
            }
        }
        if !mod_base
            throw TargetError("Mod not found!")
        if !process_handle := DllCall("OpenProcess", "uint", 0x40a, "int", false, "uint", pid, "ptr")
            throw OSError()
        if !free_library := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32", "ptr"), "astr", "FreeLibrary", "ptr")
            throw OSError()
        if !thread_handle := DllCall("CreateRemoteThread", "ptr", process_handle, "ptr", 0, "uptr", 0, "ptr", free_library, "ptr", mod_base, "uint", 0, "ptr", 0)
            throw OSError()
        DllCall("WaitForSingleObject", "ptr", thread_handle, "uint", -1, "uint")
    } catch as e {
        throw e
    } finally {
        if snapshot_handle
            DllCall("CloseHandle", "ptr", snapshot_handle)
        if thread_handle
            DllCall("CloseHandle", "ptr", thread_handle)
        if process_handle
            DllCall("CloseHandle", "ptr", process_handle)
    }
    return true
}