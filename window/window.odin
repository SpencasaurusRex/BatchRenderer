package window

import "core:runtime"
import "core:sys/win32"
import "core:strings"
import "core:fmt"

import "../log"

should_close: bool
device_context: win32.Hdc
opengl_context: win32.Hglrc

Window_Mode :: enum {
    Windowed,
    Fullscreen,
    BorderlessFullscreen,
}

open :: proc(window_name: string, width, height: i32, mode: Window_Mode) -> bool {
    using win32

    hmodule := get_module_handle_a(nil)

    CLASS_NAME: cstring : "BatchRendererWindowClass"

    class: Wnd_Class_Ex_A
    class.size = size_of(Wnd_Class_Ex_A)
    class.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC
    class.wnd_proc = _window_proc
    class.cls_extra = 0
    class.wnd_extra = 0
    class.instance = Hinstance(hmodule)
    class.icon = Hicon(nil)
    class.cursor = Hcursor(nil)
    class.background = Hbrush(nil)
    class.menu_name = nil
    class.class_name = CLASS_NAME
    class.sm = Hicon(nil)

    res := register_class_ex_a(&class)
    if res == 0 {
        log.write("Failed to register window class:", get_last_error())
        return false
    }

    ex_style: u32
    style: u32

    switch (mode) {
        case Window_Mode.Windowed:
            ex_style = 0
            style = WS_OVERLAPPEDWINDOW | WS_VISIBLE
        case Window_Mode.Fullscreen:
            ex_style = 0
            style = WS_MAXIMIZE | WS_BORDER | WS_VISIBLE// TODO
        case Window_Mode.BorderlessFullscreen:
            ex_style = 0
            style = WS_MAXIMIZE | WS_VISIBLE// TODO
    }

    title := strings.clone_to_cstring(window_name, context.temp_allocator)

    window_handle := create_window_ex_a(
        ex_style = ex_style, 
        class_name = CLASS_NAME, 
        title = title, 
        style = style, 
        x = CW_USEDEFAULT, y = CW_USEDEFAULT, w = width, h = height, 
        parent = Hwnd(nil), menu = Hmenu(nil), instance = Hinstance(hmodule), 
        param = nil,
    )

    if window_handle == nil {
        log.write("Failed to create window:", get_last_error())
        return false
    }

    device_context = get_dc(Hwnd(uintptr(0)))
    if device_context == Hdc(uintptr(0)) {
        log.write("Failed to get DC:", get_last_error())
        return false
    }

    desired_format: Pixel_Format_Descriptor
    desired_format.size = size_of(desired_format)
    desired_format.version = 1
    desired_format.pixel_type = PFD_TYPE_RGBA
    desired_format.flags = PFD_SUPPORT_OPENGL | PFD_DRAW_TO_WINDOW | PFD_DOUBLEBUFFER
    desired_format.color_bits = 32
    desired_format.alpha_bits = 8
    desired_format.depth_bits = 24
    desired_format.layer_type = PFD_MAIN_PLANE

    format_index := choose_pixel_format(device_context, &desired_format)
    if format_index == 0 {
        log.write("Unable to find a matching pixel format")
        return false
    }

    suggested_format: Pixel_Format_Descriptor
    if describe_pixel_format(device_context, format_index, size_of(suggested_format), &suggested_format) == 0 {
        log.write("Unable to describe pixel format:", get_last_error())
        return false
    }
    
    log.write(suggested_format)

    if set_pixel_format(device_context, format_index, &suggested_format) != true {
        log.write("Unable to set pixel format:", get_last_error())
        return false
    }

    opengl_context = create_context(device_context)
    if opengl_context == rawptr(uintptr(0)) {
        log.write("Failed to create context:", get_last_error())
        return false
    }
    
    if !make_current(device_context, opengl_context) {
        log.write("Unable to make context current:", get_last_error())
        return false
    }
    
    should_close = false
    return true
}

poll_events :: proc() {
    message: win32.Msg
    for {
        message_result := win32.peek_message_a(&message, win32.Hwnd(nil), 0, 0, win32.PM_REMOVE)
        if i32(message_result) <= 0 {
            break
        }

        win32.translate_message(&message)
        win32.dispatch_message_a(&message)
    }
}

_window_proc :: proc "std" (window: win32.Hwnd, message: u32, w_param: win32.Wparam, l_param: win32.Lparam) -> win32.Lresult {
    context = runtime.default_context()
    
    if message == win32.WM_CLOSE || message == win32.WM_QUIT {
        log.write("Exiting")
        should_close = true
    }

    return win32.def_window_proc_a(window, message, w_param, l_param)
}