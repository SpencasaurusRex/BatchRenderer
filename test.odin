package test

import "core:time"
import "core:os"

import "window"
import "log"

import "core:sys/win32"

main :: proc() {
    log.should_log_to_console(true)
    log.should_log_to_file(true)

    window.open("Testing window name", 800, 600, window.Window_Mode.Windowed)

    for !window.should_close {
        time.sleep(time.Millisecond * 1)
        window.poll_events()
    }
}