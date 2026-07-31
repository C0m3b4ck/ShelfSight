#Functions

proc clock_update {} {
global clock
set clock(value) [clock format [clock seconds] -format $::clock(format)]
after 1000 clock_update
}

