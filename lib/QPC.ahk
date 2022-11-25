QPC() {
    static m := (DllCall("QueryPerformanceFrequency", "int64*", &f := 0), 1000 / f)
    , q := DllCall("GetProcAddress", "ptr", DllCall("GetModuleHandle", "str", "kernel32", "ptr"), "astr", "QueryPerformanceCounter", "ptr")
    return (DllCall(q, "int64*", &c := 0), c * m)
}