package test

import "core:time"
import "core:os"
import "core:fmt"
import "core:sys/win32"

import "vendor:glfw"

import "window"
import "log"
import "gl"
import "perf"

main :: proc() {
    log.should_log_to_console(true)
    log.should_log_to_file(true)

    window.open("Test window", 800, 600, .Windowed)
    window.set_key_callback(key_callback, true)

    gl.load_functions()
    gl.ClearColor(0.3, 0.3, 0.3, 1.0)

    for !window.should_close {
        window.poll_events()
        window.draw()
        time.sleep(time.Millisecond * 1)
    }
}

key_callback :: proc(key_code: int, pressed: bool) {
    log.write(key_code, pressed)
}