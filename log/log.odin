package log;

import "core:time"
import "core:fmt"

import win "../windows"

write :: proc(message: string) {
    t: win.SYSTEMTIME;
    win.GetLocalTime(&t);
    fmt.printf("%2d:%2d:%2d.%3d: %s\n", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds, message);
}