/************************************************************************
 * @description Save image as file by HBITMAP. Supports bmp, jpg, jpeg, gif, png, tiff.
 * @author Tebayaki
 * @version 1.0
 ***********************************************************************/

/* @example
hbmp := LoadPicture(A_AhkPath)
dumper := BitmapDumper()
dumper.Dump(hbmp, "ahkicon.png")
*/
class BitmapDumper {
    __New() {
        this.__HDll := this.__GdipToken := 0
        if !this.__HDll := DllCall("LoadLibraryW", "str", "Gdiplus.dll", "ptr")
            throw OSError()
        input := Buffer(A_PtrSize == 8 ? 24 : 16, 0)
        NumPut("uint", 1, input) ; GdiplusVersion
        if status := DllCall("Gdiplus\GdiplusStartup", "uptr*", &token := 0, "ptr", input, "ptr*", 0)
            throw Error("Failed to startup gdiplus: " status)
        this.__GdipToken := token
        ; get all image encoders
        this.__Encoders := Map()
        DllCall("Gdiplus\GdipGetImageEncodersSize", "uint*", &numEncoders := 0, "uint*", &size := 0)
        encoderInfos := Buffer(size)
        DllCall("Gdiplus\GdipGetImageEncoders", "uint", numEncoders, "uint", size, "ptr", encoderInfos)
        encoderInfoSize := A_PtrSize == 8 ? 104 : 76
        mimeTypeOffset := 32 + A_PtrSize * 4
        loop numEncoders {
            clsid := Buffer(16)
            NumPut("int64", NumGet(encoderInfos, (A_Index - 1) * encoderInfoSize, "int64"), clsid, 0)
            NumPut("int64", NumGet(encoderInfos, (A_Index - 1) * encoderInfoSize + 8, "int64"), clsid, 8)
            this.__Encoders[StrGet(NumGet(encoderInfos, mimeTypeOffset + (A_Index - 1) * encoderInfoSize, "ptr") + 12)] := clsid
        }
    }
    __Delete() {
        if this.__GdipToken
            DllCall("Gdiplus\GdiplusShutdown", "uptr", this.__GdipToken)
        if this.__HDll
            DllCall("FreeLibrary", "ptr", this.__HDll)
    }
    ; params is unused for now
    Dump(hBitmap, path, mime := unset, params := unset, overwrite := false) {
        if !hBitmap
            throw Error("Invalid bitmap handle")
        if !overwrite && InStr(FileExist(path), "A")
            throw Error("File already exists")
        if !IsSet(mime)
            SplitPath(path, , , &mime)
        if mime = "jpg"
            mime := "jpeg"
        if !this.__Encoders.Has(mime)
            throw Error("The specified encoder was not found")
        encoderClsid := this.__Encoders[mime]
        if status := DllCall("Gdiplus\GdipCreateBitmapFromHBITMAP", "ptr", hBitmap, "uint", 0, "ptr*", &bmp := 0)
            throw Error("Failed to create bitmap: " status)
        if DllCall("Gdiplus\GdipSaveImageToFile", "ptr", bmp, "str", path, "ptr", encoderClsid, "ptr", 0) {
            DllCall("Gdiplus\GdipDisposeImage", "ptr", bmp)
            throw Error("Failed to save image: " status)
        }
        DllCall("Gdiplus\GdipDisposeImage", "ptr", bmp)
    }
}