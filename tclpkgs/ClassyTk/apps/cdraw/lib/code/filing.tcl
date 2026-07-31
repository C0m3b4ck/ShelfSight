#Functions

proc filesave {object} {
	set object [getobj $object]
	private $object canvas current
	set w $object.canvas
	if {![info exists current(file)]||("$current(file)" == "")||![string_equal [file extension $current(file)] .str]} {
		saveas $object
	}
	file_write $current(file) [$canvas save]
	wm title $object "cdraw: $current(file)"
	changed $object 0
}

proc saveas {object} {
	set object [getobj $object]
	private $object canvas current
	global status
	if {![info exists current(file)]||("$current(file)" == "")} {
		set init new.str
	} else {
		set init $current(file)
		if ![string_equal [file extension $init] .str] {
			set init [file root $init].str
		}
	}
	set file [Classy::savefile -title "Save as" \
		-defaultextension .str\
		-initialfile $init]
	if {"$file" == ""} return
	set current(file) $file
	wm title $object "cdraw: $current(file)"
	filesave $object
	changed $object 0
}

proc fileload {args} {
	checkargs fileload "object ?file?" $args
	set object [getobj $object]
	private $object canvas current
	global status
	if ![info exists file] {
		set files [Classy::selectfile -title Open -selectmode persistent]
		if ![llength $files] return
	} else {
		set files [list $file]
	}
	if ![info exists current(file)] {
		set current(file) [file root [lindex $files 0]].cdr
		wm title $object "cdraw: $current(file)"
		set changed 1
	} else {
		set changed 0
	}
	foreach file $files {
		set f [open $file]
		set line [read $f 100]
		set line [lindex [split $line \n] 0]
		switch -regexp -- $line {
			{header Classy::Canvas} {
				$canvas load [file_read $file]
			}
			default {
				error "Format of file \"$file\" not recognised"
			}
		}
		close $f
	}
	if $changed {changed $object 0}
}
