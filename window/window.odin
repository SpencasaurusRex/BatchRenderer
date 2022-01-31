package window

import "core:runtime"
import "core:sys/win32"
import "core:strings"
import "core:fmt"

import gl "vendor:OpenGL"

import "../log"

should_close: bool
device_context: win32.Hdc
opengl_context: win32.Hglrc
window_handle: win32.Hwnd
prev_window_placement: win32.Window_Placement

key_changed: key_callback

Window_Mode :: enum {
    Windowed,
    Fullscreen,
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
    class.cursor = load_cursor_a(nil, win32.IDC_ARROW)
    class.background = Hbrush(nil)
    class.menu_name = nil
    class.class_name = CLASS_NAME
    class.sm = Hicon(nil)

    res := register_class_ex_a(&class)
    if res == 0 {
        log.write("Failed to register window class:", get_last_error())
        return false
    }

    ex_style: u32 = 0
    style: u32 = WS_OVERLAPPEDWINDOW | WS_VISIBLE

    title := strings.clone_to_cstring(window_name, context.temp_allocator)

    window_handle = create_window_ex_a(
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

    should_close = true

    device_context = get_dc(window_handle)
    if device_context == Hdc(nil) {
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
        log.write("Failed to find a matching pixel format", get_last_error())
        return false
    }

    suggested_format: Pixel_Format_Descriptor
    if describe_pixel_format(device_context, format_index, size_of(suggested_format), &suggested_format) == 0 {
        log.write("Failed to describe pixel format:", get_last_error())
        return false
    }

    if !set_pixel_format(device_context, format_index, &suggested_format) {
        log.write("Failed to set pixel format:", get_last_error())
        return false
    }

    opengl_context = create_context(device_context)
    if opengl_context == nil {
        log.write("Failed to create context:", get_last_error())
        return false
    }
    
    if !make_current(device_context, opengl_context) {
        log.write("Failed to make context current:", get_last_error())
        return false
    }
    
    should_close = false
    if mode == .Fullscreen {
        toggle_fullscreen()
    }
    
    return true
}

toggle_fullscreen :: proc() {
    if should_close {
        return
    }

    style := win32.get_window_long_ptr_a(window_handle, win32.GWL_STYLE)
    if style & win32.WS_OVERLAPPEDWINDOW == 0 {
        // Set windowed
        win32.set_window_long_ptr_a(window_handle, win32.GWL_STYLE, style | win32.WS_OVERLAPPEDWINDOW)
        win32.set_window_placement(window_handle, &prev_window_placement)
        win32.set_window_pos(window_handle, nil, 0, 0, 0, 0, win32.SWP_NOMOVE | win32.SWP_NOSIZE | win32.SWP_NOZORDER | win32.SWP_NOOWNERZORDER | win32.SWP_FRAMECHANGED)
    }
    else {
        // Set fullscreen
        prev_window_placement.length = size_of(win32.Window_Placement)
        
        if !win32.get_window_placement(window_handle, &prev_window_placement) {
            log.write("Unable to get window placement:", win32.get_last_error())
        }

        monitor := win32.monitor_from_window(window_handle, win32.MONITOR_DEFAULTTONEAREST)// MONITOR_DEFAULTTOPRIMARY
        if monitor == nil {
            log.write("Unable to get monitor:", win32.get_last_error())
            return
        }

        monitor_info: win32.Monitor_Info
        monitor_info.size = size_of(win32.Monitor_Info)
        if !win32.get_monitor_info_a(monitor, &monitor_info) {
            log.write("Unable to get monitor info:", win32.get_last_error())
            return
        }

        win32.set_window_long_ptr_a(window_handle, win32.GWL_STYLE, style & ~win32.Long_Ptr(win32.WS_OVERLAPPEDWINDOW))
        rect := monitor_info.monitor
        win32.set_window_pos(window_handle, win32.Hwnd(nil), 
            rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top,
            win32.SWP_NOOWNERZORDER | win32.SWP_FRAMECHANGED)
    }
}

poll_events :: proc() {
    message: win32.Msg
    for {
        message_result := win32.peek_message_a(&message, win32.Hwnd(nil), 0, 0, win32.PM_REMOVE)
        if i32(message_result) <= 0 {
            break
        }

        switch(message.message) {
            case win32.WM_SIZE:
                // TODO: Need to wrap this into resize callback
                gl.Viewport(0, 0, i32(win32.LOWORD_L(message.lparam)), i32(win32.HIWORD_L(message.lparam)))
                // TODO: redraw
        
            // TODO: Need to handle Alt+F4 & other key combos
            case win32.WM_KEYDOWN:
                fallthrough
            case win32.WM_KEYUP:
                fallthrough
            case win32.WM_SYSKEYDOWN:
                fallthrough
            case win32.WM_SYSKEYUP:
                key_code := int(message.wparam)
                
                first_down := (message.lparam >> 30) & 1 == 0
                first_up := (message.lparam >> 31) & 1 == 1
                repeat := !first_down && !first_up
                
                if key_changed != nil {
                    key_changed(key_code, !first_up, repeat)
                }

            case:
                win32.translate_message(&message)
                win32.dispatch_message_a(&message)
        }
    }
}

swap_buffers :: proc() {
    win32.swap_buffers(device_context)
}

set_key_callback :: proc(callback: key_callback) {
    key_changed = callback
}

key_callback :: proc(keycode: int, pressed, repeat: bool)

_window_proc :: proc "std" (window: win32.Hwnd, message: u32, wparam: win32.Wparam, lparam: win32.Lparam) -> win32.Lresult {
    context = runtime.default_context()

    switch message {
        case win32.WM_DESTROY:
            fallthrough
        case win32.WM_CLOSE:
            fallthrough
        case win32.WM_QUIT:
            should_close = true
    }
    return win32.def_window_proc_a(window, message, wparam, lparam)
}