await(operation) {
    asyncInfo := operation.QueryInterface(IAsyncInfo)
    loop {
        switch asyncInfo.Status {
            case 0: continue
            case 1: return operation.GetResults()
            case 2: throw Error("The operation was canceled.")
            case 3: throw Error("The operation has encountered an error.")
        }
    }
}

IIDFromString(str) => (DllCall("ole32\IIDFromString", "str", str, "ptr", iid := Buffer(16), "HRESULT"), iid)

class HString {
    static FromString(str) => (DllCall("Combase\WindowsCreateString", "wstr", str, "uint", StrLen(str), "ptr*", &pHStr := 0, "HRESULT"), this(pHStr))
    __New(ptr) {
        if 0 == this.Ptr := ptr
            throw Error("null pointer")
    }
    __Delete() => this.Ptr && DllCall("Combase\WindowsDeleteString", "ptr", this, "HRESULT")
    ToString() => StrGet(this.Ptr + 28, "utf-16")
}

class IUnknown {
    static IId := "{00000000-0000-0000-C000-000000000046}"
    __New(ptr) {
        if 0 == this.Ptr := ptr
            throw Error("null pointer")
    }
    __Delete() => this.Ptr && ObjRelease(this.Ptr)
    QueryInterface(interface) => (ComCall(0, this, "ptr", IIDFromString(interface.IId), "ptr*", &pInterface := 0), interface(pInterface))
}

class IInspectable extends IUnknown {
    static IId := "{AF86E2E0-B12D-4c6a-9C5A-D7AA65101E90}"
    static GetActivationFactory() => (DllCall("Combase\RoGetActivationFactory", "ptr", HString.FromString(this.ClassName), "ptr", IIDFromString(this.IId), "ptr*", &pInterface := 0, "HRESULT"), this(pInterface))
    static ActivateInstance() => (DllCall("Combase\RoActivateInstance", "ptr", HString.FromString(this.ClassName), "ptr*", &ptr := 0, "HRESULT"), this(ptr))
}

class IAsyncInfo extends IInspectable {
    static IId := "{00000036-0000-0000-C000-000000000046}"
    Status => (ComCall(7, this, "uint*", &status := 0), status)
}

class IAsyncOperation_TResult extends IInspectable {
    static IId := "{5A648006-843A-4DA9-865B-9D26E5DFAD7B}"
    __New(TResult, ptr) {
        if 0 == this.Ptr := ptr
            throw Error("null pointer")
        this.TResult := TResult
    }
    GetResults() => (ComCall(8, this, "ptr*", &result := 0), (this.TResult)(result))
}

class IAsyncOperationWithProgress_TResult_TProgress extends IInspectable {
    static IId := "{B5D036D7-E297-498F-BA60-0289E76E23DD}"
    __New(TResult, TProgress, ptr) {
        if 0 == this.Ptr := ptr
            throw Error("null pointer")
        this.TResult := TResult
        this.TProgress := TProgress
    }
    GetResults() => (ComCall(10, this, "ptr*", &result := 0), (this.TResult)(result))
}