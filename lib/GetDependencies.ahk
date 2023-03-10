/*
@Example ; Resolve dependencies of AutoHotkey.exe
dependencies := GetDependencies(A_AhkPath, false, false)
out := ""
for dependency in dependencies
    out .= dependency.Name "`t=>`t" dependency.Path "`n"
MsgBox(out)
@Example ; Resolve All dependencies of user32.dll, including dependencies of dependencies
dependencies := GetDependencies(EnvGet("SystemRoot") "\System32\user32.dll", , true)
out := ""
for dependency in dependencies
    out .= dependency.Name "`t=>`t" dependency.Path "`n"
MsgBox(out)
*/
GetDependencies(path, delayLoad := false, recurse := false, workingDir := A_WorkingDir) {
    VarSetStrCapacity(&fullPath, 520)
    DllCall("GetFullPathName", "str", path, "uint", 260, "str", fullPath, "ptr", 0)
    if !FileExist(fullPath) {
        throw OSError(2)
    }
    SplitPath(fullPath, &name)
    dependencies := [{ Name: name, Path: fullPath }]
    record := Map()
    record.CaseSense := "Off"
    record[name] := dependencies[-1]
    finder := LibraryFinder()
    finder.WorkingDir := workingDir
    SubProcess(fullPath, recurse)
    return dependencies

    SubProcess(path, recurse) {
        fileObj := FileOpen(path, "R")
        if !hfileMapping := DllCall("CreateFileMappingW", "ptr", fileObj.Handle, "ptr", 0, "uint", 0x02, "uint", 0, "uint", 0, "ptr", 0, "ptr") {
            return
        }
        if !imageBase := DllCall("MapViewOfFile", "ptr", hFileMapping, "uint", 0x0004, "uint", 0, "uint", 0, "uptr", 0, "ptr") {
            DllCall("CloseHandle", "ptr", hFileMapping)
            return
        }
        DllCall("CloseHandle", "ptr", hFileMapping)
        fileBuf := { Ptr: imageBase, Size: fileObj.Length, __Delete: (_) => DllCall("UnmapViewOfFile", "ptr", _) }
        ; Check Signature
        if NumGet(fileBuf, "ushort") != 0x5A4D {
            return
        }
        peHeaderOffset := NumGet(fileBuf, 60, "uint")
        if NumGet(fileBuf, peHeaderOffset, "uint") != 0x4550 {
            return
        }

        sizeOfOptionalHeader := NumGet(fileBuf, peHeaderOffset + 20, "ushort")
        if sizeOfOptionalHeader < 0xF0 {
            finder.FindInWow64 := true
            rvaOfImportDescriptor := NumGet(fileBuf, peHeaderOffset + (delayLoad ? 224 : 128), "uint")
        }
        else {
            rvaOfImportDescriptor := NumGet(fileBuf, peHeaderOffset + (delayLoad ? 240 : 144), "uint")
        }
        if !rvaOfImportDescriptor || !importDescriptorOffset := Rva2Foa(fileBuf, rvaOfImportDescriptor) {
            return
        }
        emptyImportDescriptor := Buffer(delayLoad ? 32 : 20, 0)
        while DllCall("RtlCompareMemory", "ptr", fileBuf.Ptr + importDescriptorOffset, "ptr", emptyImportDescriptor, "uptr", emptyImportDescriptor.Size, "uptr") != emptyImportDescriptor.Size {
            if !rvaOfImportDescriptorName := NumGet(fileBuf, importDescriptorOffset + (delayLoad ? 4 : 12), "uint") {
                importDescriptorOffset += emptyImportDescriptor.Size
                continue
            }
            if !importDescriptorNameOffset := Rva2Foa(fileBuf, rvaOfImportDescriptorName) {
                importDescriptorOffset += emptyImportDescriptor.Size
                continue
            }
            dependencyName := StrGet(fileBuf.Ptr + importDescriptorNameOffset, "CP0")
            if !record.Has(dependencyName) {
                dependencyPath := finder.Find(dependencyName)
                dependencies.Push({ Name: dependencyName, Path: dependencyPath })
                record[dependencyName] := dependencies[-1]
                ; @Debug-Output => {dependencyName} => {dependencyPath}
                if recurse && dependencyPath {
                    SubProcess(dependencyPath, true)
                }
            }
            importDescriptorOffset += emptyImportDescriptor.Size
        }
    }

    static Rva2Foa(fileBuf, rva) {
        peHeader := NumGet(fileBuf, 0x3C, "uint")
        if rva < NumGet(fileBuf, peHeader + 0x54, "uint") {
            return rva
        }
        sectionHeader := peHeader + 0x18 + NumGet(fileBuf, peHeader + 0x14, "ushort")
        loop NumGet(fileBuf, peHeader + 6, "ushort") {
            rvaOfSection := NumGet(fileBuf, sectionHeader + (A_Index - 1) * 40 + 12, "uint")
            sizeOfSection := NumGet(fileBuf, sectionHeader + (A_Index - 1) * 40 + 8, "uint")
            if rva >= rvaOfSection && rva < rvaOfSection + sizeOfSection {
                foaOfSection := NumGet(fileBuf, sectionHeader + (A_Index - 1) * 40 + 20, "uint")
                foa := rva - (rvaOfSection - foaOfSection)
                return foa < fileBuf.Size ? foa : ""
            }
        }
    }
}

class LibraryFinder {
    FindInWow64 := false
    WorkingDir := A_WorkingDir

    Find(name) {
        ; Api sets
        if name ~= "i)^(?:api|ext)-[a-z0-9-]+-l\d+-\d+-" {
            if !this.HasProp("ApiSetSchemaParser") {
                this.ApiSetSchemaParser := ApiSetSchemaParser()
            }
            host := this.ApiSetSchemaParser.GetApiSetHost(name)
        }
        if !IsSet(host) || !host {
            SplitPath(name, &name, &dir, &ext, , &drive)
            if !ext && SubStr(name, -1) != "." {
                name .= ".dll"
            }
            if drive {
                VarSetStrCapacity(&path, 520)
                DllCall("GetFullPathName", "str", dir "\" name, "uint", 260, "str", path, "ptr", 0)
                return FileExist(path) ? path : ""
            }
        }
        else {
            name := host
        }
        ; Known dlls
        loop reg, "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs" {
            if RegRead() = name {
                path := this.GetSystemDir() "\" name
                if FileExist(path) {
                    return path
                }
                break
            }
        }
        ; Loading dir
        VarSetStrCapacity(&path, 520)
        DllCall("GetModuleFileNameW", "ptr", 0, "str", path, "uint", 260)
        SplitPath(path, , &dir)
        path := dir "\" name
        if FileExist(path) {
            return path
        }
        ; System dir
        path := this.GetSystemDir() "\" name
        if FileExist(path) {
            return path
        }
        ; Windows dir
        path := A_WinDir "\" name
        if FileExist(path) {
            return path
        }
        ; Current dir
        path := this.workingDir "\" name
        if FileExist(path) {
            return path
        }
        ; Env:PATH
        for dir in StrSplit(EnvGet("PATH"), ";") {
            path := RTrim(dir, "\") "\" name
            if FileExist(path) {
                return path
            }
        }
    }

    GetSystemDir() {
        fn := this.FindInWow64 ? "GetSystemWow64DirectoryW" : "GetSystemDirectoryW"
        cc := DllCall(fn, "ptr", 0, "uint", 0, "uint")
        VarSetStrCapacity(&dir, cc * 2)
        DllCall(fn, "str", dir, "uint", cc)
        return dir
    }
}

class ApiSetSchemaParser {
    __New(path?) {
        if !IsSet(path) {
            VarSetStrCapacity(&dir, 520)
            DllCall("GetSystemDirectoryW", "str", dir, "uint", 260)
            path := dir "\ApiSetSchema.dll"
        }
        fileObj := FileOpen(path, "R")
        if !hfileMapping := DllCall("CreateFileMappingW", "ptr", fileObj.Handle, "ptr", 0, "uint", 0x02, "uint", 0, "uint", 0, "ptr", 0, "ptr") {
            throw OSError()
        }
        if !imageBase := DllCall("MapViewOfFile", "ptr", hFileMapping, "uint", 0x0004, "uint", 0, "uint", 0, "uptr", 0, "ptr") {
            DllCall("CloseHandle", "ptr", hFileMapping)
            throw OSError()
        }
        DllCall("CloseHandle", "ptr", hFileMapping)
        this.FileBuffer := { Ptr: imageBase, Size: fileObj.Length }
        if NumGet(this.FileBuffer, "ushort") != 0x5A4D {
            throw Error("Invalid PE file")
        }
        peHeaderOffset := NumGet(this.FileBuffer, 60, "uint")
        if NumGet(this.FileBuffer, peHeaderOffset, "uint") != 0x4550 {
            throw Error("Invalid PE file")
        }
    }

    __Delete() {
        if this.HasProp("FileBuffer") {
            DllCall("UnmapViewOfFile", "ptr", this.FileBuffer)
        }
    }

    GetApiSetHost(name) {
        peHeaderOffset := NumGet(this.FileBuffer, 60, "uint")
        sizeOfOptionalHeader := NumGet(this.FileBuffer, peHeaderOffset + 20, "ushort")
        sectionHeadersOffset := peHeaderOffset + 24 + sizeOfOptionalHeader
        apiSetMapOffset := 0
        loop numberOfSections := NumGet(this.FileBuffer, peHeaderOffset + 6, "ushort") {
            if StrGet(this.FileBuffer.Ptr + sectionHeadersOffset + (A_Index - 1) * 40, 8, "CP20127") = ".apiset" {
                apiSetMapOffset := NumGet(this.FileBuffer, sectionHeadersOffset + (A_Index - 1) * 40 + 20, "uint")
                break
            }
        }
        if !apiSetMapOffset {
            return
        }

        entryCount := NumGet(this.FileBuffer, apiSetMapOffset + 12, "uint")
        entryOffset := NumGet(this.FileBuffer, apiSetMapOffset + 16, "uint") + apiSetMapOffset
        hashOffset := NumGet(this.FileBuffer, apiSetMapOffset + 20, "uint") + apiSetMapOffset
        hashFactor := NumGet(this.FileBuffer, apiSetMapOffset + 24, "uint")

        hashKey := 0
        loop parse hashedName := StrLower(SubStr(name, 1, InStr(name, "-", , -1) - 1)) {
            hashKey := hashKey * hashFactor + Ord(A_LoopField)
        }
        hashKey &= 0xFFFFFFFF

        foundEntryOffset := 0
        low := 0
        high := entryCount - 1
        while low <= high {
            mid := (low + high) >> 1
            value := NumGet(this.FileBuffer, hashOffset + 8 * mid, "uint")
            if hashKey == value {
                foundEntryOffset := entryOffset + 24 * NumGet(this.FileBuffer, hashOffset + 8 * mid + 4, "uint")
                break
            }
            else if hashKey > value {
                low := mid + 1
            }
            else {
                high := mid - 1
            }
        }
        if !foundEntryOffset {
            return
        }

        if valueCount := NumGet(this.FileBuffer, foundEntryOffset + 20, "uint") {
            nameOffset := NumGet(this.FileBuffer, foundEntryOffset + 4, "uint") + apiSetMapOffset
            hashedLength := NumGet(this.FileBuffer, foundEntryOffset + 12, "uint")
            if hashedName = StrGet(this.FileBuffer.Ptr + nameOffset, hashedLength >> 1) {
                valueEntryOffset := NumGet(this.FileBuffer, foundEntryOffset + 16, "uint") + apiSetMapOffset
                valueOffset := NumGet(this.FileBuffer, valueEntryOffset + 12, "uint") + apiSetMapOffset
                valueLength := NumGet(this.FileBuffer, valueEntryOffset + 16, "uint")
                return StrGet(this.FileBuffer.Ptr + valueOffset, valueLength >> 1)
            }
        }
    }
}