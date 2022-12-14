ImportTypeHelper() {
    Any.Prototype.DefineProp := Object.Prototype.DefineProp
    Any.Prototype.DefineProp("Type", {Get: Type})

    Object.Prototype.DefineProp("ToString", {Call: JSON.stringify.Bind(JSON)})

    String.Prototype.DefineProp("__Item", {Get: SubStr.Bind(, , 1)})
    String.Prototype.DefineProp("Length", {Get: StrLen})

    Buffer.Prototype.DefineProp("ToString", {Call: BufferToString})
    Buffer.Prototype.DefineProp("Compare", {Call: BufferCompare})
    Buffer.Prototype.DefineProp("Equals", {Call: (buf1, buf2) => buf1.Size == buf2.Size && BufferCompare(buf1, buf2) == buf1.Size})
    Buffer.Prototype.DefineProp("Copy", {Call: BufferCopy})

    BufferCopy(src, size?) {
        if !IsSet(size)
            size := src.Size
        else if size > src.Size
            throw Error("invalid size")
        DllCall("RtlCopyMemory", "ptr", newBuf := Buffer(src.Size), "ptr", src, "uptr", size)
        return newBuf
    }

    BufferToString(binary) {
        DllCall("crypt32\CryptBinaryToStringW", "ptr", binary, "uint", binary.Size, "uint", 0x0000000B, "ptr", 0, "uint*", &cnt := 0)
        VarSetStrCapacity(&str, cnt * 2)
        DllCall("crypt32\CryptBinaryToStringW", "ptr", binary, "uint", binary.Size, "uint", 0x0000000B, "wstr", str, "uint*", cnt)
        return str
    }

    BufferCompare(buf1, buf2, size := unset) {
        if !IsSet(size)
            size := Min(buf1.Size, buf2.Size)
        else if size > Max(buf1.Size, buf2.Size)
            throw Error("invalid size")
        return DllCall("RtlCompareMemory", "ptr", buf1, "ptr", buf2, "uptr", size, "uptr")
    }
}
