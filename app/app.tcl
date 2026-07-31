#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@"

# ShelfSight GUI -- plain Tcl/Tk (vTcl-generated apps look like this).
# `shelf_today`, `shelf_add_days`, `add_ints` are C++ functions linked into
# the single executable via libshelf.a.

wm title . "ShelfSight"
wm geometry . 480x360

set f [frame .f -borderwidth 2 -relief groove]
pack $f -fill both -expand 1 -padx 8 -pady 8

label $f.l1 -text "Today:" -anchor w
label $f.v1 -text "" -anchor w -width 24 -relief sunken -bg white
grid $f.l1 -row 0 -column 0 -sticky w -padx 4 -pady 4
grid $f.v1 -row 0 -column 1 -sticky we -padx 4 -pady 4

label $f.l2 -text "Add days:" -anchor w
entry $f.e2 -width 10
label $f.v2 -text "" -width 24 -relief sunken -bg white
grid $f.l2 -row 1 -column 0 -sticky w -padx 4 -pady 4
grid $f.e2 -row 1 -column 1 -sticky w -padx 4 -pady 4
grid $f.v2 -row 1 -column 2 -sticky we -padx 4 -pady 4

button $f.b1 -text "Add" -command {
    if {[catch {set n [expr {int([$f.e2 get])}]}]} { set n 0 }
    $f.v2 configure -text [shelf_add_days $today $n]
}
button $f.b2 -text "Quit" -command exit
grid $f.b1 -row 2 -column 1 -sticky w -padx 4 -pady 8
grid $f.b2 -row 2 -column 2 -sticky e -padx 4 -pady 8

set today [shelf_today]
$f.v1 configure -text $today
$f.e2 insert 0 "14"

focus $f.e2
