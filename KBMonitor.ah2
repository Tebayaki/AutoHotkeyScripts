#SingleInstance Force

KB_BACK_COLOR := "636363"
KB_FONT_NAME := "Microsoft YaHei"
KEY_SIZE_UNIT := 40
KEY_INI_COLOR := "333333"
KEY_DOWN_COLOR := "ff0000"
KEY_UP_COLOR := "222831"
KEY_INJECTED_DOWN_COLOR := "0055ff"
KEY_INJECTED_UP_COLOR := "002050"
KEY_FONT_COLOR := "ffffff"
KEY_LOCKED_FONT_COLOR := "ff9900"
KEY_FONT_SIZE := 0.3 * KEY_SIZE_UNIT / A_ScreenDPI * 72
RECORD_LIST_BACK_COLOR := "333333"
RECORD_LIST_FONT_SIZE := KEY_FONT_SIZE + 1
RECORD_MAX_COUNT := 50

layout := [
    [["Esc", 27], { x: 1 }, ["F1", 112], ["F2", 113], ["F3", 114], ["F4", 115], { x: 0.5 }, ["F5", 116], ["F6", 117], ["F7", 118], ["F8", 119], { x: 0.5 }, ["F9", 120], ["F10", 121], ["F11", 122], ["F12", 123], { x: 0.2 }, ["PRTSC", 44], ["LOCK", 145], ["PAUSE", 19]],
    [{ y: 0.2 }, ["~`n``", 192], ["!`n1", 49], ["@`n2", 50], ["#`n3", 51], ["$`n4", 52], ["%`n5", 53], ["^`n6", 54], ["&&`n7", 55], ["*`n8", 56], ["(`n9", 57], [")`n0", 48], ["_`n-", 189], ["+`n=", 187], { w: 2 }, ["BACKSPACE", 8], { x: 0.2 }, ["INS", 45], ["HOME", 36], ["PGUP", 33], { x: 0.2 }, ["NUM`nLOCK", 144], ["/", 111], ["*", 106], ["-", 109]],
    [{ w: 1.5 }, ["Tab", 9], ["Q", 81], ["W", 87], ["E", 69], ["R", 82], ["T", 84], ["Y", 89], ["U", 85], ["I", 73], ["O", 79], ["P", 80], ["{`n[", 219], ["}`n]", 221], { w: 1.5 }, ["|`n\", 220], { x: 0.2 }, ["DEL", 46], ["END", 35], ["PGDN", 34], { x: 0.2 }, ["7", 103], ["8", 104], ["9", 105], { h: 2 }, ["`n`n+", 107]],
    [{ w: 1.75 }, ["CAPSLOCK", 20], ["A", 65], ["S", 83], ["D", 68], ["F", 70], ["G", 71], ["H", 72], ["J", 74], ["K", 75], ["L", 76], [":`n;", 186], ["`"`n'", 222], { w: 2.25 }, ["ENTER", 13], { x: 3.4 }, ["4", 100], ["5", 101], ["6", 102]],
    [{ w: 2.25 }, ["SHIFT", 160], ["Z", 90], ["X", 88], ["C", 67], ["V", 86], ["B", 66], ["N", 78], ["M", 77], ["<`n,", 188], [">`n.", 190], ["?`n/", 191], { w: 2.75 }, ["SHIFT", 161], { x: 1.2 }, ["↑", 38], { x: 1.20 }, ["1", 97], ["2", 98], ["3", 99], { h: 2 }, ["`n`nENTER", 108]],
    [{ w: 1.25 }, ["CTRL", 162], { w: 1.25 }, ["WIN", 91], { w: 1.25 }, ["ALT", 164], { w: 6.25 }, ["", 32], { w: 1.25 }, ["ALT", 165], { w: 1.25 }, ["Win", 92], { w: 1.25 }, ["MENU", 93], { w: 1.25 }, ["CTRL", 163], { x: 0.2 }, ["←", 37], ["↓", 40], ["→", 39], { x: 0.2 }, { w: 2 }, ["0", 96], [".", 110]]
]
kbm := Gui("AlwaysOnTop E0x8000000 -MaximizeBox", "KeyboardMonitor")
kbm.BackColor := KB_BACK_COLOR
kbm.SetFont("bold c" KEY_FONT_COLOR " s" KEY_FONT_SIZE, KB_FONT_NAME)
kbm.MarginX := kbm.MarginY := 1
kbm.OnEvent("Close", (*) => ExitApp())
; load keyboard layout
keyButtons := kbm_LoadLayout(kbm, layout, kbm.MarginX, kbm.MarginY + 1, , &bottom)
; load log window
recordList := kbm.Add("ListView", "NoSort ym" " h" bottom - kbm.MarginY " w" 12.5 * RECORD_LIST_FONT_SIZE / 72 * A_ScreenDPI " Count" RECORD_MAX_COUNT " Background" RECORD_LIST_BACK_COLOR, ["Elapse", "Keyname", "⚑"])
; install keyboard hook
hook := WindowsHookEx.HookLowLevelKeyboard(kbm_KeyboardProc)
startTime := A_TickCount
; check key and show state before installing hook
keyButtons[20].Opt("c" (GetKeyState("CapsLock", "T") ? KEY_LOCKED_FONT_COLOR : KEY_FONT_COLOR))
keyButtons[144].Opt("c" (GetKeyState("NumLock", "T") ? KEY_LOCKED_FONT_COLOR : KEY_FONT_COLOR))
keyButtons[145].Opt("c" (GetKeyState("ScrollLock", "T") ? KEY_LOCKED_FONT_COLOR : KEY_FONT_COLOR))
for state in GetKeyboardState() {
    if state & 0x80 && (A_Index < 16 || A_Index > 18) {
        if keyButtons[A_Index]
            keyButtons[A_Index].Opt("Background" (KEY_DOWN_COLOR))
        kbm_RecordKeyInfomation(A_Index, 1, 0, startTime, 1)
    }
}
; show gui
kbm.Show("NoActivate AutoSize")
VarSetStrCapacity(&layout, 0)
VarSetStrCapacity(&bottom, 0)

kbm_LoadLayout(ui, lo, left, top, &right := unset, &bottom := unset) {
    key_buttons := [], key_buttons.Length := 254
    x := left, y := top
    w := h := KEY_SIZE_UNIT
    right := bottom := 0

    for , v in lo {
        for , v in v {
            if v is Array {
                key_buttons[v[2]] := ui.Add("Text", "w" w " h" h " x" x " y" y " Background" KEY_INI_COLOR " Border", RegExReplace(v[1], "m)^", A_Space))
                right := (right >= right_buf := x + w) ? right : right_buf
                bottom := (bottom >= bottom_buf := y + h) ? bottom : bottom_buf
                x += w
                w := h := KEY_SIZE_UNIT
            } else {
                x += v.HasOwnProp("x") ? v.x * KEY_SIZE_UNIT : 0
                y += v.HasOwnProp("y") ? v.y * KEY_SIZE_UNIT : 0
                w := v.HasOwnProp("w") ? v.w * KEY_SIZE_UNIT : w
                h := v.HasOwnProp("h") ? v.h * KEY_SIZE_UNIT : h
            }
        }
        x := left
        y += KEY_SIZE_UNIT
    }
    return key_buttons
}

kbm_KeyboardProc(nCode, wParam, lParam) {
    if !nCode
        SetTimer(kbm_KeyboardProc2.Bind(KBDLLHOOKSTRUCT(lParam).Load()), -1)
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam, "ptr")
}

kbm_KeyboardProc2(record) {
    static last_flag := "", last_vk := "", repeat := 1
    pressed := !(record.Flag & 0x80)
    injected := record.Flag & 0x10
    ; Filter repetitive behavior and unset key
    if record.Flag != last_flag || record.VK != last_vk {
        last_flag := record.Flag, last_vk := record.VK, repeat := 1
        if keyButtons[record.VK]
            kbm_ChangeKeyButtonColor(record.VK, pressed, injected)
    } else repeat++
    kbm_RecordKeyInfomation(record.VK, pressed, injected, record.Time, repeat)
}

kbm_ChangeKeyButtonColor(vk, pressed, injected) {
    if pressed
        keyButtons[vk].Opt("Background" (injected ? KEY_INJECTED_DOWN_COLOR : KEY_DOWN_COLOR) " c" ((20 = vk || 144 = vk || 145 = vk) && GetKeyState("vk" Format("{:x}", vk), "T") ? KEY_LOCKED_FONT_COLOR : KEY_FONT_COLOR))
    else SetTimer(ObjBindMethod(() => (GetKeyState("vk" Format("{:x}", vk)) ? "" : (keyButtons[vk].Opt("Background" (injected ? KEY_INJECTED_UP_COLOR : KEY_UP_COLOR)), keyButtons[vk].Redraw()))), -20)
}

kbm_RecordKeyInfomation(vk, pressed, injected, time, repeat) {
    action := pressed ? (injected ? "∨" : "▼") : (injected ? "∧" : "▲")
    try {
        if repeat > 1
            recordList.Modify(recordList.GetCount(), "Col3", action repeat)
        else if 50 <= recordList.Add(, (time - startTime & 0xffffffff) / 1000, GetKeyName("vk" Format("{:x}", vk)), action)
            recordList.Delete(1)
    }
    SendMessage(0x0115, 7, 0, recordList)
}

/********************************************************************************
 * lib
 ********************************************************************************/
class WindowsHookEx {
    static WH := { MSGFILTER: -1, JOURNALRECORD: 0, JOURNALPLAYBACK: 1, KEYBOARD: 2, GETMESSAGE: 3, CALLWNDPROC: 4, CBT: 5, SYSMSGFILTER: 6, MOUSE: 7, HARDWARE: 8, DEBUG: 9, SHELL: 10, FOREGROUNDIDLE: 11, CALLWNDPROCRET: 12, KEYBOARD_LL: 13, MOUSE_LL: 14 }
    __New(hookid, proc, module, threadid) {
        if !this.Hook := DllCall("SetWindowsHookEx", "int", hookid, "ptr", proc, "ptr", module, "uint", threadid)
            throw Error(A_LastError, -1)
        this.Proc := proc
    }
    __Delete() => (DllCall("GlobalFree", "ptr", this.Proc, "ptr"), DllCall("UnhookWindowsHookEx", "ptr", this.Hook))
    static HookLowLevelKeyboard(function) => WindowsHookEx(this.WH.KEYBOARD_LL, CallbackCreate(function, "F"), DllCall("GetModuleHandle", "ptr", 0, "ptr"), 0)
    static HookLowLevelMouse(function) => WindowsHookEx(this.WH.MOUSE_LL, CallbackCreate(function, "F"), DllCall("GetModuleHandle", "ptr", 0, "ptr"), 0)
}

class KBDLLHOOKSTRUCT {
    __New(ptr) => (this.Ptr := ptr, this.Size := 24)
    VirtualKeyCode => NumGet(this, "uint")
    ScanCode => NumGet(this, 4, "uint")
    Flag => NumGet(this, 8, "uint")
    Time => NumGet(this, 12, "uint")
    ExtraInfo => NumGet(this, 16, "ptr")
    Load() => { VK: this.VirtualKeyCode, SC: this.ScanCode, Flag: this.Flag, Time: this.Time, ExtraInfo: this.ExtraInfo }
}

GetKeyboardState() {
    DllCall("GetKeyboardState", "ptr", kb_state := Buffer(256))
    return (&state) => (A_Index <= 254 ? (state := NumGet(kb_state, A_Index, "uchar"), 1) : 0)
}