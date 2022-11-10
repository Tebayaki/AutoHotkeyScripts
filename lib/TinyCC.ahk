/*
c := "
(
#include <windows.h>

int APIENTRY WinMain() {}

void foo(wchar_t *msg, wchar_t *title){
    MessageBoxW(0, msg, title, MB_OK);
}
)"
res := TCScript(c, "foo", "str", "Hello TCC!", "str", A_ScriptName)
*/

TCScript(script, funcName, param*) {
    if !libtcc := DllCall("LoadLibraryW", "str", "libtcc", "ptr")
        throw OSError()
    try {
        if !tcc := DllCall("libtcc\tcc_new", "ptr")
            throw Error("Failed to create a new TCC compilation context")
        DllCall("libtcc\tcc_set_output_type", "ptr", tcc, "int", 1)
        if DllCall("libtcc\tcc_compile_string", "ptr", tcc, "astr", script) == -1
            throw Error("compile error")
        if DllCall("libtcc\tcc_relocate", "ptr", tcc, "ptr", 1) < 0
            throw Error("relocate error")
        if !fn := DllCall("libtcc\tcc_get_symbol", "ptr", tcc, "astr", funcName)
            throw Error("undefined symbol")
        res := DllCall(fn, param*)
    }
    catch as e
        throw e
    finally {
        if tcc
            DllCall("libtcc\tcc_delete", "ptr", tcc)
        DllCall("FreeLibrary", "ptr", libtcc)
    }
    return res
}

CONST := CONST ?? {},
CONST.TCC_OUTPUT_MEMORY := 1,       ; output will be run in memory (default)
CONST.TCC_OUTPUT_EXE := 2,          ; executable file
CONST.TCC_OUTPUT_DLL := 3,          ; dynamic library
CONST.TCC_OUTPUT_OBJ := 4,          ; object file
CONST.TCC_OUTPUT_PREPROCESS := 5,   ; only preprocess (used internally) ; only preprocess (used internally)
CONST.TCC_RELOCATE_AUTO := 1        ; Allocate and manage memory internally

class TinyCC {
    static LibTccPath := "libtcc.dll"

    /* create a new TCC compilation context */
    __New() {
        if !this.LibTcc := DllCall("LoadLibraryW", "str", TinyCC.LibTccPath, "ptr")
            throw OSError()
        if !this.Ptr := DllCall("libtcc\tcc_new", "ptr")
            throw Error("Failed to create TCC compilation context")
    }

    /* free a TCC compilation context */
    __Delete() {
        if this.HasOwnProp("Ptr") && this.Ptr
            DllCall("libtcc\tcc_delete", "ptr", this.Ptr)
        if this.HasOwnProp("LibTcc") && this.LibTcc
            DllCall("FreeLibrary", "ptr", this.LibTcc)
    }

    /* set CONFIG_TCCDIR at runtime */
    SetLibPath(path) => DllCall("libtcc\tcc_set_lib_path", "ptr", this, "astr", path)

    /* set error/warning display callback */
    SetErrorFunc(errorOpaque, errorFunc) => DllCall("libtcc\tcc_set_error_func", "ptr", this, "ptr", errorOpaque, "ptr", errorFunc)

    /* set options as from command line (multiple supported) */
    SetOptions(str) => DllCall("libtcc\tcc_set_options", "ptr", this, "astr", str)

    /* add include path */
    AddIncludePath(pathname) => DllCall("libtcc\tcc_add_include_path", "ptr", this, "astr", pathname)

    /* add in system include path */
    AddSysIncludePath(pathname) => DllCall("libtcc\tcc_add_sysinclude_path", "ptr", this, "astr", pathname)

    /* define preprocessor symbol 'sym'. Can put optional value */
    DefineSymbol(sym, value) => DllCall("libtcc\tcc_define_symbol", "ptr", this, "astr", sym, "astr", value)

    /* undefine preprocess symbol 'sym' */
    UndefineSymbol(sym) => DllCall("libtcc\tcc_undefine_symbol", "ptr", this, "astr", sym)

    /* add a file (C file, dll, object, library, ld script). Return -1 if error. */
    AddFile(filename) => DllCall("libtcc\tcc_add_file", "ptr", this, "astr", filename)

    /* compile a string containing a C source. Return -1 if error. */
    CompileString(buf) => DllCall("libtcc\tcc_compile_string", "ptr", this, "astr", buf)

    /* set output type. MUST BE CALLED before any compilation */
    SetOutputType(outputType) => DllCall("libtcc\tcc_set_output_type", "ptr", this, "int", outputType)

    /* equivalent to -Lpath option */
    AddLibraryPath(pathname) => DllCall("libtcc\tcc_add_library_path", "ptr", this, "astr", pathname)

    /* the library name is the same as the argument of the '-l' option */
    AddLibrary(libraryname) => DllCall("libtcc\tcc_add_library", "ptr", this, "astr", libraryname)

    /* add a symbol to the compiled program */
    AddSymbol(name, val) => DllCall("libtcc\tcc_add_symbol", "ptr", this, "astr", name, "ptr", val)

    /* output an executable, library or object file. DO NOT call tcc_relocate() before. */
    OutputFile(filename) => DllCall("libtcc\tcc_output_file", "ptr", this, "astr", filename)

    /* link and run main() function and return its value. DO NOT call tcc_relocate() before. */
    Run(args*) {
        if args.Length {
            bytes := 0
            for v in args
                bytes += StrPut(v, "cp0")
            offset := args.Length * A_PtrSize
            argv := Buffer(offset + bytes)
            for v in args {
                p := argv.Ptr + offset
                NumPut("ptr", p, argv, (A_Index - 1) * A_PtrSize)
                offset += StrPut(v, p, "cp0")
            }
        }
        else
            argv := 0
        return DllCall("libtcc\tcc_run", "ptr", this, "int", args.Length, "ptr", argv, "int")
    }

    /* do all relocations (needed before using tcc_get_symbol()) */
    /* possible values for 'ptr':
    - TCC_RELOCATE_AUTO : Allocate and manage memory internally
    - NULL              : return required memory size for the step below
    - memory address    : copy code to memory passed by the caller
    returns -1 if error. */
    Relocate(ptr) => DllCall("libtcc\tcc_relocate", "ptr", this, "ptr", ptr)

    /* return symbol value or NULL if not found */
    GetSymbol(name) => DllCall("libtcc\tcc_get_symbol", "ptr", this, "astr", name, "ptr")
}
