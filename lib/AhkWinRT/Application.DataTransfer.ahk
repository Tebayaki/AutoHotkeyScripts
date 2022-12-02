#Include "Foundation.ahk"
#Include "Foundation.Collections.ahk"
#Include "Storage.Streams.ahk"

class IClipboardStatic extends IInspectable {
    static ClassName        := "Windows.ApplicationModel.DataTransfer.Clipboard"
    static IId := "{C627E291-34E2-4963-8EED-93CBB0EA3D70}"
    GetContent()        => (ComCall(6, this, "ptr*", &result := 0), IDataPackageView(result))
    SetContent(content) => ComCall(7, this, "ptr", content)
    Flush()             => ComCall(8, this)
    Clear()             => ComCall(9, this)
}

class IClipboardStatic2 extends IInspectable {
    static ClassName        := "Windows.ApplicationModel.DataTransfer.Clipboard"
    static IId := "{D2AC1B6A-D29F-554B-B303-F0452345FE02}"
    GetHistoryItemsAsync()                  => (ComCall(6, this, "ptr*", &operation := 0), IAsyncOperation_TResult(IClipboardHistoryItemsResult, operation))
    ClearHistory()                          => (ComCall(7, this, "char*", &result := 0), result)
    DeleteItemFromHistory(item)             => (ComCall(8, this, "ptr", item, "char*", &result := 0), result)
    SetHistoryItemAsContent(item)           => (ComCall(9, this, "ptr", item, "char*", &result := 0), result)
    IsHistoryEnabled()                      => (ComCall(10, this, "char*", &result := 0), result)
    IsRoamingEnabled()                      => (ComCall(11, this, "char*", &result := 0), result)
    SetContentWithOptions(content, options) => (ComCall(12, this, "ptr", content, "ptr", options, "char*", &result := 0), result)
}

class IClipboardHistoryItemsResult extends IInspectable {
    static IId := "{E6DFDEE6-0EE2-52E3-852B-F295DB65939A}"
    Items        => (ComCall(7, this, "ptr*", &items := 0), IVectorView_T(IClipboardHistoryItem, items))
}

class IClipboardHistoryItem extends IInspectable {
    static IId := "{0173BD8A-AFFF-5C50-AB92-3D19F481EC58}"
    Id           => (ComCall(6, this, "ptr*", &id := 0), HString(id))
    Timestamp    => (ComCall(7, this, "uint64*", &time := 0), time)
    Content      => (ComCall(8, this, "ptr*", &pDataPackageView := 0), IDataPackageView(pDataPackageView))
}

class IClipboardContentOptions extends IInspectable {
    static IId := "{E888A98C-AD4B-5447-A056-AB3556276D2B}"
    IsRoamable {
        get => (ComCall(6, this, "char*", &result := 0), result)
        set => ComCall(7, this, "char", value)
    }
    IsAllowedInHistory {
        get => (ComCall(8, this, "char*", &result := 0), result)
        set => ComCall(9, this, "char", value)
    }
    RoamingFormats => (ComCall(10, this, "ptr*", &result := 0), IVector_T(HString, result))
    HistoryFormats => (ComCall(11, this, "ptr*", &result := 0), IVector_T(HString, result))
}

class IDataPackageView extends IInspectable {
    static IId := "{7B840471-5900-4D85-A90B-10CB85FE3552}"
    AvailableFormats                => (ComCall(9, this, "ptr*", &pVectorView := 0), IVectorView_T(HString, pVectorView))
    Contains(standardFormat)        => (ComCall(10, this, "ptr", standardFormat, "char*", &bContains := 0), bContains)
    GetTextAsync()                  => (ComCall(12, this, "ptr*", &pOperation := 0), IAsyncOperation_TResult(HString, pOperation))
    GetCustomTextAsync(formatId)    => (ComCall(13, this, "ptr", formatId, "ptr*", &pOperation := 0), IAsyncOperation_TResult(HString, pOperation))
    GetHtmlFormatAsync()            => (ComCall(15, this, "ptr*", &pOperation := 0), IAsyncOperation_TResult(HString, pOperation))
    GetRtfAsync()                   => (ComCall(17, this, "ptr*", &pOperation := 0), IAsyncOperation_TResult(HString, pOperation))
    GetBitmapAsync()                => (ComCall(18, this, "ptr*", &pOperation := 0), IAsyncOperation_TResult(IRandomAccessStreamReference, pOperation))
}

class IDataPackage extends IInspectable {
    static ClassName := "Windows.ApplicationModel.DataTransfer.DataPackage"
    static IId := "{61EBF5C7-EFEA-4346-9554-981D7E198FFE}"
    GetView()        => (ComCall(6, this, "ptr*", &result := 0), IDataPackageView(result))
    SetText(value)   => ComCall(16, this, "ptr", value)
    SetBitmap(value) => ComCall(21, this, "ptr", value)
}

class IStandardDataFormatsStatics extends IInspectable {
    static ClassName := "Windows.ApplicationModel.DataTransfer.StandardDataFormats"
    static IId := "{7ED681A1-A880-40C9-B4ED-0BEE1E15F549}"
    Text            => (ComCall(6, this, "ptr*", &value := 0), HString(value))
    Uri             => (ComCall(7, this, "ptr*", &value := 0), HString(value))
    Html            => (ComCall(8, this, "ptr*", &value := 0), HString(value))
    Rtf             => (ComCall(9, this, "ptr*", &value := 0), HString(value))
    Bitmap          => (ComCall(10, this, "ptr*", &value := 0), HString(value))
    StorageItems    => (ComCall(11, this, "ptr*", &value := 0), HString(value))
}

class IStandardDataFormatsStatics2 extends IInspectable {
    static ClassName := "Windows.ApplicationModel.DataTransfer.StandardDataFormats"
    static IId := "{42A254F4-9D76-42E8-861B-47C25DD0CF71}"
    WebLink           => (ComCall(6, this, "ptr*", &value := 0), HString(value))
    ApplicationLink   => (ComCall(7, this, "ptr*", &value := 0), HString(value))
}

class IStandardDataFormatsStatics3 extends IInspectable {
    static ClassName := "Windows.ApplicationModel.DataTransfer.StandardDataFormats"
    static IId := "{3B57B069-01D4-474C-8B5F-BC8E27F38B21}"
    UserActivityJsonArray => (ComCall(6, this, "ptr*", &value := 0), HString(value))
}
