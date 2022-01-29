package gl

import "core:sys/win32"

foreign import OpenGL "system:opengl32.lib"

@(default_calling_convention = "c")
foreign OpenGL {
    @(link_name="glClearColor") ClearColor :: proc(r, g, b, a: f32) ---
    @(link_name="glClear")      Clear      :: proc(mask: i32) ---
    @(link_name="glViewport")   Viewport   :: proc(x, y: i32, width, height: u32) ---
    
}

DEPTH_BUFFER_BIT               :: 0x00000100
STENCIL_BUFFER_BIT             :: 0x00000400
COLOR_BUFFER_BIT               :: 0x00004000

load_functions :: proc() {
    
}

@private
_get_proc_address :: proc(p: rawptr, name: cstring) {
    fptr := win32.get_gl_proc_address(name)
    (^rawptr)(p)^ = fptr
}