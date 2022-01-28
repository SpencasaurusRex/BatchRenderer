package winext

import win32 "core:sys/win32"
import win "core:sys/windows"

foreign import kernel32 "system:kernel32.lib"

@(default_calling_convention = "stdcall")
foreign kernel32 {
    GetTimeZoneInformation :: proc(info: ^TIME_ZONE_INFORMATION) -> win.DWORD ---
    GetLocalTime :: proc(lpSystemTime: ^SYSTEMTIME) ---
}


TIME_ZONE_INFORMATION :: struct {
    Bias: win.LONG,
    StandardName: [32]win.WCHAR,
    StandardDate: SYSTEMTIME,
    StandardBias: win.LONG,
    DaylightName: [32]win.WCHAR,
    DaylightDate: SYSTEMTIME,
    DaylightBias: win.LONG,
}


SYSTEMTIME :: struct {
    wYear: win.WORD,
    wMonth: win.WORD,
    wDayOfWeek: win.WORD,
    wDay: win.WORD,
    wHour: win.WORD,
    wMinute: win.WORD,
    wSecond: win.WORD,
    wMilliseconds: win.WORD,
}