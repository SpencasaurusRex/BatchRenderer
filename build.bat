@echo off
if [%1] == [release] ( goto :Release ) else ( goto :Debug )

:Release
    odin build main.odin -opt:3
    goto :exit
:Debug
    odin build main.odin -debug
:exit