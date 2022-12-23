GetSelection() {
    before := A_Clipboard
    A_Clipboard := ""
    Send("^c")
    selection := ClipWait(0.2) ? A_Clipboard : ""
    A_Clipboard := before
    return selection
}

PasteSend(text) {
    before := A_Clipboard
    A_Clipboard := text
    Send("^v"), Sleep(100)
    A_Clipboard := before
}

JoinArray(arr, delimiter := "`n") {
    joint := arr.Length && arr[1]
    loop arr.Length - 1
        joint .= delimiter arr[A_Index + 1]
    return joint
}

SendText(str, window := "A") {
    ctrl := ControlGetFocus(window) || WinExist(window)
    loop parse, str
        PostMessage(0x102, ord(A_LoopField), , ctrl)
}

ScreenToClient(screenX, screenY, &clientX, &clientY, window := "A") {
    clientX := clientY := 0
    if res := DllCall("ScreenToClient", "ptr", WinExist(window), "ptr*", &pt := (screenX & 0xffffffff) | (screenY << 32)) {
        clientX := pt & 0xffffffff, clientY := pt >> 32
        if clientX > 0x7fffffff
            clientX -= 0x100000000
        if clientY > 0x7fffffff
            clientY -= 0x100000000
    }
    return res
}

ClientToScreen(clientX, clientY, &screenX, &screenY, window := "A") {
    screenX := screenY := 0
    if res := DllCall("ClientToScreen", "ptr", WinExist(window), "ptr*", &pt := (clientX & 0xffffffff) | (clientY << 32)) {
        screenX := pt & 0xffffffff, screenY := pt >> 32
        if screenX > 0x7fffffff
            screenX -= 0x100000000
        if screenY > 0x7fffffff
            screenY -= 0x100000000
    }
    return res
}