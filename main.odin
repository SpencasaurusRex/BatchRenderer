package engine

import "core:time"
import "core:fmt"
import "core:math"
import "core:math/rand"

import "perf"
import "log"
import "renderer"
import "trace"
import "data"

import "window"

update_count: int

game_data: data.Game_Data

update_stats: perf.Frame_Stats
render_stats: perf.Frame_Stats
FRAME_STATS_COUNT :: 10

main :: proc() {
    log.should_log_to_console(true)
    log.should_log_to_file(true)
    log.write("Starting")
    
    res_x, res_y : i32 = 800,600
    
    log.write("Creating window", res_x, "x", res_y)
    
    window.open("Batch Renderer", res_x, res_y, .Windowed)
    window.set_key_callback(key_callback)

    if !renderer.init() {
        log.write("Unable to initialize renderer")
        return
    }

    if !init() {
        log.write("Unable to initialize game")
    }

    previous_time := time.now()

    for !window.should_close {
        new_time := time.now()
        
        perf.start_measure(&update_stats)
        update(time.duration_seconds(time.diff(previous_time, new_time)))
        perf.end_measure(&update_stats)
        
        previous_time = new_time
        
        perf.start_measure(&render_stats)
        renderer.draw(&game_data)
        perf.end_measure(&render_stats)

        window.swap_buffers()
        window.poll_events()
    }
}


init :: proc() -> bool {
    trace.proc_start()
    defer trace.proc_end()
    
    log.write("Init")

    game_data.entities = make([dynamic]data.Entity, 1000)
    for entity in &game_data.entities {
        entity.pos.x = rand.float32_range(0, 1)
        entity.pos.y = rand.float32_range(0, 1)
        entity.rot = rand.float32_range(0, math.PI * 2)
    }

    perf.init(&update_stats, FRAME_STATS_COUNT)
    perf.init(&render_stats, FRAME_STATS_COUNT)

    return true
}


update :: proc(dt: f64) {
    for entity in &game_data.entities {
        entity.rot += f32(dt)
        update_transform(&entity)
    }

    if update_count % 100 == 0 {
        log.write("Update:", time.duration_microseconds(update_stats.average), "us", "Render:", time.duration_microseconds(render_stats.average), "us")
    }

    update_count += 1
}


key_callback :: proc(key_code: int, pressed: bool) {
    log.write(key_code, pressed)
}


// key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, modes: i32) {
//     if key == glfw.KEY_ESCAPE && action == glfw.PRESS {
//         glfw.SetWindowShouldClose(window, true)
//     }
// }


// size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
//     gl.Viewport(0, 0, width, height)
// }


update_transform :: proc(using entity: ^data.Entity) {
    transform = translation(pos.x, pos.y) * rotation(rot)
}


rotation :: proc(theta: f32) -> matrix[4, 4]f32 {
    c := math.cos(theta);
    s := math.sin(theta);

    return matrix[4, 4]f32 {
        c,-s, 0, 0,
        s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };
}


translation :: proc(x, y: f32) -> matrix[4, 4]f32 {
    return matrix[4, 4]f32 {
        1, 0, 0, x,
        0, 1, 0, y,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };
}