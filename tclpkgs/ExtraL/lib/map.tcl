# map
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc map title {
#Maps
#} shortdescr {
#store structured data in lists
#} descr {
#In a map names (or fields) alternate with the value attached to this name,
#eg.: {name1 {value of name1} name2 {value of name2} ...}
#Using the map commands, you can use a list as a sort of array.
#However, maps have some advantages to arrays:
#<ul>
#<li>They can be passed to functions easily
#<li>maps can be nested: an element of a map can
#   contain another map, etc.
#<li>although finding a value in an array should be faster,
#   creating the array can take more time.
#<li>maps can be handled according to a certain schema using the -map option.
#</ul>
# Using maps, data can be stored in a treelike structure (see examples further down).
# Using the map_get and map_set functions, data in any of the branches or leaves can be
# easily obtained or set, using a field (a list of names of successive branches).
# <p>
# Using the -map option a schema can be specified that puts constraints on which branches are 
# allowed, and what values are allowed in the branches.
# A schema is also organised as a map. when the first element in a value starts with 
# an asterisk, it is an endnode. Otherwise it is the schema of the submap starting
# at the name of that value.
# An endnode consists of a type indicator (the first element starting with an asterisk) and 
# type parameters. A number of types 
# are available by default (*any, *int, *regexp, *date, *named *list, ...). 
# New types can be added using either Tcl or C code.
# <p>
# If a schema contains names consisting of a list where element 0 is a questionmark these are treated specially: 
# The list must have 2 further elements: element 1 is the long name for the value, and element
# 2 the short name. Both long and short name can be used to set or get values from the map.
# However, map_set will always return a struct with the short name (efficient storage), while
# map_get will return the long form.
#}

proc Extral::map_setstruct {map data list taglen taglist value} {
#putsvars map list taglen taglist value
	set ctag [lindex $map 0]
	if [regexp {^\*[^ ]} $ctag] {
		# An endnode
		# ----------
		return [::Extral::set[string range $ctag 1 end] $map $data $list $taglist $value]
	} elseif {$taglen == 0} {
		# Go further down map by value
		# ----------------------------------
		set len [llength $value]
		if [expr $len & 1] {
			return -code error "error: incorrect value trying to assign \"$value\" to map \"$map\""
		}
		foreach {tag val} $value {
			set structpos [map_find $map $tag]
			if {$structpos == -1} {
				return -code error "error: tag \"$tag\" not present in map \"$map\""
			}
			set structtag [lindex $map [expr {$structpos-1}]]
			if {"[lindex $structtag 0]" == "?"} {
				set tag [lindex $structtag 2]
			}
			set submap [lindex $map $structpos]
			set sublistpos [map_find $list $tag]
			if {$sublistpos == -1} {
				set sublist ""
			} else {
				set sublist [lindex $list $sublistpos]
			}
			set code [catch {Extral::map_setstruct $submap $data $sublist 0 "" $val} sublist]
			if {$code == 1} {
				error "$sublist at field \"$tag\""
			} elseif {$code == 5} {
				if {$sublistpos != -1} {
					set list [lreplace $list [expr $sublistpos-1] $sublistpos]
				}
			} else {
				if {$sublistpos != -1} {
					set list [lreplace $list $sublistpos $sublistpos $sublist]
				} else {
					if {"[lindex $tag 0]" == "?"} {
						lappend list [lindex $tag 2] $sublist
					} else {
						lappend list $tag $sublist
					}
				}
			}
		}
	} else {
		# Go further down map by tags
		# ---------------------------------
		set tag [list_pop taglist 0]
		incr taglen -1
		set structpos [map_find $map $tag]
		if {$structpos == -1} {
			return -code error "error: tag \"$tag\" not present in map \"$map\""
		}
		set structtag [lindex $map [expr {$structpos-1}]]
		if {"[lindex $structtag 0]" == "?"} {
			set tag [lindex $structtag 2]
		}
		set submap [lindex $map $structpos]
		set sublistpos [map_find $list $tag]
		if {$sublistpos == -1} {
			set sublist ""
		} else {
			set sublist [lindex $list $sublistpos]
		}
		set code [catch {Extral::map_setstruct $submap $data $sublist $taglen $taglist $value} sublist]
		if {$code == 1} {
			error "$sublist at field \"$tag\""
		} elseif {$code == 5} {
			if {$sublistpos != -1} {
				set list [lreplace $list [expr $sublistpos-1] $sublistpos]
			}
		} else {
			if {$sublistpos != -1} {
				set list [lreplace $list $sublistpos $sublistpos $sublist]
			} else {
				lappend list $tag $sublist
			}
		}
	}
	if {"$list" == ""} {
		return -code 5 ""
	} else {
		return $list
	}
}

proc Extral::map_setnostruct {list taglen taglist value} {
	set tag [list_pop taglist 0]
	incr taglen -1
	set pos 1
	set len [llength $list]
	if {[expr $len%2] != 0} {
		return -code error "error: \"$list\" does not have an even number of elements"
	}
	foreach {ctag cvalue} $list {
		if {"$tag"=="$ctag"} {
			if {$taglen != 0} {
				set value [Extral::map_setnostruct [lindex $list $pos] $taglen $taglist $value]
			}
			return [lreplace $list $pos $pos $value]
		}
		incr pos 2
	}
	if {$taglen == 0} {
		return [concat $list [list $tag] [list $value]]
	} else {
		set value [list [list_pop taglist] $value]
		incr taglen -1
		for {set i 0} {$i<$taglen} {incr i} {
			set ctag [list_pop taglist]
			set value [list $ctag $value]
		}
		return [concat $list [list $tag] [list $value]]
	}
}

#doc {map map_set} cmd {
#map_set ?-map schema? ?-data clientdata? list field value ?field value ...?
#} descr {
# set the value of a field in the map. The -data option can be used to
# pass data to self defined data types.
#} example {
#	set the value for tag
#		% set list {a 1 b 4}
#		a 1 b 4
#		% set list [map_set $list c 3]
#		a 1 b 4 c 3
#		% map_set {a 1 b 4 c 3} b 2
#		a 1 b 2 c 3
#	example of nesting:
#		% map_set {a 1 b {a 1 b 4} c 3} {b b} 2
#		a 1 b {a 1 b 2} c 3
#	example of map:
#		% set struct {
#			reg {*regexp {^a[0-9]} ?}
#			sub {
#				a {*any ?}
#				b {*between 0 10 ?}
#			}
#			ints {
#				*named {*int ?}
#			}
#		}
#		% set data {}
#		% set data [map_set -map $struct $data {sub b} 9]
#		sub {b 9}
#		% set data [map_set -map $struct $data {sub b} 11]
#		error: 11 is not between 0 and 10 at field "b" at field "sub"
#		% set data [map_set -map $struct $data ints {a 9}]
#		sub {b 9} ints {a 9}
#		% set data [map_set -map $struct $data {sub b} ?]
#		ints {a 9}
#}
proc map_set {args} {
	set usestr 0
	set data {}
	set len [llength $args]
	while {$len >= 0} {
		if {"[lindex $args 0]" == "-map"} {
			set struct [lindex $args 1]
			set args [lrange $args 2 end]
			incr len -2
			set usestr 1
		} elseif {"[lindex $args 0]" == "-data"} {
			set data [lindex $args 1]
			set args [lrange $args 2 end]
			incr len -2
		} else break
	}
	if {($len < 3)||(![expr $len&1])} {
		return -code error "wrong # args: should be \"map_set ?-map schema? ?-data clientdata? list field value ?field value ...?\""
	}
	if {$usestr == 1} {
		set list [list_shift args]
		foreach {taglist value} $args {
			set taglen [llength $taglist]
			set code [catch {Extral::map_setstruct $struct $data $list $taglen $taglist $value} result]
			if {"$code" == 1} {
				error $result
			} elseif {"$code" == 5} {
				set list ""
			} else {
				set list $result
			}
		}
	} else {
		set list [list_shift args]
		foreach {taglist value} $args {
			set taglen [llength $taglist]
			if {$taglen == 0} {
				return $value
			}
			set list [Extral::map_setnostruct $list $taglen $taglist $value]
		}
	}
	return $list
}

proc Extral::map_getstruct {map data list taglen taglist} {
#putsvars map data list taglen taglist
	# Is this an endnode
	# ------------------
	set ctag [lindex $map 0]
	if [regexp {^\*[^ ]} $ctag] {
		return [::Extral::get[string range $ctag 1 end] $map $data $taglist $list]
	}
	# out of tags
	# -----------
	if {$taglen == 0} {
		set maplen [llength $map]
		if [expr $maplen&1] {
			return -code error "error: map \"$map\" does not have an even number of elements"
		} elseif {$maplen != 0} {
			set result ""
			foreach {tag str} $map {
				if {"[lindex $tag 0]" == "?"} {
					set sublist [map_find $list [lindex $tag 2] value]
					lappend result [lindex $tag 1] [Extral::map_getstruct $str $data $sublist 0 ""]
				} else {
					set sublist [map_find $list $tag value]
					lappend result $tag [Extral::map_getstruct $str $data $sublist 0 ""]
				}
			}
			return $result
		} else {
			return $list
		}
	} else {
		# find submap corresponding to tag 
		# --------------------------------------
		set tag [list_pop taglist 0]
		incr taglen -1
		set pos [map_find $map $tag]
		if {$pos == -1} {
			return -code error "error: tag \"$tag\" not present in map \"$map\""
		}
		set submap [lindex $map $pos]
		set structtag [lindex $map [expr {$pos-1}]]
		if {"[lindex $structtag 0]" == "?"} {
			set tag [lindex $structtag 2]
		}
	
		# find the tag
		# ------------
		set sublist [map_find $list $tag value]
		return [Extral::map_getstruct $submap $data $sublist $taglen $taglist]
	}
}

proc Extral::map_getnostruct {list taglen taglist} {
	foreach tag $taglist {
		set len [llength $list]
		if {[expr $len%2] != 0} {
			return -code error "error: list \"$list\" does not have an even number of elements"
		}
		foreach {ctag value} $list {
			if {"$tag"=="$ctag"} {
				set found $value
			}
		}
		if ![info exists found] {
			return -code error "tag \"$tag\" not found"
		} else {
			set list $found
			unset found
		}
	}
	return $list
}

#doc {map map_get} cmd {
#map_get ?-map schema? list field ?field ...?
#} descr {
#get the value of a field in the map
#} example {
#	% set struct {
#		reg {*regexp {^a[0-9]} ?}
#		sub {
#			a {*any ?}
#			b {*between 0 10 ?}
#		}
#		ints {
#			*named {*int ?}
#		}
#	}
#	% map_get -map $struct {ints {a 9}} {sub b}
#	?
#	% map_get -map $struct {ints {a 9}} {ints}
#	a 9
#}
proc map_get {args} {
	set usestr 0
	set data {}
	set alen [llength $args]
	set pos 0
	while {$alen >= 0} {
		if {"[lindex $args 0]" == "-map"} {
			set struct [lindex $args 1]
			set args [lrange $args 2 end]
			incr alen -2
			set usestr 1
		} elseif {"[lindex $args 0]" == "-data"} {
			set data [lindex $args 1]
			set args [lrange $args 2 end]
			incr alen -2
		} else break
	}
	if {$alen < 2} {
		return -code error "wrong # args: should be \"map_get ?-map schema? list field ?field ...?\""
	}
	set list [list_shift args]
	if {$alen == 2} {
		set taglist [lindex $args 0]
		set len [llength $taglist]
		if {$usestr == 1} {
			return [Extral::map_getstruct $struct $data $list $len $taglist]
		} else {
			return [Extral::map_getnostruct $list $len $taglist]
		}
	} else {
		set result ""
		foreach taglist $args {
			set len [llength $taglist]
			if {$usestr == 1} {
				lappend result [Extral::map_getstruct $struct $data $list $len $taglist]
			} else {
				lappend result [Extral::map_getnostruct $list $len $taglist]
			}
		}
		return $result
	}
}

proc Extral::map_unsetstruct {map data list taglen taglist} {
#putsvars map list taglen taglist
	set ctag [lindex $map 0]
	if [regexp {^\*[^ ]} $ctag] {
		# An endnode
		# ----------
		set cmd ::Extral::unset[string range $ctag 1 end]
		if {"[info commands $cmd]" != ""} {
			set code [catch {$cmd $map $data $list $taglist} res]
			return -code $code $res
		} else {
			return -code 5 ""
		}
	} elseif {$taglen == 0} {
		return -code 5 ""
	} else {
		# Go further down map by tags
		# ---------------------------------
		set tag [list_pop taglist 0]
		incr taglen -1
		set structpos [map_find $map $tag]
		if {$structpos == -1} {
			return -code error "error: tag \"$tag\" not present in map \"$map\""
		}
		set structtag [lindex $map [expr {$structpos-1}]]
		if {"[lindex $structtag 0]" == "?"} {
			set tag [lindex $structtag 2]
		}
		set submap [lindex $map $structpos]
		set sublistpos [map_find $list $tag]
		if {$sublistpos == -1} {
			set sublist ""
		} else {
			set sublist [lindex $list $sublistpos]
		}
		set code [catch {Extral::map_unsetstruct $submap $data $sublist $taglen $taglist} sublist]
		if {$code == 1} {
			error "$sublist at field \"$tag\""
		} elseif {$code == 5} {
			if {$sublistpos != -1} {
				set list [lreplace $list [expr $sublistpos-1] $sublistpos]
			}
		} else {
			if {$sublistpos != -1} {
				set list [lreplace $list $sublistpos $sublistpos $sublist]
			} else {
				lappend list $tag $sublist
			}
		}
	}
	if {"$list" == ""} {
		return -code 5 ""
	} else {
		return $list
	}
}

proc Extral::map_unsetnostruct {list taglist} {
	set len [llength $list]
	if {[expr $len%2] != 0} {
		return -code error "error: list \"$list\" does not have an even number of elements"
	}
	set pos 1
	set tag [list_pop taglist 0]
	set taglen [llength $taglist]
	foreach {ctag cvalue} $list {
		if {"$tag"=="$ctag"} {
			if {$taglen == 0} {
				return [lreplace $list [expr $pos-1] $pos]
			} else {
				set temp [map_unset [lindex $list $pos] $taglist]
				return [lreplace $list $pos $pos $temp]
			}
		}
		incr pos 2
	}
	return $list
}

#doc {map map_unset} cmd {
#map_unset ?-map schema? ?-data clientdata? list field ?field ...?
#} descr {
#unset the value of a field in the map
#} example {
#	% map_unset {a 1 b 2} b
#	a 1
#}
proc map_unset {args} {
	set usestr 0
	set data {}
	set len [llength $args]
	set pos 0
	while {$len >= 0} {
		if {"[lindex $args 0]" == "-map"} {
			set struct [lindex $args 1]
			set args [lrange $args 2 end]
			incr len -2
			set usestr 1
		} elseif {"[lindex $args 0]" == "-data"} {
			set data [lindex $args 1]
			set args [lrange $args 2 end]
			incr len -2
		} else break
	}
	if {$len < 2} {
		return -code error "wrong # args: should be \"map_unset ?-map schema? ?-data clientdata? list field ?field ... ?\""
	}
	if {$usestr == 1} {
		set list [list_shift args]
		foreach taglist $args {
			set taglen [llength $taglist]
			set code [catch {Extral::map_unsetstruct $struct $data $list $taglen $taglist} result]
			if {"$code" == 1} {
				error $result
			} elseif {"$code" == 5} {
				set list ""
			} else {
				set list $result
			}
		}
		return $list
	} else {
		set result [lindex $args 0]
		foreach el [lrange $args 1 end] {
			set result [Extral::map_unsetnostruct $result $el]
		}
		return $result
	}
}

#doc {map map_fields} cmd {
#map_fields list field ?valueVar?
#} descr {
#returns the fields present in the map list
#}
proc map_fields {list {field {}} args} {
	set result {}
	set len [llength $args]
	if {($len != 0)&&($len != 1)} {
		return -code error "wrong # args: should be \"map_fields list field ?valueVar?\""
	}
	set list [map_get $list $field]
	set len [llength $list]
	if {[expr $len%2] != 0} {
		return -code error "error: list \"$list\" does not have an even number of elements"
	}
	if {$len == 0} {
		foreach {tag val} $list {
			if {"[lindex $tag 0]" == "?"} {
				lappend result [lindex $tag 1]
			} else {
				lappend result $tag
			}
		}	
	} else {
		upvar [lindex $args 0] values
		set values ""
		foreach {tag val} $list {
			if {"[lindex $tag 0]" == "?"} {
				lappend result [lindex $tag 1]
			} else {
				lappend result $tag
			}
			lappend values $val
		}	
	}
	return $result
}

proc map_find {list tag args} {
	set pos 1
	foreach {ctag val} $list {
		if {"[lindex $ctag 0]" == "?"} {
			if {("$tag" == "[lindex $ctag 2]")||("$tag" == "[lindex $ctag 1]")} {
				if {"$args" == ""} {
					return $pos
				} else {
					return $val
				}
			}
		} else {
			if {"$tag" == "$ctag"} {
				if {"$args" == ""} {
					return $pos
				} else {
					return $val
				}
			}
		}
		incr pos 2
	}	
	if {"$args" == ""} {
		return -1
	} else {
		return ""
	}
}
