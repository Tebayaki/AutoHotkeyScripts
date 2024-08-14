Where(name) {
    VarSetStrCapacity(&path, 520)
    DllCall("Shell32\FindExecutableW", "str", name, "ptr", 0, "str", path)
    return path
}