proc clearpage {object} {
	set object [getobj $object]
	wm title $object cdraw
	private $object canvas current
	catch {unset current(file)}
	$canvas clear
	$canvas undo check start
}

proc delete {w} {
	set object [getobj $w]
	private $object canvas current
	if [info exists current(cpos)] {
		foreach cpos [lsort -integer -decreasing $current(cpos)] {
			set p1 [expr {2 * $cpos}]
			set p2 [expr {$p1 + 1}]
			set current(coords) [lreplace $current(coords) $p1 $p2]
		}
		eval $canvas coords $current(item) $current(coords)
		$canvas selection redraw
		return
	}
	$canvas delete _sel
}

