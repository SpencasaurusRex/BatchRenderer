package test

import "window"
import "log"

main :: proc() {
    log.should_log_to_console(true)
    log.should_log_to_file(true)
    window.open("Testing window name", 800, 600, window.Window_Mode.Windowed)
}