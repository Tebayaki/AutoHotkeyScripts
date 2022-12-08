/*
WaitOrTimerCallback(lpParameter, timerOrWaitFired) {
}
*/
RegisterWaitForProcess(pidOrName, callback, param := 0, timeout := -1) {
    if (hProcess := DllCall("OpenProcess", "uint", 0x100000, "int", false, "uint", ProcessExist(pidOrName), "ptr"))
        && DllCall("RegisterWaitForSingleObject", "ptr*", &hNewWaitObject := 0, "ptr", hProcess, "ptr", callback, "ptr", param, "uint", timeout, "uint", 8)
        return hNewWaitObject
    throw OSError()
}

RegisterWaitForThread(tid, callback, param := 0, timeout := -1) {
    if (hThread := DllCall("OpenThread", "uint", 0x100000, "int", false, "uint", tid, "ptr"))
        && DllCall("RegisterWaitForSingleObject", "ptr*", &hNewWaitObject := 0, "ptr", hThread, "ptr", callback, "ptr", param, "uint", timeout, "uint", 8)
        return hNewWaitObject
    throw OSError()
}

UnregisterWaitForProcessThread(waitHandle) => DllCall("UnregisterWait", "ptr", waitHandle)