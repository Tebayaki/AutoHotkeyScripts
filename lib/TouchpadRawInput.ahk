Persistent

; 初始化
touchpad := TouchpadRawInput()
; 注册回调
touchpad.SubscribeTouchpadEvent(fn)
; 显示触摸板信息
if !DllCall("GetStdHandle", "uint", -11, "ptr")
    DllCall("AllocConsole")
fn(contactID, x, y, tip, confidence) {
    FileAppend(
        "触点ID: " contactID "`t"
        "X: " x "`t"
        "Y: " y "`t"
        "触碰: " tip "`t"
        "置信: " confidence "`n", "*"
    )
}

; 把触摸板的不同部分当成修饰键使用
#HotIf touchpad.contacts[1].tip && touchpad.contacts[1].confidence && touchpad.contacts[1].x < 1500 && touchpad.contacts[1].y < 1000
a:: ToolTip "手指放在触摸板左上角"
#HotIf


class TouchpadRawInput {
    static __ini := false

    contacts := [
            { contactID: 0, x: 0, y: 0, tip: false, confidence: false },
            { contactID: 1, x: 0, y: 0, tip: false, confidence: false },
            { contactID: 2, x: 0, y: 0, tip: false, confidence: false },
            { contactID: 3, x: 0, y: 0, tip: false, confidence: false },
            { contactID: 4, x: 0, y: 0, tip: false, confidence: false },
        ]

    SubscribeTouchpadEvent(callback) {
        if !callback is Func || (callback.MinParams < 5 && !callback.IsVariadic) || callback.MinParams > 5
            throw Error("Invalid callback function")
        this.__callback := callback
    }

    UnSubscribeTouchpadEvent() => this.__callback := ""

    __New() {
        if TouchpadRawInput.__ini
            throw Error("An instance already exists")
        rawInputDevice := Buffer(16)
        NumPut("ushort", 0x0D, "ushort", 0x05, "uint", 0x100, "ptr", A_ScriptHwnd, rawInputDevice)
        if !TouchpadRawInput.__ini := DllCall("RegisterRawInputDevices", "ptr", rawInputDevice, "uint", 1, "uint", rawInputDevice.Size)
            throw OSError()
        OnMessage(0x00ff, this.__ProcBinding := this.__Proc.Bind(this))
        this.__callback := ""
    }

    __Delete() {
        if !TouchpadRawInput.__ini
            return
        rawInputDevice := Buffer(16)
        NumPut("ushort", 0x0D, "ushort", 0x05, "uint", 0x1, "ptr", 0, rawInputDevice)
        DllCall("RegisterRawInputDevices", "ptr", rawInputDevice, "uint", 1, "uint", rawInputDevice.Size)
        OnMessage(0x00ff, this.__ProcBinding, 0)
    }

    __Proc(wParam, lParam, msg, hwnd) {
        Critical
        DllCall("GetRawInputData", "ptr", lParam, "uint", 0x10000003, "ptr", 0, "uint*", &dataSize := 0, "uint", 24, "uint")
        rawInputData := Buffer(dataSize)
        if DllCall("GetRawInputData", "ptr", lParam, "uint", 0x10000003, "ptr", rawInputData, "uint*", &dataSize, "uint", 24, "uint") != dataSize
            goto end

        if NumGet(rawInputData, 0, "uint") != 2
            goto end

        hDevice := NumGet(rawInputData, 8, "ptr")
        DllCall("GetRawInputDeviceInfo", "ptr", hDevice, "uint", 0x20000005, "ptr", 0, "uint*", &dataSize, "uint")
        preparsedData := Buffer(dataSize)
        if DllCall("GetRawInputDeviceInfo", "ptr", hDevice, "uint", 0x20000005, "ptr", preparsedData, "uint*", &dataSize, "uint") != dataSize
            goto end

        hidpCaps := Buffer(64)
        if DllCall("Hid\HidP_GetCaps", "ptr", preparsedData, "ptr", hidpCaps) != 1114112
            goto end

        inputValueCapsLength := NumGet(hidpCaps, 48, "ushort")
        inputValueCaps := Buffer(inputValueCapsLength * 72)
        if DllCall("Hid\HidP_GetValueCaps", "uint", 0, "ptr", inputValueCaps, "uint*", &inputValueCapsLength, "ptr", preparsedData) != 1114112
            goto end

        contactID := x := y := ""
        dwSizeHid := NumGet(rawInputData, 24, "uint")
        loop inputValueCapsLength {
            offset := (A_Index - 1) * 72
            usagePage := NumGet(inputValueCaps, offset, "ushort")
            linkCollection := NumGet(inputValueCaps, offset + 6, "ushort")
            if linkCollection <= 0
                continue
            usage := NumGet(inputValueCaps, offset + 56, "ushort")
            if DllCall("Hid\HidP_GetUsageValue", "uint", 0, "ushort", usagePage, "ushort", linkCollection, "ushort", usage, "uint*", &value := 0, "ptr", preparsedData, "ptr", rawInputData.Ptr + 32, "uint", dwSizeHid) != 1114112
                continue

            if usage == 0x51 && usagePage == 0x0d
                contactID := value
            else if usage == 0x30 && usagePage == 0x01
                x := value
            else if usage == 0x31 && usagePage == 0x01
                y := value

            if contactID !== "" && x !== "" && y !== ""
                break
            else if A_Index == inputValueCapsLength
                goto end
        }
        contact := this.contacts[contactID + 1]
        contact.x := x
        contact.y := y

        usageLength := 9
        usageAndPage := Buffer(36)
        if DllCall("Hid\HidP_GetUsagesEx", "uint", 0, "ushort", linkCollection, "ptr", usageAndPage, "uint*", &usageLength, "ptr", preparsedData, "ptr", rawInputData.Ptr + 32, "uint", dwSizeHid) !== 1114112
            goto end
        contact.tip := contact.confidence := false
        loop usageLength {
            usage := NumGet(usageAndPage, (A_Index - 1) * 4, "ushort")
            usagePage := NumGet(usageAndPage, (A_Index - 1) * 4 + 2, "ushort")
            if usage == 0x42 && usagePage == 0x0d
                contact.tip := true
            else if usage == 0x47 && usagePage == 0x0d
                contact.confidence := true
        }
        if this.__callback
            this.__callback.Call(contactID, x, y, contact.tip, contact.confidence)
    end:
        return (wParam & 0xff) == 0 ? DllCall("DefWindowProc", "ptr", hwnd, "uint", msg, "ptr", wParam, "ptr", lParam, "ptr") : 0
    }
}