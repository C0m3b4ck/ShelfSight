proc ::Extral::setstring {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	return $value
}

proc ::Extral::getstring {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::settext {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	return $value
}

proc ::Extral::gettext {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setany {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	return $value
}

proc ::Extral::getany {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setint {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	if ![regexp {^-?[0-9]+$} $value] {
		return -code error "expected integer but got \"$value\""
	}
	return $value
}

proc ::Extral::getint {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setdouble {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	if [catch {expr $value}] {
		return -code error "expected floating-point number but got \"$value\""
	}
	return $value
}

proc ::Extral::getdouble {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setbool {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	set value [string tolower $value]
	if [regexp {^1$|^true$|^t$|^yes$|^y$} $value] {
		return 1
	} elseif [regexp {^0$|^false$|^f$|^no$|^n$} $value] {
		return 0
	} else {
		return -code error "expected boolean value but got \"$value\""
	}
}

proc ::Extral::getbool {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setregexp {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	if {[llength $map] != 4} {
		return -code error "error: wrong number of arguments in map \"$map\": should be \"*regexp pattern errormsg default\""
	}
	set pattern [lindex $map 1]
	if ![regexp $pattern $value] {
		return -code error "error: \"$value\" [lindex $map 2]"
	}
	return $value
}

proc ::Extral::getregexp {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setbetween {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	if {[llength $map] != 4} {
		return -code error "error: wrong number of arguments in map \"$map\""
	}
	set min [lindex $map 1]
	set max [lindex $map 2]
	if ![regexp {^-?[0-9]+$} $value] {
		return -code error "expected integer but got \"$value\""
	}
	if {($value<$min)||($value>$max)} {
		return -code error "error: $value is not between $min and $max"
	}
	return $value
}

proc ::Extral::getbetween {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setdbetween {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	if {[llength $map] != 4} {
		return -code error "error: wrong number of arguments in map \"$map\""
	}
	set min [lindex $map 1]
	set max [lindex $map 2]
	if {($value<$min)||($value>$max)} {
		return -code error "error: $value is not between $min and $max"
	}
	return $value
}

proc ::Extral::getdbetween {map data field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == ""} {return [lindex $map end]}
	return $value
}

proc ::Extral::setdate {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	return [time_scan $value]
}

proc ::Extral::getdate {map data field value} {
	if {"$value" == ""} {return [lindex $map end]}
	if {"$field" != ""} {
		if {"$field" == "val"} {
			return $value
		} else {
			return [time_format $value [lindex $field 0]]
		}
	} else {
		return [time_format $value "%e %b %Y"]
	}
}

proc ::Extral::settime {map data oldvalue field value} {
	if {"$field" != ""} {return -code error "error: field \"$field\" not present in map \"$map\""}
	if {"$value" == "[lindex $map end]"} {
		return -code 5 $value
	}
	return [time_scan $value]
}

proc ::Extral::gettime {map data field value} {
	if {"$value" == ""} {return [lindex $map end]}
	if {"$field" != ""} {
		if {"$field" == "val"} {
			return $value
		} else {
			return [time_format $value [lindex $field 0]]
		}
	} else {
		return [time_format $value "%e %b %Y %H:%M:%S"]
	}
}

proc ::Extral::setnamed {map data oldvalue field value} {
#putsvars map data oldvalue field value
	if {"$field" == ""} {
		set len [llength $value]
		if {[expr $len%2] != 0} {
			return -code error "error: \"$value\" does not have an even number of elements"
		}
		foreach {name val} $value {
			set code [catch {::Extral::setnamed $map $data $oldvalue $name $val} oldvalue]
			if {$code == 1} {
				error $oldvalue
			}
		}
		set result $oldvalue
	} else {
		set struct [lindex $map 1]
		set tag [list_shift field]
		set pos [map_find $oldvalue $tag]
		if {$pos == -1} {
			set code [catch {::Extral::map_setstruct $struct $data "" [llength $field] $field $value} res]
			if {$code == 1} {
				error "$res in named \"$tag\""
			} elseif {$code == 5} {
				set result $oldvalue
			} else {
				lappend oldvalue $tag
				lappend oldvalue $res
				set result $oldvalue
			}
		} else {
			set code [catch {::Extral::map_setstruct $struct $data [lindex $oldvalue $pos] [llength $field] $field $value} res]
			if {$code == 1} {
				error "$res in named \"$tag\""
			} elseif {$code == 5} {
				set result [lreplace $oldvalue [expr {$pos-1}] $pos]
			} else {
				set result [lreplace $oldvalue $pos $pos $res]
			}
		}
	}
	if {"$result" == ""} {
		return -code 5 $result
	} else {
		return $result
	}
}

proc ::Extral::unsetnamed {map data oldvalue field} {
#putsvars map data oldvalue field
	if {"$field" == ""} {
		return -code 5 ""
	} else {
		set struct [lindex $map 1]
		set tag [list_shift field]
		set pos [map_find $oldvalue $tag]
		if {$pos == -1} {
			set code [catch {::Extral::map_unsetstruct $struct $data "" [llength $field] $field} res]
			if {$code == 1} {
				error "$res in named \"$tag\""
			} elseif {$code == 5} {
				set result $oldvalue
			} else {
				lappend oldvalue $tag
				lappend oldvalue $res
				set result $oldvalue
			}
		} else {
			set code [catch {::Extral::map_unsetstruct $struct $data [lindex $oldvalue $pos] [llength $field] $field} res]
			if {$code == 1} {
				error "$res in named \"$tag\""
			} elseif {$code == 5} {
				set result [lreplace $oldvalue [expr {$pos-1}] $pos]
			} else {
				set result [lreplace $oldvalue $pos $pos $res]
			}
		}
	}
	if {"$result" == "[lindex $map end]"} {
		return -code 5 $result
	} else {
		return $result
	}
}

proc ::Extral::getnamed {map data field value} {
#putsvars map data field value
	set struc [lindex $map 1]
	if {"$field" == ""} {
		set result ""
		foreach {name val} $value {
			lappend result $name [map_getstruct $struc $data $val 0 ""]
		}
		return $result
	} else {
		set tag [list_shift field]
		set pos [map_find $value $tag]
		if {$pos != -1} {
			return [map_getstruct $struc $data [lindex $value $pos] [llength $field] $field]
		} else {
			return [map_getstruct $struc $data {} [llength $field] $field]
		}
	}
}

proc ::Extral::setlist {map data oldvalue field value} {
#putsvars map oldvalue field value
	set tag [list_shift field]
	set struct [lindex $map 1]
	if {"$tag" == ""} {
		set result ""
		foreach val $value oldval $oldvalue {
			set code [catch {::Extral::map_setstruct $struct $data $oldval [llength $field] $field $val} res]
			if {$code == 1} {
				error $res
			} else {
				lappend result $res
			}
		}
		return $result
	} elseif {"$tag" == "next"} {
		set code [catch {::Extral::map_setstruct $struct $data "" [llength $field] $field $value} res]
		if {$code == 1} {
			error $res
		} else {
			lappend oldvalue $res
			return $oldvalue
		}
	} elseif {[llength $tag] == 1} {
		set len [llength $oldvalue]
		if {$len == 0} {
			return -code error "empty list"
		}
		incr len -1
		if {("$tag"!="end")&&($tag>$len)} {
			return -code error "list doesn't contain element $tag"
		}
		set code [catch {::Extral::map_setstruct $struct $data [lindex $oldvalue $tag] [llength $field] $field $value} res]
		if {$code == 1} {
			error $res
		} else {
			return [lreplace $oldvalue $tag $tag $res]
		}
	} else {
		return -code error "wrong # args to list: \"$tag\""
	}
}

proc ::Extral::unsetlist {map data oldvalue field} {
#putsvars map oldvalue field
	set len [llength $oldvalue]
	if {$len == 0} {
		return -code 5 ""
	}
	incr len -1
	set tag [list_shift field]
	set fieldlen [llength $field]
	set struct [lindex $map 1]
	if {$fieldlen != 0} {
		set result ""
		if {"$tag" == ""} {
			foreach element $oldvalue {
				set code [catch {::Extral::map_unsetstruct $struct $data $element $fieldlen $field} res]
				if {$code == 1} {
					error $res
				} elseif {$code == 5} {
					lappend result {}
				} else {
					lappend result $res
				}
			}
		} elseif {[llength $tag] == 1} {
			if {("$tag"!="end")&&($tag>$len)} {
				return $oldvalue
			}
			set code [catch {::Extral::map_unsetstruct $struct $data [lindex $oldvalue $tag] $fieldlen $field} res]
			if {$code == 1} {
				error $res
			} else {
				set result [lreplace $oldvalue $tag $tag $res]
			}
		} else {
			return -code error "wrong # args to list: \"$tag\""
		}
	} else {
		if {"$tag" == ""} {
			return -code 5 ""
		} elseif {[llength $tag] == 1} {
			if {("$tag"!="end")&&($tag>$len)} {
				return $oldvalue
			}
			set result [lreplace $oldvalue $tag $tag]
		} else {
			return -code error "wrong # args to list: \"$tag\""
		}
	}
	if {"$result" == ""} {
		return -code 5 ""
	} else {
		return $result
	}
}

proc ::Extral::getlist {map data field value} {
#putsvars map field value
	set tag [list_shift field]
	set struct [lindex $map 1]
	set taglen [llength $tag]
	if {$taglen == 0} {
		set result ""
		foreach val $value {
			set code [catch {::Extral::map_getstruct $struct $data $val [llength $field] $field} res]
			if {$code == 1} {
				error $res
			} else {
				lappend result $res
			}
		}
		return $result
	} elseif {$taglen == 1} {
		set len [llength $value]
		if {$len == 0} {
			return ""
		}
		incr len -1
		if {("$tag" != "end")&&($tag > $len)} {
			return ""
		}
		set code [catch {::Extral::map_getstruct $struct $data [lindex $value $tag] [llength $field] $field} res]
		if {$code == 1} {
			error $res
		} else {
			return $res
		}
	} elseif {($taglen == 2) || ($taglen == 3)} {
		set len [llength $value]
		if {$len == 0} {
			return ""
		}
		incr len -1
		set start [lindex $tag 0]
		set end [lindex $tag 1]
		if {("$start"!="end")&&($start>$len)} {
			return ""
		}
		if {("$end"!="end")&&($end>$len)} {
			set end $len
		}
		set result ""
		foreach val [lrange $value $start $end] {
			set code [catch {::Extral::map_getstruct $struct $data $val [llength $field] $field} res]
			if {$code == 1} {
				error $res
			} else {
				lappend result $res
			}
		}
		if {$taglen == 2} {
			return $result
		} else {
			return [eval [lindex $tag 2] {$result}]
		}
	} else {
		return -code error "wrong # args to list: \"$tag\""
	}
}
