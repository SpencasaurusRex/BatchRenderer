package renderer

import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:sys/win32"

import "../log"
import "../perf"

get_proc_address :: proc(p: rawptr, name: cstring) {
    (cast(^rawptr)p)^ = glfw.GetProcAddress(name)
}

init :: proc() -> bool {
    gl.load_up_to(4, 6, get_proc_address)
    log.write(args={"Loaded OpenGL ", gl.loaded_up_to[0], ".", gl.loaded_up_to[1]}, sep="")

    gl.ClearColor(0.2, 0.3, 0.3, 1.0)

    load_shaders()

    return true
}

load_shaders :: proc() -> u32 {
    program: u32
    fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    fragment_source := string(#load("shaders/fragment.glsl"))
    fragment_source_len := i32(len(fragment_source))
    fragment_source_data := cstring(raw_data(fragment_source))
    gl.ShaderSource(fragment_shader, 1, &fragment_source_data, &fragment_source_len)
    gl.CompileShader(fragment_shader)

    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    vertex_source := string(#load("shaders/vertex.glsl"))
    vertex_source_len := i32(len(vertex_source))
    vertex_source_data := cstring(raw_data(vertex_source))
    gl.ShaderSource(vertex_shader, 1, &vertex_source_data, &vertex_source_len)
    gl.CompileShader(vertex_shader)

    program = gl.CreateProgram()
    gl.AttachShader(program, fragment_shader)
    gl.AttachShader(program, vertex_shader)
    gl.LinkProgram(program)

    gl.DetachShader(program, fragment_shader)
    gl.DetachShader(program, vertex_shader)
    gl.DeleteShader(fragment_shader)
    gl.DeleteShader(vertex_shader)

    return program
}

clear :: proc() {
    gl.Clear(gl.COLOR_BUFFER_BIT)
}

draw :: proc() {
    perf.start_render()
    clear()
    perf.end_render()
}