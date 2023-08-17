#SingleInstance Off
#Include <FIGLet\FIGLet>

FIGLetGui()

FIGLetGui() {
    defaultFontName := "Slant"
    currentInput := "AutoHotkey"
    currentFontNameList := []
    fl := FIGLet()
    stopped := false

    flg := Gui("Resize MinSize", "FIGLet Font Generator")
    flg.SetFont(, "Cascadia Code")

    flg.AddText("Section", "Font:")
    flg.AddText(, "Width:")
    flg.AddText(, "Height:")

    ddlFont := flg.AddDropDownList("ys Section"), ddlFont.GetPos(, &ddlFontY)
    ddlWidth := flg.AddDropDownList("Choose1", ["Default", "Full", "Fit", "Smush", "Controlled Smush"])
    ddlHeight := flg.AddDropDownList("Choose1", ["Default", "Full", "Fit", "Smush", "Controlled Smush"]), ddlHeight.GetPos(, &ddlHeightY, , &ddlHeightH)

    buttonTestAllH := (ddlHeightY + ddlHeightH - ddlFontY - flg.MarginY) / 2
    buttonTestAll := flg.AddButton("ys Section h" buttonTestAllH, "Test All"), buttonTestAll.GetPos(, , &buttonTestAllW)
    buttonCopy := flg.AddButton("w" buttonTestAllW " h" buttonTestAllH, "Copy")

    editInput := flg.AddEdit("Multi -Wrap ys h" (ddlHeightY + ddlHeightH - ddlFontY), currentInput), editInput.GetPos(&editInputX, , , &editInputH)
    editOutput := flg.AddEdit("Multi ReadOnly HScroll -Wrap xm"), editOutput.GetPos(, &editOutputY)

    statusBar := flg.AddStatusBar(), statusBar.GetPos(, , , &statusBarH)

    flg.MenuBar := MenuBar()
    menuFile := Menu()
    flg.MenuBar.Add("&File", menuFile)
    menuFile.Add("Open &Folder...`tCtrl+O", (*) => OpenFolder(FileSelect("D", , "Select fonts library...")))

    flg.OnEvent("Size", WindowFLG_Size)
    flg.OnEvent("Close", (_) => !stopped := true)
    ddlFont.OnEvent("Change", DropDownList_Change)
    ddlWidth.OnEvent("Change", DropDownList_Change)
    ddlHeight.OnEvent("Change", DropDownList_Change)
    buttonTestAll.OnEvent("Click", ButtonTestAll_Click)
    buttonCopy.OnEvent("Click", ButtonCopy_Click)
    editInput.OnEvent("Change", EditInput_Change)

    OpenFolder(fl.FontsPath, defaultFontName)
    DllCall("imm32\ImmAssociateContext", "ptr", editInput.Hwnd, "ptr", 0, "ptr") ; disable ime
    editInput.Focus()
    flg.Show("Hide")
    flg.GetPos(, , &uiW, &uiH)
    flg.Show("Center w" uiW * 2 " h" uiH * 2)
    return flg

    OpenFolder(folder, choose?) {
        if DirExist(folder) {
            fl.FontsPath := folder
            currentFontNameList.Length := 0
            loop files folder "\*.flf", "F" {
                currentFontNameList.Push(SubStr(A_LoopFileName, 1, -4))
            }
            chooseIndex := 1
            if IsSet(choose) {
                for fontName in currentFontNameList {
                    if fontName = choose {
                        chooseIndex := A_Index
                        break
                    }
                }
            }
            ddlFont.Delete()
            ddlFont.Add(currentFontNameList)
            ControlChooseIndex(currentFontNameList.Length && chooseIndex, ddlFont)
        }
    }

    WindowFLG_Size(sender, minMax, width, height) {
        editInput.Move(, , width - editInputX - sender.MarginX)
        editOutput.Move(, , width - sender.MarginX * 2, height - editOutputY - statusBarH - sender.MarginY)
    }

    DropDownList_Change(sender, info) {
        try {
            if sender == ddlFont {
                if ddlFont.Value {
                    fl.Load(ddlFont.Text, true, ddlWidth.Value || 1, ddlHeight.Value || 1)
                }
            }
            else if sender == ddlWidth {
                fl.HorizontalLayout := ddlWidth.Value || 1
            }
            else if sender == ddlHeight {
                fl.VerticalLayout := ddlHeight.Value || 1
            }
            editOutput.Text := fl.Generate(currentInput)
        }
        catch as e {
            editOutput.Text := ""
            statusBar.Text := e.Message
        }
    }

    ButtonTestAll_Click(*) {
        if currentInput == "" {
            return
        }
        editOutput.Text := ""
        for ctrl in flg {
            ctrl.Opt("+Disabled")
        }
        ControlFocus(flg)
        index := failedCount := 0
        count := currentFontNameList.Length
        testFL := FIGLet()
        testFL.FontsPath := fl.FontsPath
        stopped := false
        OnMessage(0x0102, WM_CHAR_Proc)
        for fontName in currentFontNameList {
            if stopped {
                break
            }
            try {
                EditPaste("`r`n" fontName ":`r`n", editOutput)
                statusBar.Text := index++ "/" count ", " failedCount " failed, press Ctrl+C to stop"
                testFL.Load(fontName, true, ddlWidth.Value || 1, ddlHeight.Value || 1)
                EditPaste(testFL.Generate(currentInput), editOutput)
            }
            catch as e {
                failedCount++
                EditPaste(e.Message "`n" e.Stack, editOutput)
            }
        }
        OnMessage(0x0102, WM_CHAR_Proc, 0)
        statusBar.Text := index "/" count ", " failedCount " failed"
        for ctrl in flg {
            ctrl.Opt("-Disabled")
        }
        return

        WM_CHAR_Proc(wp, lp, msg, hwnd) {
            if hwnd == flg.Hwnd && wp == 3 {
                return stopped := true
            }
        }
    }

    ButtonCopy_Click(*) {
        A_Clipboard := editOutput.Text
        statusBar.Text := "Copied"
    }

    EditInput_Change(*) {
        currentInput := editInput.Text
        editOutput.Text := fl.Generate(currentInput)
        if currentInput ~= "[^\x00-\xFF]" {
            editInput.Opt("CRed")
            statusBar.Text := "only supports ascii characters"
        }
        else {
            editInput.Opt("-C")
            statusBar.Text := ""
        }
    }
}