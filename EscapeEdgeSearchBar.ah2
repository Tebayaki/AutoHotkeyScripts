#Include <UIAutomation>

; Take focus out from chrome and edge's omnibar
#HotIf WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe msedge.exe")
~Esc:: {
    focused := IUIAutomation.GetFocusedElement()
    try {
        if focused.CurrentAcceleratorKey == "Ctrl+L" {
            focused.GetCurrentPattern(CONST.UIA_ValuePatternId).SetValue("javascript:()")
            ControlSend("{Enter}", , "A")
        } else if toolbar := IUIAutomation.CreateTreeWalker(IUIAutomation.CreateAndCondition(IUIAutomation.CreatePropertyCondition(CONST.UIA_NamePropertyId, "应用栏"), IUIAutomation.CreatePropertyCondition(CONST.UIA_ControlTypePropertyId, CONST.UIA_ToolBarControlTypeId))).GetParentElement(focused) {
            if omnibar := IUIAutomation.CreateTreeWalker(IUIAutomation.CreatePropertyCondition(CONST.UIA_AcceleratorKeyPropertyId, "Ctrl+L")).GetFirstChildElement(toolbar) {
                omnibar.SetFocus()
                omnibar.GetCurrentPattern(CONST.UIA_ValuePatternId).SetValue("javascript:()")
                ControlSend("{Enter}", , "A")
            }
        }
    }
}