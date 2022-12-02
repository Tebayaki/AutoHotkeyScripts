#Include "Foundation.ahk"
#Include "Storage.Streams.ahk"

FileAccessMode :=
{
    Read:      0,
    ReadWrite: 1
}

CreationCollisionOption :=
{
    GenerateUniqueName : 0,
    ReplaceExisting    : 1,
    FailIfExists       : 2,
    OpenIfExists       : 3
}

class IStorageFile extends IInspectable {
    static IId := "{FA3F6186-4214-428C-A64C-14C9AC7315EA}"
    OpenAsync(accessMode) => (ComCall(8, this, "uint", accessMode, "ptr*", &operation := 0), IAsyncOperation_TResult(IRandomAccessStream, operation))
}

class IStorageFileStatics extends IInspectable {
    static ClassName := "Windows.Storage.StorageFile"
    static IId := "{5984C710-DAF2-43C8-8BB4-A4D3EACFD03F}"
    GetFileFromPathAsync(path) => (ComCall(6, this, "ptr", path, "ptr*", &operation := 0), IAsyncOperation_TResult(IStorageFile, operation))
}

class IStorageFolder extends IInspectable {
    static IId := "{72D1CB78-B3EF-4F75-A80B-6FD9DAE2944B}"
    CreateFileAsyncOverloadDefaultOptions(desiredName) => (ComCall(6, this, "ptr", desiredName, "ptr*", &operation := 0), IAsyncOperation_TResult(IStorageFile, operation))
    CreateFileAsync(desiredName, options) => (ComCall(7, this, "ptr", desiredName, "uint", options, "ptr*", &operation := 0), IAsyncOperation_TResult(IStorageFile, operation))
}

class IStorageFolderStatics extends IInspectable {
    static ClassName := "Windows.Storage.StorageFolder"
    static IId := "{08F327FF-85D5-48B9-AEE9-28511E339F9F}"
    GetFolderFromPathAsync(path) => (ComCall(6, this, "ptr", path, "ptr*", &operation := 0), IAsyncOperation_TResult(IStorageFolder, operation))
}

class IApplicationData extends IInspectable {
    static IId := "{C3DA6FB7-B744-4B45-B0B8-223A0938D0DC}"
    LocalFolder => (ComCall(12, this, "ptr*", &value := 0), IStorageFolder(value))
}

class IApplicationDataStatics extends IInspectable {
    static IId := "{5612147B-E843-45E3-94D8-06169E3C8E17}"
}