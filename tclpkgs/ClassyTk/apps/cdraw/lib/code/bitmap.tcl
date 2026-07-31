#Functions

proc bitmap_insert {w {file {}}} {
	set object [getobj $w]
	private $object current canvas
	set x [$canvas canvasx [expr {[winfo width $canvas]/2.0}]]
	set y [$canvas canvasy [expr {[winfo height $canvas]/2.0}]]
	$canvas addbitmap $x $y $file
}

