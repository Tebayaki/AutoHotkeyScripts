BubbleSort(arr, function) {
    loop arr.length - 1
        loop arr.length - A_Index
            if function(arr[A_Index], arr[A_Index + 1]) > 0
                temp := arr[A_Index], arr[A_Index] := arr[A_Index + 1], arr[A_Index + 1] := temp
    return arr
}

SelectionSort(arr, function) {
    len := arr.Length
    loop len - 1 {
        min := A_Index, j := A_Index + 1
        loop len - A_Index {
            if function(arr[min], arr[j]) > 0
                min := j
            j++
        }
        if min != A_Index
            temp := arr[min], arr[min] := arr[A_Index], arr[A_Index] := temp
    }
    return arr
}

QuickSort(arr, function) {
    if 2 > len := arr.Length
        return arr
    ranges := [1 | (len << 32)], ranges.Length := len, i := 2
    while i > 1 {
        range := ranges[--i]
        if (start := range & 0xffffffff) >= (end := range >> 32)
            continue
        mid := arr[(start + end) / 2], left := start, right := end
        loop {
            while function(arr[left], mid) < 0
                ++left
            while function(arr[right], mid) > 0
                --right
            if left <= right
                temp := arr[left], arr[left] := arr[right], arr[right] := temp, left++, right--
        } until left > right
        if start < right
            ranges[i++] := start | right << 32
        if end > left
            ranges[i++] := left | end << 32
    }
    return arr
}

CompareStringChinesePhoneBook(str1, str2) => DllCall("CompareStringEx", "wstr", "zh-CN_phoneb", "uint", 0, "wstr", str1, "int", -1, "wstr", str2, "int", -1, "ptr", 0, "ptr", 0, "ptr", 0) - 2

/*
locale name
https://learn.microsoft.com/en-us/windows/win32/intl/sort-order-identifiers#:~:text=Constant-,Locale%20name,-Meaning

@LINGUISTIC_IGNORECASE 0x00000010
@LINGUISTIC_IGNOREDIACRITIC 0x00000020

@NORM_IGNORECASE 0x00000001
@NORM_IGNOREKANATYPE 0x00010000
@NORM_IGNORENONSPACE 0x00000002
@NORM_IGNORESYMBOLS 0x00000004
@NORM_IGNOREWIDTH 0x00020000
@NORM_LINGUISTIC_CASING 0x08000000

@SORT_DIGITSASNUMBERS 0x00000008
@SORT_STRINGSORT 0x00001000
*/
CompareString(str1, str2, locale, cmpFlags := 0) => DllCall("CompareStringEx", "wstr", locale, "uint", cmpFlags, "wstr", str1, "int", -1, "wstr", str2, "int", -1, "ptr", 0, "ptr", 0, "ptr", 0) - 2