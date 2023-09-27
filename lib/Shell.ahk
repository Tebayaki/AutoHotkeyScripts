/*
@Members https://learn.microsoft.com/en-us/windows/win32/shell/folderitems
@Example firstItemPath := Shell_GetSelectedFolderItems().Item(0).Path
*/
Shell_GetSelectedFolderItems() {
    if folderView := Shell_GetActiveFolderView()
        return folderView.SelectedItems
}

/*
@Members https://learn.microsoft.com/en-us/windows/win32/shell/folderitem
@Example foucusedItemName := Shell_GetFocusedFolderItem().Name
*/
Shell_GetFocusedFolderItem() {
    if folderView := Shell_GetActiveFolderView()
        return folderView.FocusedItem
}

/*
@Members https://learn.microsoft.com/en-us/windows/win32/shell/folderitem
@Example activeFolderPath := Shell_GetActiveFolder().Path
*/
Shell_GetActiveFolder() {
    if folderView := Shell_GetActiveFolderView()
        return folderView.Folder.Self
}

/*
@Members https://learn.microsoft.com/en-us/windows/win32/shell/shellfolderview
@Example foucusedItemSize := Shell_GetActiveFolderView().FocusedItem.Size
*/
Shell_GetActiveFolderView() {
    hwndFore := WinExist("A")
    windows := ComObject("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")
    for webBrowser in windows
        if webBrowser.Hwnd == hwndFore
            return webBrowser.Document
    hwndBuf := Buffer(4)
    if webBrowser := windows.FindWindowSW(0, 0, 8, ComValue(0x4003, hwndBuf.Ptr), 1) {
        hwndDesktop := NumGet(hwndBuf, "int")
        if hwndFore == hwndDesktop
            return webBrowser.Document
        if WinGetClass(hwndFore) == "WorkerW" {
            hwndFocus := ControlGetFocus(hwndFore)
            if hwndFocus && WinGetClass(hwndFocus) == "SysListView32"
                return webBrowser.Document
        }
    }
}

/*
@Members https://learn.microsoft.com/en-us/windows/win32/shell/folderitem
@Example firstFolderPath := Shell_GetAllOpenedFolders()[1].Path
*/
Shell_GetAllOpenedFolders() {
    folders := []
    for webBrowser in ComObject("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")
        folders.Push(webBrowser.Document.Folder.Self)
    return folders
}

Shell_UnZipFileTo(src, dest) {
    shell := ComObject("Shell.Application")
    dest := shell.NameSpace(dest)
    src := shell.NameSpace(src)
    dest.CopyHere(src.Items, 4)
}