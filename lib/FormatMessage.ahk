FormatMessage(msg, modName?) {
    if IsSet(modName) && !hMod := DllCall("LoadLibraryW", "str", modName, "ptr")
        return
    fmtMsg := "", hMod := hMod ?? 0
    if DllCall("FormatMessageW", "uint", hMod ? 0x0B00 : 0x1300, "ptr", hMod, "uint", msg, "uint", 0, "ptr*", &hlocal := 0, "uint", 0, "ptr", 0, "uint")
        fmtMsg := StrGet(DllCall("LocalLock", "ptr", hlocal, "ptr")), DllCall("LocalFree", "ptr", hlocal)
    DllCall("FreeLibrary", "ptr", hMod)
    return fmtMsg
}