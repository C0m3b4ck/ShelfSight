#Functions

proc print {object {tag all}} {
	private $object canvas
	$canvas print all -command [list doprint $object]
}

proc doprint {object args} {
	private $object canvas
	$canvas lower {_ start} _paper
	$canvas lower {_ end} _paper
	set code [catch {eval $canvas doprint $args} result]
	$canvas raise {_ start} _paper
	$canvas raise {_ end} _paper
	return -code $code $result
}
