package test

import "core:time"
import "core:os"

import "window"
import "log"

main :: proc() {
    when ODIN_DEBUG {
        log.should_log_to_console(true)
        log.should_log_to_file(true)
    }
    else {
        log.should_log_to_console(false)
        log.should_log_to_file(true)
    }

    window.open("Testing window name", 800, 600, window.Window_Mode.Fullscreen)

    for !window.should_close {
        time.sleep(time.Millisecond * 1)
        window.poll_events()
    }
}