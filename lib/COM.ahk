CONST                 := CONST ?? {},
CONST.IID_IUnknown    := "{00000000-0000-0000-c000-000000000046}",
CONST.IID_IDispatch   := "{00020400-0000-0000-c000-000000000046}",

CONST.VT_EMPTY        := 0,  ; No value
CONST.VT_NULL         := 1,  ; SQL-style Null
CONST.VT_I2           := 2,  ; 16-bit signed int
CONST.VT_I4           := 3,  ; 32-bit signed int
CONST.VT_R4           := 4,  ; 32-bit floating-point number
CONST.VT_R8           := 5,  ; 64-bit floating-point number
CONST.VT_CY           := 6,  ; Currency
CONST.VT_DATE         := 7,  ; Date
CONST.VT_BSTR         := 8,  ; COM string (Unicode string with length prefix)
CONST.VT_DISPATCH     := 9,  ; COM object
CONST.VT_ERROR        := 0xA,  ; Error code (32-bit integer)
CONST.VT_BOOL         := 0xB,  ; Boolean True (-1) or False (0)
CONST.VT_VARIANT      := 0xC,  ; VARIANT (must be combined with VT_ARRAY or VT_BYREF)
CONST.VT_UNKNOWN      := 0xD,  ; IUnknown interface pointer
CONST.VT_DECIMAL      := 0xE,  ; (not supported)
CONST.VT_I1           := 0x10,  ; 8-bit signed int
CONST.VT_UI1          := 0x11,  ; 8-bit unsigned int
CONST.VT_UI2          := 0x12,  ; 16-bit unsigned int
CONST.VT_UI4          := 0x13,  ; 32-bit unsigned int
CONST.VT_I8           := 0x14,  ; 64-bit signed int
CONST.VT_UI8          := 0x15,  ; 64-bit unsigned int
CONST.VT_INT          := 0x16,  ; Signed machine int
CONST.VT_UINT         := 0x17,  ; Unsigned machine int
CONST.VT_RECORD       := 0x24,  ; User-defined type -- NOT SUPPORTED
CONST.VT_ARRAY        := 0x2000,  ; SAFEARRAY
CONST.VT_BYREF        := 0x4000  ; Pointer to another type of value

class Interface {
    static Call(ptr) => ptr && {Ptr: ptr, Base: this.Prototype}
    __Delete() => this.Ptr && ObjRelease(this.Ptr)
}

CreateVariant(vt := 0, val := 0) {
    if vt == CONST.VT_BSTR
        val := DllCall("OleAut32\SysAllocString", "str", val, "ptr")
    var := Buffer(24)
    NumPut("ushort", vt, var)
    NumPut("ptr", val, var, 8)
    var.__Delete := (this) => DllCall("OleAut32\VariantClear", "ptr", this)
    return var
}

VariantType(var) => NumGet(var, "ushort")

VariantValue(var){
    vt := VariantType(var)
    switch vt {
        case CONST.VT_EMPTY:
            return
        case CONST.VT_NULL:
            return
        case CONST.VT_I2:
            return NumGet(var, 8, "short")
        case CONST.VT_I4:
            return NumGet(var, 8, "int")
        case CONST.VT_ERROR:
            return NumGet(var, 8, "int")
        case CONST.VT_BOOL:
            return NumGet(var, 8, "int")
        case CONST.VT_INT:
            return NumGet(var, 8, "int")
        case CONST.VT_R4:
            return NumGet(var, 8, "float")
        case CONST.VT_R8:
            return NumGet(var, 9, "double")
        case CONST.VT_BSTR:
            if p := NumGet(var, 8, "ptr")
                return StrGet(p)
            return
        case CONST.VT_DISPATCH:
            ObjAddRef(p := NumGet(var, 8, "ptr"))
            return p
        case CONST.VT_UNKNOWN:
            ObjAddRef(p := NumGet(var, 8, "ptr"))
            return p
        case CONST.VT_I1:
            return NumGet(var, 8, "char")
        case CONST.VT_UI1:
            return NumGet(var, 8, "uchar")
        case CONST.VT_UI2:
            return NumGet(var, 8, "ushort")
        case CONST.VT_UI4:
            return NumGet(var, 8, "uint")
        case CONST.VT_UINT:
            return NumGet(var, 8, "uint")
        case CONST.VT_I8:
            return NumGet(var, 8, "int64")
        case CONST.VT_UI8:
            return NumGet(var, 8, "uint64")
        default:
            if vt & 0x2000
                return ComValue(vt, NumGet(var, 8, "ptr"), -1).Clone()
            return
    }
}

BStrToString(bstr){
    if bstr {
        str := StrGet(bstr)
        DllCall("OleAut32\SysFreeString", "ptr", bstr)
        return str
    }
}

CoTaskMemFree(pv) => DllCall("ole32\CoTaskMemFree", "ptr", pv)

TaskMemToString(pv){
    str := StrGet(pv)
    DllCall("ole32\CoTaskMemFree", "ptr", pv)
    return str
}

CLSIDFromString(str) => (DllCall("ole32\CLSIDFromString", "str", str, "ptr", clsid := Buffer(16), "HRESULT"), clsid)

IIDFromString(str) => (DllCall("ole32\IIDFromString", "str", str, "ptr", clsid := Buffer(16), "HRESULT"), clsid)

IsEqualGUID(rguid1, rguid2) => DllCall("Ole32\IsEqualGUID", "ptr", rguid1, "ptr", rguid2)

StringFromCLSID(clsid) => (DllCall('ole32\StringFromGUID2', "ptr", clsid, "wstr", str := "{00000000-0000-0000-0000-000000000000}", "int", 39), str)

ProgIDFromCLSIDString(str) => ProgIDFromCLSID(CLSIDFromString(str))

CLSIDStringFromProgID(progid){
    DllCall("ole32\CLSIDFromProgID", "str", progid, "ptr", clsid := Buffer(16), "HRESULT")
    return StringFromCLSID(clsid)
}

CLSIDFromProgID(progid) => (DllCall("ole32\CLSIDFromProgID", "str", progid, "ptr", clsid := Buffer(16), "HRESULT"), clsid)

ProgIDFromCLSID(clsid) {
    DllCall("ole32\ProgIDFromCLSID", "ptr", clsid, "ptr*", &lplpszProgID := 0, "HRESULT")
    progid := StrGet(lplpszProgID)
    DllCall("ole32\CoTaskMemFree", "ptr", lplpszProgID)
    return progid
}

GUIDFromArray(l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) => (NumPut("int", l, "short", w1, "short", w2, "char", b1, "char", b2, "char", b3, "char", b4, "char", b5, "char", b6, "char", b7, "char", b8, guid := Buffer(16)), guid)

GUIDStringFromArray(l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) => StringFromCLSID(GUIDFromArray(l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8))

RegisterEventHandler(function, uuid) {
    cbQueryInterface := CallbackCreate(QueryInterface, "F")
    cbAddOrRelease := CallbackCreate((self) => "", "F")
    handler := CallbackCreate(function, "F")

    iidIUnknown := IIDFromString("{00000000-0000-0000-C000-000000000046}")
    thisIId := IIDFromString(uuid)

    vt := Buffer(5 * A_PtrSize)
    NumPut("ptr", vt.Ptr + A_PtrSize, "ptr", cbQueryInterface, "ptr", cbAddOrRelease, "ptr", cbAddOrRelease, "ptr", handler, vt)
    vt.DefineProp("__Delete", { call: (_) => (CallbackFree(cbQueryInterface), CallbackFree(cbAddOrRelease), CallbackFree(handler)) })
    return vt

    QueryInterface(self, riid, ppvObject) {
        if IsEqualGUID(riid, thisIId) || IsEqualGUID(riid, iidIUnknown) {
            NumPut("ptr", self, ppvObject)
            return 0
        }
        return 0x80004002
    }
}