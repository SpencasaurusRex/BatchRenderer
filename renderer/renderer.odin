package renderer

import "vendor:glfw"
import gl "vendor:OpenGL"

import "../log"

get_proc_address :: proc(p: rawptr, name: cstring) {
    (cast(^rawptr)p)^ = glfw.GetProcAddress(name);
}

init :: proc() -> bool {
    gl.load_up_to(4, 6, get_proc_address);
    log.write("Loaded", gl.loaded_up_to);

    return true;
}