package perf

import "vendor:glfw"

import "../log"

buffer_size :: 100

perf_stats :: struct {
    measurements: [buffer_size]f32,
    current_measure_index: i32,
    total: f32,
    average: f32,
    start_time: f32,
}

render: perf_stats
update: perf_stats

start_measure :: proc(stats: ^perf_stats) {
    stats.start_time = f32(glfw.GetTime())
}

end_measure :: proc(stats: ^perf_stats) {
    using stats
    diff := f32(glfw.GetTime()) - start_time
    total -= measurements[current_measure_index]
    measurements[current_measure_index] = diff
    total += diff

    average = total / len(measurements)

    current_measure_index += 1
    if current_measure_index >= len(&measurements) {
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
    log.write(args={"Update: ", update.average * 1000, "ms | Render: ", render.average * 1000, "ms"}, sep="")
}