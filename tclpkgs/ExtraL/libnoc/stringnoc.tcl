#doc {stringcommands string_change} cmd {
#string_change string changelist
#} descr {
# change some parts of a string<br>
# changelist gives alternating a substring to be changed, and what it should be changed into.
# The command returns a string that is the given string where each occurence of the
# substrings in the changelist have been changed.
#}
proc string_change {string changelist} {
	if {[expr {[llength $changelist]%2}]} {
		error "changelist does not have an even number of elements"
	}
	array set translate $changelist
	foreach {from to} $changelist {
		if [string_equal $from {}] {
			error "changelist for string_change cannot contain empty keys"
		}
		lappend index([string index $from 0]) $from
		set length($from) [expr {[string length $from]-1}]
	}
	set len [string length $string]	
	set prevpos 0
	set pos 0
	set result ""
	while {$pos < $len} {
		set first [string index $string $pos]
		if [info exists index($first)] {
			set found 0
			foreach name $index($first) {
				set nlen $length($name)
				if {($nlen == 0)||[string_equal [string range $string $pos [expr {$pos+$nlen}]] $name]} {
					if {$pos != $prevpos} {
						append result [string range $string $prevpos [expr {$pos-1}]]
					}
					append result $translate($name)
					incr pos $nlen
					incr pos
					set prevpos $pos
					set found 1
					break
				}
			}
			if !$found {incr pos}
		} else {
			incr pos
		}
	}
	if {$pos != $prevpos} {
		append result [string range $string $prevpos [expr {$pos-1}]]
	}
	return $result
}

#doc {stringcommands string_reverse} cmd {
#string_reverse list
#} descr {
# returns the reverse of list.
#}
proc string_reverse {string} {
	set i [string length $string]
	set result ""
	for {incr i -1} {$i >= 0} {incr i -1} {
		append result [string index $string $i]
	}
	return $result
}

#doc {stringcommands string_find} cmd {
#string_find mode list pattern
#} descr {
#	returns a list of all indices which match a pattern.
#	mode can be -exact, -glob, or -regexp
#	The default mode is -exact
#} example {
#	% string_find -regexp {Ape Ball Field {Antwerp city} Egg} {^A}
#	0 16
#}
proc string_find {args} {
	if {[llength $args]==2} {
		set string [lindex $args 0]
		set pattern [lindex $args 1]
		set mode -exact
	} elseif {[llength $args]==3} {
		set mode [lindex $args 0]
		set string [lindex $args 1]
		set pattern [lindex $args 2]
	} else {
		error "Format is \"list_find ?mode? list pattern\""
	}
	set result ""
	set pos 0
	set len [string length $string]
	switch -- $mode {
		{-exact} {
			set end [expr {[string length $pattern] - 1}]
			for {set i 0} {$i < $len} {incr i} {
				if {"[string range $string $i $end]"=="$pattern"} {lappend result $i}
				incr end
			}
		}
		{-glob} {
			for {set i 0} {$i < $len} {incr i} {
				if [string match $pattern [string range $string $i end]] {lappend result $i}
			}
		}
		{-regexp} {
			for {set i 0} {$i < $len} {incr i} {
				if [regexp $pattern [string range $string $i end]] {lappend result $i}
			}
		}
		default {
			error "Unkown mode \"$mode\""
		}
	}
	return $result
}

#doc {stringcommands string_replace} cmd {
#string_replace string first last replacement
#} descr {
# replace a part of a string
#}
proc string_replace {string first last replacement} {
	if {$last < $first} {
		set last $first
	} else {
		incr last 1
	}
	if {$first < 0} {
		error "first position < 0"
	}
	incr first -1
	set diff [expr {$first - [string length $string]}]
	if {$diff > 0} {
		for {set i 0} {$i <= $diff} {incr i} {append string " "}
	}
	return [string range $string 0 $first]$replacement[string range $string $last end]
}

#doc {stringcommands string_foreach} cmd {
#string_foreach varList string ?varList string ...? command
#} descr {
# loop over the characters from a string, follows the same syntax as foreach for lists
#}
proc string_foreach {args} {
	if {![expr {[llength $args]%2}]} {
		error "wrong # args: should be \"string_foreach varList string ?varList string ...? command\""
	}
	set cmd foreach
	foreach {vars values} [lrange $args 0 end-1] {
		lappend cmd $vars [split $values {}]
	}
	lappend cmd [lindex $args end]
	uplevel 1 $cmd
}
