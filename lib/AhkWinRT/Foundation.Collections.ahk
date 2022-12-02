#Include "Foundation.ahk"

class IVectorView_T extends IInspectable {
    static IId := "{BBE1FA4C-B0E3-4583-BAEF-1F1B2E483E56}"
    __New(T, ptr) => (super.__New(ptr), this.T := T)
    __Enum(_) => (&item) => ComCall(6, this, "int", A_Index - 1, "ptr*", &pItem := 0, "int") == 0 && item := (this.T)(pItem)
    __Item[index]       => (ComCall(6, this, "int", index, "ptr*", &pItem := 0), (this.T)(pItem))
    Size                => (ComCall(7, this, "uint*", &size := 0), size)
}

class IVector_T extends IInspectable {
    static IId := "{913337E9-11A1-4345-A3A2-4E7F956E222D}"
    __New(T, ptr) => (super.__New(ptr), this.T := T)
    __Enum(_) => (&item) => ComCall(6, this, "int", A_Index - 1, "ptr*", &pItem := 0, "int") == 0 && item := (this.T)(pItem)
    __Item[index]       => (ComCall(6, this, "int", index, "ptr*", &pItem := 0), (this.T)(pItem))
    Size                => (ComCall(7, this, "uint*", &size := 0), size)
    GetView()           => (ComCall(8, this, "ptr*", &result := 0), IVectorView_T(this.T, result))
}