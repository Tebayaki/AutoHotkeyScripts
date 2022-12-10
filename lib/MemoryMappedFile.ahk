/*
@Example
; In process 1
mmf := MemoryMappedFile.Create("AHKMMF")
StrPut("Hello MMF!", mmf.GetView())

; In process 2
mmf := MemoryMappedFile.Open("AHKMMF")
MsgBox(StrGet(mmf.GetView()))
*/
class MemoryMappedFile {
    static Create(name?, size := 10000, protect := 0x4) {
        if !hFileMapping := DllCall("CreateFileMappingW", "ptr", -1, "ptr", 0, "uint", 4, "uint", size >> 32, "uint", size & 0xffffffff, "ptr", IsSet(name) ? StrPtr(name) : 0, "ptr")
            throw OSError(183)
        if A_LastError == 183
            throw OSError(183)
        return this(hFileMapping)
    }

    static Open(name) {
        if !hFileMapping := DllCall("OpenFileMapping", "uint", 6, "int", false, "str", name, "ptr")
            throw OSError()
        return this(hFileMapping)
    }

    GetView() {
        if !pView := DllCall("MapViewOfFile", "ptr", this.Handle, "uint", 6, "uint", 0, "uint", 0, "uptr", 0, "ptr")
            throw OSError()
        DllCall("VirtualQueryEx", "uint", DllCall("GetCurrentProcess", "ptr"), "ptr", pView, "ptr", memBasicInfo := Buffer(A_PtrSize == 8 ? 48 : 28), "uint", memBasicInfo.Size)
        return {Ptr: pView, Size: NumGet(memBasicInfo, A_PtrSize == 8 ? 24 : 12, "uint64"),  __Delete: (_) => DllCall("UnmapViewOfFile", "ptr", _)}
    }

    __New(handle) => this.Handle := handle

    __Delete() => this.Handle && DllCall("CloseHandle", "ptr", this.Handle)
}