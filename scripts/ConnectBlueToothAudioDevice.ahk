; example
name := "Tebayaki's AirPods Pro"
if 0 == res := ConnectBluetoothAudioDevieByName(name)
    MsgBox "Connected！"

ConnectBluetoothAudioDevieByName(deviceName) {
    if !deviceInfo := FindRememberedDeviceByName(deviceName)
        return 1 ; Device not found
    if GetBluetoothDevicefConnected(deviceInfo)
        return 2 ; The device is already connected
    if !ReEnableAVRemoteControlService(deviceInfo)
        return 3 ; Unable to reenable AVRemoteControlService
    if !IsDeviceConnected(GetBlueToothDeviceAddress(deviceInfo))
        return 4 ; Unable to connect to the device
    return 0
}

FindRememberedDeviceByName(deviceName) {
    if !hModule := DllCall("LoadLibraryW", "str", "Bthprops.cpl", "ptr")
        return
    res := false
    deviceSearchParams := Buffer(40, 0)
    NumPut("uint", deviceSearchParams.Size, deviceSearchParams)
    NumPut("int", 1, deviceSearchParams, 8)
    NumPut("uchar", 1, deviceSearchParams, 24)
    deviceInfo := Buffer(560)
    NumPut("uint", deviceInfo.Size, deviceInfo)
    if hDeviceFind := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", deviceSearchParams, "ptr", deviceInfo, "ptr") {
        loop {
            if (StrGet(deviceInfo.Ptr + 64) == deviceName) {
                res := true
                break
            }
        } until !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", hDeviceFind, "ptr", deviceInfo)
        DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", hDeviceFind)
    }
    DllCall("FreeLibrary", "ptr", hModule)
    return res ? deviceInfo : ""
}

IsDeviceConnected(address) {
    res := false
    if !hModule := DllCall("LoadLibraryW", "str", "Bthprops.cpl", "ptr")
        return
    deviceSearchParams := Buffer(40, 0)
    NumPut("uint", deviceSearchParams.Size, deviceSearchParams)
    NumPut("int", 1, deviceSearchParams, 16)
    NumPut("uchar", 1, deviceSearchParams, 24)
    deviceInfo := Buffer(560)
    NumPut("uint", deviceInfo.Size, deviceInfo)
    if hDeviceFind := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", deviceSearchParams, "ptr", deviceInfo, "ptr") {
        loop {
            if (NumGet(deviceInfo, 8, "uint64") == address) {
                res := true
                break
            }
        } until !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", hDeviceFind, "ptr", deviceInfo)
        DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", hDeviceFind)
    }
    DllCall("FreeLibrary", "ptr", hModule)
    return res
}

ReEnableAVRemoteControlService(deviceInfo) {
    res := false
    if !hModule := DllCall("LoadLibraryW", "str", "Bthprops.cpl", "ptr")
        return
    DllCall("ole32\CLSIDFromString", "str", "{0000110E-0000-1000-8000-00805F9B34FB}", "ptr", AVRemoteControlServiceClass_UUID := Buffer(16))
    if 1060 !== DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", deviceInfo, "ptr", AVRemoteControlServiceClass_UUID, "uint", 0) {
        if 0 == DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", deviceInfo, "ptr", AVRemoteControlServiceClass_UUID, "uint", 1) {
            res := true
        }
    }
    DllCall("FreeLibrary", "ptr", hModule)
    return res
}

GetBlueToothDeviceAddress(deviceInfo) => NumGet(deviceInfo, 8, "uint64")
GetBluetoothDevicefConnected(deviceInfo) => NumGet(deviceInfo, 20, "int")