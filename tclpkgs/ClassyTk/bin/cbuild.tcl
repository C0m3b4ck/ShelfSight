#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
#
# ClassyTk
# --------- Peter De Rijk
#

package require Tk

wm withdraw .
tk appname cbuild
if {[package require ClassyTk] < 1.0} {
	error "version conflict for package \"ClassyTk\": need version 1.0 or later"
}

if [llength $argv] {
	set file [lindex $argv 0]
	set argv [lrange $argv 1 end]
	if {"[file pathtype $file]" == "relative"} {
		set file [file join [pwd] $file]
	}
} else {
	set file ""
	set file [Classy::savefile -title "Build Application" -help cbuild]
	if {"$file" == ""} exit
}

set name [file root [file tail $file]]
if ![file exists $file] {
	if {[lsearch -exact {conf help lib} $name] != -1} {
		error "Cannot create application named \"$name\": reserved"
	}
	if ![Classy::yorn "Create application	\"$name\""] {exit}
	set cachefile [file join [file dir $::Classy::dira(appuser)] $name config.cache]
	if [file exists $cachefile] {
		file delete $cachefile
	}
	file copy [file join $Classy::dir template] $file
	file rename [file join $file template.tcl] [file join $file $name.tcl]
	set file [file join $file $name.tcl]
} elseif [file isdir $file] {
	set file [file join $file $name.tcl]
}

if ![catch {open [file root $file]} f] {
	gets $f;gets $f;gets $f
	set line [gets $f]
	set v 0.1
	regexp {[0-9.]+$} $line v
	close $f
	switch $v {
		0.1 {
			puts "Converting to new builder format"
			exec [file join $::Classy::dir bin convert0.1_to_0.2] $file
		}
	}
}
puts "Starting application \"$name\""
if {"$tcl_platform(platform)" != "windows"} {
	eval exec {$file} -builder $argv &
} else {
	set dir [file dir [file dir [info library]]]
	if {[string equal [string tolower [file extension $dir]] .exe]} {
		set wishbin $dir
	} else {
		regsub \\. [info tclversion] {} temp
		set wishbin [file join $dir bin wish$temp.exe]
	}
	eval exec [list $wishbin] {$file} -builder $argv &
}
exit

