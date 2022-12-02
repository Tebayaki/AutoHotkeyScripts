#Include "Foundation.ahk"

class IRandomAccessStream extends IInspectable {
    static IId := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"
}

class IRandomAccessStreamReference extends IInspectable {
    static IId := "{33EE3134-1DD6-4E3A-8067-D1C162E8642B}"
    OpenReadAsync() => (ComCall(6, this, "ptr*", &operation := 0), IAsyncOperation_TResult(IRandomAccessStreamWithContentType, operation))
}

class IRandomAccessStreamStatics extends IInspectable {
    static ClassName := "Windows.Storage.Streams.RandomAccessStream"
    static IId := "{524CEDCF-6E29-4CE5-9573-6B753DB66C3A}"
    CopyAsync(source, destination) => (ComCall(6, this, "ptr", source, "ptr", destination, "ptr*", &operation := 0), IAsyncOperationWithProgress_TResult_TProgress(Integer, Integer, operation))
}

class IRandomAccessStreamWithContentType extends IInspectable {
    static IId := "{CC254827-4B3D-438F-9232-10C76BC7E038}"
}

class IRandomAccessStreamReferenceStatics extends IInspectable {
    static ClassName := "Windows.Storage.Streams.RandomAccessStreamReference"
    static IId := "{857309DC-3FBF-4E7D-986F-EF3B1A07A964}"
    CreateFromFile(storageFile) => (ComCall(6, this, "ptr", storageFile, "ptr*", &streamReference := 0), IRandomAccessStreamReference(streamReference))
}