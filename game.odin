package game;

import "core:fmt"

import "vendor:glfw"

import "../log"

init :: proc() -> bool {
    log.write("Init");

    return true;
}

update :: proc(dt: f32) {
    log.write("Update");
}

key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, modes: i32) {
    if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
        engine.exit();
    }
}