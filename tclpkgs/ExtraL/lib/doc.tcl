# Copyright (c) 1996 Peter De Rijk
#
# See the file "README.txt" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# =============================================================

proc Extral::makedoc {files dstdir {indextitle ""} {order ""}} {
	catch {unset docdata}
	catch {unset sections}
	foreach file $files {
		puts "Reading file \"$file\""
		set f [open $file]
		while 1 {
			if ![info exists earlydoc] {
				set line [gets $f]
			} else {
				unset earlydoc
			}
			if [regexp ^#doc $line] {
				set list [string range $line 5 end]
				while 1 {
					if [info complete $list] break
					set line [gets $f]
					if [regexp ^# $line] {
						if [regexp ^#doc $line] {
							set earlydoc 1
							append list "\n\}"
							break
						}
						append list "\n"
						append list [string range $line 1 end]
					} else {
						append list "\n\}"
						break
					}
				}
				set section [list_shift list]
				set full ""
				foreach level $section {
					list_addnew sections($full) $level
					lappend full $level
				}
				eval {lappend docdata($section)} $list
			}
			if [eof $f] break
		}
		close $f
	}
	set index() ""
	set extra [list_lremove $order $sections()]
	set order [list_lremove $order $extra]
	set rest [list_lremove $sections() $order]
	foreach section [list_concat $order $rest] {
		puts "Writing section \"$section\""
		if ![info exists docdata($section)] {
			set docdata($section) {}
		}
		set list $docdata($section)
		if [catch {set title [map_get $list title]}] {
			set title $section
		}
		if [catch {set descr [map_get $list descr]}] {
			set descr ""
		}
		if [catch {set ind [map_get $list index]}] {
			set ind ""
		}
		if {"$ind" != "none"} {
			regsub -all \n $title {} title
			append index($ind) "\n<li><a href=\"$section.html\">$title</a>"
			if ![catch {set shortdescr [map_get $list shortdescr]}] {
				regsub -all \n $shortdescr {} shortdescr
				append index($ind) ": $shortdescr"
			}
		}
		set f [open [file join $dstdir $section.html] w]
		puts $f "<HEAD>"
		puts $f "<TITLE>$title</TITLE>"
		puts $f "</HEAD>"
		puts $f "<BODY>"
		puts $f "<h1>$title</h1>"
		puts $f $descr
		set prevcmd 0
		if [info exists sections($section)] {
			foreach subsection $sections($section) {
				puts $f [::Extral::outputdoc [list $section $subsection]]
			}
		}
		if $prevcmd {
			append result "</dl>\n"
		}
		puts $f "</body>"
		close $f
	}
	set f [open [file join $dstdir index.html] w]
	puts $f "<HEAD>"
	puts $f "<TITLE>$indextitle</TITLE>"
	puts $f "</HEAD>"
	puts $f "<BODY>"
	puts $f "<h1>$indextitle</h1>"
	puts $f <ul>$index()\n</ul>
	unset index()
	foreach subtitle [lsort [array names index]] {
		puts $f "<h2>$subtitle</h2>"
		puts $f <ul>$index($subtitle)</ul>
	}
	puts $f "</body>"
	close $f
}

proc Extral::outputdoc {section} {
	upvar docdata docdata
	upvar sections sections
	upvar prevcmd prevcmd
	if ![info exists docdata($section)] return
	set list $docdata($section)
	set result ""
	if [catch {set type [map_get $list type]}] {
		set type [lindex $list 0]
	}
	switch -regexp $type {
		^cmd$ {
			if !$prevcmd {
				append result "<dl>"
				set prevcmd 1
			}
			if [catch {set cmd [map_get $list cmd]}] {
				set cmd [lindex $section end]
			}
			append result "<b><dt>$cmd</b>"
			if ![catch {set descr [map_get $list descr]}] {
				append result "<dd>$descr"
			}
			if ![catch {set example [map_get $list example]}] {
				append result "<br>eg.:<pre>$example</pre>"
			}
		}
		^option$ {
			if !$prevcmd {
				append result "<dl>"
				set prevcmd 1
			}
			if [catch {set option [map_get $list option]}] {
				set option [lindex $section end]
			}
			append result "<b><dt>Command-Line Name: [lindex $option 0]</b>"
			append result "<b><dt>Database Name: [lindex $option 1]</b>"
			append result "<b><dt>Database Class: [lindex $option 2]</b>"
			if ![catch {set descr [map_get $list descr]}] {
				append result "<dd>$descr"
			}
			if ![catch {set example [map_get $list example]}] {
				append result "<br>eg.:<pre>$example</pre>"
			}
		}
		{^h[0-9]+} {
			if $prevcmd {
				append result "</dl>"
				set prevcmd 0
			}
			if [catch {set title [map_get $list $type]}] {
				set title [lindex $section end]
			}
			append result "<$type>$title</$type>"
			if ![catch {set descr [map_get $list descr]}] {
				append result $descr
			}
			if [info exists sections($section)] {
				foreach subsection $sections($section) {
					append result [Extral::outputdoc [concat $section $subsection]]
				}
			}
		}
	}
	return $result
}
