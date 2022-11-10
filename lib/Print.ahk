Print(output, space := 4, encoding := "utf-8") {
    static _ := DllCall("GetStdHandle", "uint", -11, "ptr") || DllCall("AllocConsole")
    if !(output is Primitive)
        output := JSON.stringify(output, space)
    FileAppend(output "`n", "*", encoding)
}