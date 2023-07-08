/*
@Example
ocr := RapidOcrOnnx()
param := RapidOcrParam.Default
result := ocr.DetectFile("C:\Users\Jensen\Desktop\Snipaste_2023-07-08_21-50-03.jpg")
for block in result {
    MsgBox "x1: " block.Points[1].X "`ty1: " block.Points[1].Y "`n" .
    "x2: " block.Points[2].X "`ty2: " block.Points[2].Y "`n" .
    "x3: " block.Points[3].X "`ty3: " block.Points[3].Y "`n" .
    "x4: " block.Points[4].X "`ty4: " block.Points[4].Y "`n" .
    "Text: " block.Text
}
MsgBox result.ToString()
*/
class RapidOcrOnnx {
    static DllPath := A_LineFile "\..\RapidOcrOnnx.dll"
    static __detectionProc := CallbackCreate((pBox, pText, pBlocks) => (
        ObjFromPtrAddRef(pBlocks).Push({
            Points: [{
                X: NumGet(pBox, 0, "int"),
                Y: NumGet(pBox, 4, "int")
            }, {
                X: NumGet(pBox, 8, "int"),
                Y: NumGet(pBox, 12, "int")
            }, {
                X: NumGet(pBox, 16, "int"),
                Y: NumGet(pBox, 20, "int")
            }, {
                X: NumGet(pBox, 24, "int"),
                Y: NumGet(pBox, 28, "int")
            },
                ],
            Text: StrGet(pText, "utf-8")
        }), true), "Fast")

    __libHandle := 0
    __ocrHandle := 0

    __New(detPath := A_LineFile "\..\models\ch_PP-OCRv3_det_infer.onnx",
        clsPath := A_LineFile "\..\models\ch_ppocr_mobile_v2.0_cls_infer.onnx",
        recPath := A_LineFile "\..\models\ch_PP-OCRv3_rec_infer.onnx",
        keyPath := A_LineFile "\..\models\ppocr_keys_v1.txt",
        numOfThreads := 8) {
        if !this.__libHandle := DllCall("LoadLibraryW", "str", RapidOcrOnnx.DllPath, "ptr") {
            throw OSError()
        }
        this.__ocrHandle := DllCall("RapidOcrOnnx\OcrInit", "astr", detPath, "astr", clsPath, "astr", recPath, "astr", keyPath, "int", numOfThreads)
    }

    __Delete() {
        if (this.__ocrHandle) {
            DllCall("RapidOcrOnnx\OcrDestroy", "ptr", this.__ocrHandle)
        }
        if (this.__libHandle) {
            DllCall("FreeLibrary", "ptr", this.__libHandle)
        }
    }

    DetectFile(filePath, param := RapidOcrParam.Default) {
        blocks := RapidOcrResult()
        DllCall("RapidOcrOnnx\OcrDetectFile", "ptr", this.__ocrHandle, "astr", filePath, "ptr", param, "ptr", RapidOcrOnnx.__detectionProc, "ptr", ObjPtr(blocks))
        return blocks
    }

    DetectBitmapData(bitmapData, param := RapidOcrParam.Default) {
        blocks := RapidOcrResult()
        DllCall("RapidOcrOnnx\OcrDetectBitmapData", "ptr", this.__ocrHandle, "ptr", bitmapData, "ptr", param, "ptr", RapidOcrOnnx.__detectionProc, "ptr", ObjPtr(blocks))
        return blocks
    }

    DetectHBitmap(hBitmap, param := RapidOcrParam.Default) {
        bitmap := Buffer(32, 0)
        DllCall("GetObjectW", "ptr", hBitmap, "int", bitmap.Size, "ptr", bitmap)
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
        NumPut("ptr", data.Ptr, "uint", stride, "int", width, "int", height, "int", pixelBytes, bitmapData)
        return this.DetectBitmapData(bitmapData, param)
    }
}

class RapidOcrResult extends Array {
    ToString() {
        text := this.Length && this[1].Text
        loop this.Length - 1
            text .= "`n" this[A_Index + 1].Text
        return text
    }
}

class RapidOcrParam extends Buffer {
    static Default => this(50, 1024, 0.6, 0.3, 2.0, true, true)

    __New(padding, maxSideLen, boxScoreThresh, boxThresh, unClipRatio, doAngle, mostAngle) {
        super.__New(28)
        p := NumPut("int", padding, "int", maxSideLen, "float", boxScoreThresh, "float", boxThresh, "float", unClipRatio, "int", doAngle, "int", mostAngle, this)
    }
    Padding {
        get => NumGet(this, 0, "int")
        set => NumPut("int", value, this)
    }
    MaxSideLen {
        get => NumGet(this, 4, "int")
        set => NumPut("int", value, this, 4)
    }
    BoxScoreThresh {
        get => NumGet(this, 8, "float")
        set => NumPut("float", value, this, 8)
    }
    BoxThresh {
        get => NumGet(this, 12, "float")
        set => NumPut("float", value, this, 12)
    }
    UnClipRatio {
        get => NumGet(this, 16, "float")
        set => NumPut("float", value, this, 16)
    }
    DoAngle {
        get => NumGet(this, 20, "int")
        set => NumPut("int", value, this, 20)
    }
    MostAngle {
        get => NumGet(this, 24, "int")
        set => NumPut("int", value, this, 24)
    }
}