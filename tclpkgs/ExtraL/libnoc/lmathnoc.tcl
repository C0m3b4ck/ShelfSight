# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc {lmath lmath_calc} cmd {
#	lmath_calc ?list1? ?action? ?list2?
#} descr {
#	makes calculations on lists. Action can be one of +, -, * or /
#	list2 may also be a single number, in which case
#	this number will be used for all elements in list1
#} example {
#	% lmath_calc {1 2 3.2 4} + {1 2 3.2 4}
#	2.0 4.0 6.4 8.0
#}
proc lmath_calc {args} {
	if {([llength $args] != 3) && ([llength $args] != 4)} {
		error "wrong # args: should be \"lmath_calc list1 action list2 ?startpos?\""
	}
	set result ""
	foreach {l1 calc l2 startpos} $args break
	set len1 [llength $l1]
	set len2 [llength $l2]
	if {[isint $startpos]} {
		foreach e2 $l2 {
			set e1 [lindex $l1 $startpos]
			if {![isdouble $e1]} break
			set val [expr $e1 $calc $e2]
			lset l1 $startpos $val
			incr startpos
		}
		return $l1
	} else {
		if {$len1 == 1} {
			set e1 [lindex $l1 0]
			foreach e2 $l2 {
				lappend result [expr $e1 $calc $e2]
			}
		} elseif {$len2 == 1} {
			set e2 [lindex $l2 0]
			foreach e1 $l1 {
				lappend result [expr $e1 $calc $e2]
			}
		} else {
			if {$len2 > $len1} {set l2 [lrange $l2 0 [expr {$len1-1}]]}
			if {$len1 > $len2} {set l1 [lrange $l1 0 [expr {$len2-1}]]}
			foreach e1 $l1 e2 $l2 {
				lappend result [expr $e1 $calc $e2]
			}
		}
		return $result
	}
}

#doc {lmath lmath_sum} cmd {
#	lmath_sum ?list?
#} descr {
#	returns the sum of the numbers in the list
#}
proc lmath_sum {args} {
	if {[llength $args]!=1} {
		error "wrong # args: should be \"lmath_sum list\""
	}
	set result 0
	foreach e1 [lindex $args 0]  {
		set result [expr {$result+$e1}]
	}
	return $result
}

#doc {lmath lmath_average} cmd {
#	lmath_between ?list?
#} descr {
#	returns the average of the numbers in the list.
#}
proc lmath_average {args} {
	if {[llength $args]!=1} {
		error "wrong # args: should be \"lmath_average list\""
	}
	set result 0.0
	set list [lindex $args 0]
	foreach e1 $list  {
		set result [expr {$result+$e1}]
	}
	return [expr {$result/[llength $list]}]
}

#doc {lmath lmath_min} cmd {
#	lmath_min ?list?
#} descr {
#	returns the minimum of the numbers in the list
#}
proc lmath_min {args} {
	if {[llength $args]!=1} {
		error "wrong # args: should be \"lmath_min list\""
	}
	set list [lindex $args 0]
	set result [lindex $list 0]
	if {![isdouble $result]} {
		error "expected floating-point number but got \"$result\""
	}
	foreach e1 $list  {
		if {![isdouble $e1]} {
			error "expected floating-point number but got \"$e1\""
		}
		if {$e1<$result} {
			set result $e1
		}
	}
	return $result
}

#doc {lmath lmath_max} cmd {
#	lmath_max ?list?
#} descr {
#	returns the maximum of the numbers in the list
#}
proc lmath_max {args} {
	if {[llength $args]!=1} {
		error "wrong # args: should be \"lmath_max list\""
	}
	set list [lindex $args 0]
	if {![llength $list]} {return {}}
	set result [lindex $list 0]
	if {![isdouble $result]} {
		error "expected floating-point number but got \"$result\""
	}
	foreach e1 $list  {
		if {![isdouble $e1]} {
			error "expected floating-point number but got \"$e1\""
		}
		if {$e1 > $result} {
			set result $e1
		}
	}
	return $result
}

#doc {lmath lmath_filter} cmd {
#	lmath_filter list filter ?filterpos? ?unfilteredvalue?
#} descr {
#	applies the filter by sliding it over the list, multiplying all elements of the filter with 
#	the current elements in the list, and changing the list element in the middle of the 
#	filter (or at filterpos) with the sum of the products.
#	The numbers at the beginning and end of the list that are not covered by the filter, are given the value
#	of the first, respectively last element that can be calculated, unless a value for these is
#	explicitly given (unfilteredvalue)
#	returns the filtered list
#}
proc lmath_filter {list filter {filterpos {}} args} {
	set len [llength $list]
	set flen [llength $filter]
	if {![isint $filterpos]} {
		set filterpos [expr {$flen/2}]
	}
	if {($filterpos < 0) || ($filterpos >= $flen)} {
		error "filterpos outside of filter"
	}
	if {[llength $args] > 1} {
		error "wrong # args: should be \"lmath_filter list filter ?filterpos? ?unfilteredvalue?\""
	} elseif {[llength $args] == 1} {
		set unfilteredvalue [lindex $args 0]
		set useunfilteredvalue 1
	} else {
		set useunfilteredvalue 0
	}
	if {[llength $filter] > [llength $list]} {
		error "filter longer than list"
	}
	if {!$useunfilteredvalue} {
		set el 0.0
		foreach f $filter v [lrange $list 0 [expr {$flen - 1}]] {
			set el [expr {$el+$f*$v}]
		}
		#set result [lrange $list 0 [expr {$filterpos - 1}]]
		set result [list_fill $filterpos $el]
	} else {
		set result [list_fill $filterpos $unfilteredvalue]
	}
	set end [expr {$len - $flen+1}]
	for {set pos 0} {$pos < $end} {incr pos} {
		set el 0.0
		foreach f $filter v [lrange $list $pos [expr {$pos+$flen-1}]] {
			set el [expr {$el+$f*$v}]
		}
		lappend result $el
	}
	if {!$useunfilteredvalue} {
		#eval lappend result [lrange $list end-[expr {$len-$filterpos-2}] end]
		eval lappend result [list_fill [expr {$flen-$filterpos-1}] $el]
	} else {
		eval lappend result [list_fill [expr {$flen-$filterpos-1}] $unfilteredvalue]
	}
	return $result
}
