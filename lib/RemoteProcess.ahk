/* @Version 0.2 */
#Requires AutoHotkey v2.0.0 64-bit
#Include <ToolHelp>

CONST := CONST ?? {}

CONST.PAGE_NOACCESS := 0x01,
CONST.PAGE_READONLY := 0x02,
CONST.PAGE_READWRITE := 0x04,
CONST.PAGE_WRITECOPY := 0x08,
CONST.PAGE_EXECUTE := 0x10,
CONST.PAGE_EXECUTE_READ := 0x20,
CONST.PAGE_EXECUTE_READWRITE := 0x40,
CONST.PAGE_EXECUTE_WRITECOPY := 0x80,
CONST.PAGE_GUARD := 0x100,
CONST.PAGE_NOCACHE := 0x200,
CONST.PAGE_WRITECOMBINE := 0x400,
CONST.PAGE_GRAPHICS_NOACCESS := 0x0800,
CONST.PAGE_GRAPHICS_READONLY := 0x1000,
CONST.PAGE_GRAPHICS_READWRITE := 0x2000,
CONST.PAGE_GRAPHICS_EXECUTE := 0x4000,
CONST.PAGE_GRAPHICS_EXECUTE_READ := 0x8000,
CONST.PAGE_GRAPHICS_EXECUTE_READWRITE := 0x10000,
CONST.PAGE_GRAPHICS_COHERENT := 0x20000,
CONST.PAGE_GRAPHICS_NOCACHE := 0x40000,
CONST.PAGE_ENCLAVE_THREAD_CONTROL := 0x80000000,
CONST.PAGE_REVERT_TO_FILE_MAP := 0x80000000,
CONST.PAGE_TARGETS_NO_UPDATE := 0x40000000,
CONST.PAGE_TARGETS_INVALID := 0x40000000,
CONST.PAGE_ENCLAVE_UNVALIDATED := 0x20000000,
CONST.PAGE_ENCLAVE_MASK := 0x10000000,
CONST.PAGE_ENCLAVE_DECOMMIT := (CONST.PAGE_ENCLAVE_MASK | 0),
CONST.PAGE_ENCLAVE_SS_FIRST := (CONST.PAGE_ENCLAVE_MASK | 1),
CONST.PAGE_ENCLAVE_SS_REST := (CONST.PAGE_ENCLAVE_MASK | 2)

CONST.MEM_COMMIT := 0x00001000,
CONST.MEM_RESERVE := 0x00002000,
CONST.MEM_REPLACE_PLACEHOLDER := 0x00004000,
CONST.MEM_RESERVE_PLACEHOLDER := 0x00040000,
CONST.MEM_RESET := 0x00080000,
CONST.MEM_TOP_DOWN := 0x00100000,
CONST.MEM_WRITE_WATCH := 0x00200000,
CONST.MEM_PHYSICAL := 0x00400000,
CONST.MEM_ROTATE := 0x00800000,
CONST.MEM_DIFFERENT_IMAGE_BASE_OK := 0x00800000,
CONST.MEM_RESET_UNDO := 0x01000000,
CONST.MEM_LARGE_PAGES := 0x20000000,
CONST.MEM_4MB_PAGES := 0x80000000,
CONST.MEM_64K_PAGES := (CONST.MEM_LARGE_PAGES | CONST.MEM_PHYSICAL),
CONST.MEM_UNMAP_WITH_TRANSIENT_BOOST := 0x00000001,
CONST.MEM_COALESCE_PLACEHOLDERS := 0x00000001,
CONST.MEM_PRESERVE_PLACEHOLDER := 0x00000002,
CONST.MEM_DECOMMIT := 0x00004000,
CONST.MEM_RELEASE := 0x00008000,
CONST.MEM_FREE := 0x00010000

/*
@Example Open a process
; You can open a process by process name, hwnd or pid
ps := RemoteProcess.FromProcessName("explorer.exe")
ps := RemoteProcess.FromWindow(WinExist("ahk_class Shell_TrayWnd"))
ps := RemoteProcess.FromProcessId(WinGetPID("Program Manager"))

@Example Converts the base address described by module name, segment name, function name, or THREADSTACKXX to a numeric address
ps := RemoteProcess.FromWindow(WinExist("ahk_class Notepad"))
MsgBox '"Kernel.dll": ' Format("{:#016x}", ps.GetModuleAddressByName("Kernel32.dll"))
MsgBox '"User32.dll.data": ' Format("{:#016x}", ps.GetSectionAddressByName("User32.dll", ".data"))
MsgBox '"User32.MessageBoxW": ' Format("{:#016x}", ps.GetFunctionAddressByName("User32.dll", "MessageBoxW"))
MsgBox '"THREADSTACK0": ' Format("{:#016x}", ps.GetThreadStackAddress(0))

@Example Find the address of the data we need via base address and offsets, then read & write number from it
ps := RemoteProcess.FromProcessName("TextInputHost.exe")
; In this case, the base address is "THREADSTACK0"-00000750 in CE
ptr := ps.TracePointer(ps.GetThreadStackAddress(0) - 0x750, 0xC8, 0xC0, 0x300, 0x58, 0x8, 0xB0, 0, 0x1C0, 0x48, 0x18, 0x40, 0xF0)
; Read and Write a 32 bit integer
MsgBox ps.ReadNumber(ptr, "int")
ps.WriteNumber(ptr, 0, "int")
MsgBox ps.ReadNumber(ptr, "int")

@Example Read text from Notepad
ps := RemoteProcess.FromWindow(WinExist("ahk_class Notepad"))
ptr := ps.GetModuleAddressByName("textinputframework.dll") + 0xE83C0
MsgBox ps.ReadWString(ptr)

@Example Call a function
MsgBox RunWait("Notepad",,, &pid)
f1::{
    ps := RemoteProcess.FromProcessId(pid)
    pExitProcess := ps.GetFunctionAddressByName("Kernel32.dll", "ExitProcess")
    ps.CreateThread(pExitProcess, 123)
}
*/
class RemoteProcess {
    static __TypeSize := {Char: 1, UChar: 1, Short: 2, UShort: 2, Int: 4, UInt: 4, Ptr: A_PtrSize, UPtr: A_PtrSize, Int64: 8, UInt64: 8, Float: 4, Double: 8}

    static FromProcessName(processname) {
        if !pid := ProcessExist(processname)
            throw Error("Cannot find the process.")
        return this.FromProcessId(pid)
    }

    static FromWindow(winTitle) {
        if !DllCall("GetWindowThreadProcessId", "ptr", WinExist(winTitle), "uint*", &processId := 0)
            throw OSError()
        return this.FromProcessId(processId)
    }

    static FromProcessId(processId) {
        if !hProcess := DllCall("OpenProcess", "uint", 0x1fffff, "int", false, "uint", processId, "ptr")
            throw OSError()
        return this(hProcess)
    }

    __New(hProcess) {
        this.Handle := hProcess
        DllCall("IsWow64Process2", "ptr", hProcess, "ushort*", &isWow64 := 0, "ushort*", 0)
        this.IsWow64 := isWow64
        this.ProcessId := DllCall("GetProcessId", "ptr", hProcess, "uint")
    }

    __Delete() {
        DllCall("CloseHandle", "ptr", this.Handle)
    }

    Alloc(bytes, allocationType := CONST.MEM_COMMIT, protectType := CONST.PAGE_EXECUTE_READWRITE) {
        if !address := DllCall("VirtualAllocEx", "ptr", this.Handle, "ptr", 0, "ptr", bytes, "uint", allocationType, "uint", protectType, "ptr")
            throw OSError()
        return address
    }

    Free(address, bytes := 0, freeType := CONST.MEM_RELEASE) {
        if !DllCall("VirtualFreeEx", "ptr", this.Handle, "ptr", address, "uptr", bytes, "uint", freeType)
            throw OSError()
    }

    Protect(address, bytes, newProtectType) {
        if !DllCall("VirtualProtectEx", "ptr", this.Handle, "ptr", address, "uptr", bytes, "uint", newProtectType, "uint*", &oldProtectType := 0)
            throw OSError()
        return oldProtectType
    }

    CreateThread(address, param, &threadId := 0, closeHanlde := true) {
        if !hThread := DllCall("CreateRemoteThread", "ptr", this.Handle, "ptr", 0, "uptr", 0, "ptr", address, "ptr", param, "uint", 0, "uint*", &threadId, "ptr")
            throw OSError()
        if closeHanlde
            return DllCall("CloseHandle", "ptr", hThread)
        return hThread
    }

    ReadMemory(dest, src, bytes) {
        if !DllCall("ReadProcessMemory", "ptr", this.Handle, "ptr", src, "ptr", dest, "uptr", bytes, "uptr*", &bytesRead := 0)
            throw OSError()
        return bytesRead
    }

    ReadBuffer(address, bytes) {
        if !DllCall("ReadProcessMemory", "ptr", this.Handle, "ptr", address, "ptr", buf := Buffer(bytes), "uptr", bytes, "uptr*", &bytesRead := 0)
            throw OSError()
        if buf.Size != bytesRead
            buf.Size := bytesRead
        return buf
    }

    ReadNumber(address, type) {
        if !DllCall("ReadProcessMemory", "ptr", this.Handle, "ptr", address, type "*", &num := 0, "uptr", RemoteProcess.__TypeSize.%type%, "ptr", 0)
            throw OSError()
        return num
    }

    ReadString(address, cch := 0, encoding := "cp0") {
        offset := char := 0
        if cch == 0 {
            buf := Buffer(1024)
            while DllCall("ReadProcessMemory", "ptr", this.Handle, "ptr", address, "char*", &char, "uptr", 2, "ptr", 0) && char != 0 {
                NumPut("char", char, buf, offset)
                ++address
                ++offset
                if offset == buf.Size
                    buf.Size += 1024
            }
        }
        else {
            buf := Buffer(cch)
            while A_Index < cch && DllCall("ReadProcessMemory", "ptr", this.Handle, "ptr", address, "char*", &char, "uptr", 2, "ptr", 0) && char != 0 {
                NumPut("char", char, buf, offset)
                ++address
                ++offset
            }
        }
        NumPut("char", 0, buf, offset)
        return StrGet(buf.Ptr, encoding)
    }

    ReadWString(address, cch := 0) {
        offset := char := 0
        if cch == 0 {
            buf := Buffer(1024)
            while DllCall("ReadProcessMemory", "ptr", this.Handle, "ptr", address, "ushort*", &char, "uptr", 2, "ptr", 0) && char != 0 {
                NumPut("ushort", char, buf, offset)
                address += 2
                offset += 2
                if offset == buf.Size
                    buf.Size += 1024
            }
        }
        else {
            buf := Buffer(cch * 2)
            while A_Index < cch && DllCall("ReadProcessMemory", "ptr", this.Handle, "ptr", address, "short*", &char, "uptr", 2, "ptr", 0) && char != 0 {
                NumPut("short", char, buf, offset)
                address += 2
                offset += 2
            }
        }
        NumPut("ushort", 0, buf, offset)
        return StrGet(buf.Ptr, "utf-16")
    }

    WriteMemory(dest, src, bytes) {
        if !DllCall("WriteProcessMemory", "ptr", this.Handle, "ptr", dest, "ptr", src, "uptr", bytes, "ptr", 0)
            throw OSError()
    }

    WriteNumber(dest, number, type) {
        if !DllCall("WriteProcessMemory", "ptr", this.Handle, "ptr", dest, type "*", number, "uptr", RemoteProcess.__TypeSize.%type%, "ptr", 0)
            throw OSError()
    }

    WriteString(dest, str, encoding := "cp0") {
        if encoding = "cp0" || encoding = "" {
            if !DllCall("WriteProcessMemory", "ptr", this.Handle, "ptr", dest, "astr", str, "uptr", StrPut(str, "cp0"), "ptr", 0)
                throw OSError()
        }
        else {
            buf := Buffer(StrPut(str, encoding))
            StrPut(str, buf, encoding)
            if !DllCall("WriteProcessMemory", "ptr", this.Handle, "ptr", dest, "ptr", buf, "uptr", buf.Size, "ptr", 0)
                throw OSError()
        }
    }

    WriteWString(dest, str) {
        if !DllCall("WriteProcessMemory", "ptr", this.Handle, "ptr", dest, "wstr", str, "uptr", StrPut(str, "utf-16"), "ptr", 0)
            throw OSError()
    }

    TracePointer(baseAddress, offsetArray*) {
        if offsetArray.Length !== 0
            lastOffset := offsetArray.Pop()
        ptrType := this.IsWow64 ? "uint" : "ptr"
        pointer := this.ReadNumber(baseAddress, ptrType)
        for , offset in offsetArray
            pointer := this.ReadNumber(pointer + offset, ptrType)
        return pointer + lastOffset
    }

    GetModuleAddressByName(moduleName) {
        if !moduleEntry := ToolHelpFindModuleByName(moduleName, this.ProcessId)
            throw OSError(18)
        return moduleEntry.modBaseAddr
    }

    GetSectionAddressByName(moduleName, sectionName) {
        moduleEntry := ToolHelpFindModuleByName(moduleName, this.ProcessId)
        fileBuffer := FileRead(moduleEntry.szExePath, "RAW")
        pNtHeaders := fileBuffer.Ptr + NumGet(fileBuffer, 60, "int")
        pFileHearder := pNtHeaders + 4
        pOptionalHearder := pFileHearder + 20
        pSectionHeader := pOptionalHearder + NumGet(pFileHearder, 16, "ushort")
        loop NumGet(pFileHearder, 2, "ushort") {
            if StrGet(pSectionHeader + (A_Index - 1) * 40, 8, "cp0") = sectionName
                return moduleEntry.modBaseAddr + NumGet(pSectionHeader, (A_Index - 1) * 40 + 12, "uint")
        }
        throw Error("Unable to find the address")
    }

    GetFunctionAddressByName(moduleName, functionName) {
        moduleEntry := ToolHelpFindModuleByName(moduleName, this.ProcessId)
        fileBuffer := FileRead(moduleEntry.szExePath, "RAW")
        pNtHeaders := fileBuffer.Ptr + NumGet(fileBuffer, 60, "int")
        pFileHearder := pNtHeaders + 4
        pOptionalHearder := pFileHearder + 20
        sizeOfOptionalHearder := NumGet(pFileHearder, 16, "ushort")
        pSectionHeader := pOptionalHearder + sizeOfOptionalHearder
        if NumGet(pOptionalHearder, this.IsWow64 ? 96 : 112, "uint") == 0 {
            throw Error("Unable to find the address")
        }
        pExportDirectory := fileBuffer.Ptr + RvaToFoa(NumGet(pOptionalHearder, this.IsWow64 ? 96 : 112, "uint"))
        pFunctionNames := fileBuffer.Ptr + RvaToFoa(NumGet(pExportDirectory, 32, "uint"))
        loop NumGet(pExportDirectory, 24, "uint") {
            if StrGet(fileBuffer.Ptr + RvaToFoa(NumGet(pFunctionNames, (A_Index - 1) * 4, "uint")), "cp0") = functionName {
                pFunctionAddresses := fileBuffer.Ptr + RvaToFoa(NumGet(pExportDirectory, 28, "uint"))
                pNameOrdinals := fileBuffer.Ptr + RvaToFoa(NumGet(pExportDirectory, 36, "uint"))
                return moduleEntry.modBaseAddr + NumGet(pFunctionAddresses, NumGet(pNameOrdinals, (A_Index - 1) * 2, "ushort") * 4, "uint")
            }
        }
        throw Error("Unable to find the address")

        RvaToFoa(rva){
            if rva < NumGet(pOptionalHearder, 60, "uint")
                return rva
            loop NumGet(pFileHearder, 2, "ushort") {
                virtualAddress := NumGet(pSectionHeader, (A_Index - 1) * 40 + 12, "uint")
                if rva >= virtualAddress && rva < virtualAddress + NumGet(pSectionHeader, (A_Index - 1) * 40 + 8, "uint") {
                    return rva - virtualAddress + NumGet(pSectionHeader, (A_Index - 1) * 40 + 20, "uint")
                }
            }
            throw Error("Unable to find the address")
        }
    }

    GetThreadStackAddress(threadNumber) {
        for threadEntry in ToolHelpEnumThread() {
            if threadEntry.th32OwnerProcessID == this.ProcessId && threadNumber-- == 0 {
                kernel32ModuleEntry := ToolHelpFindModuleByName("kernel32.dll", this.ProcessId)
                if !hThread := DllCall("OpenThread", "uint", 0x1f03ff, "int", 0, "uint", threadEntry.th32ThreadID, "ptr")
                    throw Error("Unable to find the address")
                DllCall("Ntdll\NtQueryInformationThread", "ptr", hThread, "uint", 0, "ptr", threadInfo := Buffer(48), "uint", threadInfo.Size, "uint*", 0)
                DllCall("CloseHandle", "ptr", hThread)
                pTeb := NumGet(threadInfo, 8, "ptr")
                stackBase := ptrType := ptrSize := unset
                if this.IsWow64 {
                    stackBase := this.ReadNumber(pTeb + 4096 * 2 + 4, "uint")
                    ptrType := "uint"
                    ptrSize := 4
                }
                else {
                    stackBase := this.ReadNumber(pTeb + 8, "uint64")
                    ptrType := "uint64"
                    ptrSize := 8
                }
                stackBuf := this.ReadBuffer(stackBase - 4096, 4096)
                ; find the stack entry pointing to the function that calls "ExitXXXXXThread"
                offsetToExitThread := 4096 - ptrSize
                while (offsetToExitThread >= 0) {
                    pExitThread := NumGet(stackBuf, offsetToExitThread, ptrType)
                    if pExitThread >= kernel32ModuleEntry.modBaseAddr && pExitThread <= kernel32ModuleEntry.modBaseAddr + kernel32ModuleEntry.modBaseSize
                        return stackBase - 4096 + offsetToExitThread
                    offsetToExitThread -= ptrSize
                }
                throw Error("Unable to find the address")
            }
        }
        throw Error("Unable to find the address")
    }

    ReadCommandLine() {
        if DllCall("Ntdll\NtQueryInformationProcess", "ptr", this.Handle, "uint", 0, "ptr", processBasicInfo := Buffer(48), "uint", processBasicInfo.Size, "uint*", 0)
            throw Error("NtQueryInformationProcess failed")
        pPeb := NumGet(processBasicInfo, 8, "ptr")
        if this.IsWow64 {
            pProcessParams := this.ReadNumber(pPeb + 4096 + 16, "uint")
            pCommandLineUnicodeString := this.ReadBuffer(pProcessParams + 64, 8)
            commandLine := this.ReadBuffer(NumGet(pCommandLineUnicodeString, 4, "uint"), NumGet(pCommandLineUnicodeString, "ushort"))
        }
        else {
            pProcessParams := this.ReadNumber(pPeb + 32, "ptr")
            pCommandLineUnicodeString := this.ReadBuffer(pProcessParams + 112, 16)
            commandLine := this.ReadBuffer(NumGet(pCommandLineUnicodeString, 8, "ptr"), NumGet(pCommandLineUnicodeString, "ushort"))
        }
        return StrGet(commandLine, "utf-16")
    }
}