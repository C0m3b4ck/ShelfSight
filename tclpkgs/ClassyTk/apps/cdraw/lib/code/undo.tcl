proc undo {object} {
	private $object canvas
	if [catch {$canvas undo} result] {
		if ![string_equal $result "No more undo steps"] {
			error $result
		}
	}
}

proc redo {object} {
	private $object canvas
	if [catch {$canvas redo} result] {
		if ![string_equal $result "Nothing to redo"] {
			error $result
		}
	}
}

proc clearundo {object} {
	private $object canvas
	$canvas undo clear
	$canvas undo check start
}

proc undoon {object {value {}}} {
	private $object canvas current
	if ![string length $value] {
		set value $current(undo)
	}
	$canvas undo $value
	set current(undo) $value
	clearundo $object
}

proc undosteps {object} {
	private $object canvas
	Classy::Dialog .undosteps -title "Undo steps"
	.undosteps add go "Go" [varsubst canvas {
		$canvas configure -undosteps [.undosteps.options.steps get]
	}] default
	Classy::NumEntry .undosteps.options.steps -label "Number of undo steps" -orient stacked
	pack .undosteps.options.steps -fill x
	.undosteps.options.steps set [$canvas cget -undosteps]
}

proc undocheck object {
	private $object canvas
	$canvas undo check
}
