package log;

import "core:time"
import "core:fmt"
import "core:strings"

import win "../windows"

write :: proc(args: ..any, sep := " ") {
    t: win.SYSTEMTIME;
    win.GetLocalTime(&t);
    fmt.printf("%2d:%2d:%2d.%3d: ", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds);
    fmt.println(args=args, sep=sep);
}