guidGenWnd := Gui()
guidGenWnd.SetFont("s10", "Consolas")
uppercaseCheckBox := guidGenWnd.AddCheckbox("xm10 Section Checked", "Uppercase")
withBraceCheckBox := guidGenWnd.AddCheckbox("ys Checked", "With Brace")
withHyphenCheckBox := guidGenWnd.AddCheckbox("ys Checked", "With Hyphen")
genNumberEditText := guidGenWnd.AddText("xm10 Section", "Number(100 max): ")
NumberEdit := guidGenWnd.AddEdit("ys Number r1 w50", "1")
NumberEdit.GetPos(, , , &numberEditH)
genButton := guidGenWnd.AddButton("ys h" numberEditH, "Gen")
copyButton := guidGenWnd.AddButton("ys h" numberEditH, "Copy")
guidsEdit := guidGenWnd.AddEdit("xm10 ReadOnly -Wrap r10", "{00000000-0000-0000-0000-000000000000}")

genButton.OnEvent("Click", OnGenButtonClick)
OnGenButtonClick(btn, info) {
    guidsEdit.Text := ""
    if IsNumber(num := NumberEdit.Text) && num <= 100 {
        VarSetStrCapacity(&guids, num * 38 * 2)
        loop num
            guids .= CreateGuid(uppercaseCheckBox.Value, withBraceCheckBox.Value, withHyphenCheckBox.Value) "`n"
        guidsEdit.Text := RTrim(guids, "`n")
    }
}
copyButton.OnEvent("Click", OnCopyButtonClick)
OnCopyButtonClick(btn, info) {
    if guids := guidsEdit.Text
        A_Clipboard := guids
}
guidGenWnd.Show()

CreateGuid(upperCase := true, withBrace := true, withHyphen := true) {
    DllCall("Ole32\CoCreateGuid", "ptr", guid := Buffer(16), "HRESULT")
    VarSetStrCapacity(&str, 78)
    DllCall('ole32\StringFromGUID2', "ptr", guid, "wstr", str, "int", 39)
    if !upperCase
        str := StrLower(str)
    if !withBrace
        str := SubStr(str, 2, 36)
    if !withHyphen
        str := StrReplace(str, "-")
    return str
}
