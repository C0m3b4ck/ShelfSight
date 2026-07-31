proc busy {object text {todo {}}} {
	private $object keepextratool
	if ![winfo exists $object.msg] {
		frame $object.msg
		label $object.msg.text
		Classy::Progress $object.msg.progress
		pack $object.msg.text -side left
		pack $object.msg.progress -side left
	}
	if [isdouble $todo] {
		set todo [expr {int($todo)}]
		pack $object.msg.progress -side left
		$object.msg.progress configure -ticks $todo
		$object.msg.progress set 0
	} else {
		pack forget $object.msg.progress
	}
	$object.msg.text configure -text $text
	if ![info exists keepextratool] {
		set keepextratool [grid info $object.extratool]
		grid forget $object.extratool
		eval grid $object.msg $keepextratool
	}
	Classy::busy .mainw
	update
	return $object.msg.progress
}

proc notbusy {object} {
	private $object keepextratool
	if [info exists keepextratool] {
		grid forget $object.msg
		eval grid $object.extratool $keepextratool
		unset keepextratool
	}
	Classy::busy remove
}

proc busyincr {object {num 1}} {
	$object.msg.progress incr $num
}

proc msg {object text} {
	private $object keepextratool
	if ![winfo exists $object.msg] {
		frame $object.msg
		label $object.msg.text
		Classy::Progress $object.msg.progress
		pack $object.msg.text -side left
		pack $object.msg.progress -side left
	}
	pack forget $object.msg.progress
	$object.msg.text configure -text $text
	if ![info exists keepextratool] {
		set keepextratool [grid info $object.extratool]
		grid forget $object.extratool
		eval grid $object.msg $keepextratool
	}
	return $object.msg.progress
}

proc nomsg {object} {
	private $object keepextratool
	if [info exists keepextratool] {
		grid forget $object.msg
		eval grid $object.extratool $keepextratool
		unset keepextratool
	}
}

