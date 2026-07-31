# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc arraycommands title {
#Extra array manipulation commands
#}

#doc {arraycommands array_lappend} cmd {
#array_lappend arrayName list
#} example {
#	% array set try {a 1 b 2}
#	% array_lappend try {a a c 3}
#	% array get try
#	a {1 a} b 2 c 3
#}
proc array_lappend {args} {
	set len [llength $args]
	if {$len!=2} {
		error "wrong # args: should be \"array_lappend arrayName list\""
	}
	upvar [lindex $args 0] var
	foreach {e val} [lindex $args 1] {
		lappend var($e) $val
	}
}

#doc {arraycommands array_lget} cmd {
#array_lget arrayName list ?default?
#} example {
#	% array set try {a 1 b 2}
#	% array_lget try {b c} def
#	b 2 c def
#}
proc array_lget {args} {
	set len [llength $args]
	if {($len!=2)&&($len!=3)} {
		error "wrong # args: should be \"array_lget arrayName list ?default?\""
	}
	upvar [lindex $args 0] var
	set result ""
	if {[llength $args] == 3} {
		set default [lindex $args 2]
		foreach e [lindex $args 1] {
			if [info exists var($e)] {
				lappend result $var($e)
			} else {
				lappend result $default
			}
		}
	} else {
		foreach e [lindex $args 1] {
			if [info exists var($e)] {
				lappend result $e $var($e)
			}
		}
	}
	return $result
}

#doc {arraycommands array_trans} cmd {
#array_trans varName list ?default?
#} descr {
# returns a list of all the values in the array corresponding to the
# indices in the given list. If the index is not present in the array,
# the index itself will be returned.
# If $default is given, it will be returned for indices not in the array.
#}
proc array_trans {varName list args} {
	upvar $varName var
	set result ""
	if {"$args" == ""} {
		foreach item $list {
			if [info exists var($item)] {
				lappend result $var($item)
			} else {
				lappend result $item
			}
		}
	} else {
		set def [lindex $args 0]
		foreach item $list {
			if [info exists var($item)] {
				lappend result $var($item)
			} else {
				lappend result $def
			}
		}
	}
	return $result
}

#doc {arraycommands array_lset} cmd {
#array_lset arrayName keylist valuelist
#} example {
#	% array_lset try {a b} {1 2}
#	% array get try
#	a 1 b 2
#}
proc array_lset {arrayName keylist valuelist} {
	upvar [lindex $arrayName 0] var
	foreach key $keylist value $valuelist {
		set var($key) $value
	}
}

