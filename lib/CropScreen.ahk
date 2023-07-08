/*
@Example
; 选择屏幕范围并显示
info := CropScreen()
MsgBox(info.Left " " info.Top " " info.Right " " info.Bottom)
ui := Gui()
ui.AddPicture(, "HBITMAP:" info.HBitmap)
ui.Show()

@Example
; ocr屏幕范围
#Include <RapidOcrOnnx\RapidOcrOnnx>
ocr := RapidOcrOnnx()
info := CropScreen()
MsgBox ocr.DetectHBitmap(info.HBitmap).ToString()
*/
; ocr屏幕范围
#Include <RapidOcrOnnx\RapidOcrOnnx>
ocr := RapidOcrOnnx()
info := CropScreen()
MsgBox ocr.DetectHBitmap(info.HBitmap).ToString()
CropScreen() {
    static count := 0
    res := ""
    originDc := displayDc := bluePen := 0
    anchorX := anchorY := mouseX := mouseY := 0
    left := right := bottom := top := 0
    drawing := false

    className := "CropScreenWndClass" count++
    proc := CallbackCreate(WndProc)
    wndClass := Buffer(72, 0)
    NumPut("uint", 3, wndClass)
    NumPut("ptr", proc, wndClass, 8)
    NumPut("ptr", DllCall("LoadCursorW", "ptr", 0, "ptr", 32515), wndClass, 40)
    NumPut("ptr", StrPtr(className), wndClass, 64)
    if !DllCall("RegisterClassW", "ptr", wndClass)
        throw OSError()
    if !hwndCropScreen := DllCall("CreateWindowExW", "uint", 0x88, "str", className, "ptr", 0, "uint", 0x82000000, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr")
        throw OSError()
    WinShow(hwndCropScreen)
    msg := Buffer(48)
    while DllCall("GetMessageW", "ptr", msg, "ptr", 0, "uint", 0, "uint", 0) {
        DllCall("TranslateMessage", "ptr", msg)
        DllCall("DispatchMessageW", "ptr", msg)
    }
    CallbackFree(proc)
    DllCall("UnregisterClassW", "str", className, "ptr", 0)
    return res

    WndProc(hwnd, msg, wp, lp) {
        switch msg {
            case 0x0001:    ; WM_CREATE
                SnapScreen()
            case 0x0002:    ; WM_DESTROY
                Release()
                DllCall("PostQuitMessage", "int", 0)
            case 0x000F:    ; WM_PAINT
                static paintStruct := Buffer(72)
                dc := DllCall("BeginPaint", "ptr", hwnd, "ptr", paintStruct)
                DllCall("BitBlt", "ptr", dc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", displayDc, "int", 0, "int", 0, "uint", 0x00CC0020)
                DllCall("EndPaint", "ptr", hwnd, "ptr", paintStruct)
                DllCall("StretchBlt", "ptr", displayDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", originDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", 0x00CC0020)
            case 0x0200:    ; WM_MOUSEMOVE
                if drawing {
                    mouseX := lp & 0xffff
                    mouseY := lp >> 16
                    DrawViewFinder()
                    DllCall("InvalidateRect", "ptr", hwnd, "ptr", 0, "int", 0)
                }
            case 0x0201:    ; WM_LBUTTONDOWN
                drawing := true
                anchorX := lp & 0xffff
                anchorY := lp >> 16
                DllCall("SetCapture")
            case 0x0202:    ; WM_LBUTTONUP
                drawing := false
                DllCall("ReleaseCapture")
                if left != right && top != bottom
                    res := Crop()
                DllCall("DestroyWindow", "ptr", hwnd)
            case 0x0205:    ; WM_RBUTTONUP
                DllCall("DestroyWindow", "ptr", hwnd)
            case 0x0100:    ; WM_KEYDOWN
                if (wp == 0x1B)    ; Escape
                    DllCall("DestroyWindow", "ptr", hwnd)
            default:
                return DllCall("DefWindowProcW", "ptr", hwnd, "uint", msg, "ptr", wp, "ptr", lp, "ptr")
        }
        return 0
    }

    SnapScreen() {
        screenDc := DllCall("GetDC", "ptr", 0)
        originDc := DllCall("CreateCompatibleDC", "ptr", screenDc)
        originBmp := DllCall("CreateCompatibleBitmap", "ptr", screenDc, "int", A_ScreenWidth, "int", A_ScreenHeight)
        DllCall("SelectObject", "ptr", originDc, "ptr", originBmp)
        DllCall("BitBlt", "ptr", originDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", screenDc, "int", 0, "int", 0, "uint", 0x00CC0020)
        DllCall("DeleteObject", "ptr", originBmp)

        displayDc := DllCall("CreateCompatibleDC", "ptr", screenDc)
        displayBmp := DllCall("CreateCompatibleBitmap", "ptr", screenDc, "int", A_ScreenWidth, "int", A_ScreenHeight)
        DllCall("SelectObject", "ptr", displayDc, "ptr", displayBmp)
        bluePen := DllCall("CreatePen", "int", 6, "int", 3, "uint", 0xFE4F7F)
        DllCall("SelectObject", "ptr", displayDc, "ptr", bluePen)
        DllCall("SelectObject", "ptr", displayDc, "ptr", DllCall("GetStockObject", "int", 5))
        DllCall("BitBlt", "ptr", displayDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", originDc, "int", 0, "int", 0, "uint", 0x00CC0020)
        DllCall("DeleteObject", "ptr", displayBmp)
        DllCall("ReleaseDC", "ptr", 0, "ptr", screenDc)

        DllCall("SetStretchBltMode", "ptr", displayDc, "int", 4)
        DllCall("SetBrushOrgEx", "ptr", displayDc, "int", 0, "int", 0, "ptr", 0)
        filter := Buffer(24, 0)
        DllCall("GetColorAdjustment", "ptr", displayDc, "ptr", filter)
        NumPut("short", -10, "short", -15, filter, 16)
        DllCall("SetColorAdjustment", "ptr", displayDc, "ptr", filter)
        DllCall("StretchBlt", "ptr", displayDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", originDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", 0x00CC0020)
    }

    Release() {
        DllCall("DeleteObject", "ptr", bluePen)
        DllCall("DeleteDC", "ptr", originDc)
        DllCall("DeleteDC", "ptr", displayDc)
    }

    DrawViewFinder() {
        if mouseX >= anchorX {
            left := anchorX
            right := mouseX + 1
        }
        else {
            left := mouseX
            right := anchorX
        }
        if mouseY >= anchorY {
            top := anchorY
            bottom := mouseY + 1
        }
        else {
            top := mouseY
            bottom := anchorY
        }
        DllCall("BitBlt", "ptr", displayDc, "int", left, "int", top, "int", right - left, "int", bottom - top, "ptr", originDc, "int", left, "int", top, "uint", 0x00CC0020)
        DllCall("Rectangle", "ptr", displayDc, "int", left - 3, "int", top - 3, "int", right + 3, "int", bottom + 3)
    }

    Crop() {
        bmpInfo := Buffer(40, 0)
        width := right - left
        height := bottom - top
        NumPut("uint", bmpInfo.Size, "int", width, "int", height, "short", 1, "short", 32, bmpInfo)
        hMemDc := DllCall("CreateCompatibleDC", "ptr", originDc)
        hBmp := DllCall("CreateDIBSection", "ptr", hMemDc, "ptr", bmpInfo, "uint", 0, "ptr*", &pData := 0, "ptr", 0, "uint", 0)
        DllCall("SelectObject", "ptr", hMemDc, "ptr", hBmp)
        DllCall("BitBlt", "ptr", hMemDc, "int", 0, "int", 0, "int", width, "int", height, "ptr", originDc, "int", left, "int", top, "uint", 0x00CC0020)
        DllCall("DeleteDC", "ptr", hMemDc)
        bitmap := Buffer(32, 0)
        DllCall("GetObjectW", "ptr", hBmp, "int", bitmap.Size, "ptr", bitmap)
        bitmapData := Buffer(24)
        pData := NumGet(bitmap, 24, "ptr")
        stride := NumGet(bitmap, 12, "uint")
        width := NumGet(bitmap, 4, "int")
        height := NumGet(bitmap, 8, "int")
        pixelBytes := NumGet(bitmap, 18, "ushort") // 8
        data := Buffer(stride * height)
        loop height {
            DllCall("RtlCopyMemory", "ptr", data.Ptr + (A_Index - 1) * stride, "ptr", pData + (height - A_Index) * stride, "uptr", stride)
        }
        NumPut("ptr", data.Ptr, "uint", stride, "int", width, "int", height, "int", 4, bitmapData)
        bitmapData.__data := data
        return {
            Left: left,
            Top: top,
            Right: right,
            Bottom: bottom,
            Width: width,
            Height: height,
            HBitmap: hBmp,
            BitmapData: bitmapData,
            Show: (this) => (ui := Gui(), ui.AddPicture(, "HBITMAP:" this.HBitmap), ui.Show()),
            __Delete: (this) => DllCall("DeleteObject", "ptr", this.HBitmap)
        }
    }
}