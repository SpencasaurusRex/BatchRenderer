package windows

import win "core:sys/windows"

foreign import kernel32 "system:kernel32.lib"

@(default_calling_convention = "stdcall")
foreign kernel32 {
    GetTimeZoneInformation :: proc(info: ^TIME_ZONE_INFORMATION) -> DWORD ---
    GetLocalTime :: proc(lpSystemTime: ^SYSTEMTIME) ---
}

TIME_ZONE_INFORMATION :: struct {
    Bias: win.LONG,
    StandardName: [32]WCHAR,
    StandardDate: SYSTEMTIME,
    StandardBias: LONG,
    DaylightName: [32]WCHAR,
    DaylightDate: SYSTEMTIME,
    DaylightBias: LONG,
};

SYSTEMTIME :: struct {
    wYear: WORD,
    wMonth: WORD,
    wDayOfWeek: WORD,
    wDay: WORD,
    wHour: WORD,
    wMinute: WORD,
    wSecond: WORD,
    wMilliseconds: WORD,
};