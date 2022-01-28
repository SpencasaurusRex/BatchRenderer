package test

import "core:time"
import "core:os"
import "core:fmt"
import "core:sys/win32"

import gl "vendor:OpenGL"
import "vendor:glfw"

import "window"
import "log"

import "perf"

impl_ClearColor: proc "c" (red: f32, green: f32, blue: f32, alpha: f32)
other_proc :: proc "c" (red, green, blue, alpha: f32) { impl_ClearColor(red, green, blue, alpha) } 

main :: proc() {
    log.should_log_to_console(true)
    log.should_log_to_file(true)

    window.open("Test window", 800, 600, .Windowed)
    
    get_proc_address_manual(&impl_ClearColor, "glClearColor")
    log.write("Loaded proc:", impl_ClearColor)

    for !window.should_close {
        window.poll_events()
        
        // OpenGL stuff
        gl.Clear(gl.COLOR_BUFFER_BIT)

        time.sleep(time.Millisecond * 1)
    }
}


get_proc_address_glfw :: proc(p: rawptr, name: cstring) {
    (cast(^rawptr)p)^ = glfw.GetProcAddress(name)
    log.write("glfw:", p)
}

get_proc_address_manual :: proc(p: rawptr, name: cstring) {
    fmt.println(win32.get_gl_proc_address(name))
    (cast(^rawptr)p)^ = win32.get_gl_proc_address(name)
}