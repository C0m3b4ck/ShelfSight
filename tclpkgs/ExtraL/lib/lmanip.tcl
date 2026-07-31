# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc {listcommands list_mangle} cmd {
#list_mangle ?list1? ?list2?
#} descr {
#	mangles two lists into one
#} example {
#	% list_mangle {a b c} {1 2 3}
#	{a 1} {b 2} {c 3}
#}
proc list_mangle {args} {
	if {[llength $args]!=2} {
		error "wrong # args: should be \"list_mangle list1 list2\""
	}
	set result ""
	foreach e1 [lindex $args 0] e2 [lindex $args 1] {
		lappend result [list $e1 $e2]
	}
	return $result
}

#doc {listcommands list_extract} cmd {
#list_extract ?list? ?expression?
#} descr {
#	tries to match each element in a list; if the element matches, it extracts the 
#	parenthesised part. It returns a list of all extracted parts. If there was no match,
#	an empty element is put in the list.
#} example { 
#	% list_extract {Results {A: 50%} {B: 25%} {C: 25%}} { ([0-9+]+)\%}
#		{} 50 25 25
#}
proc list_extract {args} {
	if {[llength $args]!=2} {
		error "wrong # args: should be \"list_extract list expression\""
	}
	set result ""
	set pattern [lindex $args 1]
	foreach e [lindex $args 0] {
		if [regexp $pattern $e temp res] {
			lappend result $res
		} else {
			lappend result ""
		}
	}
	return $result
}

#doc {listcommands list_split} cmd {
#list_split ?list? -before/-after/-outside ?positions?
#} descr {
#	splits a list at positions into sublists
#} example {
#	% list_split {a b c d e} -before {1 3}
#	a {b c} {d e}
#}
proc list_split {args} {
	if {[llength $args]!=3} {
		error "wrong # args: should be \"list_split list -before/-after/-outside ?positions?\""
	}
	set result ""
	set list [lindex $args 0]
	set mode [lindex $args 1]
	if {"$mode"=="-before"} {
		set ii -1
		set ip 1
	} elseif {"$mode"=="-after"} {
		set ii 0
		set ip 1
	} elseif {"$mode"=="-outside"} {
		set ii -1
		set ip 2
	} else {
		error "wrong arg: $mode"
	}
	set prev 0
	foreach index [lindex $args 2] {
		incr index $ii
		lappend result [lrange $list $prev $index]
		set prev $index
		incr prev $ip
	}			
	if {[llength $list]>$prev} {
		lappend result [lrange $list $prev end]
	}
	return $result
}

#doc {listcommands list_join} cmd {
#list_join ?list? ?join string? ?position list?
#} descr {
#	joins list elements at positions given in the ?position list?. When you
#	specify all, all elements will be joined.
#} example {
#	% list_join {a b c {a d} e} { } {0 2}
#		{a b} {c a d} e
#	% list_join {a b c {a d} e} {} {0 2}
#		ab {ca d} e
#	% list_join {a b c {a d} e} {} all
#	abca de
#}
proc list_join {args} {
	if {[llength $args]!=3} {
		error "wrong # args: should be \"list_join list <join string> <positions>\""
	}
	set list [lindex $args 0]
	set join [lindex $args 1]
	if {"[lindex $args 2]"=="all"} {return [join $list $join]}
	foreach index [lsort -integer -decreasing [lindex $args 2]] {
		set i2 [expr $index+1]
		set list [lreplace $list $index $i2 [join [lrange $list $index $i2] $join]]
	}
	return $list
}

#doc {listcommands list_lengths} cmd {
#list_lengths ?list?
#} descr {
#	returns a list with the lengths of the elements
#} example {
#	% list_lengths {abc abcdef}
#	3 6
#}
proc list_lengths {args} {
	if {[llength $args]!=1} {
		error "wrong # args: should be \"list_lengths list\""
	}
	set result ""
	foreach el [lindex $args 0] {
		lappend result [string length $el]
	}
	return $result
}

#doc {listcommands list_select} cmd {
#list_select ?mode? list pattern
#} descr {
#	selects all elements of a list that match a certain pattern. Default mode is -glob
#} example {
#	% list_select {a b ab bc} a*
#	a ab
#	% list_select -regexp {a ab aa bc} {^[ab]*$}
#	a ab aa
#}
proc list_select {args} {
	if {[llength $args]==2} {
		set list [lindex $args 0]
		set pattern [lindex $args 1]
		set mode -glob
	} elseif {[llength $args]==3} {
		set mode [lindex $args 0]
		set list [lindex $args 1]
		set pattern [lindex $args 2]
	} else {
		error "Format is \"list_select ?mode? list pattern\""
	}
	return [list_sub $list [list_find $mode $list $pattern]]
}

