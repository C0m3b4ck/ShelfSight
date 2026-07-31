proc extratool {w type} {
	set object [getobj $w]
	private $object current
	if ![info exists current(prevtool)] {
		set current(prevtool) [$object.extratool cget -type]
	}
	if [string length $type] {
		$object.extratool configure -type $type
	} else {
		if [info exists current(prevtool)] {
			if ![string_equal [$object.extratool cget -type] $current(prevtool)] {
				$object.extratool configure -type $current(prevtool)
			}
			unset current(prevtool)
		}
	}
}

proc getobj {w} {
	if [info exists ::status($w,object)] {
		return $::status($w,object)
	} else {
		return $w
	}
}

proc toolvar {w name} {
	privatevar [getobj $w] current($name)]
}

proc getname {canvas id} {
	return [lindex [lindex [$canvas itemcget $id -tags] 1] 2]
}

proc gettype {canvas id} {
	return [lindex [lindex [$canvas itemcget $id -tags] 1] 0]
}

proc getpart {canvas id} {
	return [lindex [lindex [$canvas itemcget $id -tags] 1] 3]
}

proc checkargs {format vars arg} {
	set pos 0
	set lengths {}
	set actualvars ""
	foreach var $vars {
		if [regexp {^\?} $var] {
			list_addnew lengths $pos
		}
		if [regexp {\?$} $var] {
			list_addnew lengths [expr {$pos+1}]
		}
		lappend actualvars [string trimright [string trimleft $var "?"] "?"]
		incr pos
	}
	set len [llength $arg]
	foreach num $lengths {
		if {$len == $num} {
			set actualvars [lrange $actualvars 0 [expr {$len-1}]]
			if $len {uplevel [list foreach $actualvars $arg {}]}
			return $len
		}
	}	
	if ![regsub @ $format $vars format] {
		set format "$format $vars"
	}
	return -code error "wrong # of args: should be \"$format\""
}

proc mktestvars {args} {
	set body ""
	foreach var $args {
		set val [uplevel get $var]
		append body "\nuplevel set $var [list [list $val]]"
	}
	proc testvars {} $body
}

proc changed {object {value {}}} {
	private $object changed canvas
	if ![string length $value] {
		return [get changed 0]
	} elseif $value {
		set title [wm title $object]
		if ![regexp {\*$} $title] {
			wm title $object "$title *"
		}
		$canvas configure -changedcommand {}
	} else {
		set title [wm title $object]
		if [regsub { \*$} $title {} title] {
			wm title $object $title
		}		
		$canvas configure -changedcommand [list changed $object 1]
	}
	set changed $value
}

proc _getalltags {object} {
	global current
	if ![info exists current(object)] return
	set object $current(object)
	private $object canvas
	set list [eval list_concat [$canvas mitemcget all -tags]]
	set list [list_sub $list -exclude [list_find -glob $list _*]]
	set list [list_remdup $list]
	return $list
}
