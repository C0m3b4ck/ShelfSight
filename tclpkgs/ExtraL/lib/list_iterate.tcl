# Code to let a variable iterate over a list
# handy when checking a foreach loop manually
# list_iterate ?variable name? ?list?
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# ===========================================

#doc {convenience list_iterate} cmd {
#	list_iterate variableName list
#} descr {
#	debugging tool to interactively iterate a variable over a list. list_iterate
#	is used to initialise and it sets the variable to the first element of 
#	the list. Every 'list_next variableName' will puts the next element into the 
#	variable.
#}
proc list_iterate {var list} {
	global extraL__Priv_iterate
	upvar $var ref
	set extraL__Priv_iterate($var:list) $list
	set extraL__Priv_iterate($var:len) [llength $list]
	set extraL__Priv_iterate($var:pos) 0
	set ref [lindex $extraL__Priv_iterate($var:list) 0]
}

#doc {convenience list_next} cmd {
#	list_next variableName
#} descr {
#	complement to list_iterate. sets the variable to the next element of the list 
#	first given by list_iterate.
#}
proc list_next {var} {
	global extraL__Priv_iterate
	upvar $var ref
	if ![info exists extraL__Priv_iterate($var:list)] {
		error "No iteration over $var set"
	}
	incr extraL__Priv_iterate($var:pos)
	if {$extraL__Priv_iterate($var:pos)==$extraL__Priv_iterate($var:len)} {
		unset extraL__Priv_iterate($var:list)
		unset extraL__Priv_iterate($var:len)
		unset extraL__Priv_iterate($var:pos)
		unset ref
	} else {
		set ref [lindex $extraL__Priv_iterate($var:list) $extraL__Priv_iterate($var:pos)]
	}
}
