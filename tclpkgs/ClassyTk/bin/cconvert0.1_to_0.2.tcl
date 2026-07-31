#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
#
# ClassyTk
# --------- Peter De Rijk
#
if {[package require ClassyTk] < 1.0} {
	error "version conflict for package \"ClassyTk\": need version 1.0 or later"
}
set file [lindex $argv 0]

proc convtool {confvar descrvar src} {
puts "Converting $src"
	upvar $confvar conf
	upvar $descrvar confdescr
	array set ttl {
		Classy::configtool Toolbars
		Classy::configmenu Menus
	}
	array set tp {
		Classy::configtool toolbar
		Classy::configmenu menu
	}
	set f [open $src]
	while {![eof $f]} {
		set line [cmd_get $f]
		if [regexp ^Classy::config $line] {
			foreach {type name descr value} $line {}
			regsub -all \n\n\n* $value \n value
			lappend conf $tp($type),$name $value
			set confdescr [map_set $confdescr [list $ttl($type) Application $name] [list _$tp($type) $name $descr]]
		}
	}
	close $f
}

proc convother {confvar descrvar src} {
puts "Converting $src"
	upvar $confvar conf
	upvar $descrvar confdescr
	array set ttl {
		Classy::configkey Keys
		Classy::configmouse Mouse
		Classy::configcolor Colors
		Classy::configfont Fonts
		Classy::configmisc Misc
	}
	array set tp {
		Classy::configkey key
		Classy::configmouse mouse
		Classy::configcolor color
		Classy::configfont font
		Classy::configmisc misc
	}
	set f [open $src]
	set result ""
	while {![eof $f]} {
		set line [cmd_get $f]
		if [regexp ^Classy::configmisc $line] {
			foreach {type title cmd} $line {}
			foreach {name key value type descr} $cmd {
				if [regexp ^# $name] {
					set name [string range $name 1 end]
					set comment 1
				} else {
					set comment 0
				}
				regsub -all \n\n $value \n value
				regsub -all \n\n $value \n value
				if !$comment {
					lappend conf $type,$key $value
				}
				set confdescr [map_set $confdescr [list Misc $title $name] [list _$type $key $descr]]
			}
		} elseif [regexp ^Classy::config $line] {
			foreach {type title cmd} $line {}
			foreach {name key value descr} $cmd {
				if [regexp ^# $name] {
					set name [string range $name 1 end]
					set comment 1
				} else {
					set comment 0
				}
				regsub -all \n\n $value \n value
				regsub -all \n\n $value \n value
				if !$comment {
					lappend conf $tp($type),$key $value
				}
				set confdescr [map_set $confdescr [list $ttl($type) $title $name] [list _$tp($type) $key $descr]]
			}
		}
	}
	close $f
	return $result
}

proc convfiles {confdir confvar descrvar files} {
	upvar $confvar conf
	upvar $descrvar confdescr
	set conf {}
	set confdescr {}
	foreach src $files {
		set file [file tail $src]
		switch $file {
			Toolbars.tcl - Menus.tcl {
				convtool conf confdescr $src
			}
			Keys.tcl - Mouse.tcl - Colors.tcl - Fonts.tcl - Misc.tcl {
				convother conf confdescr $src
			}
		}
	}
	set f [open [file join $confdir conf] w]
	foreach {key value} $conf {
		puts $f [list $key $value]
	}
	close $f
}

proc convrec {src} {
	foreach file [dirglob $src *.tcl] {
		if [file isdir [file join $src $file]] {
			convrec [file join $src $file]
		} else {
			switch $file {
				Toolbars.tcl - Menus.tcl {
					set c [convtool [file join $src $file]]
					file_write [file join $src [file root $file].conf] $c
					file delete [file join $src $file]
				}
				Keys.tcl - Mouse.tcl - Colors.tcl - Fonts.tcl - Misc.tcl {
					set c [convother [file join $src $file]]
					file_write [file join $src [file root $file].conf] $c
					file delete [file join $src $file]
				}
			}
		}
	}
}

proc convcode {dir} {
	set files [glob -nocomplain [file join $dir *.tcl]]
	foreach file $files {
		set c [cmd_split [file_read $file]]
		set newc ""
		foreach line $c {
			if [regexp "^proc \[^ \]+ args \{# ClassyTk generated (\[^ \n\]+)" $line temp type] {
				set newcode ""
				set function [lindex $line 1]
				set code [lindex $line 3]
				set code [string_change $code {$window $object {varsubst window} {varsubst object}}]
				set code [cmd_split $code]
				set opt [lindex $code 2]
				set code [lreplace $code 0 2 "\tsuper init"]
				set code [lreplace $code 2 2]
				set pos [lsearch -regexp $code {^# ClassyTk Initialise}]
				if {$pos == -1} {
					set pos [lsearch -regexp $code "^\t# Parse this"]
				}
				set code [linsert $code $pos \t[list if {"$args" == "___Classy::Builder__create"} {return $object}]]
				set pos [lsearch -regexp $code {^# ClassyTk Finalise}]
				set insert "\t# Configure initial arguments"
				append insert \n\t[list if {"$args" != ""} {eval $object configure $args}]
				if {$pos != -1} {
					set code [linsert $code $pos $insert]
				} else {
					lappend code $insert
				}
				set code [join $code \n]
				lappend newcode [list Classy::$type subclass $function]
				lappend newcode "[list $function] method init args \{\n$code\}"
				foreach {option options default} [lindex $opt 3] {
					if [string length $options] {
						if {"$options" == "0 1"} {
							set code {set value [true $value]}
						} else {
							set code "\tif \{\[lsearch -exact $options $value\] == -1\} \{\n"
							append code "\t\terror \"Unkown option(s): \\\"$value\\\"\\nmust be one of: $options\"\n"
							append code "\t\}\n"
						}
					} else {
						set code {}
					}
					lappend newcode [list $function addoption $option [list [string range $option 1 end] "[string toupper [string index $option 1]][string range $option 2 end]" $default] $code]
				}
				set f [open [file join [file dir $file] interface $function.tcl] w]
				set space 0
				foreach line $newcode {
					if ![string length $line] {
						if $space continue
						set space 1
					} else {
						set space 0
					}
					puts $f $line
				}
				close $f
			} elseif [regexp "^proc main \{?args\}?" $line] {
				regsub "(\[\[\n\t \]mainw)(\[\]\t\n \]\[^.\])" $line "\\1 .mainw\\2" line
				regsub "(\[\n\t \]mainw)(\n)" $line "\\1 .mainw\\2" line
				lappend newc $line
			} else {
				lappend newc $line
			}
		}
		catch {file rename -force $file $file~}
		set f [open [file join [file dir $file] code [file tail $file]] w]
		set space 0
		foreach line $newc {
			if ![string length $line] {
				if $space continue
				set space 1
			} else {
				set space 0
			}
			puts $f $line
		}
		close $f
	}
	puts "Making index on \"[file join [pwd] $dir interface]\""
	catch {Class::auto_mkindex [file join $dir interface] *.tcl}
	puts "Making index on \"[file join [pwd] $dir code]\""
	catch {Class::auto_mkindex [file join $dir code] *.tcl}
	file delete [file join $dir tclIndex]
}

invoke {file} {
	if [file isdir $file] {
		set dir $file
		set file [file join $file [file tail $file].tcl]
	} else {
		set dir [file dir $file]
	}
	if [file exists [file join $dir conf init]] {
		puts "file $dir in older format: converting"
		file mkdir [file join $dir conf themes]
		convfiles [file join $dir conf] conf descr [glob [file join $dir conf init *.tcl]]
		set f [open [file join $dir conf conf] w]
		foreach {key value} $conf {
			puts $f [list $key $value]
		}
		close $f
		set f [open [file join $dir conf conf.descr] w]
		foreach {type value} $descr {
			puts $f "[list $type] \{"
			foreach {type value} $value {
				puts $f "\t[list $type] \{"
					foreach {type value} $value {
						puts $f \t\t[list $type $value]
					}
				puts $f "\t\}"
			}
		}
		close $f
		catch {file delete -force [file join $dir conf init]}
	}
	convrec [file join $dir conf]
	file copy -force [file join $::Classy::dir template template.tcl] $file
	catch {file mkdir [file join $dir conf themes]}
	foreach file [file join $dir conf opt *.tcl] {
		catch {file rename $file [file join $dir conf themes [file tail $file]]}
	}
	catch {file delete [file join $dir conf opt]}
	file mkdir [file join $dir lib interface]
	file mkdir [file join $dir lib code]
	convcode [file join $dir lib]
	file delete [file join $dir [file tail $dir]]
	puts "conversion done"
	puts "WARNING: behaviour has changed a lot between these versions, and you might very well need to change some code"
} $file

exit

if 0 {
	set file ccalc
}