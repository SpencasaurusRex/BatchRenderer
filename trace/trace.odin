package trace

import "core:strings"
import "core:fmt"
import "core:os"
import "core:time"

import "../log"
import win "../windows"

output_buffer: strings.Builder
output_file_handle: os.Handle

start_tick: time.Tick

record_stack_pointer: int
record_stack: [dynamic]Trace_Record

Trace_Record :: struct {
    name: string,
    start: time.Tick,
}

init :: proc() { 
    if _create_trace_file() {
        fmt.println("Unable to create trace output file")
        return
    }
    
    os.write_string(output_file_handle, "{\"otherData\": {},\"traceEvents\":[")
    os.flush(output_file_handle)

    output_buffer = strings.make_builder_len_cap(0, 1024)

    start_tick = time.tick_now()
}

stop :: proc() {
    os.seek(output_file_handle, -2, 1)
    os.write_string(output_file_handle, "]}")
    os.flush(output_file_handle)
}

when ODIN_DEBUG {
    proc_start :: proc(loc := #caller_location) {
        if output_file_handle == 0 {
            return
        }
        name := _name(loc.procedure, loc.file_path)

        if len(record_stack) <= record_stack_pointer {
            append(&record_stack, Trace_Record{})
        }
        record_stack[record_stack_pointer].name = name
        record_stack[record_stack_pointer].start = time.tick_now()

        record_stack_pointer += 1
    }

    proc_end :: proc(loc := #caller_location) {
        if output_file_handle == 0 {
            return
        }
        name := _name(loc.procedure, loc.file_path)

        if record_stack_pointer < 1 {
            panic("Mismatched trace.proc_end call")
        }
        
        record_stack_pointer -= 1
        record := record_stack[record_stack_pointer]

        if record.name != name {
            panic("Mismatched proc_end call")
        }

        dur := time.tick_since(record.start)

        _record(name, record.start, dur, 0)
    }
}
else {
    proc_start :: #force_inline proc() {}
    proc_end :: #force_inline proc() {}
}

@private
_create_trace_file :: proc() -> bool {
    FILE_PATH_MAX :: 300
    data: [FILE_PATH_MAX]byte
    
    file_path: string
    
    res := win.GetModuleFileNameA(cast(win.Hmodule)nil, transmute(cstring)&data, FILE_PATH_MAX)

    if win.GetLastError() != 0 {
        log.write("Unable to locate exe, falling back to current directory")
        file_path = string(os.get_current_directory())
    }
    else {
        file_path = string(data[:])
        file_path = file_path[:strings.last_index(file_path, "\\")]
    }


    file_path = fmt.tprintf("%s\\trace.json", file_path)
    
    err: os.Errno
    output_file_handle,err = os.open(file_path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC)
    if err != 0 {
        log.write("Unable to create trace file at", file_path)
        return false
    }

    return true
}

@private
_name :: proc(proc_name, file_path: string) -> string {
    from,to := strings.last_index(file_path, "/"), strings.last_index(file_path, ".")
    file := file_path[from+1:to]
    return fmt.tprintf("%s/%s", file, proc_name)
}

@private
_record :: proc(name: string, start: time.Tick, dur: time.Duration, thread: int) {
    diff := time.tick_diff(start_tick, start)
    fmt.sbprintln(buf=&output_buffer, args={"{"}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"\t\"cat\":\"function\","}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"\t\"dur\":", time.duration_milliseconds(dur), ','}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"\t\"name\":\"", name, "\","}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"\t\"ph\":\"X\","}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"\t\"pid\":0,"}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"\t\"tid\":", thread, ","}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"\t\"ts\":", time.duration_milliseconds(diff)}, sep="")
    fmt.sbprintln(buf=&output_buffer, args={"},"}, sep="")
    
    os.write_string(output_file_handle, strings.to_string(output_buffer))
    os.flush(output_file_handle)
    
    strings.reset_builder(&output_buffer)
}