# Some handy filing functions I often use, so they ended up here
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================
#doc filing title {
#Filing commands
#}

#doc {filing dirglob} cmd {
#	dirglob dir pattern
#} descr {
#	returns a list of all filenames in directory dir mathing the given pattern
#}
proc dirglob {dir pattern args} {
	set pwd [pwd]
	if [catch {cd $dir}] {return ""}
	if {[llength $args]} {
		set result [eval {glob -nocomplain -- $pattern} $args]
	} else {
		set result [glob -nocomplain -- $pattern]
	}
	cd $pwd
	return $result
}

#doc {filing file_read} cmd {
#	file_read filename
#} descr {
#	returns the contents of the file given by filename
#}
proc file_read {args} {
	set filename [list_pop args]
	set f [open $filename "r"]
	eval fconfigure $f -buffersize 100000 $args
	set result [read $f]
	close $f
	return $result
}

#doc {filing file_write} cmd {
#	file_write filename data
#} descr {
#	create a file by the name filename with data as its content
#}
proc file_write {args} {
	set list [list_pop args]
	set filename [list_pop args]
	set f [open $filename "w"]
	eval fconfigure $f -buffersize 100000 $args
	puts -nonewline $f $list
	close $f
}

#doc {filing file_fullpath} cmd {
#	file_fullpath filename
#} descr {
#	returns a absolute path to the given file
#}
proc file_fullpath {filename} {
	if [string_equal [file pathtype $filename] absolute] {
		set resultlist {}
	} else {
		set resultlist [file split [pwd]]
	}
	foreach el [file split $filename] {
		if {[string_equal $el .]} continue
		if {[string_equal $el ..]} {
			list_pop resultlist
		} else {
			lappend resultlist $el
		}
	}
	return [eval file join $resultlist]
}

# Using the Unix tools
# --------------------

proc chmod {args} {
	set cl ""
	while {[string match \-* [lindex $args 0]]} {
		set item [list_shift args]
		lappend cl $item
	}
	eval lappend cl [list_shift args]
	eval lappend cl [eval glob -nocomplain $args]
	eval exec chmod $cl
}

if {"$tcl_platform(platform)"=="windows"} {
#
# ls and chmod for Windows ?
# This is just a very quick hack to get the most important things working.
# Don't expect to much of it ;-)
# ------------------------------------------------------------------------

proc ls {args} {
	set recurse 1
	while {[string match \-* [lindex $args 0]]} {
		set opt [list_shift args]
		switch -glob -- $opt {
			-d* {set recurse 0}
			-- break
			default {
				error "Unknown argument $opt, should be one of: -d"
			}
		}
	}
	if {"$args"==""} {set args *}
	set files [lsort [eval glob -nocomplain $args]]
	set result ""
	foreach file $files {
		if [file isdir $file] {
			lappend result $file
			if $recurse {
				lappend result "\t[lsort [eval glob -nocomplain [file join $file *]]]"
			}
		} else {
			lappend result $file
		}
	}
	return [join $result "\n"]
}

proc mkdir {args} {
	eval file mkdir $args
}

proc cp {args} {
	eval file copy -force $args
}

proc mv {args} {
	eval file rename $args
}

proc rm {args} {
	eval file delete $args
}

proc chmod {args} {
	set files ""
	set item [list_shift args]
	set num [string index $item 1]
	if {$num==6} {set mod read} else {set mod write}
	foreach file [eval glob -nocomplain $args] {
		win_chmod $mod $file
	}
}

}
