Persistent()
gInterval := 1000

DllCall("GetSystemTimes", "uint64*", &gIdleTimeBefore := 0, "uint64*", &gKernelTimeBefore := 0, "uint*", &gUserTimeBefore := 0)
SetTimer(UpdateCpuUsage, gInterval)
UpdateCpuUsage() {
    global gIdleTimeBefore, gKernelTimeBefore, gUserTimeBefore
    DllCall("GetSystemTimes", "uint64*", &idleTime := 0, "uint64*", &kernelTime := 0, "uint*", &userTime := 0)
    sum := kernelTime - gKernelTimeBefore + userTime - gUserTimeBefore
    usage := sum ? (sum - (idleTime - gIdleTimeBefore)) / sum * 100 : ""
    gIdleTimeBefore := idleTime, gKernelTimeBefore := kernelTime, gUserTimeBefore := userTime
    ToolTip(Format("{:.2f}", usage), A_ScreenWidth, A_ScreenHeight)
}