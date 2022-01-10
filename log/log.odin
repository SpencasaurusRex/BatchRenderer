package log

import "core:time"
import "core:fmt"
import "core:strings"
import "core:os"

import win "../windows"

log_to_file_flag := false
log_file_handle : os.Handle

should_log_to_file :: proc(flag: bool) {
    log_to_file_flag = flag
}

write :: proc(args: ..any, sep := " ") {
    _write_formatted(format_message(args=args, sep=sep))
}

// TODO: Change this to write to buffer and asyncrhonously write to file
_write_formatted :: proc(message: string) {
    if log_to_file_flag {
        log_to_file(message)
    }
    fmt.print(message)
}

format_message :: proc(args: ..any, sep := " ") -> string {
    t: win.SYSTEMTIME
    win.GetLocalTime(&t)
    
    message := fmt.tprint(args=args, sep=sep)
    line := fmt.tprintf("%2d:%2d:%2d.%3d: %s\n", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds, message)

    return line
}

log_to_file :: proc(line: string) {
    if log_file_handle == cast(os.Handle)0 {
        _create_log_file()
    }
    
    _, err := os.write_string(log_file_handle, line)
    if err != win.ERROR_NONE {
        should_log_to_file(false)
        write("Failure to write string to file, disabling log to file")
    }
    err = os.flush(log_file_handle)
    if err != win.ERROR_NONE {
        should_log_to_file(false)
        write("Failure to flush string to file, disabling log to file")
    }
}

_create_log_file :: proc() {
    temp_log := strings.make_builder(0, 500, context.temp_allocator)

    file_path_max :: 300
    data: [file_path_max]byte
    
    file_path: string
    
    res := win.GetModuleFileNameA(cast(win.Hmodule)nil, transmute(cstring)&data, file_path_max)

    if win.GetLastError() != 0 {
        fmt.sbprint(&temp_log, format_message("Unable to locate exe, falling back to current directory"))
        file_path = string(os.get_current_directory())
    }
    else {
        file_path = string(data[:])
        file_path = file_path[:strings.last_index(file_path, "\\")]
    }

    file_path = fmt.tprintf("%s\\log.txt", file_path)
    
    err: os.Errno
    log_file_handle,err = os.open(file_path, win.O_CREATE | win.O_WRONLY | win.O_TRUNC)
    if err != 0 {
        should_log_to_file(false)
        fmt.sbprint(&temp_log, format_message("Unable to create log file at", file_path, ", disabling log to file"))
        fmt.print(strings.to_string(temp_log))
        return
    }
    fmt.sbprint(&temp_log, format_message("Logging to", file_path))
    fmt.print(strings.to_string(temp_log))
}