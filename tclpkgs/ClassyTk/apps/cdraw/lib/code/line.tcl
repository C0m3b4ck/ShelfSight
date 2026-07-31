#Functions

proc line_action {object x y} {
	set object [getobj $object]
	private $object current canvas
	focus $canvas
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	if [info exists current(item)] {
		set cur $current(item)
		set coords [$canvas coords $cur]
		lappend coords $x $y
		if {[llength $coords] == 6} {
			if {([lindex $coords 0]==[lindex $coords 2])&&([lindex $coords 1]==[lindex $coords 3])} {
				set coords [lrange $coords 2 end]
			}
		}
		eval $canvas coords $cur $coords
	} else {
		set current(item) [$canvas create line $x $y $x $y]
	}
}

proc line_motion {object x y} {
	set object [getobj $object]
	private $object current canvas
	if ![info exists current(item)] return
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	set cur $current(item)
	set coords [$canvas coords $cur]
	set pos [expr {[llength $coords]/2-1}]
	$canvas coord $cur $pos $x $y
}	

proc line_abort {object x y} {
	set object [getobj $object]
	private $object current
	catch {unset current(item)}
}

proc line_start object {
	set object [getobj $object]
	private $object current canvas
	focus $canvas
	catch {unset current(item)}
	$canvas selection set {}
	bindtags $canvas [list Line $canvas Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set current(tool) line
	extratool $object {}
	changecursor $canvas crosshair
}

