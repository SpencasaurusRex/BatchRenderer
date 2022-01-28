package winext

import win32 "core:sys/win32"
import win "core:sys/windows"

foreign import kernel32 "system:kernel32.lib"

@(default_calling_convention = "stdcall")
foreign kernel32 {
    GetTimeZoneInformation :: proc(info: ^TIME_ZONE_INFORMATION) -> win.DWORD ---
    GetLocalTime :: proc(lpSystemTime: ^win.SYSTEMTIME) ---
}


TIME_ZONE_INFORMATION :: struct {
    Bias: win.LONG,
    StandardName: [32]win.WCHAR,
    StandardDate: win.SYSTEMTIME,
    StandardBias: win.LONG,
    DaylightName: [32]win.WCHAR,
    DaylightDate: win.SYSTEMTIME,
    DaylightBias: win.LONG,
}