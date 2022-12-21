/*
@Param arr 一个数组
@Param function 自定义的排序函数对象，接受a, b两个参数，当a > b时返回正数，当a < b时返回负数，当a = b时返回0
@Example
arr := ["Cucumber", "Asparagus", "Broccoli", "张三", "李四", "王五", "1", "2", "3"]
MsgBox(JoinArray(arr))
BubbleSort(arr, CompareString) ; 冒泡排序, CompareString默认按拼音排序
MsgBox(JoinArray(arr))

arr := []
loop 10
    arr.Push(Random(-10, 10))
MsgBox(JoinArray(arr))
newArr := QuickSort(arr.Clone(), (a, b) => a - b) ; 快速排序, arr.Clone() 复制数组，防止arr被修改, (a, b) => a - b 从小到大排序
MsgBox(JoinArray(newArr))

JoinArray(arr, delimiter := "`n") {
    res := ""
    for i in arr
        res .= i delimiter
    return res
}
*/

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

InsertionSort(arr, function) {
    i := 2, len := arr.Length
    while i <= len {
        temp := arr[j := i]
        while j > 1 && function(arr[j - 1], temp) > 0
            arr[j] := arr[j - 1], --j
        arr[j] := temp, ++i
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

/*
locale name
https://learn.microsoft.com/en-us/windows/win32/intl/sort-order-identifiers#:~:text=Constant-,Locale%20name,-Meaning

@define LINGUISTIC_IGNORECASE 0x00000010
@define LINGUISTIC_IGNOREDIACRITIC 0x00000020

@define NORM_IGNORECASE 0x00000001
@define NORM_IGNOREKANATYPE 0x00010000
@define NORM_IGNORENONSPACE 0x00000002
@define NORM_IGNORESYMBOLS 0x00000004
@define NORM_IGNOREWIDTH 0x00020000
@define NORM_LINGUISTIC_CASING 0x08000000

@define SORT_DIGITSASNUMBERS 0x00000008
@define SORT_STRINGSORT 0x00001000
*/
CompareString(str1, str2, locale := "zh-CN", cmpFlags := 0) => DllCall("CompareStringEx", "wstr", locale, "uint", cmpFlags, "wstr", str1, "int", -1, "wstr", str2, "int", -1, "ptr", 0, "ptr", 0, "ptr", 0) - 2