#Functions

proc rectangle_start w {
	set object [getobj $w]
	private $object current canvas
	focus $canvas
	catch {unset current(item)}
	$canvas selection set {}
	bindtags $canvas [list Rectangle $canvas Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set current(tool) rectangle
	extratool $object {}
	changecursor $canvas dotbox
}

proc rectangle_action {w x y} {
	set object [getobj $w]
	private $object current canvas
	focus $canvas
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	set current(x) $x
	set current(y) $y
#	set current(item) [$canvas create rectangle $x $y $x $y]
	set current(item) [$canvas create polygon $x $y $x $y $x $y $x $y -fill {} -outline black]
}

proc rectangle_motion {w x y} {
	set object [getobj $w]
	private $object current canvas
	if ![info exists current(item)] return
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
#	$canvas coord $current(item) 1 $x $y
	$canvas coords $current(item) $current(x) $current(y) $x $current(y) $x $y $current(x) $y
}

proc rectangle_release {w x y} {
	set object [getobj $w]
	undocheck $object
}

proc rectangle_abort {w x y} {
	set object [getobj $w]
	private $object current canvas
	$canvas delete $current(item)
	catch {unset current(item)}
}


