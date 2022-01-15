package perf

import "core:math"
import "core:time"
import "vendor:glfw"

import "../log"


buffer_size :: 10


perf_stats :: struct {
    measurements: [buffer_size]time.Duration,
    current_measure_index: i32,
    total: time.Duration,
    average: time.Duration,
    start_time: time.Tick,
}


render: perf_stats
update: perf_stats


start_measure :: proc(stats: ^perf_stats) {
    stats.start_time = time.tick_now()
}


end_measure :: proc(stats: ^perf_stats) {
    using stats
    diff := time.tick_diff(start_time, time.tick_now())
    total -= measurements[current_measure_index]
    measurements[current_measure_index] = diff
    total += diff

    average = total / len(measurements)

    current_measure_index += 1
    if current_measure_index >= len(measurements) {
        current_measure_index = 0
    }
}


start_update :: proc() {
    start_measure(&update)
}


end_update :: proc() {
    end_measure(&update)
}


start_render :: proc() {
    start_measure(&render)
}


end_render :: proc() {
    end_measure(&render)
}


write_stats :: proc() {
    update_time := time.duration_microseconds(update.average)
    render_time := time.duration_microseconds(render.average)
    log.write("Updt", update_time, "us | Rndr", render_time, "us")
}