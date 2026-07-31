#set auto_path {/home/peter/bin /usr/local/lib/tcl8.0 /usr/local/lib /usr/local/lib/tk8.0}
tk appname editextral
package require ClassyTcl
wm withdraw .
eval edit [lsort [glob lib/*.tcl]] [lsort [glob src/*.c]] extral.txt src/Makefile.in
eval edit try.tcl st [glob tests/*.tcl]
eval edit [lsort [glob lib/*.tcl]] [lsort [glob src/*.c]] [lsort [glob tests/*.tcl]]
