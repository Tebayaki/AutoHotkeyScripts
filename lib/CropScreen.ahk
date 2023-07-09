/*
@Example
; 选择屏幕范围并显示
res := CropScreen()
MsgBox(res.X " " res.Y " " res.Width " " res.Height)
res.Show()

@Example
; ocr屏幕范围
#Include <RapidOcrOnnx\RapidOcrOnnx>
ocr := RapidOcrOnnx()
res := CropScreen()
MsgBox ocr.DetectHBitmap(res.HBitmap).ToString()
*/
CropScreen() {
    _thickness := 3
    _color := 0xFE4F7F
    _shown := false
    _lButtonDown := false
    _canceled := false
    _lButtonDownX := 0
    _lButtonDownY := 0
    _lastSelectionRect := { X1: 0, Y1: 0, X2: 0, Y2: 0, W: 0, H: 0 }
    _lastChangedRect := { X1: 0, Y1: 0, X2: 0, Y2: 0, W: 0, H: 0 }
    _lastSelectionRectBuf := Buffer(16, 0)
    _lastChangedRectBuf := Buffer(16, 0)

    _pen := DllCall("CreatePen", "int", 6, "int", _thickness, "uint", _color)
    _nullClipRgn := DllCall("CreateRectRgn", "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr")

    win := Gui("-Caption")
    _winDc := DllCall("GetDC", "ptr", win.Hwnd)

    ; init source dc
    screenDc := DllCall("GetDC", "ptr", 0)
    _srcDc := DllCall("CreateCompatibleDC", "ptr", screenDc)
    srcBmp := DllCall("CreateCompatibleBitmap", "ptr", screenDc, "int", A_ScreenWidth, "int", A_ScreenHeight)
    DllCall("SelectObject", "ptr", _srcDc, "ptr", srcBmp)
    DllCall("DeleteObject", "ptr", srcBmp)
    DllCall("BitBlt", "ptr", _srcDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", screenDc, "int", 0, "int", 0, "uint", 0x00CC0020)
    DllCall("ReleaseDC", "ptr", 0, "ptr", screenDc)

    ; init background dc
    _bkgDc := DllCall("CreateCompatibleDC", "ptr", _srcDc)
    DllCall("SetStretchBltMode", "ptr", _bkgDc, "int", 4)
    DllCall("SetBrushOrgEx", "ptr", _bkgDc, "int", 0, "int", 0, "ptr", 0)
    filter := Buffer(24, 0)
    DllCall("GetColorAdjustment", "ptr", _bkgDc, "ptr", filter)
    NumPut("short", -20, "short", -20, filter, 16)
    DllCall("SetColorAdjustment", "ptr", _bkgDc, "ptr", filter)
    bkgBmp := DllCall("CreateCompatibleBitmap", "ptr", _srcDc, "int", A_ScreenWidth, "int", A_ScreenHeight)
    DllCall("SelectObject", "ptr", _bkgDc, "ptr", bkgBmp)
    DllCall("DeleteObject", "ptr", bkgBmp)
    DllCall("StretchBlt", "ptr", _bkgDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", _srcDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "uint", 0x00CC0020)

    ; init buffer dc
    _bufDc := DllCall("CreateCompatibleDC", "ptr", _bkgDc)
    bufBmp := DllCall("CreateCompatibleBitmap", "ptr", _bkgDc, "int", A_ScreenWidth, "int", A_ScreenHeight)
    DllCall("SelectObject", "ptr", _bufDc, "ptr", bufBmp)
    DllCall("DeleteObject", "ptr", bufBmp)
    DllCall("SelectObject", "ptr", _bufDc, "ptr", _pen)
    DllCall("SelectObject", "ptr", _bufDc, "ptr", DllCall("GetStockObject", "int", 5))

    win.OnMessage(0x0010, OnWM_CLOSE)
    win.OnMessage(0x0014, OnWM_ERASEBKGND)
    win.OnMessage(0x0100, OnWM_KEYDOWN)
    win.OnMessage(0x0200, OnWM_MOUSEMOVE)
    win.OnMessage(0x0201, OnWM_LBUTTONDOWN)
    win.OnMessage(0x0202, OnWM_LBUTTONUP)
    win.OnMessage(0x0205, OnWM_RBUTTONUP)

    win.Show("Maximize")
    _shown := true
    StartMessageLoop()
    win.Destroy()

    res := ""
    if _lastSelectionRect.W && _lastSelectionRect.H && !_canceled {
        ; get HBitmap
        bmpInfo := Buffer(40, 0)
        NumPut("uint", bmpInfo.Size, "int", _lastSelectionRect.W, "int", _lastSelectionRect.H, "short", 1, "short", 32, bmpInfo)
        hMemDc := DllCall("CreateCompatibleDC", "ptr", _srcDc)
        hBmp := DllCall("CreateDIBSection", "ptr", hMemDc, "ptr", bmpInfo, "uint", 0, "ptr*", &pData := 0, "ptr", 0, "uint", 0)
        DllCall("SelectObject", "ptr", hMemDc, "ptr", hBmp)
        DllCall("BitBlt", "ptr", hMemDc, "int", 0, "int", 0, "int", _lastSelectionRect.W, "int", _lastSelectionRect.H, "ptr", _srcDc, "int", _lastSelectionRect.X1, "int", _lastSelectionRect.Y1, "uint", 0x00CC0020)
        DllCall("DeleteDC", "ptr", hMemDc)

        ; get BitmapData
        bitmap := Buffer(32, 0)
        DllCall("GetObjectW", "ptr", hBmp, "int", bitmap.Size, "ptr", bitmap)
        pData := NumGet(bitmap, 24, "ptr")
        stride := NumGet(bitmap, 12, "uint")
        width := NumGet(bitmap, 4, "int")
        height := NumGet(bitmap, 8, "int")
        pixelBytes := NumGet(bitmap, 18, "ushort") // 8
        bitmapData := Buffer(24 + stride * height)
        loop height {
            DllCall("RtlCopyMemory", "ptr", bitmapData.Ptr + (A_Index - 1) * stride + 24, "ptr", pData + (height - A_Index) * stride, "uptr", stride)
        }
        NumPut("ptr", bitmapData.Ptr + 24, "uint", stride, "int", width, "int", height, "int", 4, bitmapData)
        res := {
            X: _lastSelectionRect.X1,
            Y: _lastSelectionRect.Y1,
            Width: _lastSelectionRect.W,
            Height: _lastSelectionRect.H,
            HBitmap: { Ptr: hBmp, __Delete: (this) => DllCall("DeleteObject", "ptr", this) },
            BitmapData: bitmapData,
            Show: (this) => (ui := Gui(), ui.AddPicture(, "HBITMAP:" this.HBitmap.Ptr), ui.Show()),
        }
    }

    DllCall("ReleaseDC", "ptr", _winDc)
    DllCall("ReleaseDC", "ptr", _srcDc)
    DllCall("ReleaseDC", "ptr", _bkgDc)
    DllCall("ReleaseDC", "ptr", _bufDc)
    DllCall("DeleteObject", "ptr", _pen)
    DllCall("DeleteObject", "ptr", _nullClipRgn)
    return res

    OnWM_CLOSE(this, wParam, lParam, msg) {
        if _shown {
            _shown := false
            DllCall("PostQuitMessage", "int", 0)
        }
        return 0
    }

    OnWM_MOUSEMOVE(this, wParam, lParam, msg) {
        mouseX := lParam & 0xffff
        mouseY := lParam >> 16

        if _lButtonDown {
            if mouseX < _lButtonDownX {
                rectX1 := mouseX
                rectX2 := _lButtonDownX + 1
            }
            else {
                rectX1 := _lButtonDownX
                rectX2 := mouseX + 1
            }
            if mouseY < _lButtonDownY {
                rectY1 := mouseY
                rectY2 := _lButtonDownY + 1
            }
            else {
                rectY1 := _lButtonDownY
                rectY2 := mouseY + 1
            }

            selectionRectBuf := RectBuf(rectX1, rectY1, rectX2, rectY2)
            boxRectBuf := RectBuf(rectX1 - _thickness, rectY1 - _thickness, rectX2 + _thickness, rectY2 + _thickness)
            changedRectBuf := RectBuf(rectX1 - _thickness * 2, rectY1 - _thickness * 2, rectX2 + _thickness * 2, rectY2 + _thickness * 2)
            selectionRect := GetRectObj(selectionRectBuf)
            boxRect := GetRectObj(boxRectBuf)
            changedRect := GetRectObj(changedRectBuf)

            intersectRectBuf := Buffer(16)
            DllCall("IntersectRect", "ptr", intersectRectBuf, "ptr", selectionRectBuf, "ptr", _lastSelectionRectBuf)
            intersectRect := GetRectObj(intersectRectBuf)
            DllCall("SelectClipRgn", "ptr", _bufDc, "ptr", _nullClipRgn)
            DllCall("SelectClipRgn", "ptr", _winDc, "ptr", _nullClipRgn)
            DllCall("ExcludeClipRect", "ptr", _bufDc, "int", intersectRect.X1, "int", intersectRect.Y1, "int", intersectRect.X2, "int", intersectRect.Y2)
            DllCall("ExcludeClipRect", "ptr", _winDc, "int", intersectRect.X1, "int", intersectRect.Y1, "int", intersectRect.X2, "int", intersectRect.Y2)

            DllCall("BitBlt", "ptr", _bufDc, "int", _lastChangedRect.X1, "int", _lastChangedRect.Y1, "int", _lastChangedRect.W, "int", _lastChangedRect.H, "ptr", _bkgDc, "int", _lastChangedRect.X1, "int", _lastChangedRect.Y1, "uint", 0x00CC0020)
            DllCall("BitBlt", "ptr", _bufDc, "int", selectionRect.X1, "int", selectionRect.Y1, "int", selectionRect.W, "int", selectionRect.H, "ptr", _srcDc, "int", selectionRect.X1, "int", selectionRect.Y1, "uint", 0x00CC0020)
            DllCall("Rectangle", "ptr", _bufDc, "int", boxRect.X1, "int", boxRect.Y1, "int", boxRect.X1 + boxRect.W, "int", boxRect.Y1 + boxRect.H)
            unionRectBuf := Buffer(16)
            DllCall("UnionRect", "ptr", unionRectBuf, "ptr", _lastChangedRectBuf, "ptr", changedRectBuf)
            unionRect := GetRectObj(unionRectBuf)
            DllCall("BitBlt", "ptr", _winDc, "int", unionRect.X1, "int", unionRect.Y1, "int", unionRect.W, "int", unionRect.H, "ptr", _bufDc, "int", unionRect.X1, "int", unionRect.Y1, "uint", 0x00CC0020)

            _lastSelectionRect := selectionRect
            _lastChangedRect := changedRect
            _lastSelectionRectBuf := selectionRectBuf
            _lastChangedRectBuf := changedRectBuf
        }
        return 0
    }

    OnWM_LBUTTONDOWN(this, wParam, lParam, msg) {
        _lButtonDown := true
        _lButtonDownX := lParam & 0xffff
        _lButtonDownY := lParam >> 16
        DllCall("SetCapture")
        return 0
    }

    OnWM_LBUTTONUP(this, wParam, lParam, msg) {
        _lButtonDown := false
        DllCall("ReleaseCapture")
        OnWM_CLOSE(this, 0, 0, 0)
        return 0
    }

    OnWM_RBUTTONUP(this, wParam, lParam, msg) {
        _canceled := true
        OnWM_CLOSE(this, 0, 0, 0)
        return 0
    }

    OnWM_KEYDOWN(this, wParam, lParam, msg) {
        if (wParam == 0x1B) {
            _canceled := true
            OnWM_CLOSE(this, 0, 0, 0)
        }
        return 0
    }

    OnWM_ERASEBKGND(this, wParam, lParam, msg) {
        DllCall("BitBlt", "ptr", _winDc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight, "ptr", _bkgDc, "int", 0, "int", 0, "uint", 0x00CC0020)
        return 0
    }

    static StartMessageLoop() {
        msg := Buffer(48)
        while DllCall("GetMessageW", "ptr", msg, "ptr", 0, "uint", 0, "uint", 0) {
            DllCall("TranslateMessage", "ptr", msg)
            DllCall("DispatchMessageW", "ptr", msg)
        }
    }

    static RectBuf(x1, y1, x2, y2) {
        buf := Buffer(16)
        NumPut("int", x1, "int", y1, "int", x2, "int", y2, buf)
        return buf
    }

    static GetRectObj(rect) {
        left := NumGet(rect, 0, "int")
        top := NumGet(rect, 4, "int")
        right := NumGet(rect, 8, "int")
        bottom := NumGet(rect, 12, "int")
        return {
            X1: left,
            Y1: top,
            X2: right,
            Y2: bottom,
            W: right - left,
            H: bottom - top
        }
    }
}