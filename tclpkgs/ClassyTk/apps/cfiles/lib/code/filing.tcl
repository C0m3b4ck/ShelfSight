#Functions
proc gettext {file} {
	return [file tail $file]
}

proc getimage {file} {
	if {[file isdirectory $file]} {
		return [Classy::geticon folder]
	} else {
		return [Classy::geticon file]
	}
}

proc getsmimage {file} {
	set pre {}
	if {[file isdirectory $file]} {
		return [Classy::geticon sm_folder]
	} else {
		return [Classy::geticon sm_file]
	}
}

proc getdata {file} {
	file lstat $file temp
	array set attr [file attributes $file]
	set data ""
	lappend data $attr(-permissions)
	lappend data "$attr(-owner).$attr(-group)"
	lappend data $temp(size)
	lappend data [clock format $temp(mtime) -format "%b %d %H:%M %Y"]
	return $data
}

proc getdir {dir} {
	if {"$dir" == ""} return
	set dirs {}
	set files {}
	if {[string first * $dir] == -1} {
		set dir $dir/*
	}
	foreach file [glob -nocomplain $dir] {
		if {[file isdirectory $file]} {
			lappend dirs $file
		} else {
			lappend files $file
		}
	}
	set result ..
	foreach file [lsort $dirs] {
		lappend result $file
	}
	foreach file [lsort $files] {
		lappend result $file
	}
	return $result
}

proc setdir {w dir} {
	global status
	set status($w,dir) $dir
	$w selection clear
	$w configure -list [getdir $dir]
	setfile $w {}
}

proc setfile {w file} {
	global status
	set status($w,file) $file
	set status($w,keepfile) $file
	catch {$w active $file} result
#	catch {$w selection set $file} result
}

proc file_rename {w file} {
	global status
	file rename $status($w,keepfile) $file
	redraw $w
}

proc redraw {w} {
	global status
	$w configure -list [getdir $status($w,dir)]
	setfile $w $status($w,file)
}

proc newfiler {} {
	set num 1
	while 1 {
		if ![winfo exists .filerw$num] break
		incr num
	}
	mainw .filerw$num
}

