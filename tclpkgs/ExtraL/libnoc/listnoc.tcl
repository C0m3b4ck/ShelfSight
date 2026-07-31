# File containing the Tcl part of the list commands in the Extral extension
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc {listcommands list_pop} cmd {
#list_pop listName ?pos?
#} descr {
#	returns the last element from a list, thereby removing it from the list.
#	If pos is given it will return the pos element of the list.
#}
proc list_pop {listname {pos end}} {
	upvar $listname list
	if {"$list"==""} {
		return ""
	}
	set result [lindex $list $pos]
	set list [lreplace $list $pos $pos]
	return $result
}

#doc {listcommands list_shift} cmd {
#list_shift listName
#} descr {
#	returns the first element from a list, thereby removing it from the list.
#}
proc list_shift {listname} {
	upvar $listname list
	set result [lindex $list 0]
	set list [lrange $list 1 end]
	return $result
}

#doc {listcommands list_sub} cmd {
#list_sub list ?-exclude? [index list]
#} descr {
#	create a sublist from a set of indices
#	When -exclude is specified, the elements of which the indexes are not in the list 
#	will be given.
#} example {
#	% list_sub {Ape Ball Field {Antwerp city} Egg} {0 3}
#	Ape {Antwerp city}
#	% list_sub {Ape Ball Field {Antwerp city} Egg} -exclude {0 3}
#	Ball Field Egg
#}
proc list_sub {list args} {
	set len [llength $args]
	if {$len==1} {
		set result ""
		set len [llength $list]
		foreach index [lindex $args 0] {
			lappend result [lindex $list $index]
		}
		return $result
	} elseif {($len == 2)&&("[lindex $args 0]"=="-exclude")} {
		set result ""
		foreach index [lsort -integer -decreasing [lindex $args 1]] {
			set list [lreplace $list	$index $index]
		}
		return $list
	} else {
		error "Format is \"list_sub list ?-exclude? indices\""
	}
}

#doc {listcommands list_find} cmd {
#list_find mode list pattern
#} descr {
#	returns a list of all indices which match a pattern.
#	mode can be -exact, -glob, -regexp, -inlist, -oflist or -lcommon
#	The default mode is -exact
#	-inlist matches when the element at the index is a list that (exactly) contains the query as alist element
#	-oflist matches when the element at the index (exactly) matches one of the elements in the query (which is regarded as alist)
#	-lcommon both list elements and query are regarded as lists; they match if these lists have an element in common
#} example {
#	% list_find -regexp {Ape Ball Field {Antwerp city} Egg} {^A}
#	0 3
#}
proc list_find {args} {
	if {[llength $args]==2} {
		set list [lindex $args 0]
		set pattern [lindex $args 1]
		set mode -exact
	} elseif {[llength $args]==3} {
		set mode [lindex $args 0]
		set list [lindex $args 1]
		set pattern [lindex $args 2]
	} else {
		error "Format is \"list_find ?mode? list pattern\""
	}
	set result ""
	set pos 0
	switch -- $mode {
		{-exact} {
			foreach el $list {
				if {"$el" eq "$pattern"} {lappend result $pos}
				incr pos
			}
		}
		{-glob} {
			foreach el $list {
				if {[string match $pattern $el]} {lappend result $pos}
				incr pos
			}
		}
		{-regexp} {
			foreach el $list {
				if {[regexp $pattern $el]} {lappend result $pos}
				incr pos
			}
		}
		{-inlist} {
			foreach el $list {
				if {[inlist $el $pattern]} {lappend result $pos}
				incr pos
			}
		}
		{-oflist} {
			foreach el $list {
				if {[inlist $pattern $el]} {lappend result $pos}
				incr pos
			}
		}
		{-lcommon} {
			foreach el $list {
				if {[llength [list_common $pattern $el]]} {lappend result $pos}
				incr pos
			}
		}
		default {
			error "Unkown mode \"$mode\""
		}
	}
	return $result
}

#doc {listcommands list_cor} cmd {
#list_cor <referencelist> <list>
#} descr {
#	gives the positions of the elements in list in the reference list. If an element is not
#	found in the reference list, it returns -1. Elements are matched only once.
#} example {
#	% list_cor {a b c d e f} {d b}
#	3 1
#	% list_cor {a b c d e f} {b d d}
#	1 3 -1
#}
proc list_cor {reflist list} {
	set pos 0
	set result {}
	foreach item $reflist {
		lappend grid($item) $pos
		incr pos
	}
	foreach item $list {
		if [info exists grid($item)] {
			lappend result [list_shift grid($item)]
			if {"$grid($item)"==""} {unset grid($item)}
		} else {
			lappend result -1
		}
	}
	return $result
}


#doc {listcommands list_remdup} cmd {
#list_remdup list
#} descr {
#returns a list in which all duplactes are removed
#	with the -sorted option the command will usually be a lot faster,
#	but $list must be sorted with lsort;
#	The optional $var gives the name of a variable in which the removed items
#	will be stored.
#}
proc list_remdup {args} {
	set len [llength $args]
	if {"[lindex $args 0]"=="-sorted"} {
		set list [lindex $args 1]
		set var [lindex $args 2]
		set sorted 1
		incr len -1
	} else {
		set list [lindex $args 0]
		set var [lindex $args 1]
		set sorted 0
	}
	if {$len == 2} {
		upvar $var v
		set v {}
		set usevar 1
	} else {
		set usevar 0
	}
	if {($len != 1)&&($len != 2)} {
		return -code error "wrong # args: should be \"list_remdup ?-sorted? list ?var?\""
	}
	set len [llength $list]
	if {($len == 1)||($len == 0)} {return $list}
	set done ""
	if !$sorted {
		foreach e $list {
			if {![info exists a($e)]} {
				lappend done $e
				set a($e) {}
			} elseif $usevar {
				lappend v $e
			}
		}
	} else {
		set prev [lindex $list 0]
		lappend done $prev
		foreach e [lrange $list 1 end] {
			if {"$e" != "$prev"} {
				lappend done $e
				set prev $e
			} elseif $usevar {
				lappend v $e
			}
		}
	}
	return $done
}

#doc {listcommands list_lremove} cmd {
#list_lremove ?-sorted? list1 list2
#} descr {
#	returns a list with all items in list1 that are not in list2
#	with the -sorted option the command will usually be a lot faster,
#	but both given lists must be sorted with lsort;
#	The optional $var gives the name of a variable in which the removed items
#	will be stored.
#}
proc list_lremove {args} {
	set len [llength $args]
	if {"[lindex $args 0]"=="-sorted"} {
		set list [lindex $args 1]
		set removelist [lindex $args 2]
		set var [lindex $args 3]
		set sorted 1
		incr len -1
	} else {
		set list [lindex $args 0]
		set removelist [lindex $args 1]
		set var [lindex $args 2]
		set sorted 0
	}
	if {$len == 3} {
		upvar $var v
		set v {}
		set usevar 1
	} else {
		set usevar 0
	}
	if {($len != 2)&&($len != 3)} {
		return -code error "wrong # args: should be \"list_lremove ?-sorted? list removelist ?var?\""
	}
	if {"$removelist"==""} {
		set removelist {{}}
	}
	if !$sorted {
		set result ""
		foreach item $removelist {
			set a($item) {}
		}
		foreach item $list {
			if {![info exists a($item)]} {
				lappend result $item
			} elseif $usevar {
				lappend v $item
			}
		}
		return $result
	} else {
		set pos 0
		set result ""
		set cur [lindex $removelist $pos]
		set len [llength $removelist]
		foreach item $list {
			if {$pos >= $len} {
				lappend result $item
			} else {
				while 1 {
					if {"$item" < "$cur"} {
						lappend result $item
						break
					} elseif {"$item" > "$cur"} {
						incr pos
						if {$pos >= $len} {
							lappend result $item
							break
						}
						set cur [lindex $removelist $pos]
					} else {
						if $usevar {
							lappend v $item
						}
						break
					}
				}
			}
		}
		return $result
	}
}
 
#doc {listcommands list_merge} cmd {
#list_merge ?list1? ?list2? ??spacing??
#} descr {
#	merges two lists into one
#} example {
#	% list_merge {a b c} {1 2 3}
#	a 1 b 2 c 3
#	% list_merge {a b c d} {1 2} 2
#	a b 1 c d 2
#}
proc list_merge {args} {
	if {([llength $args]!=2)&&([llength $args]!=3)} {
		error "wrong # args: should be \"list_merge list1 list2 ?spacing?\""
	}
	set result ""
	set list1 [lindex $args 0]
	set list2 [lindex $args 1]
	if ([llength $args]==3) {
		set spacing [lindex $args 2]
	} else {
		set spacing 1
	}
	if {($spacing!=1)||([llength $list1]<[llength $list2])} {
		set c $spacing
		foreach e1 $list1 {
			lappend result $e1
			incr c -1
			if !$c {
				lappend result [list_shift list2]
				set c $spacing
			}
		}
		return $result
		
	} else {
		foreach e1 $list1 e2 $list2 {
			lappend result $e1 $e2
		}
		return $result
	}
}

#doc {listcommands list_unmerge} cmd {
#list_unmerge ?list? ??spacing?? ??var??
#} descr {
#	unmerges items from a list to the result; the remaining items are stored
#	in the given variable ?var?
#} example {
#	% list_unmerge {a 1 b 2 c 3}
#	a b c
#	% list_unmerge {a b 1 c d 2} 2 var
#	a b c d
#	% set var
#	1 2
#}
proc list_unmerge {args} {
	if {([llength $args]<1)||([llength $args]>3)} {
		error "wrong # args: should be \"list_unmerge list ?spacing? ?var?\""
	}
	set result ""
	if {[llength $args]==3} {
		upvar [lindex $args 2] var
		set var ""
	}
	if {[llength $args]>1} {
		set spacing [lindex $args 1]
	} else {
		set spacing 1
	}
	if ![isint $spacing] {error "spacing \"$spacing\" is not an integer"}
	if {$spacing==1} {
		foreach {e1 e2} [lindex $args 0] {
			lappend result $e1
			if [info exists var] {lappend var $e2}
		}
		return $result
	} else {
		set c $spacing
		foreach e1 [lindex $args 0] {
			if !$c {
				if [info exists var] {lappend var $e1}
				set c $spacing
			} else {
				lappend result $e1
				incr c -1
			}
		}
		return $result
		
	}
}

#doc {listcommands list_reverse} cmd {
#list_reverse list
#} descr {
# returns the reverse of the list.
#}
proc list_reverse {list} {
	set i [llength $list]
	set result ""
	for {incr i -1} {$i >= 0} {incr i -1} {
		lappend result [lindex $list $i]
	}
	return $result
}

#doc {listcommands list_change} cmd {
#list_change list change to ?change to ...?
#} descr {
# change matching elements in a list to other values
#}
proc list_change {list changelist} {
	array set trans $changelist
	foreach element $list {
		if [info exists trans($element)] {
			lappend result $trans($element)
		} else {
			lappend result $element
		}
	}
	return $result
}

#doc {convenience get} cmd {
#get varName ?default?
#} descr {
# get returns the value of the variable given by varName if it exists.
# If the variable does not exists, it returns an empty string, or
# value given by $default if present
# 
#}
#ps: using uplevel this way instead of teh obvious upvar make strange things 
# happening with threads go away, and is faster too
proc get {varName {default {}}} {
	if {[uplevel [list info exists $varName]]} {
		return [uplevel [list set $varName]]
	} else {
		return $default
	}
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

#doc {listcommands list_concat} cmd {
#list_concat list ?list? ?list ...?
#} descr {
#	This  command  treats each argument as a list and concatenates them into a single list
#	If a single list is given, each element in this list is treated a a list, and concatenated
#}
proc list_concat {args} {
	if {[llength $args] == 1} {
		set args [lindex $args 0]
	}
	set list [lindex $args 0]
	foreach arg [lrange $args 1 end] {
		foreach el $arg {
			lappend list $el
		}
	}
	return $list
}

#doc {listcommands list_foreach} cmd {
#list_foreach varlist1 list1 ?varlist2 list2 ...? body
#} descr {
#	acts like foreach, except that list1, ... are treated as a list of lists
#	and each iteration the next sublist is taken to fill the variables in varlist1, ...
#} example {
#   % list_foreach {a b} {{1 2} {3 4}} {puts $a,$b}
#   1,2
#   3,4
#   % list_foreach {a b} {{1 2 3} 4} {puts $a,$b}
#   1,2
#   4,
#}
proc list_foreach {args} {
	set body [list_pop args]
	set max 0
	foreach {vars valuelist} $args {
		set len [llength $valuelist]
		if {$len > $max} {set max $len}
	}
	for {set pos 0} {$pos < $max} {incr pos} {
		foreach {vars valuelist} $args {
			set values [lindex $valuelist $pos]
			set len [llength $vars]
			if {[llength $values] < $len} {
				for {set i 0} {$i < $len} {incr i} {lappend values {}}
			}
			uplevel [list foreach $vars $values break]
		}
		set result [uplevel $body]
	}
}
