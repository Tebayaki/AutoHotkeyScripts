
/*
; 示例1: 实时获取当前文本插入点坐标
Persistent
OnMessage(RegisterCaretMessageHook(true), CaretMsgHandler1)

CaretMsgHandler1(leftTop, rightBottom, msg, hwnd) {
    CoordMode("ToolTip", "Screen")
    x := rightBottom & 0xffffffff
    y := rightBottom >> 32
    if x > 0x7fffffff
        x -= 0x100000000
    if y > 0x7fffffff
        y -= 0x100000000
    ToolTip x " | " y, x, y
}
*/

/*
; 示例2 当输入焦点切换的时候显示当前输入法状态
Persistent
OnMessage(RegisterCaretMessageHook(true), CaretMsgHandler2)

CaretMsgHandler2(leftTop, rightBottom, msg, hwnd) {
    static lastHasCaret := 0, showToolTip := 0

    hasCaret := leftTop || rightBottom
    if !lastHasCaret && hasCaret {
        showToolTip := 1
        SetTimer(StopShowToolTip, -2000)
    }
    else if lastHasCaret && !hasCaret {
        StopShowToolTip()
    }
        lastHasCaret := hasCaret

    if showToolTip && hasCaret {
        if rightBottom == leftTop + 1 {
            DllCall("SystemParametersInfo", "uint", 48, "uint", 0, "ptr", rect := Buffer(16), "uint", 0)
            if NumGet(rect, 8, "int64") == rightBottom + 0x100000000
                return 0
        }
        CoordMode("ToolTip", "Screen")
        x := rightBottom & 0xffffffff
        y := rightBottom >> 32
        if x > 0x7fffffff
            x -= 0x100000000
        if y > 0x7fffffff
            y -= 0x100000000
        try
            ToolTip SendMessage(0x0283, 0x005, 0, DllCall("imm32\ImmGetDefaultIMEWnd", "ptr", WinExist("A"), "ptr")) ? "中" : "英", x, y
    }
    return 0

    static StopShowToolTip() => (ToolTip(), showToolTip := 0)
}
*/

RegisterCaretMessageHook(flag) {
    static pShellCode := 0
    hProcess := hMsvcrt := 0

    if !pid := ProcessExist("explorer.exe")
        throw Error('"explorer.exe" not found')
    if !hProcess := DllCall("OpenProcess", "uint", 0x1fffff, "int", false, "uint", pid, "ptr")
        throw OSError()
    try {
        if !hMsvcrt := DllCall("LoadLibraryW", "str", "msvcrt.dll", "ptr")
            throw OSError()
        pLocalMemcpy := DllCall("GetProcAddress", "ptr", hMsvcrt, "astr", "memcpy", "ptr")
        if !msvcrtEntry := ToolHelpFindModuleByName("msvcrt.dll", pid)
            throw Error('"msvcrt.dll" not found')
        pMemcpy := msvcrtEntry.modBaseAddr + pLocalMemcpy - hMsvcrt
        msg := DllCall("RegisterWindowMessage", "str", "WM_CARETPOSCHANGED")

        if !flag || pShellCode {
            if !flag {
                OnExit(unregister, 0)
                DllCall("ChangeWindowMessageFilterEx", "ptr", A_ScriptHwnd, "uint", msg, "uint", 0, "ptr", 0)
            }
            if !DllCall("WriteProcessMemory", "ptr", hProcess, "ptr", pMemcpy, "ptr", pLocalMemcpy, "uptr", 16, "uptr*", 0)
                throw OSError()
            if pShellCode {
                DllCall("VirtualFreeEx", "ptr", hProcess, "ptr", pShellCode, "uptr", 0, "uint", 0x8000)
                pShellCode := 0
            }
            return
        }

        memcpyBytes := DllCall("GetProcAddress", "ptr", hMsvcrt, "astr", "memset", "ptr") - pLocalMemcpy

        if !user32Entry := ToolHelpFindModuleByName("user32.dll", pid)
            throw Error('"User32.dll" not found')
        hUser32 := DllCall("GetModuleHandle", "str", "user32", "ptr")
        pPostMessageW := user32Entry.modBaseAddr + DllCall("GetProcAddress", "ptr", hUser32, "astr", "PostMessageW", "ptr") - hUser32

        if !coreUiComponentsEntry := ToolHelpFindModuleByName("CoreUIComponents.dll", pid)
            throw Error('"CoreUIComponents.dll" not found')

        CryptHexStringToBinary("00000000000000000000000000000000000000000000000090909090909090904983F8100F85970000004C8B54240849BB00000000000000004D29DA4981FA000000000F8378000000837914090F840A000000837914070F856400000083791C000F855A0000004C8B124C8B5A084C3B158BFFFFFF0F850D0000004C3B1D86FFFFFF0F84390000004C891571FFFFFF4C891D72FFFFFF415052514883EC404D8BCB4D8BC2BA0000000048B90000000000000000FF1557FFFFFF4883C440595A4158", &shellCodeBuf)
        NumPut("ptr", pPostMessageW, shellCodeBuf, 0x10)
        NumPut("ptr", coreUiComponentsEntry.modBaseAddr, shellCodeBuf, 0x31)
        NumPut("uint", coreUiComponentsEntry.modBaseSize, shellCodeBuf, 0x3F)
        NumPut("uint", msg, shellCodeBuf, 0xA5)
        NumPut("ptr", A_ScriptHwnd, shellCodeBuf, 0xAB)

        if !pShellCode := DllCall("VirtualAllocEx", "ptr", hProcess, "ptr", 0, "uptr", shellCodeBuf.Size + memcpyBytes, "uint", 0x1000, "uint", 0x40, "ptr")
            throw OSError()
        CryptHexStringToBinary("48B80000000000000000FFD0C3", &hookBuf)
        NumPut("ptr", pShellCode + 32, hookBuf, 2)

        if !DllCall("WriteProcessMemory", "ptr", hProcess, "ptr", pShellCode, "ptr", shellCodeBuf, "uptr", shellCodeBuf.Size, "uptr*", 0)
            throw OSError()
        if !DllCall("WriteProcessMemory", "ptr", hProcess, "ptr", pShellCode + shellCodeBuf.Size, "ptr", pLocalMemcpy, "uptr", memcpyBytes, "uptr*", 0)
            throw OSError()
        if !DllCall("WriteProcessMemory", "ptr", hProcess, "ptr", pMemcpy, "ptr", hookBuf, "uptr", hookBuf.Size, "uptr*", 0)
            throw OSError()
        DllCall("ChangeWindowMessageFilterEx", "ptr", A_ScriptHwnd, "uint", msg, "uint", 1, "ptr", 0)
        OnExit(unregister)
    }
    catch as e {
        if pShellCode {
            DllCall("VirtualFreeEx", "ptr", hProcess, "ptr", pShellCode, "uptr", 0, "uint", 0x8000)
            pShellCode := 0
        }
        throw e
    }
    finally {
        if hMsvcrt
            DllCall("FreeLibrary", "ptr", hMsvcrt)
        DllCall("CloseHandle", "ptr", hProcess)
    }
    return msg

    static unregister(*) => RegisterCaretMessageHook(false)
}

/*
alloc(data, 2048)
label(begin)
label(ready)
label(memcpy)
label(L1)

data:
dq 0,0,0
dq 9090909090909090

begin:
cmp r8,10
jne memcpy
mov r10,[rsp+08]
mov r11,0000000000000000 // uicorecomponents address
sub r10,r11
cmp r10,00000000 // uicorecomponents size
jae memcpy
cmp dword ptr[rcx+14],9
je L1
cmp dword ptr[rcx+14],7
jne memcpy
L1:
cmp dword ptr[rcx+1C],0
jne memcpy
mov r10,[rdx]
mov r11,[rdx+08]
cmp r10,[data]
jne ready
cmp r11,[data+08]
je memcpy

ready:
mov [data],r10
mov [data+08],r11
push r8
push rdx
push rcx
sub rsp,40
mov r9,r11
mov r8,r10
mov edx,0 // msg
mov rcx,0 // hwnd
call [data+10]
add rsp,40
pop rcx
pop rdx
pop r8

memcpy:
*/

CryptHexStringToBinary(hexString, &binary){
    DllCall("crypt32\CryptStringToBinaryW", "str", hexString, "uint", len := StrLen(hexString), "uint", 4, "ptr", 0, "uint*", &bytes := 0, "ptr", 0, "ptr", 0)
    return DllCall("crypt32\CryptStringToBinaryW", "str", hexString, "uint", len, "uint", 4, "ptr", binary := binary ?? Buffer(bytes), "uint*", bytes, "ptr", 0, "ptr", 0)
}

ToolHelpFindModuleByName(moduleName, pid := 0) {
    if !snapshot := DllCall("CreateToolhelp32Snapshot", "uint", 0x18, "uint", pid, "ptr")
        return
    entry := tagMODULEENTRY32W()
    entry.dwSize := entry.Size
    next := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "str", "kernel32", "ptr"), "astr", "Module32NextW", "ptr")

    res := DllCall("Module32FirstW", "ptr", snapshot, "ptr", entry)
    while res {
        if entry.szModule = moduleName {
            res := entry
            break
        }
        res := DllCall(next, "ptr", snapshot, "ptr", entry)
    }
    DllCall("CloseHandle", "ptr", snapshot)
    return res
}

class tagMODULEENTRY32W {
    Size := 1080
    __New() => this.Ptr := (this._ := Buffer(this.Size)).Ptr
    dwSize {
        get => NumGet(this, "uint")
        set => NumPut("uint", Value, this)
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