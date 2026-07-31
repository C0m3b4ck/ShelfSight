# maptools
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

#doc {map map_xml} cmd {
#map_xml xml
#} descr {
# puts the information in xml into a map
# data (not in tags) will be placed in the map with the tag "_"
#} example {
#}
proc map_xml {xml} {
	regsub -all {<!--[^>]*>} $xml {} xml
	regsub -all "\[ \t\n\]\[ \t\n\]+" $xml { } xmllist
	regsub -all < $xmllist <\7 xmllist
	set xmllist [split $xmllist <>]
	set pos 0
	catch {unset xmla}
	foreach el $xmllist {
		if [regexp "\7(\[^ \]+)" $el temp key] {
			lappend xmla($key) $pos
		}
		incr pos
	}
	set result ""
	set pos 0
	set len [llength $xmllist]
	while {$pos < $len} {
		set el [lindex $xmllist $pos]
		set ch [string index $el 0]
		if {"$ch" == "\7"} {
			set ch [string index $el 1]
			if {"$ch" == "?"} {
				if {[regexp {^([^=]+)="(.*)"\?$} [string range $el 2 end] temp key value]} {
					set result [map_set $result $key $value]
				}
			} elseif {"$ch" == "!"} {
				foreach {key value} [string range $el 2 end] {
					set result [map_set $result !$key $value]
				}
			} else {
				_map_xml_parse_el $el
			}
		}
		incr pos
	}
	return $result
}

proc _map_xml_parse_el {el} {
	upvar xmllist xmllist
	upvar xmla xmla
	upvar pos pos
	upvar num num
	upvar result result
	# parse what is in the tag
	if {"[string index $el end]" == "/"} {
		set self 1
		set el [string range $el 1 end-1]
	} else {
		set self 0
		set el [string range $el 1 end]
	}
	set apos [string first " " $el]
	if {$apos == -1} {
		set key $el
		set args ""
	} else {
		set key [string range $el 0 [expr {$apos-1}]]
		set args [string range $el [expr {$apos+1}] end]
	} 
	if [info exists num($key)] {
		incr num($key)
		set ukey ${key}($num($key))
	} else {
		set num($key) 0
		set ukey $key
	}
	# use the parsed values
	set presult ""
	if $self {
		incr pos
	} else {
		if ![info exists xmla(/$key)] {
			error "could not find closing /$key"
		}
		set pos2 [list_shift xmla(/$key)]
		incr pos 1
		incr pos2 -1
		if {$pos == $pos2} {
			lappend presult _data [lindex $xmllist $pos]
			incr pos
		} else {
			set presult [_map_xml_recurse $pos $pos2]
			set pos [expr {$pos2+1}]
		}
	}
	if [string length $args] {
		regsub -all {="} $args { "} args
		lappend presult _args [eval list $args]
	}
	lappend result $ukey $presult
}

proc _map_xml_recurse {pos len} {
	upvar xmllist xmllist
	upvar xmla xmla
	set result ""
	while {$pos < $len} {
		set el [lindex $xmllist $pos]
		set ch [string index $el 0]
		if {"$ch" == "\7"} {
			_map_xml_parse_el $el
		}
		incr pos
	}
	return $result
}
