#Include <AhkWinRT\Application.DataTransfer>
#Include <AhkWinRT\Storage>

SetClipboardImage(path) {
    StorageFile := IStorageFileStatics.GetActivationFactory()
    RandomAccessStreamReference := IRandomAccessStreamReferenceStatics.GetActivationFactory()
    Clipboard := IClipboardStatic.GetActivationFactory()

    storageFile_ := await(StorageFile.GetFileFromPathAsync(HString.FromString(path)))
    streamRef := RandomAccessStreamReference.CreateFromFile(storageFile_)
    dataPackage := IDataPackage.ActivateInstance()
    dataPackage.SetBitmap(streamRef)
    Clipboard.SetContent(dataPackage)
    return Clipboard.Flush()
}

SaveClipboardImage(dir, name) {
    Clipboard := IClipboardStatic.GetActivationFactory()
    StandardDataFormats := IStandardDataFormatsStatics.GetActivationFactory()
    RandomAccessStreamReference := IRandomAccessStreamReferenceStatics.GetActivationFactory()
    StorageFolder := IStorageFolderStatics.GetActivationFactory()
    RandomAccessStream := IRandomAccessStreamStatics.GetActivationFactory()

    dataPackage_ := Clipboard.GetContent()
    if !dataPackage_.Contains(StandardDataFormats.Bitmap)
        return 0
    randomAccessStreamRef_ := await(dataPackage_.GetBitmapAsync())
    randomAccessStreamWithContentType_ := await(randomAccessStreamRef_.OpenReadAsync())
    storageFolder_ := await(StorageFolder.GetFolderFromPathAsync(HString.FromString(dir)))
    storageFile_ := await(storageFolder_.CreateFileAsync(HString.FromString(name), CreationCollisionOption.ReplaceExisting))
    randomAccessStream_ := await(storageFile_.OpenAsync(FileAccessMode.ReadWrite))
    return await(RandomAccessStream.CopyAsync(randomAccessStreamWithContentType_, randomAccessStream_))
}