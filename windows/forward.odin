package windows

import win "core:sys/windows"
import win32 "core:sys/win32"
import "core:os"

GetModuleFileNameA :: win32.get_module_file_name_a
GetLastError :: win.GetLastError

Hmodule :: win32.Hmodule

Handle :: os.Handle
LONG :: win.LONG
WCHAR :: win.WCHAR
WORD :: win.WORD
DWORD :: win.DWORD
LPCSTR :: win.LPCSTR

O_TRUNC :: os.O_TRUNC
O_CREATE :: os.O_CREATE
O_WRONLY :: os.O_WRONLY

ERROR_NONE :: os.ERROR_NONE