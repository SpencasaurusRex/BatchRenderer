package renderer

import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:sys/win32"

import "../log"
import "../perf"
import "../trace"
import "../data"

render_data: data.Render_Data

get_proc_address :: proc(p: rawptr, name: cstring) {
    (cast(^rawptr)p)^ = glfw.GetProcAddress(name)
}

init :: proc() -> bool {
    trace.proc_start()
    defer trace.proc_end()

    gl.load_up_to(4, 6, get_proc_address)
    log.write(args={"Loaded OpenGL ", gl.loaded_up_to[0], ".", gl.loaded_up_to[1]}, sep="")

    gl.ClearColor(0.2, 0.3, 0.3, 1.0)

    if !load_shaders() { return false }
    get_uniforms()
    load_buffers()

    return true
}

load_shaders :: proc() -> bool {
    fragment_shader := gl.CreateShader(gl.FRAGMENT_SHADER)
    fragment_source := string(#load("shaders/fragment.glsl"))
    fragment_source_len := i32(len(fragment_source))
    fragment_source_data := cstring(raw_data(fragment_source))
    gl.ShaderSource(fragment_shader, 1, &fragment_source_data, &fragment_source_len)
    gl.CompileShader(fragment_shader)

    if !check_shader(fragment_shader) { return false }

    vertex_shader := gl.CreateShader(gl.VERTEX_SHADER)
    vertex_source := string(#load("shaders/vertex.glsl"))
    vertex_source_len := i32(len(vertex_source))
    vertex_source_data := cstring(raw_data(vertex_source))

    gl.ShaderSource(vertex_shader, 1, &vertex_source_data, &vertex_source_len)
    gl.CompileShader(vertex_shader)
    if !check_shader(vertex_shader) { return false }

    render_data.program = gl.CreateProgram()
    gl.AttachShader(render_data.program, fragment_shader)
    gl.AttachShader(render_data.program, vertex_shader)
    gl.LinkProgram(render_data.program)

    gl.DetachShader(render_data.program, fragment_shader)
    gl.DetachShader(render_data.program, vertex_shader)
    gl.DeleteShader(fragment_shader)
    gl.DeleteShader(vertex_shader)

    return true
}

get_uniforms :: proc() {
    count: i32
    gl.GetProgramiv(render_data.program, gl.ACTIVE_UNIFORMS, &count)

    uniform_length: i32
    gl.GetProgramiv(render_data.program, gl.ACTIVE_UNIFORM_MAX_LENGTH, &uniform_length)

    len: i32
    size: i32
    _type: u32
    name := make([]byte, uniform_length)
    
    for i: u32 = 0; i < u32(count); i += 1 {
        gl.GetActiveUniform(render_data.program, i, uniform_length, &len, &size, &_type, &name[0])
        uniform_name := string(cstring(&name[0]))
        
        uniform_location := gl.GetUniformLocation(render_data.program, cstring(&name[0]))

        render_data.uniforms[uniform_name] = uniform_location
    }
}

check_shader :: proc(shader: u32) -> bool {
    stat: i32
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &stat)

    if (stat == 1) { return true }

    len: i32
    gl.GetShaderiv(shader, gl.INFO_LOG_LENGTH, &len)
    
    info_log_data := make([]byte, len)
    defer delete(info_log_data)

    gl.GetShaderInfoLog(shader, len, &len, &info_log_data[0])
    info_log := cstring(&info_log_data[0])

    log.write(args={"Unable to compile shader:\n", info_log}, sep="")
    return false
}

load_buffers :: proc() {
    gl.GenVertexArrays(1, &render_data.vao)
    gl.GenBuffers(1, &render_data.vbo)
    gl.GenBuffers(1, &render_data.ebo)

    gl.BindVertexArray(render_data.vao)

    gl.BindBuffer(gl.ARRAY_BUFFER, render_data.vbo)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(rectangle_vertices), &rectangle_vertices, gl.STATIC_DRAW)
    gl.VertexAttribPointer(0, 3, gl.FLOAT, false, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, render_data.ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(rectangle_indices), &rectangle_indices, gl.STATIC_DRAW)

    gl.UseProgram(render_data.program)
}

rectangle_vertices := [?]f32 {
    0.5, 0.5, 0.0,
    0.5,-0.5, 0.0,
   -0.5,-0.5, 0.0,
   -0.5, 0.5, 0.0,
}

rectangle_indices := [?]u32 {
    0, 1, 3,
    1, 2, 3,
}

draw :: proc(game: ^data.Game_Data) {
    gl.Clear(gl.COLOR_BUFFER_BIT)
    
    gl.BindVertexArray(render_data.vao)
    for entity, i in game.entities {
        gl.UniformMatrix4fv(render_data.uniforms["transform"], 1, false, &game.entities[i].transform[0, 0])
        gl.DrawElements(gl.TRIANGLES, len(rectangle_indices), gl.UNSIGNED_INT, rawptr(uintptr(0)))
    }
}