
proc newwindow {} {
global num
if ![info exists num] {set num 2} else {incr num}
mainw .mainw$num

}

