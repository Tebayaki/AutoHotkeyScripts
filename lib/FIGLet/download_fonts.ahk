if !DllCall("GetStdHandle", "uint", -11, "ptr")
    DllCall("AllocConsole")
FileAppend("Sending Request...`n", "*")
fontList := RequestFontList()
FileAppend("Downloading...`n", "*")
DownloadFontFiles(fontList)

RequestFontList() {
    request := ComObject("WinHttp.WinHttpRequest.5.1")
    request.Open("Get", "http://patorjk.com/software/taag/", true)
    request.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.203")
    request.Send()
    request.WaitForResponse()
    if request.status !== 200
        throw Error("failed to request font list, status: " request.status)
    ret := {}
    doc := ComObject("htmlfile")
    doc.write(request.ResponseText)
    fontList := doc.getElementById("fontList")
    loop fontList.children.length {
        optgroup := fontList.children[A_Index - 1]
        temp := ret.%optgroup.label% := []
        loop optgroup.children.length {
            option := optgroup.children[A_Index - 1]
            temp.Push(option.value)
        }
    }
    return ret
}

DownloadFontFiles(fontList, dir := ".\fonts") {
    index := count := 0
    for groupName, group in fontList.OwnProps() {
        count += group.Length
    }
    for groupName, group in fontList.OwnProps() {
        DirCreate(dir "\" groupName)
        for fontName in group {
            FileAppend(fontName "`t", "*")
            try {
                Download("http://patorjk.com/software/taag/fonts/" fontName, dir "\" groupName "\" fontName)
                index++
                FileAppend(Format(" downloaded ({1} / {2})`n", index, count), "*")
            }
            catch as e {
                count--
                FileAppend(" download failed, " e.Message "`n", "*")
            }
        }
    }
}