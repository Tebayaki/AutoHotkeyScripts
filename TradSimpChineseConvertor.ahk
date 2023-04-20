convertorUI := Gui(, "繁简汉字转换器")
convertorUI.SetFont("s10", "SimHei")
simpEdit := convertorUI.AddEdit("xm3 r10 w500", "忧郁的台湾乌龟")
simpEdit.GetPos(,, &simpEditW)
simpTotradButton := convertorUI.AddButton("w" simpEditW / 2 - 1, "简`n︾`n繁")
tradTosimpButton := convertorUI.AddButton("x+2 w" simpEditW / 2 - 1, "简`n︽`n繁")
tradEdit := convertorUI.AddEdit("xm3 r10 w500", "憂鬱的臺灣烏龜")

simpTotradButton.OnEvent("Click", (btn, info) => tradEdit.Text := SimplifiedToTraditional(simpEdit.Text))
tradTosimpButton.OnEvent("Click", (btn, info) => simpEdit.Text := TraditionalToSimplified(tradEdit.Text))

convertorUI.Show()

TraditionalToSimplified(str) {
    if cch := DllCall("LCMapStringEx", "str", "zh-CN", "uint", 0x02000000, "str", str, "int", -1, "ptr", 0, "int", 0, "ptr", 0, "ptr", 0, "ptr", 0) {
        VarSetStrCapacity(&ret, cch * 2)
        if DllCall("LCMapStringEx", "str", "zh-CN", "uint", 0x02000000, "str", str, "int", -1, "str", &ret, "int", cch, "ptr", 0, "ptr", 0, "ptr", 0)
            return ret
    }
}

SimplifiedToTraditional(str) {
    if cch := DllCall("LCMapStringEx", "str", "zh-CN", "uint", 0x04000000, "str", str, "int", -1, "ptr", 0, "int", 0, "ptr", 0, "ptr", 0, "ptr", 0) {
        VarSetStrCapacity(&ret, cch * 2)
        if DllCall("LCMapStringEx", "str", "zh-CN", "uint", 0x04000000, "str", str, "int", -1, "str", &ret, "int", cch, "ptr", 0, "ptr", 0, "ptr", 0)
            return ret
    }
}