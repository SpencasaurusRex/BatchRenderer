package log;

import "core:time"
import "core:fmt"
import "core:strings"
import "core:os"

import win "../windows"

log_to_file_flag := false;

should_log_to_file :: proc(flag: bool) {
    log_to_file_flag = flag;
}

write :: proc(args: ..any, sep := " ") {
    t: win.SYSTEMTIME;
    win.GetLocalTime(&t);
    
    fmt.printf("%2d:%2d:%2d.%3d: ", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds);
    fmt.println(args=args, sep=sep);

    if log_to_file_flag {
        log_to_file();
    }
}

log_to_file :: proc() {
    
}