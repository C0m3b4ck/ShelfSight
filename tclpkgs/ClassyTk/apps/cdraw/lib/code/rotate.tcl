proc rotate_switch {w x y} {
	set object [getobj $w]
	private $object current canvas
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	if $current(rotate) {
		set current(rotate) 0 
	} else {
		set current(rotate) 1
	}
	rotate_set $canvas $x $y
}

proc rotate_set {w {x {}} {y {}}} {
	set object [getobj $w]
	private $object current canvas
	if !$current(rotate) {
		$canvas noundo itemconfigure _sb -bitmap [Classy::getbitmap canvas_select]
		$canvas noundo delete _rotatepos
	} else {
		if {"$x" == ""} {
			if [info exists current(rotatex)] {
				set x $current(rotatex)
				set y $current(rotatey)
			} else {
				if ![info exists current(item)] {
					set current(rotate) 0
					return
				}
				set pos [$canvas coords $current(item)]
				set x [lindex $pos 0]
				set y [lindex $pos 1]
			}
		}
		$canvas noundo itemconfigure _sb -bitmap [Classy::getbitmap canvas_rotate]
		$canvas noundo create bitmap $x $y -bitmap [Classy::getbitmap rotatepos] -tags {_rotatepos _sel}
	}
}

