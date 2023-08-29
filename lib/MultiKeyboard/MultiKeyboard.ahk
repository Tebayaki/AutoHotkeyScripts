/*
@Version 0.2
@Description Distinguish input from different keyboard device, and bind function. Not work in UWP application.

@Example Hook a key and Bind Function
#SingleInstance Force
Persistent
id := MultiKeyboard.GetKeyboardIDByName("\\?\HID#VID_DE29&PID_7318&MI_00#8&34d6b40c&0&0000#{884b96c3-56ef-11d1-bc8c-00a0c91405dd}")
hook := MultiKeyboard()
; true means key down
hook.CreateKeyBinding(id, "f1", true, KeyEvent)
; false means key up
hook.CreateKeyBinding(id, "f1", false, KeyEvent)
; unmap key
esc:: {
    hook.DeleteKeyBinding(id, "f1", true)
    hook.DeleteKeyBinding(id, "f1", false)
}

KeyEvent(key, isDown) {
    ToolTip(GetKeyName(Format("vk{:x}", key)) " - " (isDown ? "Down" : "Up") " - " A_TickCount)
    ; if retrun true, this key will not be block
    return false
}

@Example Work with ahk hotkey, must use ~ prefix
#SingleInstance Force
Persistent
id := MultiKeyboard.GetKeyboardIDByName("\\?\HID#VID_DE29&PID_7318&MI_00#8&34d6b40c&0&0000#{884b96c3-56ef-11d1-bc8c-00a0c91405dd}")
hook := MultiKeyboard()
~f2:: {
    if hook.IsKeyboardActive(id)
        ToolTip "Keyboard id: " id " is active"
}
*/

class MultiKeyboard {
    static __ini := false
    __module := 0
    __keyBindingMap := Map()

    __New(dllpath := unset) {
        if MultiKeyboard.__ini
            throw Error("An instance already exists")
        dllpath := dllpath ?? (SplitPath(A_LineFile, , &dir), dir) "\MultiKeyboard.dll"
        if !this.__module := DllCall("LoadLibrary", "str", dllpath, "ptr")
            throw OSError()
        if !MultiKeyboard.__ini := DllCall("MultiKeyboard\InstallHook", "ptr", A_ScriptHwnd)
            throw Error("InstallHook failed")
    }

    __Delete() {
        if MultiKeyboard.__ini {
            DllCall("MultiKeyboard\UninstallHook")
            MultiKeyboard.__ini := false
        }
        if this.__module
            DllCall("FreeLibrary", "ptr", this.__module)
        for , callback in this.__keyBindingMap {
            if callback
                CallbackFree(callback)
        }
    }

    CreateKeyBinding(keyboardID, keyname, isDown, callback) {
        if !vk := GetKeyVK(keyname)
            throw Error("Invalid key")
        mapkey := keyboardID keyname isDown
        if this.__keyBindingMap.Has(mapkey)
            CallbackFree(this.__keyBindingMap[mapkey])
        return DllCall("MultiKeyboard\CreateKeyBinding", "ptr", keyboardID, "uchar", vk, "uchar", isDown, "ptr", this.__keyBindingMap[mapkey] := CallbackCreate(callback))
    }

    DeleteKeyBinding(keyboardID, keyname, isDown) {
        if !vk := GetKeyVK(keyname)
            throw Error("Invalid key")
        mapkey := keyboardID keyname isDown
        if this.__keyBindingMap.Has(mapkey) {
            CallbackFree(this.__keyBindingMap[mapkey])
            this.__keyBindingMap.Delete(mapkey)
            return DllCall("MultiKeyboard\DeleteKeyBinding", "ptr", keyboardID, "uchar", GetKeyVK(keyname), "uchar", isDown)
        }
    }

    IsKeyboardActive(keyboardID) => DllCall("MultiKeyboard\IsKeyboardActive", "ptr", keyboardID)

    static GetKeyboardIDByName(deviceName) {
        DllCall("GetRawInputDeviceList", "ptr", 0, "uint*", &cnt := 0, "uint", 16, "uint")
        devices := Buffer(16 * cnt)
        DllCall("GetRawInputDeviceList", "ptr", devices, "uint*", &cnt, "uint", 16, "uint")
        VarSetStrCapacity(&foundName, szName := 256)
        loop cnt {
            if NumGet(devices, 16 * (A_Index - 1) + 8, "uint") !== 1 ;RIM_TYPEKEYBOARD
                continue
            hDevice := NumGet(devices, 16 * (A_Index - 1), "ptr")
            DllCall("GetRawInputDeviceInfo", "ptr", hDevice, "uint", 0x20000007, "str", foundName, "uint*", szName, "uint")
            if foundName == deviceName
                return hDevice
        }
        return 0
    }
}