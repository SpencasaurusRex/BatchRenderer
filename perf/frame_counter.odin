package perf

import "core:math"
import "core:time"
import "vendor:glfw"

import "../log"

Perf_Stats :: struct {
    measurements: [dynamic]time.Duration,
    current_measure_index: int,
    total: time.Duration,
    average: time.Duration,
    start_time: time.Tick,
}

init :: proc(stats: ^Perf_Stats, size: int) {
    stats.measurements = make([dynamic]time.Duration, size)
}

start_measure :: proc(stats: ^Perf_Stats) {
    stats.start_time = time.tick_now()
}

end_measure :: proc(stats: ^Perf_Stats) {
    using stats
    diff := time.tick_diff(start_time, time.tick_now())
    total -= measurements[current_measure_index]
    measurements[current_measure_index] = diff
    total += diff

    average = time.Duration(f64(total) / f64(len(measurements)))

    current_measure_index += 1
    if current_measure_index >= len(measurements) {
        current_measure_index = 0
    }
}