proc csv_parse {data {sep ,} {linecmd {}}} {
	set result {}
	set resultline {}
	set newline 0
	regsub -all \r\n $data \n data
	set data [string trimright $data \n]
	set data [split $data \n]
	if {[info exists quotedstring]} {unset quotedstring}
	set quotereplace {{""} {"}}
	set quoteconnect $sep
	foreach line $data {
		set line [split $line $sep]
		foreach el $line {
			if {![info exists quotedstring]} {
				if {[string equal [string index $el 0] \"]} {
					if {[string equal $el \"]} {
						set quotedstring ""
					} elseif {[string equal $el \"\"] || [regexp {([^"]|\A)("")*"$} $el]} {
						# if the end of el is the proper ending of a quoted string
						set el [string trim $el]
						lappend resultline [string map $quotereplace [string range $el 1 end-1]]
					} else {
						set quotedstring [string range $el 1 end]
					}
				} else {
					set el [string trim $el]
					lappend resultline $el
				}
			} else {
				if {[regexp {([^"]|\A)("")*"$} $el]} {
					append quotedstring $quoteconnect[string range $el 0 end-1]
					set quotedstring [string map $quotereplace $quotedstring]
					lappend resultline $quotedstring
					unset quotedstring
				} else {
					append quotedstring $quoteconnect$el
				}
				set quoteconnect $sep
			}
		}
		if {![info exists quotedstring]} {
			if {$linecmd eq ""} {
				lappend result $resultline
			} else {
				uplevel [list set line $resultline]
				uplevel $linecmd
			}
			set resultline ""
		} else {
			if {![llength $line]} {append quotedstring \n}
			set quoteconnect \n
		}
	}
	if {[llength $resultline]} {lappend result $resultline}
	return $result
}

proc csv_file {f {sep ,} {linecmd {}}} {
	set result {}
	set resultline {}
	set newline 0
	if {[info exists quotedstring]} {unset quotedstring}
	set quotereplace {{""} {"}}
	set quoteconnect $sep
	while {![eof $f]} {
		set line [gets $f]
		set line [split $line $sep]
		foreach el $line {
			if {![info exists quotedstring]} {
				if {[string equal [string index $el 0] \"]} {
					if {[string equal $el \"]} {
						set quotedstring ""
					} elseif {[string equal $el \"\"] || [regexp {([^"]|\A)("")*"$} $el]} {
						# if the end of el is the proper ending of a quoted string
						set el [string trim $el]
						lappend resultline [string map $quotereplace [string range $el 1 end-1]]
					} else {
						set quotedstring [string range $el 1 end]
					}
				} else {
					set el [string trim $el]
					lappend resultline $el
				}
			} else {
				if {[regexp {([^"]|\A)("")*"$} $el]} {
					append quotedstring $quoteconnect[string range $el 0 end-1]
					set quotedstring [string map $quotereplace $quotedstring]
					lappend resultline $quotedstring
					unset quotedstring
				} else {
					append quotedstring $quoteconnect$el
				}
				set quoteconnect $sep
			}
		}
		if {![info exists quotedstring]} {
			if {$linecmd eq ""} {
				if {[eof $f] && ![llength $resultline]} break
				lappend result $resultline
			} else {
				uplevel [list set line $resultline]
				uplevel $linecmd
			}
			set resultline ""
		} else {
			if {![llength $line]} {append quotedstring \n}
			set quoteconnect \n
		}
	}
	if {[llength $resultline]} {lappend result $resultline}
	return $result
}

proc csv_split {line {sep ,}} {
	set resultline {}
	set quotereplace {{""} {"}}
	set quoteconnect $sep
	set line [split $line $sep]
	foreach el $line {
		if {![info exists quotedstring]} {
			if {[string equal [string index $el 0] \"]} {
				# check if the el is the proper ending of a quoted string
				if {[string equal $el \"\"] || [regexp {([^"]|\A)("")*"$} $el]} {
					lappend resultline [string map $quotereplace [string range $el 1 end-1]]
				} else {
					set quotedstring [string range $el 1 end]
				}
			} else {
				lappend resultline $el
			}
		} else {
			if {[regexp {([^"]|\A)("")*"$} $el]} {
				append quotedstring $quoteconnect[string range $el 0 end-1]
				set quotedstring [string map $quotereplace $quotedstring]
				lappend resultline $quotedstring
				unset quotedstring
			} else {
				append quotedstring $quoteconnect$el
			}
			set quoteconnect $sep
		}
	}
	return $resultline
}

proc csv_write {f data {sep ,} {quote "\""}} {
	set quotereplace {{"} {""}}
	foreach line $data {
		set resultline {}
		if {$quote eq ""} {
			puts $f [join $line $sep]
		} elseif {$quote eq "\""} {
			foreach el $line {
				if {[regexp "\[ ${sep}\n\"\]" $el]} {
					set el \"[string map $quotereplace $el]\"
				}
				lappend resultline $el
			}
			puts $f [join $resultline $sep]
		} else {
			set replace [list $quote \\$quote]
			foreach el $line {
				if {[regexp "\[ ${sep}\n\"\]" $el]} {
					set el $quote[string map $replace $el]$quote
				}
				lappend resultline $el
			}
			puts $f [join $resultline $sep]
		}
	}
}

proc csv_getsep {line {list {\t , " "}}} {
	foreach sep $list {
		set fields [csv_split $line $sep]
		if {[llength $fields] >= 2} break
	}
	return $sep
}
