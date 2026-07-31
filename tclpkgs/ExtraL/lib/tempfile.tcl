# Handling of temporary files
#
# Copyright (c) 1996 Peter De Rijk
#
# See the file "README" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

namespace eval Extral {
	global env
	# Set variable temp_dir to the temporary directory.
	# Make one if one doesn't exist.
	# 
	
	if {[info exists env(TMPDIR)]} {
		set temp_dir $env(TMPDIR)
	} elseif {[info exists env(TEMPDIR)]} {
		set temp_dir $env(TEMPDIR)
	} elseif {[info exists env(TEMP)]} {
		set temp_dir $env(TEMP)
	} elseif {[info exists env(TMP)]} {
		set temp_dir $env(TMP)
	} elseif {[file writable /tmp]} {
		set temp_dir /tmp
	} elseif {[file writable /usr/tmp]} {
		set temp_dir /usr/tmp
	} elseif {[info exists env(HOME)]} {
		set temp_dir [file join $env(HOME) tcltemp]
	} else {
		set temp_dir [file join [pwd] tcltemp]
	}
	
	if {![file exists $temp_dir]} {
		if [catch {file mkdir $temp_dir}] {
			puts stdout "Didn't find temporary directory"
			puts stdout "Couldn't make temporary directory \"$temp_dir\""
		}
	} elseif {![file isdirectory $temp_dir]} {
		puts stdout "Didn't find temporary directory"
		puts stdout "Temporary directory \"$temp_dir\" exists, and is not a directory"
	}
	atexit add {tempfile clean}
}

# Procedures
# ----------------------------------------------------------------

#doc tempfile title {
#tempfile
#} shortdescr {
# get names for temporary files
#}

#doc {tempfile get} cmd {
#tempfile ?get? ?file|dir?
#} descr {
#	Creates a temporary directory (using tempdir) if needed, and returns unique filenames
#	in this directory for use as temporary files. The temporary directory is deleted when
#	the program exits
#}
#doc {tempfile clean} cmd {
#tempfile clean
#} descr {
#	remove all temporary files for the running program.
#}
#doc {tempfile cleanall} cmd {
#tempfile cleanall
#} descr {
#	remove all temporary files, including those of other Extral programs.
#}
proc tempfile {{action {get}} {type file}} {
	switch $action {
		get {
			set tempdir [tempdir]
			return [file join $tempdir _Extral_temp_[incr ::Extral::tempnum].tmp]
		}
		clean {
			set tempdir [tempdir]
			catch {file delete -force $tempdir}
			unset ::Extral::tempdir
		}
		cleanall {
			catch {eval file delete -force [glob [file join $temp_dir tempExtral*]]}
		}
		default {
			return -code error "bad option \"$action\": must be get, clean or cleanall"
		}
	}
}

proc Extral::randstring {size} {
	set result {}
	for {set i 0} {$i < $size} {incr i} {
		append result [format %c [expr {int(rand() * 26) + [expr {int(rand() * 10) > 5 ? 97 : 65}]}]]
	}
	return $result
}

#doc tempdir title {
#tempdir
#} shortdescr {
# returns a directory in which temporary files can be stored. This directory is specific to one proces:
# no other processes will (should) write in this directory. Subsequent calls to the function within one process
# will allways be the same directory, The program has to take care not to overwrite its own files
# Temporary files returned by tempfile are also in this directory (named like _Extral_temp_1.tmp)
# The program should also not overwrite these
# The temporary directory is deleted when the program exits by an atexit handler
# 
#}

proc tempdir {} {
	if {![info exists ::Extral::tempdir]} {
		for {set i 0} {$i < 20} {incr i} {
			set testdir [file join $::Extral::temp_dir tempExtral.[pid]-[Extral::randstring 20]]
			if {[file exists $testdir]} continue
			if {[catch {
				file mkdir $testdir
				if {$::tcl_platform(platform) eq "unix"} {
					file attributes $testdir -permissions 0700
				}
				set files [glob -nocomplain $testdir/*]
				if {[llength $files]} {
					error "Very fishy: there are files in the temporary directory I just created"
				}
				set ::Extral::tempdir $testdir
				set ::Extral::tempnum 0
			}]} continue
			break
		}
	}
	if {![info exists ::Extral::tempdir]} {
		error "couldn't create temporary directory in [file nativename $::Extral::temp_dir]"
	}
	return $::Extral::tempdir
}
