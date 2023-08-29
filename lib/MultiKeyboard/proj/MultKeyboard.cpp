#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <queue>
#include <map>

typedef LRESULT (*KEYEVENT)(WPARAM, LPARAM);

struct KBRAWINPUT {
    DWORD dwType;
    DWORD dwSize;
    HANDLE hDevice;
    KEYEVENT callback;
    USHORT MakeCode;
    USHORT Flags;
    USHORT Reserved;
    USHORT VKey;
    UINT Message;
    ULONG ExtraInformation;
};

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam);
LRESULT CALLBACK KeyboardProc(int code, WPARAM wParam, LPARAM lParam);
extern "C" {
__declspec(dllexport) BOOL InstallHook(HWND hWnd);
__declspec(dllexport) VOID UninstallHook();
__declspec(dllexport) BOOL CreateKeyBinding(HANDLE keyboardID, UCHAR virtualKeyCode, BOOLEAN isDown, KEYEVENT callback);
__declspec(dllexport) BOOL DeleteKeyBinding(HANDLE keyboardID, UCHAR virtualKeyCode, BOOLEAN isDown);
__declspec(dllexport) BOOL IsKeyboardActive(HANDLE keyboardID);
}

EXTERN_C IMAGE_DOS_HEADER __ImageBase;
#define HMODULE_CURRENT (HMODULE) & __ImageBase
#define WM_RAWKBHOOK WM_APP + 1
#define GET_KEYBINDING_MAP_KEY(virtualKeyCode, isDown, keyboardID) (((UINT64)(virtualKeyCode) << 56) | ((UINT64)(isDown) << 48) | (UINT64)(keyboardID))
constexpr WCHAR UWP_CLASSNAME[] = L"Windows.UI.Core.CoreWindow";
constexpr UINT UWP_CLASSNAME_LEN = sizeof(UWP_CLASSNAME) / sizeof(*UWP_CLASSNAME);

#pragma data_seg("Shared")
HWND g_hWnd = NULL;
#pragma data_seg()
#pragma comment(linker, "/SECTION:Shared,RWS")
WNDPROC g_oldWndProc = NULL;
HHOOK g_hook = NULL;
BOOL g_blockKey = FALSE;
std::queue<KBRAWINPUT> g_rawKBInputQueue;
std::map<UINT64, KEYEVENT> g_keyBindingMap;

BOOL InstallHook(HWND hWnd) {
    if (!IsWindow(hWnd) || g_hWnd || g_hook || g_oldWndProc) {
        return FALSE;
    }
    RAWINPUTDEVICE rawInputDevice = {1, 6, RIDEV_INPUTSINK, hWnd};
    BOOL isRawInputDeviceRegistered = FALSE;

    g_oldWndProc = (WNDPROC)SetWindowLongPtr(hWnd, GWLP_WNDPROC, (LONG_PTR)WndProc);
    if (!g_oldWndProc) {
        goto handleError;
    }

    isRawInputDeviceRegistered = RegisterRawInputDevices(&rawInputDevice, 1, sizeof(rawInputDevice));
    if (!isRawInputDeviceRegistered) {
        goto handleError;
    }

    ChangeWindowMessageFilterEx(hWnd, WM_RAWKBHOOK, MSGFLT_ALLOW, NULL);
    g_hWnd = hWnd;
    g_hook = SetWindowsHookEx(WH_KEYBOARD, KeyboardProc, HMODULE_CURRENT, 0);
    if (!g_hook) {
        goto handleError;
    }
    return TRUE;

handleError:
    if (g_oldWndProc) {
        SetWindowLongPtr(hWnd, GWLP_WNDPROC, (LONG_PTR)g_oldWndProc);
        g_oldWndProc = NULL;
    }
    if (isRawInputDeviceRegistered) {
        rawInputDevice.dwFlags = RIDEV_REMOVE;
        rawInputDevice.hwndTarget = NULL;
        RegisterRawInputDevices(&rawInputDevice, 1, sizeof(rawInputDevice));
    }
    if (g_hWnd) {
        ChangeWindowMessageFilterEx(hWnd, WM_RAWKBHOOK, MSGFLT_RESET, NULL);
        g_hWnd = NULL;
    }
    return FALSE;
}

VOID UninstallHook() {
    if (g_hWnd) {
        if (g_oldWndProc) {
            SetWindowLongPtr(g_hWnd, GWLP_WNDPROC, (LONG_PTR)g_oldWndProc);
            g_oldWndProc = NULL;
        }
        ChangeWindowMessageFilterEx(g_hWnd, WM_RAWKBHOOK, MSGFLT_RESET, NULL);
        g_hWnd = NULL;
    }
    RAWINPUTDEVICE rawInputDevice = {1, 6, RIDEV_REMOVE, NULL};
    RegisterRawInputDevices(&rawInputDevice, 1, sizeof(rawInputDevice));
    if (g_hook) {
        UnhookWindowsHookEx(g_hook);
        g_hook = NULL;
    }
    while (!g_rawKBInputQueue.empty()) {
        g_rawKBInputQueue.pop();
    }
    g_blockKey = NULL;
    std::queue<KBRAWINPUT>().swap(g_rawKBInputQueue);
    std::map<UINT64, KEYEVENT>().swap(g_keyBindingMap);
}

BOOL CreateKeyBinding(HANDLE keyboardID, UCHAR virtualKeyCode, BOOLEAN isDown, KEYEVENT callback) {
    if (!g_hWnd || !g_hook || !g_oldWndProc || !virtualKeyCode || !callback) {
        return FALSE;
    }
    g_keyBindingMap[GET_KEYBINDING_MAP_KEY(virtualKeyCode, !isDown, keyboardID)] = callback;
    return TRUE;
}

BOOL DeleteKeyBinding(HANDLE keyboardID, UCHAR virtualKeyCode, BOOLEAN isDown) {
    if (!g_hWnd || !g_hook || !g_oldWndProc || !virtualKeyCode) {
        return FALSE;
    }
    std::map<UINT64, KEYEVENT>::iterator iter;
    iter = g_keyBindingMap.find(GET_KEYBINDING_MAP_KEY(virtualKeyCode, !isDown, keyboardID));
    if (iter == g_keyBindingMap.end()) {
        return FALSE;
    }
    g_keyBindingMap.erase(iter);
    return TRUE;
}

BOOL IsKeyboardActive(HANDLE keyboardID) {
    MSG msg;
    ULONGLONG timeBefore = GetTickCount64();
    while (!PeekMessage(&msg, g_hWnd, WM_INPUT, WM_INPUT, PM_REMOVE)) {
        if (GetTickCount64() - timeBefore > 30) {
            return NULL;
        }
    }
    WndProc(msg.hwnd, msg.message, msg.wParam, msg.lParam);
    if (!g_rawKBInputQueue.empty() && g_rawKBInputQueue.back().hDevice == keyboardID) {
        g_blockKey = TRUE;
        timeBefore = GetTickCount64();
        do {
            PeekMessage(&msg, g_hWnd, WM_RAWKBHOOK, WM_RAWKBHOOK, PM_NOREMOVE);
            if (!g_blockKey) {
                return TRUE;
            }
        }
        while (GetTickCount64() - timeBefore <= 30);
        return FALSE;
    }
    return FALSE;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    if (message == WM_INPUT) {
        // Cannot hook UWP application, so exclude it
        static GUITHREADINFO guiThreadInfo = {sizeof(GUITHREADINFO)};
        static WCHAR className[UWP_CLASSNAME_LEN] = {};
        GetGUIThreadInfo(NULL, &guiThreadInfo);
        GetClassName(guiThreadInfo.hwndFocus, className, UWP_CLASSNAME_LEN);
        if (!wcscmp(className, UWP_CLASSNAME)) {
            return (GET_RAWINPUT_CODE_WPARAM(wParam) == RIM_INPUT) ? DefWindowProc(hWnd, message, wParam, lParam) : 0;
        }

        g_rawKBInputQueue.emplace();
        UINT cbRawInput = sizeof(KBRAWINPUT);
        if (GetRawInputData((HRAWINPUT)lParam, RID_INPUT, &g_rawKBInputQueue.back(), &cbRawInput, sizeof(RAWINPUTHEADER)) != sizeof(KBRAWINPUT)) {
            return (GET_RAWINPUT_CODE_WPARAM(wParam) == RIM_INPUT) ? DefWindowProc(hWnd, message, wParam, lParam) : 0;
        }
        std::map<UINT64, KEYEVENT>::iterator iter = g_keyBindingMap.find(GET_KEYBINDING_MAP_KEY(g_rawKBInputQueue.back().VKey, g_rawKBInputQueue.back().Flags & 1, g_rawKBInputQueue.back().hDevice));
        g_rawKBInputQueue.back().callback = (iter == g_keyBindingMap.end()) ? NULL : iter->second;
        return (GET_RAWINPUT_CODE_WPARAM(wParam) == RIM_INPUT) ? DefWindowProc(hWnd, message, wParam, lParam) : 0;
    }
    else if (message == WM_RAWKBHOOK) {
        while (!g_rawKBInputQueue.empty()) {
            if (g_rawKBInputQueue.front().VKey == wParam && (g_rawKBInputQueue.front().Flags & 1) == (lParam >> 31)) {
                if (g_blockKey) {
                    g_blockKey = FALSE;
                    g_rawKBInputQueue.pop();
                    return 1;
                }
                if (g_rawKBInputQueue.front().callback) {
                    LRESULT res = g_rawKBInputQueue.front().callback(wParam, (lParam >> 31) ? 0 : 1) ? 0 : 1;
                    g_rawKBInputQueue.pop();
                    return res;
                }
                g_rawKBInputQueue.pop();
                return 0;
            }
            g_rawKBInputQueue.pop();
        }
        // No match because WM_RAWKBHOOK is received before WM_INPUT, wait and then handle WM_INPUT
        MSG msg;
        ULONGLONG timeBefore = GetTickCount64();
        while (!PeekMessage(&msg, hWnd, WM_INPUT, WM_INPUT, PM_REMOVE)) {
            if (GetTickCount64() - timeBefore > 30) {
                return 0;
            }
        }
        if (msg.wParam == RIM_INPUT) {
            DefWindowProc(msg.hwnd, msg.message, msg.wParam, msg.lParam);
        }
        g_rawKBInputQueue.emplace();
        UINT cbRawInput = sizeof(KBRAWINPUT);
        if (GetRawInputData((HRAWINPUT)msg.lParam, RID_INPUT, &g_rawKBInputQueue.back(), &cbRawInput, sizeof(RAWINPUTHEADER)) != sizeof(KBRAWINPUT)) {
            return 0;
        }
        if (g_rawKBInputQueue.front().VKey == wParam && (g_rawKBInputQueue.front().Flags & 1) == (lParam >> 31)) {
            if (g_rawKBInputQueue.front().callback) {
                LRESULT res = g_rawKBInputQueue.front().callback(wParam, (lParam >> 31) ? 0 : 1) ? 0 : 1;
                g_rawKBInputQueue.pop();
                return res;
            }
            g_rawKBInputQueue.pop();
            return 0;
        }
        // No match, the correct WM_INPUT is missing possibly
        return 0;
    }
    return CallWindowProc(g_oldWndProc, hWnd, message, wParam, lParam);
}

LRESULT CALLBACK KeyboardProc(int code, WPARAM wParam, LPARAM lParam) {
    if (code == HC_ACTION && SendMessage(g_hWnd, WM_RAWKBHOOK, wParam, lParam)) {
        return 1;
    }
    return CallNextHookEx(NULL, code, wParam, lParam);
}