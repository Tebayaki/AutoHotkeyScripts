/* @example
Print("Pass", ["any", "count", "of"], "parameters")
*/
Print(values*) {
    static printer_ := Printer()
    printer_.Print(values*)
}

/* @example
obj := {
    a: "Hello world!",
    b: [1, 2, 3],
    c: Map("a", "apple", "b", "banana", "c", "cherry"),
}
FPrint(obj)
*/
FPrint(value, breakDeepth := 1, indent := "    ") {
    static printer_ := Printer()
    printer_.BreakDeepth := breakDeepth
    printer_.IndentUnit := indent
    printer_.Print(value)
}

class Printer {
    __New(separator := " ", end := "`n", breakDeepth := 0, indent := "    ", outputFile := "*", encoding := "utf-8") {
        this.Separator := separator
        this.End := end
        this.BreakDeepth := breakDeepth
        this.OutputFile := outputFile
        this.Encoding := encoding
        this.IndentUnit := indent
    }

    Print(values*) {
        static _ := DllCall("GetStdHandle", "uint", -11, "ptr") || DllCall("AllocConsole")
        output := ""
        for v in values {
            if IsSet(v) {
                if v is Primitive
                    output .= v
                else
                    stringify(v, 1, "")
            }
            else
                output .= "unset"
            if A_Index < values.Length
                output .= this.Separator
        }
        FileAppend(output this.End, this.OutputFile, this.Encoding)
        return

        stringify(value, deepth, indent) {
            if value is Number
                output .= value
            else if value is String
                output .= '"' value '"'
            else if value is Array
                stringifyArray(value, deepth, indent)
            else if value is Map
                stringifyMap(value, deepth, indent)
            else if value is Object
                stringifyObject(value, deepth, indent)
        }

        stringifyArray(value, deepth, indent) {
            if deepth <= this.BreakDeepth {
                output .= "[`n"
                for v in value {
                    output .= indent this.IndentUnit
                    if IsSet(v)
                        stringify(v, deepth + 1, indent this.IndentUnit)
                    else
                        output .= "unset"
                    if A_Index < value.Length
                        output .= ",`n"
                }
                output .= "`n" indent "]"
            }
            else {
                output .= "["
                for v in value {
                    if IsSet(v)
                        stringify(v, deepth + 1, "")
                    else
                        output .= "unset"
                    if A_Index < value.Length
                        output .= ", "
                }
                output .= "]"
            }
        }

        stringifyMap(value, deepth, indent) {
            if deepth <= this.BreakDeepth {
                output .= "{`n"
                for k, v in value {
                    if k is String
                        k := '"' k '"'
                    else if !(k is Number)
                        k := Type(k) "_" ObjPtr(k)
                    output .= indent this.IndentUnit k ': '
                    stringify(v, deepth + 1, indent this.IndentUnit)
                    if A_Index < value.Count
                        output .= ", `n"
                }
                output .= "`n" indent "}"
            }
            else {
                output .= "{"
                for k, v in value {
                    if k is String
                        k := '"' k '"'
                    else if !(k is Number)
                        k := Type(k) "_" ObjPtr(k)
                    output .= k ': '
                    stringify(v, deepth + 1, "")
                    if A_Index < value.Count
                        output .= ", "
                }
                output .= "}"
            }
        }

        stringifyObject(value, deepth, indent) {
            if deepth <= this.BreakDeepth {
                output .= "{`n"
                for k, v in value.OwnProps() {
                    output .= indent this.IndentUnit k ": "
                    stringify(v, deepth + 1, indent this.IndentUnit)
                    if A_Index < ObjOwnPropCount(value)
                        output .= ",`n"
                }
                output .= "`n" indent "}"
            }
            else {
                output .= "{"
                for k, v in value.OwnProps() {
                    output .= k ": "
                    stringify(v, deepth + 1, "")
                    if A_Index < ObjOwnPropCount(value)
                        output .= ", "
                }
                output .= "}"
            }
        }
    }
}