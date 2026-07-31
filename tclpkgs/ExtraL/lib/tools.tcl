# Some tools
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc convenience title {
#Convenience functions
#} shortdescr {
#various useful procs
#}

#doc {convenience aproc} cmd {
#aproc args body
#} descr {
# aproc creates an 'anonymous' procedure; this means you don't have to provide a name. It
# returns the name to invoke it. These procedures are cached based on the arguments and body.
# This is actually somewhat similar to the invoke command, but is faster when the proc
# is being reused many times.
# Typical use would be in parameters that expect a command name that will be called later with 
# a number of arguments:
# .ctable configure -getcommand [aproc {args} {return $args}]
#}
set Extral::aproc() 0
proc aproc {args body} {
	upvar #0 Extral::aproc aproc
	set key [list $args $body]
	if ![info exists aproc($key)] {
		incr aproc()
		proc ::Extral::aproc$aproc() $args $body
		set aproc($key) ::Extral::aproc$aproc()
	}
	return $aproc($key)
}

#doc {convenience ?} cmd {
#? expr truevalue falsevalue
#} descr {
# ? expr truevalue falsevalue
#}
proc ? {expr truevalue falsevalue} {
	if {[uplevel [list expr $expr]]} {
		return $truevalue
	} else {
		return $falsevalue
	}
}

#doc {convenience echo} cmd {
#echo string
#} descr {
# echo returns its argument as a result
# This is useful when you want a command that will be evalled or upleveled
# to return a certain value
# 
#}
proc echo {string} {
	return $string
}

#doc {convenience rem} cmd {
#rem args
#} descr {
#	does nothing<br>
#	I use this to put some example or testing code in a program
#	without all the #'s
#}
proc rem {args} {
}

# REM:
#doc {convenience REM} cmd {
#REM args
#} descr {
#	when the procedure remof is called, REM will also do nothing
#	when the procedure remon is called, REM will put its arguments
#	to the stdout
#}
proc REM {args} {}
proc remon {} {
	proc REM {args} {	  
		puts stdout $args   
	}
}
proc remoff {} {
	proc REM {args} {}
}

#doc {convenience true} cmd {
#true expression
#} descr {
# true expr
#	returns 1 when expression is yes, true or 1<br>
#	otherwise it returns 0.
#}
proc true {expr} {
	set result 0
	return [regexp -nocase {^(1|yes|true|on)$} $expr]
}

#doc {convenience setglobal} cmd {
# setglobal varName ?newValue?
#} descr {
#	same as the set command, but then for global variables
#}
proc setglobal {varName args} {
	upvar #0 $varName var
	if {"$args" == ""} {
		if ![info exists var] {
			error "can't read \"$varName\": no such global variable"
		} else {
			return $var
		}
	} else {
		set var [lindex $args 0]
	}
}

#doc {convenience random} cmd {
#random min max
#} descr {
#returns a random number between min and max
#}
proc random {min max} {
	set r [expr $max-$min+1]
	return [expr int($min+rand()*$r)]
}

#doc {convenience putsvars} cmd {
#putsvars varname ?varname ...?
#} descr {
#returns the values of the given variables in the form:<br>
#set variable1 value1<br>
#set variable2 value2
#}
proc putsvars {args} {
	foreach var $args {
		if {[catch {uplevel [list set $var]} value]} {
			puts [list unset $var]
		} else {
			puts [list set $var $value]
		}
	}
}

#doc {convenience error_preserve} cmd {
# error_preserve
#} descr {
# preserves the error information in the variables errorInfo.
# Preserved information will be restored with the command error_restore
#}
proc error_preserve {} {
	upvar ::Extral::error_preserve keep
	set keep(Info) $::errorInfo
	set keep(Code) $::errorCode
}

#doc {convenience today} cmd {
# today
#} descr {
# returns current time in astronomical format: "%Y-%m-%d %H:%M:%S"
#}
proc today {} {
	return [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
}

proc error_restore {} {
	upvar ::Extral::error_preserve keep
	set ::errorInfo $keep(Info)
	set ::errorCode $keep(Code)
}

proc extractoption {listName option default} {
	upvar $listName l
	set pos [lsearch $l $option]
	if {$pos != -1} {
		list_pop l $pos
		return [list_pop l $pos]
	} else {
		return $default
	}
}

proc extractbool {listName option} {
	upvar $listName l
	set pos [lsearch $l $option]
	if {$pos != -1} {
		list_pop l $pos
		return 1
	} else {
		return 0
	}
}

proc Extral::scriptdir {} {
	set script [info script]
	if {"$script"==""} {
		return [pwd]
	} else {
		global tcl_platform
		if {"$tcl_platform(platform)"=="unix"} {
			if {"[file pathtype $script]"!="absolute"} {
		 		set script [file join [pwd] $script]
			}
			while 1 {
		 		if [catch {set link [file readlink $script]}] break
		 		if {"[file pathtype $link]"=="absolute"} {
		 	 		set script $link
		 		} else {
		 	 		set script [file join [file dirname $script] $l]
		 		}
			}
		}
		return [file dir $script]
	}
}

#doc {convenience Extral::event} cmd {
#Extral::event listen listener event command
#Extral::event remove listener event
#Extral::event generate event ?data? ...
#Extral::event events
#Extral::event listeners event
#Extral::event debug command
#} descr {
# When an event is generated (using Extral::event generate) the commands previously defined
# and attched to the event by one or more listeners will invoked
# The command will be executed in global scope with the data (if any) given by the
# generate command appended
#}
set ::Extral::eventdebug {}
proc Extral::event {option args} {
	upvar #0 Extral::events events
	switch $option {
		listen {
			foreach {listener event command} $args break
			set events($event) [map_set [get events($event) ""] $listener $command]
		}
		remove {
			foreach {listener event} $args break
			set events($event) [map_unset [get events($event) ""] $listener]
		}
		generate {
			set event [list_shift args]
			foreach {listener command} [get events($event) ""] {
				uplevel #0 $command $args
			}
			if {$::Extral::eventdebug ne ""} {
				uplevel #0 [list $::Extral::eventdebug [list *event* $event $args -> [list_unmerge [get events($event) ""]]]]
			}
		}
		events {
			return [array names events]
		}
		listeners {
			foreach event $args break
			return [get events($event) ""]
		}
		clear {
			unset -nocomplain events
		}
		debug {
			set ::Extral::eventdebug $args
		}
		default {
			error "unknown option \"$option\", should be one of: listen, remove, generate, events, listeners, clear"
		}
	}
}

proc Extral::tracecommands_cmd {commandstring op} {
	if {[info exists ::Extral::tracing]} return
	set ::Extral::tracing 1
	catch {
		puts "[uplevel info level] $commandstring $op"
	}
	unset ::Extral::tracing
}

proc Extral::tracecommands {args} {
	if {$args eq ""} {
		foreach cmd [info commands] {
			if {![catch {info body $cmd}]} {
				lappend args $cmd
			}
		}
	}
	set args [list_remove $args Extral::tracecommands_cmd trace history]
	foreach cmd $args {
		trace add execution $cmd enter Extral::tracecommands_cmd
	}
	trace remove execution Extral::tracecommands_cmd enter Extral::tracecommands_cmd
}

proc Extral::tracecommands_rem {args} {
	if {$args eq ""} {
		set args [info commands]
	}
	foreach cmd $args {
		trace remove execution $cmd enter Extral::tracecommands_cmd
	}
}

