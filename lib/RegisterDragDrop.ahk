/*
@description Supports dragging text and hbitmap from other process.

@example
myGui := Gui()
myPic := myGui.AddPicture("w500 h500 Border")
myGui.Show()

dragDropObj := RegisterDragDrop(myPic, OnDrop)
OnDrop(guiObj, data) {
    if data.BMP {
        guiObj.Value := "*w500 *h-1 hbitmap:*" data.BMP.Handle
    }
    else if data.Text {
        guiObj.Text := data.Text
    }
    else if data.Files {
        paths := ""
        for path in data.Files
            paths .= path "`n"
        guiObj.Text := paths
    }
}
*/
RegisterDragDrop(guiObj, callback) {
    hwnd := (guiObj is Gui || guiObj is Gui.Control) ? guiObj.Hwnd : guiObj
    dropTarget := Buffer(9 * A_PtrSize)
    dropTarget._guiObj := guiObj
    dropTarget._callback := callback
    NumPut("ptr", dropTarget.Ptr + A_PtrSize,
        "ptr", CallbackCreate(QueryInterface),
        "ptr", CallbackCreate(AddRef),
        "ptr", CallbackCreate(Release),
        "ptr", CallbackCreate(DragEnter),
        "ptr", CallbackCreate(DragOver),
        "ptr", CallbackCreate(DragLeave),
        "ptr", CallbackCreate(Drop),
        "ptr", ObjPtr(dropTarget),
        dropTarget)
    dropTarget.__Delete := Destruct
    DllCall("ole32\RegisterDragDrop", "ptr", hwnd, "ptr", dropTarget, "hresult")
    return { __Delete: (_) => DllCall("ole32\RevokeDragDrop", "ptr", hwnd, "hresult") }

    static Destruct(this) {
        loop 7
            CallbackFree(NumGet(this, A_PtrSize * A_Index, "ptr"))
    }

    static QueryInterface(this, riid, ppvObject) {
        h := NumGet(riid, 0, "int64")
        l := NumGet(riid, 8, "int64")
        if (h == 0 && l == 0x46000000000000c0) || (h == 0x112 && l == 0x46000000000000c0) {
            NumPut("ptr", this, ppvObject)
            return 0
        }
        return 0x80004002
    }

    static AddRef(this) {
        refCount := ObjAddRef(NumGet(this, 8 * A_PtrSize, "ptr"))
        ;@Debug-Output => AddRef: {refCount}
        return refCount
    }

    static Release(this) {
        refCount := ObjRelease(NumGet(this, 8 * A_PtrSize, "ptr"))
        ;@Debug-Output => Release: {refCount}
        return refCount
    }

    static DragEnter(this, pDataObj, grfKeyState, pt, pdwEffect) {
        NumPut("uint", 1, pdwEffect) ; DROPEFFECT_COPY
        return 0
    }

    static DragOver(this, grfKeyState, pt, pdwEffect) {
        NumPut("uint", 1, pdwEffect) ; DROPEFFECT_COPY
        return 0
    }

    static DragLeave(this) {
        return 0
    }

    static Drop(this, pDataObj, grfKeyState, pt, pdwEffect) {
        effect := 0
        formatEtc := Buffer(A_PtrSize == 8 ? 32 : 20, 0)
        stgMedium := Buffer(A_PtrSize == 8 ? 24 : 12, 0)
        NumPut("uint", 1, formatEtc, A_PtrSize * 2) ; dwAspect = DVASPECT_CONTENT
        NumPut("int", -1, formatEtc, A_PtrSize * 2 + 4) ; lindex = -1

        NumPut("ushort", 13, formatEtc, 0) ; cfFormat = CF_UNICODETEXT
        NumPut("uint", 1, formatEtc, A_PtrSize * 2 + 8) ; tymed = TYMED_HGLOBAL
        hr := ComCall(3, pDataObj, "ptr", formatEtc, "ptr", stgMedium, "int")
        if hr == 0 {
            hGlobal := NumGet(stgMedium, A_PtrSize, "ptr")
            pData := DllCall("GlobalLock", "ptr", hGlobal, "ptr")
            if pData {
                text := StrGet(pData)
            }
            DllCall("GlobalUnlock", "ptr", hGlobal)
            if NumGet(stgMedium, A_PtrSize * 2, "ptr") == 0 {
                DllCall("GlobalFree", "ptr", hGlobal)
            }
            effect := 1 ; DROPEFFECT_COPY
        }

        NumPut("ushort", 15, formatEtc, 0) ; cfFormat = CF_HDROP
        NumPut("uint", 1, formatEtc, A_PtrSize * 2 + 8) ; tymed = TYMED_HGLOBAL
        hr := ComCall(3, pDataObj, "ptr", formatEtc, "ptr", stgMedium, "int")
        if hr == 0 {
            if hDrop := NumGet(stgMedium, A_PtrSize, "ptr") {
                cnt := DllCall("shell32\DragQueryFileW", "ptr", hDrop, "uint", -1, "ptr", 0, "uint", 0, "uint")
                files := []
                loop cnt {
                    if cc := DllCall("shell32\DragQueryFileW", "ptr", hDrop, "uint", A_Index - 1, "ptr", 0, "uint", 0, "uint") {
                        VarSetStrCapacity(&path, cc + 1)
                        if DllCall("shell32\DragQueryFileW", "ptr", hDrop, "uint", A_Index - 1, "str", &path, "uint", cc + 1, "uint") {
                            files.Push(path)
                        }
                    }
                }
                if files.Length == 0 {
                    files := ""
                }
                if NumGet(stgMedium, A_PtrSize * 2, "ptr") == 0 {
                    DllCall("GlobalFree", "ptr", hDrop)
                }
            }
            effect := 1 ; DROPEFFECT_COPY
        }

        NumPut("ushort", 2, formatEtc, 0) ; cfFormat = CF_BITMAP
        NumPut("uint", 16, formatEtc, A_PtrSize * 2 + 8) ; tymed = TYMED_GDI
        hr := ComCall(3, pDataObj, "ptr", formatEtc, "ptr", stgMedium, "int")
        if hr == 0 {
            if hBitmap := NumGet(stgMedium, A_PtrSize, "ptr") {
                if NumGet(stgMedium, A_PtrSize * 2, "ptr") == 0 || hBitmap := DllCall("CopyImage", "ptr", hBitmap, "uint", 0, "int", 0, "int", 0, "uint", 0, "ptr") {
                    bmp := { Handle: hBitmap, __Delete: (_) => DllCall("DeleteObject", "ptr", _.Handle) }
                }
            }
            effect := 1 ; DROPEFFECT_COPY
        }

        if effect {
            dropTarget := ObjFromPtrAddRef(NumGet(this, 8 * A_PtrSize, "ptr"))
            (dropTarget._callback)(dropTarget._guiObj, { Text: text ?? "", BMP: bmp ?? "", Files: files ?? "" })
        }
        NumPut("uint", effect, pdwEffect)
        return 0
    }
}