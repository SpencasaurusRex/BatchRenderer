package data


Render_Data :: struct {
    vao: u32,
    vbo: u32,
    ebo: u32,
    program: u32,
    uniforms: map[string]i32,
}