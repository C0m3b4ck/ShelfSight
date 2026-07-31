# File containing the Tcl part of the list commands in the Extral extension
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc listcommands title {
#Extra list manipulation commands
#}

#doc {listcommands list_remove} cmd {
#list_remove listName ?item? ...
#} descr {
#removes the items from the list
#}
proc list_remove {list args} {
	if {"$args"==""} {
		return $list
	}
	set result ""
	foreach item $args {
		set a($item) {}
	}
	foreach item $list {
		if {![info exists a($item)]} {
			lappend result $item
		}
	}
	return $result
}

if {![get Extral::noc 0]} {
	proc list_remove {list args} {
		if {"$args"==""} {
			return $list
		} else {
			return [list_lremove $list $args]
		}
	}
}

#doc {listcommands list_push} cmd {
#list_push listName ?item? ?position?
#} descr {
#	opposite of list_pop.
#}
proc list_push {ulist item {pos {}}} {
	upvar $ulist list
	if {![info exists list]||("$list"=="")||("$pos"=="")} { 
		lappend list $item
	} else {
		if {$pos>=[llength $list]} {
			return $list
		}
		set temp [lindex $list $pos]
		set list [lreplace $list $pos $pos $temp $item]
	}
}

#doc {listcommands list_unshift} cmd {
#list_unshift listName ?item?
#} descr {
#	opposite of list_shift: prepends ?item? to the list.
#}
proc list_unshift {ulist item} {
	upvar $ulist list
	if {[llength $list]==0} {
		lappend list $item
	} else {
		set temp [lindex $list 0]
		set list [lreplace $list 0 0 $item $temp]
	}
}

#doc {listcommands list_set} cmd {
#list_set listName ?item? ?indexlist?
#} descr {
#	sets all elements of the list at the given indices to value ?item?
#}
proc list_set {listref value indices} {
	upvar $listref list
	foreach index $indices {
		set list [lreplace $list $index $index $value]
	}
	return $list
}

#doc {listcommands list_arrayset} cmd {
#list_arrayset array varlist valuelist
#} descr {
#	sets the values of valuelist to the respective elements in varlist for
#	the given array
#}
proc list_arrayset {array varlist valuelist} {
	upvar $array v
	foreach var $varlist value $valuelist {
		set v($var) $value
	}
}

#doc {listcommands list_common} cmd {
#list_common list list ...
#} descr {
#	returns the common elements of the lists
#}
proc list_common {args} {
	set result [list_shift args]
	foreach list $args {
		set result [list_lremove $result [list_lremove $result $list]]
	}
	return $result
}

#doc {listcommands list_union} cmd {
#list_union list list ...
#} descr {
#	returns the union of the lists
#}
proc list_union {args} {
	set result [eval concat $args]
	return [list_remdup $result]
}

#doc {listcommands list_eor} cmd {
#list_eor list1 list2
#} descr {
#	returns the elements that are not shared between both lists
#}
proc list_eor {list1 list2} {
	set list1 [lsort $list1]
	set list2 [lsort $list2]
	set result [list_lremove $list1 $list2 rem]
	return [concat $result [list_lremove $list2 $rem]]
}

#doc {listcommands list_addnew} cmd {
#list_addnew listName ?item? ...
#} descr {
#	adds the items to the list if not already there
#}
proc list_addnew {listref args} {
	upvar $listref list
	if ![info exists list] {set list ""}
	foreach item $args {
		if {[lsearch -exact $list $item] < 0} {
			lappend list $item
		}
	}
	return $list
}

#doc {listcommands inlist} cmd {
#inlist list value
#} descr {
#returns 1 if $value is an element of list $list
#returns 0 if $value is not an element of list $list
#}
proc inlist {list value} {
	if {[lsearch -exact $list $value]==-1} {
		return 0
	} else {
		return 1
	}
}

#doc {listcommands list_load} cmd {
#list_load filename
#} descr {
#	returns all lines in the specified files as a list 
#}
proc list_load {filename} {
	set f [open $filename "r"]
	set result [split [read $f] "\n"]
	close $f
	return $result
}

#doc {listcommands list_write} cmd {
#list_write file list
#} descr {
#	writes a list to a file
#}
proc list_write {filename list} {
	set f [open $filename "a"]
	puts $f [join $list "\n"] nonewline
	close $f
}

#doc {listcommands list_append} cmd {
#list_append list ?list1? ...
#} descr {
#	appends elements in list1 (and following) to list
#} example {
#   % set list {1 2 3}
#   1 2 3
#   % list_append list {3 4} {5 6}
#   % set list
#   1 2 3 4 5 6
#}
proc list_append {listName args} {
	upvar $listName list
	foreach alist $args {
		eval lappend list $alist
	}
}

#doc {listcommands list_lappend} cmd {
#list_lappend list ?index...? ?list1? ...
#} descr {
#	appends one element to the sublist of list indicated by index
#} example {
#   % set list {{a 1} {b 2}}
#   1 2 3
#   % list_lappend list 1 c
#   % set list
#   {a 1} {b 2 c}
#   % list_lappend list 0 1 d
#   % set list
#   {a {1 d}} {b 2 c}
#}
proc list_lappend {varName args} {
	upvar $varName var
	set val [list_pop args]
	set temp [eval {lindex $var} $args]
	lappend temp $val
	eval lset var $args {$temp}
	return $var
}

