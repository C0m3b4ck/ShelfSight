# Create atexit handler
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc atexit title {
#atexit
#} shortdescr {
#execute commands when Tcl exits
#}

rename exit ::Extral::exit
proc exit {{returnCode 0}} {
	global Extral::atexit
	if [info exists Extral::atexit] {
		foreach command $Extral::atexit {
			eval $command
		}
	}
	Extral::exit $returnCode
}


#doc {atexit atexit} cmd {
#atexit add command
#} descr {
#	adds a command to the atexit handler: This command will be executed when
#	the program exits. It can be used to do a cleanup. This command redefines
#	the exit command. If you use it in Tk, and you exit by calling "destroy ."
#	it will not work. You can redefine the destroy command to call exit when it 
#	has . as an argument.
#}
proc atexit {action {command {}}} {
	if ![info exists ::Extral::atexit] {set ::Extral::atexit ""}
	switch $action {
		add {
			if {[lsearch $::Extral::atexit $command] == -1} {
				list_unshift ::Extral::atexit $command
			}
		}
		remove {
			set pos [lsearch $::Extral::atexit $command]
			if {$pos != -1} {
				set ::Extral::atexit [lreplace $::Extral::atexit $pos $pos]
			}
		}
		list {
			return $::Extral::atexit
		}
		default {
			return -code error "Unknown option \"$action\": should be one of add, remove or list"
		}
	}
}
