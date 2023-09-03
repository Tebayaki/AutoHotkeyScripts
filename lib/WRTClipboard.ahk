#Requires AutoHotkey 2.0
/************************************************************************
 * @description Windows runtime clipboard class wrapper for ahk
 * @author Tebayaki
 * @version 1.0
 ***********************************************************************/

/* @example
; Read all clipboard history text, html and save bitmap
for item in WRTClipboard.History {
    if item.Contains(WRTClipboard.TextFormatId) ; Check clipboard content format
        MsgBox item.GetText()
    if item.Contains(WRTClipboard.HtmlFormatId)
        MsgBox item.GetHtml()
    if item.Contains(WRTClipboard.BitmapFormatId) {
        name := item.Id ".bmp"
        if !FileExist(name) {
            bmp := item.GetBitmap()
            FileAppend(bmp, name, "RAW")
        }
    }
}

; Get file paths from current clipboard
if WRTClipboard.Contains(WRTClipboard.FilesFormatId) {
    filePaths := WRTClipboard.GetFiles()
    str := ""
    for path in filePaths {
        str .= path "`n"
    }
    MsgBox str
}

; Put some files to current clipboard
files := [A_AhkPath, A_ScriptFullPath]
WRTClipboard.SetFiles(files)
WRTClipboard.Flush()

; Set last history item as current
history := WRTClipboard.History
len := history.Length
if len > 0 {
    WRTClipboard.ResetHistoryItem(history[len])
}

; Clear history
WRTClipboard.ClearHistory()
*/
class WRTClipboard {
    static __New() {
        this.IClipboardStatic := WRTClipboardNS.GetFactory(WRTClipboardNS.IClipboardStatic)
        this.IClipboardStatic2 := WRTClipboardNS.GetFactory(WRTClipboardNS.IClipboardStatic2)
        this.IDataPackageView := this.IClipboardStatic.GetContent()
        standardDataFormatsStatic := WRTClipboardNS.GetFactory(WRTClipboardNS.IStandardDataFormatsStaric)
        this.TextFormatId := standardDataFormatsStatic.Text
        this.HtmlFormatId := standardDataFormatsStatic.Html
        this.RtfFormatId := standardDataFormatsStatic.Rtf
        this.BitmapFormatId := standardDataFormatsStatic.Bitmap
        this.FilesFormatId := standardDataFormatsStatic.StorageItems
    }

    static AvailableFormats => [this.IDataPackageView.AvailableFormats*]

    static IsHistoryEnabled => this.IClipboardStatic2.IsHistoryEnabled()

    static IsRoamingEnabled => this.IClipboardStatic2.IsRoamingEnabled()

    static History {
        get {
            result := WRTClipboardNS.await(this.IClipboardStatic2.GetHistoryItemsAsync())
            history := [result.Items*]
            for item in history
                history[A_Index] := WRTClipboardHistoryItem(item)
            return history
        }
    }

    static Clear() => this.IClipboardStatic.Clear()

    static Flush() => this.IClipboardStatic.Flush()

    static Contains(formatId) => this.IDataPackageView.Contains(formatId)

    static GetText(formatId?) {
        if IsSet(formatId)
            return WRTClipboardNS.await(this.IDataPackageView.GetCustomTextAsync(formatId))
        else
            return WRTClipboardNS.await(this.IDataPackageView.GetTextAsync())
    }

    static GetHtml() => WRTClipboardNS.await(this.IDataPackageView.GetHtmlFormatAsync())

    static GetRtf() => WRTClipboardNS.await(this.IDataPackageView.GetRtfAsync())

    static GetBitmap() {
        streamRef := WRTClipboardNS.await(this.IDataPackageView.GetBitmapAsync())
        streamWithContentType := WRTClipboardNS.await(streamRef.OpenReadAsync())
        stream := streamWithContentType.QueryInterface(WRTClipboardNS.IRandomAccessStream)
        size := stream.Size
        inputStream := stream.GetInputStreamAt(0)
        bufferFactory := WRTClipboardNS.GetFactory(WRTClipboardNS.IBufferFactory)
        buf := bufferFactory.Create(size)
        WRTClipboardNS.await(inputStream.ReadAsync(buf, size, 0))
        iBufferByteAccess := buf.QueryInterface(WRTClipboardNS.IBufferByteAccess)
        ptr := iBufferByteAccess.Buffer()
        return { _: iBufferByteAccess, Ptr: ptr, Size: size }
    }

    static GetFiles() {
        items := [WRTClipboardNS.await(this.IDataPackageView.GetStorageItemsAsync())*]
        for item in items
            items[A_Index] := item.Path
        return items
    }

    static SetText(value, isAllowedInHistory?, isRoamable?) {
        dataPackage := WRTClipboardNS.CreateObject(WRTClipboardNS.IDataPackage)
        dataPackage.SetText(value)
        this.SetContent(dataPackage, isAllowedInHistory ?? unset, isRoamable ?? unset)
    }

    static SetHtml(value, isAllowedInHistory?, isRoamable?) {
        dataPackage := WRTClipboardNS.CreateObject(WRTClipboardNS.IDataPackage)
        dataPackage.SetHtml(value)
        this.SetContent(dataPackage, isAllowedInHistory ?? unset, isRoamable ?? unset)
    }

    static SetRtf(value, isAllowedInHistory?, isRoamable?) {
        dataPackage := WRTClipboardNS.CreateObject(WRTClipboardNS.IDataPackage)
        dataPackage.SetRtf(value)
        this.SetContent(dataPackage, isAllowedInHistory ?? unset, isRoamable ?? unset)
    }

    static SetBitmap(value, isAllowedInHistory?, isRoamable?) {
        bufferFactory := WRTClipboardNS.GetFactory(WRTClipboardNS.IBufferFactory)
        buf := bufferFactory.Create(value.Size)
        iBufferByteAccess := buf.QueryInterface(WRTClipboardNS.IBufferByteAccess)
        ptr := iBufferByteAccess.Buffer()
        DllCall("RtlCopyMemory", "ptr", ptr, "ptr", value, "uptr", value.Size)
        stream := WRTClipboardNS.CreateObject(WRTClipboardNS.InMemoryRandomAccessStream)
        iDataWriterFactory := WRTClipboardNS.GetFactory(WRTClipboardNS.IDataWriterFactory)
        dataWriter := iDataWriterFactory.CreateDataWriter(stream)
        dataWriter.WriteBuffer(buf, 0, value.Size)
        WRTClipboardNS.await(dataWriter.StoreAsync())
        streamRefStatic := WRTClipboardNS.GetFactory(WRTClipboardNS.IRandomAccessStreamReferenceStatics)
        streamRef := streamRefStatic.CreateFromStream(stream)
        dataPackage := WRTClipboardNS.CreateObject(WRTClipboardNS.IDataPackage)
        dataPackage.SetBitmap(streamRef)
        dataWriter.DetachStream()
        this.SetContent(dataPackage, isAllowedInHistory ?? unset, isRoamable ?? unset)
    }

    static SetFiles(paths, readonly := true, isAllowedInHistory?, isRoamable?) {
        arr := []
        storageFileStatic := WRTClipboardNS.GetFactory(WRTClipboardNS.IStorageFileStatics)
        storageFolderStatic := WRTClipboardNS.GetFactory(WRTClipboardNS.IStorageFolderStatics)
        for path in paths {
            attr := FileExist(path)
            if !attr
                continue
            else if InStr(attr, "D")
                arr.Push(WRTClipboardNS.await(storageFolderStatic.GetFolderFromPathAsync(path)))
            else
                arr.Push(WRTClipboardNS.await(storageFileStatic.GetFileFromPathAsync(path)))
        }
        i := 1
        iIterable := Buffer(8 * A_PtrSize)
        iIterator := Buffer(11 * A_PtrSize)
        NumPut("ptr", iIterable.Ptr + A_PtrSize,
            "ptr", noimpl := CallbackCreate(() => 0x80004001),
                "ptr", noimpl,
                "ptr", release := CallbackCreate(() => 0),
                    "ptr", noimpl, "ptr", noimpl, "ptr", noimpl,
                    "ptr", first := CallbackCreate((_, ppv) => (NumPut("ptr", iIterator.Ptr, ppv), 0)),
                        iIterable)
        NumPut("ptr", iIterator.Ptr + A_PtrSize,
            "ptr", noimpl, "ptr", noimpl,
            "ptr", release,
            "ptr", noimpl, "ptr", noimpl, "ptr", noimpl,
            "ptr", current := CallbackCreate((_, ppv) => (NumPut("ptr", (ObjAddRef(ptr := arr[i].Ptr), ptr), ppv), 0)),
                "ptr", hasCurrent := CallbackCreate((_, ppv) => (NumPut("int", i <= arr.Length, ppv), 0)),
                    "ptr", moveNext := CallbackCreate((_, ppv) => (NumPut("int", ++i <= arr.Length, ppv), 0)),
                        "ptr", noimpl,
                        iIterator)
        dataPackage := WRTClipboardNS.CreateObject(WRTClipboardNS.IDataPackage)
        dataPackage.SetStorageItems(iIterable, readonly)
        for cb in [noimpl, release, first, current, hasCurrent, moveNext]
            CallbackFree(cb)
        this.SetContent(dataPackage, isAllowedInHistory ?? unset, isRoamable ?? unset)
    }

    static SetContent(content, isAllowedInHistory?, isRoamable?) {
        if IsSet(isAllowedInHistory) || IsSet(isRoamable) {
            options := WRTClipboardNS.CreateObject(WRTClipboardNS.IClipboardContentOptions)
            options.isAllowedInHistory := isAllowedInHistory ?? this.IsHistoryEnabled
            options.isRoamable := isRoamable ?? this.IsRoamingEnabled
            return this.IClipboardStatic2.SetContentWithOptions(content, options)
        }
        this.IClipboardStatic.SetContent(content)
        return true
    }

    static ClearHistory() => this.IClipboardStatic2.ClearHistory()

    static ResetHistoryItem(item) => this.IClipboardStatic2.SetHistoryItemAsContent(item.IClipboardHistoryItem)
}

class WRTClipboardHistoryItem {
    __New(obj) {
        this.IClipboardHistoryItem := obj
        this.IDataPackageView := obj.Content
    }

    AvailableFormats => WRTClipboard.GetOwnPropDesc("AvailableFormats").get.Call(this)

    Id => this.IClipboardHistoryItem.Id

    TimeStamp => this.IClipboardHistoryItem.TimeStamp

    Contains(formatId) => WRTClipboard.Contains.Call(this, formatId)

    GetText(formatId?) => WRTClipboard.GetText.Call(this, formatId ?? unset)

    GetHtml() => WRTClipboard.GetHtml.Call(this)

    GetRtf() => WRTClipboard.GetRtf.Call(this)

    GetBitmap() => WRTClipboard.GetBitmap.Call(this)

    GetFiles() => WRTClipboard.GetFiles.Call(this)
}

class WRTClipboardNS {
    static await(operation) {
        asyncInfo := operation.QueryInterface(WRTClipboardNS.IAsyncInfo)
        loop {
            switch asyncInfo.Status {
                case 0: Sleep(1)
                case 1: break
                ; case 2: throw Error("The operation was canceled.")
                ; case 3: throw Error("The operation has encountered an error.")
                default: return
            }
        }
        return operation.GetResult()
    }

    static GUIDFromString(str) {
        DllCall("ole32\CLSIDFromString", "wstr", str, "ptr", guid := Buffer(16), "hresult")
        return guid
    }

    static StringFromGUID(guid) {
        DllCall('ole32\StringFromGUID2', "ptr", guid, "str", str := "{00000000-0000-0000-0000-000000000000}", "int", 39)
        return str
    }

    static GetFactory(cls) {
        DllCall("Combase\RoGetActivationFactory", "ptr", WRTClipboardNS.HString.Create(cls.ClassName), "ptr", WRTClipboardNS.GUIDFromString(cls.UUID), "ptr*", result := cls(0), "hresult")
        return result
    }

    static CreateObject(cls) {
        DllCall("Combase\RoActivateInstance", "ptr", WRTClipboardNS.HString.Create(cls.ClassName), "ptr*", result := cls(0), "hresult")
        return result
    }

    class HString {
        static Create(str) => (DllCall("Combase\WindowsCreateString", "str", str, "uint", StrLen(str), "ptr*", hstr := this(0), "hresult"), hstr)

        __New(ptr) => this.Ptr := ptr

        __Delete() => DllCall("Combase\WindowsDeleteString", "ptr", this, "hresult")

        ToString(encoding := "utf-16") => this.Ptr ? StrGet(this.Ptr + 28, encoding) : ""
    }

    class IUnknown {
        __New(ptr) => this.Ptr := ptr

        __Delete() => this.Ptr && ObjRelease(this.Ptr)

        QueryInterface(interface) {
            temp := ComObjQuery(this.Ptr, interface.UUID)
            ObjAddRef(temp.Ptr)
            return interface(temp.Ptr)
        }
    }

    class IClipboardStatic extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.ApplicationModel.DataTransfer.Clipboard"
        static UUID := "{C627E291-34E2-4963-8EED-93CBB0EA3D70}"

        GetContent() => (ComCall(6, this, "ptr*", result := WRTClipboardNS.IDataPackageView(0)), result)

        SetContent(content) => ComCall(7, this, "ptr", content)

        Flush() => ComCall(8, this)

        Clear() => ComCall(9, this)
    }

    class IClipboardStatic2 extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.ApplicationModel.DataTransfer.Clipboard"
        static UUID := "{D2AC1B6A-D29F-554B-B303-F0452345FE02}"

        GetHistoryItemsAsync() => (ComCall(6, this, "ptr*", operation := WRTClipboardNS.IAsyncOperation_IClipboardHistoryItemsResult(0)), operation)

        ClearHistory() => (ComCall(7, this, "uchar*", &result := 0), result)

        DeleteItemFromHistory(item) => (ComCall(8, this, "ptr", item, "uchar*", &result := 0), result)

        SetHistoryItemAsContent(item) => (ComCall(9, this, "ptr", item, "uchar*", &result := 0), result)

        IsHistoryEnabled() => (ComCall(10, this, "uchar*", &result := 0), result)

        IsRoamingEnabled() => (ComCall(11, this, "uchar*", &result := 0), result)

        SetContentWithOptions(content, options) => (ComCall(12, this, "ptr", content, "ptr", options, "uchar*", &result := 0), result)
    }

    class IClipboardHistoryItemsResult extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.ApplicationModel.DataTransfer.ClipboardHistoryItemsResult"
        static UUID := "{E6DFDEE6-0EE2-52E3-852B-F295DB65939A}"

        Items => (ComCall(7, this, "ptr*", result := WRTClipboardNS.IVectorView_IClipboardHistoryItem(0)), result)
    }

    class IClipboardHistoryItem extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.ApplicationModel.DataTransfer.ClipboardHistoryItem"
        static UUID := "{0173BD8A-AFFF-5C50-AB92-3D19F481EC58}"

        Id => (ComCall(6, this, "ptr*", value := WRTClipboardNS.HString(0)), value.ToString())

        TimeStamp => (ComCall(7, this, "uint64*", &value := 0), value)

        Content => (ComCall(8, this, "ptr*", value := WRTClipboardNS.IDataPackageView(0)), value)
    }

    class IClipboardContentOptions extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.ApplicationModel.DataTransfer.ClipboardContentOptions"

        IsRoamable {
            get => (ComCall(6, this, "uchar*", &value := 0), value)
            set => ComCall(7, this, "uchar", value)
        }

        IsAllowedInHistory {
            get => (ComCall(8, this, "uchar*", &value := 0), value)
            set => ComCall(9, this, "uchar", value)
        }
    }

    class IDataPackage extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.ApplicationModel.DataTransfer.DataPackage"

        GetView() => (ComCall(6, this.IDataPackage, "ptr*", result := WRTClipboardNS.IDataPackageView(0)), result)

        SetText(value) => ComCall(16, this, "ptr", WRTClipboardNS.HString.Create(value))

        SetHtml(value) => ComCall(18, this, "ptr", WRTClipboardNS.HString.Create(value))

        SetRtf(value) => ComCall(20, this, "ptr", WRTClipboardNS.HString.Create(value))

        SetBitmap(value) => ComCall(21, this, "ptr", value)

        SetStorageItemsReadOnly(value) => ComCall(22, this, "ptr", value)

        SetStorageItems(value, readonly) => ComCall(23, this, "ptr", value, "uchar", readonly)
    }

    class IDataPackageView extends WRTClipboardNS.IUnknown {
        AvailableFormats => (ComCall(9, this, "ptr*", formatIds := WRTClipboardNS.IVectorView_HString(0)), formatIds)

        Contains(formatId) => (ComCall(10, this, "ptr", WRTClipboardNS.HString.Create(formatId), "uchar*", &value := 0), value)

        GetCustomTextAsync(formatId) => (ComCall(13, this, "ptr", WRTClipboardNS.HString.Create(formatId), "ptr*", operation := WRTClipboardNS.IAsyncOperation_HString(0)), operation)

        GetTextAsync() => (ComCall(12, this, "ptr*", operation := WRTClipboardNS.IAsyncOperation_HString(0)), operation)

        GetHtmlFormatAsync() => (ComCall(15, this, "ptr*", operation := WRTClipboardNS.IAsyncOperation_HString(0)), operation)

        GetRtfAsync() => (ComCall(17, this, "ptr*", operation := WRTClipboardNS.IAsyncOperation_HString(0)), operation)

        GetBitmapAsync() => (ComCall(18, this, "ptr*", operation := WRTClipboardNS.IAsyncOperation_IRandomAccessStreamReference(0)), operation)

        GetStorageItemsAsync() => (ComCall(19, this, "ptr*", operation := WRTClipboardNS.IAsyncOperation_IVectorView_IStorageItem(0)), operation)
    }

    class IStandardDataFormatsStaric extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.ApplicationModel.DataTransfer.StandardDataFormats"
        static UUID := "{7ED681A1-A880-40C9-B4ED-0BEE1E15F549}"

        Text => (ComCall(6, this, "ptr*", value := WRTClipboardNS.HString(0)), value.ToString())

        Html => (ComCall(8, this, "ptr*", value := WRTClipboardNS.HString(0)), value.ToString())

        Rtf => (ComCall(9, this, "ptr*", value := WRTClipboardNS.HString(0)), value.ToString())

        Bitmap => (ComCall(10, this, "ptr*", value := WRTClipboardNS.HString(0)), value.ToString())

        StorageItems => (ComCall(11, this, "ptr*", value := WRTClipboardNS.HString(0)), value.ToString())
    }

    class InMemoryRandomAccessStream extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.Storage.Streams.InMemoryRandomAccessStream"
    }

    class IRandomAccessStreamWithContentType extends WRTClipboardNS.IUnknown {
    }

    class IRandomAccessStream extends WRTClipboardNS.IUnknown {
        static UUID := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"
        Size => (ComCall(6, this, "uint64*", &value := 0), value)

        GetInputStreamAt(position) => (ComCall(8, this, "uint64", position, "ptr*", stream := WRTClipboardNS.IInputStream(0)), stream)
    }

    class IRandomAccessStreamReferenceStatics extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.Storage.Streams.RandomAccessStreamReference"
        static UUID := "{857309DC-3FBF-4E7D-986F-EF3B1A07A964}"

        CreateFromStream(stream) => (ComCall(8, this, "ptr", stream, "ptr*", streamRef := WRTClipboardNS.IRandomAccessStreamReference(0)), streamRef)
    }

    class IRandomAccessStreamReference extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.Storage.Streams.RandomAccessStreamReference"
        static UUID := "{33EE3134-1DD6-4E3A-8067-D1C162E8642B}"

        OpenReadAsync() => (ComCall(6, this, "ptr*", result := WRTClipboardNS.IAsyncOperation_IRamdomAccessStreamWithContentType(0)), result)
    }

    class IDataWriterFactory extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.Storage.Streams.DataWriter"
        static UUID := "{338C67C2-8B84-4C2B-9C50-7B8767847A1F}"

        CreateDataWriter(outputStream) => (ComCall(6, this, "ptr", outputStream, "ptr*", dataWriter := WRTClipboardNS.IDataWriter(0)), dataWriter)
    }

    class IDataWriter extends WRTClipboardNS.IUnknown {
        WriteBuffer(buf, start, count) => ComCall(14, this, "ptr", buf, "uint", start, "uint", count)

        StoreAsync() => (ComCall(29, this, "ptr*", operation := WRTClipboardNS.IAsyncOperation_UInt32(0)), operation)

        DetachStream() => (ComCall(32, this, "ptr*", stream := WRTClipboardNS.IInputStream(0)), stream)
    }

    class IInputStream extends WRTClipboardNS.IUnknown {
        ReadAsync(buf, count, options) => (ComCall(6, this, "ptr", buf, "uint", count, "uint", options, "ptr*", operation := WRTClipboardNS.IAsyncOperationWithProgress_IBuffer_UInt32(0)), operation)
    }

    class IBufferFactory extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.Storage.Streams.Buffer"
        static UUID := "{71AF914D-C10F-484B-BC50-14BC623B3A27}"

        Create(capacity) => (ComCall(6, this, "uint", capacity, "ptr*", value := WRTClipboardNS.IBuffer(0)), value)
    }

    class IBuffer extends WRTClipboardNS.IUnknown {
    }

    class IBufferByteAccess extends WRTClipboardNS.IUnknown {
        static UUID := "{905A0FEF-BC53-11DF-8C49-001E4FC686DA}"

        Buffer() => (ComCall(3, this, "ptr*", &pData := 0), pData)
    }

    class IVectorView_IClipboardHistoryItem extends WRTClipboardNS.IUnknown {
        Size => (ComCall(7, this, "uint*", &result := 0), result)

        GetAt(index) => (ComCall(6, this, "uint", index, "ptr*", result := WRTClipboardNS.IClipboardHistoryItem(0)), result)
        __Enum(_) {
            i := 0
            return (&v) => i < this.Size ? (v := this.GetAt(i++), true) : false
        }
    }

    class IVectorView_HString extends WRTClipboardNS.IUnknown {
        Size => (ComCall(7, this, "uint*", &result := 0), result)

        GetAt(index) => (ComCall(6, this, "uint", index, "ptr*", result := WRTClipboardNS.HString(0)), result.ToString())
        __Enum(_) {
            i := 0
            return (&v) => i < this.Size ? (v := this.GetAt(i++), true) : false
        }
    }

    class IVectorView_IStorageItem extends WRTClipboardNS.IUnknown {
        Size => (ComCall(7, this, "uint*", &result := 0), result)

        GetAt(index) => (ComCall(6, this, "uint", index, "ptr*", result := WRTClipboardNS.IStorageItem(0)), result)
        __Enum(_) {
            i := 0
            return (&v) => i < this.Size ? (v := this.GetAt(i++), true) : false
        }
    }

    class IAsyncInfo extends WRTClipboardNS.IUnknown {
        static UUID := "{00000036-0000-0000-C000-000000000046}"

        Status => (ComCall(7, this, "uint*", &status := 0), status)
    }

    class IAsyncOperation_IClipboardHistoryItemsResult extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "ptr*", result := WRTClipboardNS.IClipboardHistoryItemsResult(0)), result)
    }

    class IAsyncOperation_IVectorView_IStorageItem extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "ptr*", result := WRTClipboardNS.IVectorView_IStorageItem(0)), result)
    }

    class IAsyncOperation_IRandomAccessStreamReference extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "ptr*", result := WRTClipboardNS.IRandomAccessStreamReference(0)), result)
    }

    class IAsyncOperation_HString extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "ptr*", result := WRTClipboardNS.HString(0)), result.ToString())
    }

    class IAsyncOperation_IRamdomAccessStreamWithContentType extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "ptr*", result := WRTClipboardNS.IRandomAccessStreamWithContentType(0)), result)
    }

    class IAsyncOperation_UInt32 extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "uint*", &result := 0), result)
    }

    class IAsyncOperation_StorageFolder extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "ptr*", result := WRTClipboardNS.IStorageFolder(0)), result)
    }

    class IAsyncOperation_StorageFile extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(8, this, "ptr*", result := WRTClipboardNS.IStorageFile(0)), result)
    }

    class IAsyncOperationWithProgress_IBuffer_UInt32 extends WRTClipboardNS.IUnknown {
        GetResult() => (ComCall(10, this, "ptr*", result := WRTClipboardNS.IBuffer(0)), result)
    }

    class IStorageFolderStatics extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.Storage.StorageFolder"
        static UUID := "{08F327FF-85D5-48B9-AEE9-28511E339F9F}"

        GetFolderFromPathAsync(path) => (ComCall(6, this, "ptr", WRTClipboardNS.HString.Create(path), "ptr*", operation := WRTClipboardNS.IAsyncOperation_StorageFolder(0)), operation)
    }

    class IStorageFileStatics extends WRTClipboardNS.IUnknown {
        static ClassName := "Windows.Storage.StorageFile"
        static UUID := "{5984C710-DAF2-43C8-8BB4-A4D3EACFD03F}"

        GetFileFromPathAsync(path) => (ComCall(6, this, "ptr", WRTClipboardNS.HString.Create(path), "ptr*", operation := WRTClipboardNS.IAsyncOperation_StorageFile(0)), operation)
    }

    class IStorageItem extends WRTClipboardNS.IUnknown {
        Path => (ComCall(12, this, "ptr*", value := WRTClipboardNS.HString(0)), value.ToString())
    }

    class IStorageFolder extends WRTClipboardNS.IUnknown {
    }

    class IStorageFile extends WRTClipboardNS.IUnknown {
    }
}