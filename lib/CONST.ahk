/*
@Example
Const.PI := 3.1415926
MsgBox Const.PI
; Const.PI := 0 ; throw
*/
class CONST {
    static __Set(key, params, value) => this.DefineProp(key, {Get: (_) => value})
}