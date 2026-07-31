# File containing the Tcl part of the list commands in the Extral extension
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc cmd title {
#Command manipulation commands
#}

#doc {cmd cmd_get} cmd {
#	cmd_get channelId
#} descr {
#	get one complete Tcl command, in the sense of having no unclosed quotes, 
#	braces, brackets or array element names, from the open file given by channelId
#}
proc cmd_get {channelId} {
	if [eof $channelId] {return ""}
	while 1 {
		append line "[gets $channelId]"
		if [info complete $line] break
		if [eof $channelId] {
			error "file end: \"$line\" is incomplete"
		}
		append line "\n"
	}
	return $line
}

#doc {cmd cmd_split} cmd {
#	cmd_split data
#} descr {
#	split data into complete Tcl commands in the sense of having no unclosed quotes, 
#	braces, brackets or array element names.
#}
proc cmd_split {data} {
	set result ""
	set current ""
	foreach line [split $data "\n"] {
		if {"$current" != ""} {
			append current "\n"
		}
		append current $line
		set end [string length $line]
		incr end -1
		if ![regexp {\\$} $current] {
			if [info complete $current] {
				lappend result $current
				set current ""
			}
		}
	}
	return $result
}

#proc splitesccomplete {data} {
#	set result ""
#	set current ""
#	foreach line [split $data "\n"] {
#		if {"$current" != ""} {
#			append current "\n"
#		}
#		append current $line
#		if ![regexp {\\$} $current] {
#			if [info complete $current] {
#				lappend result $current
#				set current ""
#			}
#		}
#	}
#	return $result
#}

#doc {cmd cmd_parse} cmd {
#	cmd_parse line
#} descr {
#	parses a cmdline. it returns a list where each element is the part of the cmdline that
#	will result in one element when the cmdline would be evaluated.
#	eg.
#	% cmd_parse {set test [format "%2.2f" 4.3]}
#	set test {[format "%2.2f" 4.3]}
#}
proc cmd_parse {line {recurse 0}} {
	regsub -all "\\\\\n" $line { } line
	set len [string length $line]
	set i $recurse
	while {$i < $len} {
		if ![regexp "\[ \t\]" [string index $line $i]] break
		incr i
	}
	set prev $i
	set result ""
	while {$i < $len} {
		switch -- [string index $line $i] {
			" " - "\n" {
				lappend result [string range $line $prev [expr {$i-1}]]
				while {$i < $len} {
					incr i
					set char [string index $line $i]
					if {("$char" != " ")&&("$char" != "\t")} {
						set prev $i
						incr i -1
						break
					}
				}
			}
			"\\" {
				incr i
			}
			"\{" {
				set level 1
				while 1 {
					incr i
					if {$i == $len} break
					switch -- [string index $line $i] {
						"\{" {
							incr level
						}
						"\}" {
							incr level -1
							if {$level == 0} break
						}
					}
				}
			}
			"\"" {
				while 1 {
					incr i
					if {$i == $len} {
						error "missing \""
					}
					switch -- [string index $line $i] {
						"\\" {incr i}
						"\"" break
						"\[" {
							incr i
							set i [cmd_parse $line $i]
						}
					}
				}
			}
			"\[" {
				incr i
				set i [cmd_parse $line $i]
			}
			"\]" {
				if $recurse {
					return $i
				}
			}
		}
		incr i
	}
	lappend result [string range $line $prev end]
	return $result
}
#set line "\t \$window.try configure \t -title \[puts \"\[tk appname\]\"\] \\\n-command \"\$window command\\\"\\n\\\"\" -test \{try \nit \"\"\}"
#cmd_parse $line

#doc {cmd cmd_load} cmd {
#	cmd_load filename
#} descr {
#	returns the contents of the given file als a list of complete Tcl commands.
#	
#}
proc cmd_load {filename} {
	set f [open $filename "r"]
	while {[eof $f] != 1} {
		lappend result [cmd_get $f]
	}
	close $f
	return $result
}

#doc {cmd cmd_args} cmd {
#	cmd_args cmd options vars args
#} descr {
#	parses the arguments given to a command, deals with options and optional arguments.
#	Options are stored in the array opt, values in the variables given.
#	the list of possible options consists of alternatingly the option
#	and a specification, which is a list of type and description, and optionally a default value
#	variables in the variable list enclosed in questionmarks are optional.
#	?...? will take all possible extra arguments at that position (if present), and store them in the
#	variable args.
#} example {
#	cmd_args test {
#		-test {any "test value" defvalue}
#		-b {switch "true or false"}
#		-o {{oneof a b c} "a, b or c"}
#	} {?nrruns? file} {-b -test try -o b 1 testfile}
#}
proc cmd_args {cmd options vars arg} {
	# Handle options
	set pos 0
	if {[llength $options]} {
		upvar opt opt
		foreach {key def} $options {
			if {[llength $def] > 2} {
				set opt($key) [lindex $def 2]
			}
		}
		array set op $options
		while 1 {
			set curopt [lindex $arg $pos]
			if {[string_equal $curopt --]} {
				incr pos
				break
			}
			if {![info exists op($curopt)]} break
			set type [lindex $op($curopt) 0]
			if {[string_equal [lindex $type 0] switch]} {
				set value 1
				incr pos
			} else {
				set value 1
				incr pos
				set value [lindex $arg $pos]
				incr pos
				switch [lindex $type 0] {
					int {
						if {![isint $value]} {
							return -code error "invalid value \"$value\" for option $curopt: should be an integer"
						}
					}
					double {
						if {![isdouble $value]} {
							return -code error "invalid value \"$value\" for option $curopt: should be a double number"
						}
					}
					oneof {
						if {![inlist [lrange $type 1 end] $value]} {
							return -code error "invalid value \"$value\" for option $curopt: should be one of: [lrange $type 1 end]"
						}
					}
				}
			}
			set opt($curopt) $value
		}
		set arg [lrange $arg $pos end]
	}
	# Handle arguments
	regsub -all {\?[^?]+\?} $vars {} fixedvars
	set numfixed [llength $fixedvars]
	set vartodo [expr {[llength $arg] - $numfixed}]
	set range 0
	set error 0
	if {[llength $arg] < $numfixed} {
		set error 1
	} else {
		set pos 0
		foreach var $vars {
			set value [lindex $arg $pos]
			if {$range} {
				if !$vartodo {
					set error 1
					break
				}
				if {"[string index $var [expr {[string length $var]-1}]]" == "?"} {
					lappend dovar [string trimright $var ?]
					set range 0
				} else {
					lappend dovar $var
				}
				lappend doval $value
				incr vartodo -1
				incr pos			
			} elseif {"[string index $var 0]" == "?"} {
				if {"[string index $var [expr {[string length $var]-1}]]" == "?"} {
					if {[string_equal $var ?...?]} {
						if {$vartodo} {
							set pos2 [expr {$pos+$vartodo-1}]
							lappend dovar args
							lappend doval [lrange $arg $pos $pos2]
							set vartodo 0
							set pos [expr {$pos2+1}]
						}
					} else {
						if {$vartodo} {
							lappend dovar [string trimleft [string trimright $var ?] ?]
							lappend doval $value
							incr vartodo -1
							incr pos			
						}
					}
				} else {
					if {$vartodo} {
						lappend dovar [string trimleft $var ?]
						lappend doval $value
						incr vartodo -1
						incr pos			
					}
					set range 1
				}
			} else {
				lappend dovar $var
				lappend doval $value
				incr pos			
			}
		}
	}
	if {$error||$vartodo} {
		if {[llength $options]} {
			set format "$cmd ?options? $vars"
			set opterror "\nPossible options are:"
			foreach {option descr} $options {
				if {[string_equal [lindex $descr 0] switch]} {
					append opterror "\n\t$option \"[lindex $descr end]\""
				} else {
					append opterror "\n\t$option $descr"
				}
			}
		} else {
			set format "$cmd $vars"
			set opterror ""
		}
		if {[regexp ^- [lindex $arg 0]]} {
			return -code error "bad option \"[lindex $arg 0]\":$opterror"			
		} else {
			return -code error "wrong # of args: should be \"$format\"$opterror"
		}
	}
	if {[lsearch $vars ?...?] != -1} {
		upvar args args
		set args {}
	}
	if {[info exists dovar]} {
		uplevel [list foreach $dovar $doval break]
	}
}

