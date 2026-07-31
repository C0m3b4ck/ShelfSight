#Functions

proc filer_exec {w x y} {
	set w [Classy::object $w]
	set name [$w name $x $y]
	if {"$name" == ""} return
	$w active set $name
	set curdir [file dirname [lindex [$w cget -list] 1]]
	if {"$name" == ".."} {
		if {"$curdir" != "."} {
			set name [file dirname $curdir]
		} else {
			set name [file dirname [pwd]]
		}
	}
	if [file isdir $name] {
		setdir $w $name
	} else {
		$w selection add $name
		puts $name
	}
}

proc filer_exec_adjust {w x y} {
	set w [Classy::object $w]
	set name [$w name $x $y]
	if {"$name" == ""} return
	$w active set $name
	set curdir [file dirname [lindex [$w cget -list] 1]]
	if {"$name" == ".."} {
		if {"$curdir" != "."} {
			set name [file dirname $curdir]
		} else {
			set name [file dirname [pwd]]
		}
	}
	if [file isdir $name] {
		set num 1
		while {[winfo exists .mainw$num]} {incr num}
		mainw .mainw$num
		setdir .mainw$num.browser $name
	} else {
		$w selection add $name
		puts $name
	}
}

proc filer_action {w x y} {
	set w [Classy::object $w]
	set name [$w name $x $y]
	if {"$name" == ".."} return
	if {"$name" == ""} return
	setfile $w $name
	if ![$w selection includes $name] {
		$w selection add $name
	} else {
		$w selection delete $name
	}
}

proc filer_adjust {w x y} {
	set w [Classy::object $w]
	set name [$w name $x $y]
	if {"$name" == ".."} return
	if {"$name" == ""} return
	setfile $w $name
	if ![$w selection includes $name] {
		$w selection add $name
	} else {
		$w selection delete $name
	}
}

proc browser_order {window {type {}}} {
	global status
	if {"$type" == ""} {
		set type $status($window,order)
	} else {
		set status($window,order) $type
	}
	$window configure -order $type
}

proc browser_dataunder {window {value {}}} {
	global status
	if {"$value" == ""} {
		set value $status($window,dataunder)
	} else {
		set status($window,dataunder) $value
	}
	$window configure -dataunder $value
}

proc browser_small {window {value {}}} {
	global status
	if {"$value" == ""} {
		set value $status($window,small)
	} else {
		set status($window,small) $value
	}
	if $value {
		$window configure -getimage getsmimage
	} else {
		$window configure -getimage getimage
	}
}

proc browser_data {window {value {}}} {
	global status
	if {"$value" == ""} {
		set value $status($window,data)
	} else {
		set status($window,data) $value
	}
	if $value {
		$window configure -data {perm owner size date}
	} else {
		$window configure -data {}
	}
}

proc filer_drag {w x y X Y} {
	if [catch {$w name $x $y} name] return
	if {"$name" == ""} return
	set files [$w selection get]
	if {[llength $files]>1} {
		set image [Classy::geticon folder]
	} else {
		if {[file isdirectory [lindex $files 0]]} {
			set image [Classy::geticon folder]
		} else {
			set image [Classy::geticon file]
		}
	}
	DragDrop start $X $Y $files -types [list url/file $files] -image $image
}

