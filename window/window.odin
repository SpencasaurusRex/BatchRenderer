package window

import "core:runtime"
import "core:sys/win32"
import "core:strings"
import "core:fmt"

import "../log"

should_close: bool

Window_Mode :: enum {
    Windowed,
    Fullscreen,
    BorderlessFullscreen,
}

open :: proc(window_name: string, width, height: i32, mode: Window_Mode) -> bool {
    hmodule := win32.get_module_handle_a(nil)

    CLASS_NAME: cstring : "BatchRendererWindowClass"

    class: win32.Wnd_Class_Ex_A
    class.size = size_of(win32.Wnd_Class_Ex_A)
    class.style = win32.CS_HREDRAW | win32.CS_VREDRAW | win32.CS_OWNDC
    class.wnd_proc = _window_proc
    class.cls_extra = 0
    class.wnd_extra = 0
    class.instance = win32.Hinstance(hmodule)
    class.icon = win32.Hicon(nil)
    class.cursor = win32.Hcursor(nil)
    class.background = win32.Hbrush(nil)
    class.menu_name = nil
    class.class_name = CLASS_NAME
    class.sm = win32.Hicon(nil)

    res := win32.register_class_ex_a(&class)
    if res == 0 {
        log.write("Failed to register window class:", win32.get_last_error())
        return false
    }

    ex_style: u32
    style: u32

    switch (mode) {
        case Window_Mode.Windowed:
            ex_style = 0
            style = win32.WS_OVERLAPPEDWINDOW | win32.WS_VISIBLE
        case Window_Mode.Fullscreen:
            ex_style = 0
            style = win32.WS_MAXIMIZE | win32.WS_BORDER | win32.WS_VISIBLE// TODO
        case Window_Mode.BorderlessFullscreen:
            ex_style = 0
            style = win32.WS_MAXIMIZE | win32.WS_VISIBLE// TODO
    }

    title := strings.clone_to_cstring(window_name, context.temp_allocator)

    window_handle := win32.create_window_ex_a(
        ex_style = ex_style, 
        class_name = CLASS_NAME, 
        title = title, 
        style = style, 
        x = win32.CW_USEDEFAULT, y = win32.CW_USEDEFAULT, w = width, h = height, 
        parent = win32.Hwnd(nil), menu = win32.Hmenu(nil), instance = win32.Hinstance(hmodule), 
        param = nil,
    )

    if window_handle == nil {
        log.write("Failed to create window:", win32.get_last_error())
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