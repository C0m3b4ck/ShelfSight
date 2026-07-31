#Functions

proc arc_start w {
	set object [getobj $w]
	private $object current canvas
	focus $canvas
	catch {unset current(item)}
	$canvas selection set {}
	bindtags $canvas [list Arc $canvas Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set current(tool) arc
	extratool $object {}
	changecursor $canvas {}
}

proc arc_action {w x y} {
	set object [getobj $w]
	private $object current canvas
	focus $canvas
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	set current(x) $x
	set current(y) $y
	set current(item) [$canvas create arc $x $y [expr {$x+1}] [expr {$y+1}]]
}

proc arc_motion {w x y} {
	set object [getobj $w]
	private $object current canvas
	if ![info exists current(item)] return
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	$canvas coord $current(item) 1 $x $y	
}

proc arc_release {w x y} {
	set object [getobj $w]
	undocheck $object
}

proc arc_abort {w x y} {
	set object [getobj $w]
	private $object current canvas
	$canvas delete $current(item)
	catch {unset current(item)}
}

