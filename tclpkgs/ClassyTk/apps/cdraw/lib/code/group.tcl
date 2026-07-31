proc group w {
	set object [getobj $w]
	private $object canvas
	$canvas group withtag _sel
}

proc ungroup w {
	set object [getobj $w]
	private $object current canvas
	$canvas dtag [$canvas findgroup $current(item)]
}

