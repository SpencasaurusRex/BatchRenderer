package gl

import "core:sys/win32"

foreign import OpenGL "system:opengl32.lib"

@(default_calling_convention = "c")
foreign OpenGL {
    @(link_name="glClearColor") ClearColor :: proc(r, g, b, a: f32) ---
    @(link_name="glClear")      Clear      :: proc(mask: i32) ---
    @(link_name="glViewport")   Viewport   :: proc(x, y: i32, width, height: u32) ---
    
}

load_functions :: proc() {
    
}

DEPTH_BUFFER_BIT               :: 0x00000100
STENCIL_BUFFER_BIT             :: 0x00000400
COLOR_BUFFER_BIT               :: 0x00004000

@private
_get_proc_address :: proc(p: rawptr, name: cstring) {
    fptr := win32.get_gl_proc_address(name)
    
    // negative_one := -1
    // negative_one_pointer := transmute(rawptr)(negative_one)

    // if fptr == nil || fptr == negative_one_pointer || fptr == rawptr(uintptr(1)) || fptr == rawptr(uintptr(2)) || fptr == rawptr(uintptr(3)) {
    //     fptr = win32.get_proc_address(win32.get_module_handle_a("opengl32.dll"), name)
    // }
    (^rawptr)(p)^ = fptr
}