/************************************************************************
 * @description This script creates a symbolic link as AutoHotkey's standard lib targeting our lib here.
 * @file link.ahk
 * @author Tebayaki
 * @date 2024/08/19
 * @version 1.0.0
 ***********************************************************************/

#Requires AutoHotkey v2.0 
#Include <RunAs>

linkPath := GetFullPath(A_AhkPath "\..\lib")
targetPath := A_WorkingDir "\lib"
if !InStr(FileExist(targetPath), "D") {
    throw Error("Can not found folder: '" targetPath "'")
}
attributes := FileExist(linkPath)
if attributes !== "" {
    if attributes == "DL" {
        DirDelete(linkPath)
    }
    else {
        throw Error("'" linkPath "' already exists")
    }
}
; SYMBOLIC_LINK_FLAG_DIRECTORY 1
if !DllCall("CreateSymbolicLinkW", "str", linkPath, "str", targetPath, "uint", 1) {
    throw OSError()
}
else {
    MsgBox "Symbolic link created:`n" linkPath "`n==>`n" targetPath
}

GetFullPath(path) {
    VarSetStrCapacity(&ret, 260)
    DllCall("GetFullPathName", "str", path, "uint", 260, "str", ret, "ptr", 0)
    return ret
}