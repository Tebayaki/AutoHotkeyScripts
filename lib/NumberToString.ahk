NumberToString(num, radix := 2) {
    if !(radix is Integer) || radix < 2 || radix > 36
        throw ValueError("Invalid radix")
    if radix == 10
        return String(num)
    alphabet := ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    res := "", i := Integer(Abs(num)), f := Abs(num) - i
    while i
        res := alphabet[Mod(i, radix) + 1] res, i //= radix
    else
        res := "0"
    if f {
        res .= "."
        loop {
            f *= radix
            i := Integer(f)
            res .= alphabet[i + 1]
        } until A_Index >= 64 || !f -= i
    }
    return num >= 0 ? res : "-" res
}