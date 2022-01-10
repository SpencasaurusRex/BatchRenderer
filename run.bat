@echo off
if [%1] == [release] ( goto :Release ) else ( goto :Debug )

:Release
    odin run main.odin -opt:3
    goto :exit
:Debug
    odin run main.odin -debug
:exit