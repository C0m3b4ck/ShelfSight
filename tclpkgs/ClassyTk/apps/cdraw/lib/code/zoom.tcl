#Functions

proc zoom {w {percent {}}} {
	set object [getobj $w]
	private $object zoom current canvas
	if [string length $percent] {	
		if {$percent > 2000} {set percent 2000}
		set x [$canvas canvasx 0]
		set y [$canvas canvasy 0]
		set page [$canvas papersize]
		set pw [lindex $page 2]
		set ph [lindex $page 3]
		$canvas zoom [expr {$percent/100.0}]
		$canvas xview moveto [expr {$x/$pw}]
		$canvas yview moveto [expr {$y/$ph}]
		set zoom $percent
		set current(zoom) $zoom
	} else {
		return [expr {100*[$canvas zoom]}]
	}
}

proc zoom_action {w x y args} {
	set object [getobj $w]
	private $object current canvas
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	set current(x) $x
	set current(y) $y
	$canvas selector $x $y $x $y
	set current(action) sel
}

proc zoom_drag {w x y} {
	set object [getobj $w]
	private $object current canvas
	if ![info exists current(action)] return
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	$canvas selector $current(x) $current(y) $x $y
}

proc zoom_release {w x y args} {
	set object [getobj $w]
	private $object current canvas
	if ![info exists current(action)] return
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	if {($x == $current(x))||($y == $current(y))} {
		undocheck $object
		set f 2.0
		zoom $canvas [expr {round(100.0*[$canvas zoom]/$f)}]
		set page [$canvas papersize]
		set pw [lindex $page 2]
		set ph [lindex $page 3]
		$canvas yview moveto [expr {($y/$f-[winfo height $canvas]/2)/$ph}]
		$canvas xview moveto [expr {($x/$f-[winfo width $canvas]/2)/$pw}]
		undocheck $object
		
	} else {
		set page [$canvas papersize]
		if {$x < $current(x)} {set temp $x; set x $current(x); set current(x) $temp}
		if {$y < $current(y)} {set temp $y; set y $current(y); set current(y) $temp}
		set pw [lindex $page 2]
		set ph [lindex $page 3]
		set width [expr {$x-$current(x)}]
		set height [expr {$y-$current(y)}]
		if {$x < $current(x)} {
			set temp $x
			set x $current(x)
			set current(x) $temp
		}
		if {$y < $current(y)} {
			set temp $y
			set y $current(y)
			set current(y) $temp
		}
		set zf [expr {[winfo width $canvas]/$width}]
		set zfy [expr {[winfo height $canvas]/$height}]
		if {$zfy < $zf} {set zf $zfy}
		undocheck $object
		zoom $canvas [expr {round(100.0*[$canvas zoom]*$zf)}]
		$canvas yview moveto [expr {$current(y)/$ph}]
		$canvas xview moveto [expr {$current(x)/$pw}]
		undocheck $object
	}
	$canvas selector -100 -100 -100 -100
	unset current(action)
}

proc zoom_adjust {w x y} {
}

proc zoom_abort {w x y} {
	set object [getobj $w]
	private $object current canvas
	catch {unset current(action)}
	$canvas selection redraw
	$canvas selector -100 -100 -100 -100
	return -code break
}

proc zoom_start w {
	set object [getobj $w]
	private $object current canvas
	set current(w) $canvas
	$canvas selection set {}
	bindtags $canvas [list Zoom $canvas Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set current(tool) zoom
	extratool $object Zoom
	changecursor $canvas zoompointer circle
}

proc zoomentry {w} {
	Classy::NumEntry $w -label %
	return [varsubst w {
		$w configure -command [list zoom %W] -textvariable [privatevar %W current(zoom)] \
			-combo 1 -combopreset {echo {100 10 25 50 75 100 200 300 400}}
	}]
}

