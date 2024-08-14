/**
 * @author Tebayaki
 * @version 0.1
 * @description 切换多屏模式，类似于Win+P
 * @param mode
 * internal: 仅主屏幕
 * clone: 复制屏幕
 * extend: 扩展屏幕
 * external: 仅第二屏幕
 * toggle: 在仅主屏和扩展之间切换
 */
DisplaySwitch(mode) {
    if mode = "toggle" {
        displayCount := DllCall("GetSystemMetrics", "int", 80, "int") ; SM_CMONITORS := 80
        mode := displayCount > 1 ? "internal" : "extend"
    }
    ; Run("DisplaySwitch /" mode)
    flags := 0x80 ; SDC_APPLY
    switch mode {
        case "internal": flags |= 1 ; SDC_TOPOLOGY_INTERNAL
        case "clone": flags |= 2 ; SDC_TOPOLOGY_CLONE
        case "extend": flags |= 4 ; SDC_TOPOLOGY_EXTEND
        case "external": flags |= 8 ; SDC_TOPOLOGY_EXTERNAL
        default: return
    }
    return DllCall("SetDisplayConfig", "uint", 0, "ptr", 0, "uint", 0, "ptr", 0, "uint", flags)
}