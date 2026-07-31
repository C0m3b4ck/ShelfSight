#doc {listcommands list_fill} cmd {
#list_fill ?size? ?start? ??incr??
#} descr {
#	fills a list of ?size? elements with ?start?; if ?incr? is given and ?size? is a number, each element in the list will be the former incremented with ?incr?
#   This works for integers or strings
#} example {
#	% list_fill 4 "Hello world"
#	{Hello world} {Hello world} {Hello world} {Hello world}
#	% list_fill 5 2 2
#	2 4 6 8 10
#	% list_fill 5 10 -2
#	10 8 6 4 2
#}
proc list_fill {args} {
	if {([llength $args]!=2)&&([llength $args]!=3)} {
		error "wrong # args: should be \"list_fill size start ?incr?\""
	}
	set result ""
	foreach {size start incr} $args break
	if {[llength $args]==2} {
		for {set i 0} {$i<$size} {incr i} {
			lappend result $start
		}
	} else {
		if {![isint $incr]} {
			set start [expr {double($start)}]
		}
		for {set i 0} {$i<$size} {incr i} {
			lappend result $start
			set start [expr {$start + $incr}]
		}
	}
	return $result
}

interp alias {} list_ffill {} list_fill 

#doc {listcommands list_subindex} cmd {
#list_subindex ?list? ?pos? ...
#} descr {
#	returns a list of the 'pos' element in each of the elements of the given list
#} example {
#	% list_subindex {{a 1} {b 2} {c 3}} 1
#	1 2 3
#}
proc list_subindex {args} {
	if {[llength $args] < 2} {
		error "wrong # args: should be \"list_subindex list pos ?pos ...?\""
	}
	set result ""
	if {[llength $args] == 2} {
		set index [lindex $args 1]
	} else {
		set index [lrange $args 1 end]
	}
	if {[llength $index] == 1} {
		if {![isint $index]} {error "expected integer but got \"[lindex $index 0]\""}
		foreach elem [lindex $args 0] {
			lappend result [lindex $elem $index]
		}
	} else {
		foreach pos $index {
			if {![isint $pos]} {error "expected integer but got \"$pos\""}
		}
		foreach elem [lindex $args 0] {
			set temp {}
			foreach pos $index {
				lappend temp [lindex $elem $pos]
			}
			lappend result $temp
		}
	}
	return $result
}
