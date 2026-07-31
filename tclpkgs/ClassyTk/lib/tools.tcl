#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# tools
# ----------------------------------------------------------------------

proc ::Classy::todo {object args} {
	list_unshift args $object
	list_addnew ::Classy::todolist(0) $args
	after idle ::Classy::handletodo
}

proc ::Classy::gettodo {} {
	array get ::Classy::todolist
}

proc ::Classy::settodo {todo} {
	array set ::Classy::todolist $todo
}

proc ::Classy::todoprio {prio object args} {
	list_unshift args $object
	list_addnew ::Classy::todolist($prio) $args
	after idle ::Classy::handletodo
}

proc ::Classy::canceltodo {object args} {
	list_unshift args $object
	upvar ::Classy::todolist todolist
	foreach prio [array names todolist] {
		set todolist($prio) [list_remove $todolist($prio) $args]
	}
}

proc ::Classy::cleartodo {object} {
	upvar ::Classy::todolist todolist
	foreach prio [array names todolist] {
		set temp {}
		foreach todo $todolist($prio) {
			if {[lindex $todo 0] eq $object} {lappend temp $todo}
		}
		if {[llength $temp]} {
			set todolist($prio) [list_lremove $todolist($prio) $temp]
		}
	}
}

proc ::Classy::handletodo {} {
	after cancel ::Classy::handletodo
	upvar ::Classy::todolist todolist
	if {![info exists todolist]} return
	set prios [array names todolist]
	if {![llength $prios]} return
	set prio [lindex [lsort -real $prios] 0]
	set list $todolist($prio)
	unset todolist($prio)
	foreach command $list {
		set object [lindex $command 0]
		if {"[info commands $object]" == ""} continue
#puts handletodo($prio):$command
		if [catch {uplevel #0 $command} result] {
			if {[info exists todolist]} {after idle ::Classy::handletodo}
			bgerror $result
		}
	}
	if {[info exists todolist]} {after idle ::Classy::handletodo}
}

proc ::Classy::notodo_update {args} {
	after cancel ::Classy::handletodo
	eval Classy::update $args notodo
	after idle ::Classy::handletodo
}

proc ::Classy::update {src args} {
#puts "update from $src: $args"
	if {[inlist $args notodo]} {set notodo 1} else {set notodo 0}
	if {$notodo} {
		after cancel ::Classy::handletodo
	}
	if {[inlist $args idletasks]} {
		::update idletasks
	} else {
		::update
	}
	if {$notodo} {
		after idle ::Classy::handletodo
	}
}

# This function creates a conversion table used in the following function
array set ::Classy::keytablepresyms {
	Control- C- Alt- A- Shift- S-
	Control-Alt- CA- Shift-Alt- SA- Control-Shift-Alt- CSA-  Control-Shift- CS-
}
foreach name [array names ::Classy::keytablepresyms] {
	set ::Classy::keytablepresyms(${name}Key-) $::Classy::keytablepresyms($name)
}
set ::Classy::keytablepresyms(Key-) {}
array set ::Classy::keytablesyms {
	bracketleft [ bracketright ] parenleft ( parenright )
	comma , period . equal = less < greater > question ? numbersign #
	plus + minus - asterisk * slash /
	KP_Add + KP_Subtract - KP_Multiply * KP_Divide /
	KP_1 1 KP_2 2 KP_3 3 KP_4 4 KP_5 5 KP_6 6 KP_7 7 KP_8 8 KP_9 9 KP_0 0 
}

proc Classy::shrink_accelerator {syms} {
	set result {}
	foreach sym $syms {
		if [regexp {^<<} $sym] {
			set sym [event info $sym]
		}
		set sym [lindex $sym 0]
		regsub -all {[<>]} $sym {} sym
		if [regexp {^(.*-)([^-]+)$} $sym temp pre sym] {
			set sym [get ::Classy::keytablepresyms($pre) $pre][get ::Classy::keytablesyms($sym) $sym]
		} else {
			set sym [get ::Classy::keytablesyms($sym) $sym]
		}
		lappend result $sym
	}
	return [join [list_remdup $result] " "]
}

proc Classy::check {command} {
	uplevel 1 $command
}

# Classy::parseopt arguments variable list ?remain?
# variable: name of array to set options in
# list: lists posible options in the folowing format <br>
# option {possible values} {default value} ...<br>
# if {possible values} is empty, any value is ok.
# if {possible values} is {0 1}, the option is considered a boolean (and consequently doesn't need 
# an argument).
# remain: remaining options
proc Classy::parseopt {real variable possible {remain {}}} {
	upvar $variable var
	upvar $remain rem
	set rem ""
	unset -nocomplain var
	foreach {option options default} $possible {
		if {"$options" == "0 1"} {
			set pos [lsearch -exact $real $option]
			if {$pos!=-1} {
				list_pop real $pos
				set var($option) 1
			} else {
				set var($option) 0
			}
		} else {
			set pos [lsearch -exact $real $option]
			if {$pos!=-1} {
				list_pop real $pos
				set value [list_pop real $pos]
				if {("$options"!="")&&([lsearch -exact $options $value]==-1)} {
					error "Incorrect value \"$value\" for option $option: must be one of: $options"
				}
				set var($option) $value
			} else {
				set var($option) $default
			}
		}
	}
	if {"$real"!=""} {
		if {"$remain"!=""} {
			set rem $real
		} else {
			set list ""
			foreach {option options default} $possible {lappend list $option} 
			error "Unkown option(s): \"$real\"\nmust be one of: $list"
		}
	}
}

proc ::Classy::window {object} {
	if {"[info commands ::Classy::Tk_$object]"!=""} {
		return ::Classy::Tk_$object
	} else {
		return $object
	}
}

proc ::Classy::object {window} {
	set c $window
	while 1 {
		if {"[info commands ::Classy::Tk_$c]"!=""} {
			return $c
		}
		set c [winfo parent $c]
		if {"$c" == "."} break
	}
	return -code error "\"$window\" is not part of a Widget"
}

proc Classy::cleargrid w {
	catch {eval grid forget [grid slaves $w]}
	while 1 {
		set col [grid size $w]
		set row [list_pop col]
		if {($col == 0)&&($row == 0)} break
		if {$col != 0} {
			grid columnconfigure $w [expr {$col-1}] -weight 0
		}
		if {$row != 0} {
			grid rowconfigure $w [expr {$row-1}] -weight 0
		}
	}
}

proc Classy::griditem {w col row args} {
#putsvars w col row args
	if {"$args" == ""} {
		return [list_common [grid slaves $w -column $col] [grid slaves $w -row $row]]
	} else {
		set result ""
		set endcol [lindex $args 0]
		set endrow [lindex $args 1]
		for {} {$row <= $endrow} {incr row} {
			for {set x $col} {$x <= $endcol} {incr x} {
				set item [list_common [grid slaves $w -column $x] [grid slaves $w -row $row]]
				if {"$item" != ""} {
					lappend result $item
				}
			}
		}
		return $result
	}
}

proc Classy::loadfunction {file function {pattern {}}} {
	if {"$pattern" == ""} {
		set pattern "^\[ \t\]*proc [list $function] "
	}
	set f [open $file]
	set c ""
	while {![eof $f]} {
		set line [gets $f]
		if [regexp $pattern $line] {
			append c $line
			append c "\n"
			while {![eof $f]} {
				set line [gets $f]
				append c $line
				append c "\n"
				if [info complete $c] break
			}
			break
		}
	}
	close $f
	return $c
}

proc Classy::place {w {keepgeometry 1}} {
	wm positionfrom $w program
	wm withdraw $e
	wm group $w .
	wm protocol $object WM_DELETE_WINDOW [list catch [list destroy $w]]
	after idle "Classy::doplace $w $keepgeometry"
}

proc Classy::doplace {w {keepgeometry 1}} {
	set keeppos 0
	set w [winfo reqwidth $w]
	set h [winfo reqheight $w]
	set x [lindex $resize 0]
	set y [lindex $resize 1]
	if {$x>=1} {set rx 1} else {set rx 0}
	if {$y>=1} {set ry 1} else {set ry 0}
	if {$x<=1} {set x $w}
	if {$y<=1} {set y $h}
	wm minsize $w $x $y
	set keepgeometry [getprivate $object options(-keepgeometry)]
	if [true $keepgeometry] {
		set geom [Classy::Default get geometry $object]
		if [regexp {^([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $geom temp xs ys prevx prevy] {
			if {$xs>$w} {set w $xs}
			if {$ys>$h} {set h $ys}
			set temp [expr [winfo pointerx .]-$prevx]
			if {($temp>0)&&($temp<$w)} {
				set temp [expr [winfo pointery .]-$prevy]
				if {($temp>0)&&($temp<$h)} {
					set keeppos 1
					set x $prevx
					set y $prevy
				}
			}
		}
	}
	wm resizable $object $rx $ry

	# position
	if !$keeppos {
		set maxx [expr [winfo vrootwidth $object]-$w]
		set maxy [expr [winfo vrootheight $object]-$h]
		set x [expr [winfo pointerx .]-$w/2]
		set y [expr [winfo pointery .]-$h/2]
		if {$x>$maxx} {set x $maxx}
		if {$y>$maxy} {set y $maxy}
		if {$x<0} {set x 0}
		if {$y<0} {set y 0}
	}
	wm geometry $object +1000000+1000000
	wm deiconify $object
	raise $object
	if [true $keepgeometry] {
		wm geometry $object ${w}x${h}+$x+$y
	} else {
		wm geometry $object +$x+$y
	}
}

# For debugging purposes only

proc ::Classy::msg {text} {
	if [winfo exists .classy__.message] {destroy .classy__.message}
	if {"$text"==""} {return}
	toplevel .classy__.message
	wm positionfrom .classy__.message user
	wm title .classy__.message "Message"
	wm resizable .classy__.message 0 0
	message .classy__.message.message -aspect 250\
		-justify center -text $text
	pack .classy__.message.message
	Classy::update Classy::msg idletasks
	set xpos [expr [winfo pointerx .classy__.message]-[winfo width .classy__.message]/2]
	if {$xpos<0} {set xpos 0}
	set ypos [expr [winfo pointery .classy__.message]-[winfo height .classy__.message]/2]
	if {$ypos<0} {set ypos 0}
	wm geometry .classy__.message +$xpos+$ypos
	Classy::update Classy::msg
}

#proc ::Classy::Message {window args} {
#	eval message $window $args
#	::Tk::bind $window <Configure> [varsubst {window} {
#		$window configure -width [expr [winfo width $window] - 2*[$window cget -bd]]
#	}]
#}

proc ::Classy::overwriteyn {file {append 1}} {
	if [file exists $file] {
		Classy::Dialog .classy__.overwr -title "Dialog box" -closecommand {set ::Classy::temp 0}
		.classy__.overwr add overwr Overwrite "set ::Classy::temp 1 ; [list file delete $file]"
		if {$append==1} {.classy__.overwr add append "Append" {set ::Classy::temp 2}}
		.classy__.overwr.actions.close configure -text "Cancel"
		.classy__.overwr persistent remove -all

		#top part -->message
		#-------------------
		message .classy__.overwr.options.msg -justify center -aspect 250  -text "File \"$file\" exists!"
		pack .classy__.overwr.options.msg -side top -expand yes -padx 3 -pady 3

		bind .classy__.overwr <o> {.classy__.overwr invoke overwr}
		if {$append==1} {bind .classy__.overwr <a> {.classy__.overwr invoke append}}
		bind .classy__.overwr <c> {.classy__.overwr invoke close}
		focus .classy__.overwr
		Classy::update Classy::overwriteyn idletasks
		grab .classy__.overwr
		tkwait window .classy__.overwr
		return $::Classy::temp
	}
	return 1
}

set Classy::bgid 0
proc Classy::bgstart {} {
	incr ::Classy::bgid
	set ::Classy::bg($::Classy::bgid) 1
	return $::Classy::bgid
}

proc Classy::bgcheck {id} {
	Classy::update Classy::bgcheck
	if ![info exists ::Classy::bg($id)] {
		return -code return {}
	}
}

proc Classy::bgstop {id} {
	unset -nocomplain ::Classy::bg($id)
}

proc Classy::orient {value} {
	switch -glob $value {
		v* {return vertical}
		h* {return horizontal}
		s* {return stacked}
		default {return -code error "Unknown orientation \"$value\""}
	}
}

# Class::auto_mkindex ~/dev/ClassyTk/widgets

proc Classy::pclass {class} {
	foreach method [$class info methods] {
		puts "$class $method [$class info method args $method]"
	}
	if ![catch {$class configure} conf] {
	}
}

proc Classy::allchildren w {
    set result $w
    set children [winfo children $w]
    if {"$children" == ""} {
        return $result
    } else {
        foreach child $children {
            eval lappend result [allchildren $child]
        }
        return $result
    }
}

proc Classy::bindmousewheel widget {
	bind $widget <MouseWheel> {
		%W yview scroll [expr {- (%D / 120) * 4}] units
	}
	if {[string equal [tk windowingsystem] "x11"]} {
		# Support for mousewheels on Linux/Unix commonly comes through mapping
		# the wheel to the extended buttons.  If you have a mousewheel, find
		# Linux configuration info at:
		#	http://www.inria.fr/koala/colas/mouse-wheel-scroll/
		bind $widget <4> {
		if {!$tk_strictMotif} {
			%W yview scroll -5 units
		}
		}
		bind $widget <5> {
		if {!$tk_strictMotif} {
			%W yview scroll 5 units
		}
		}
	}
}

proc Classy::geometry_borders {args} {
	global tcl_platform
	if {![llength $args]} {
		global Classy::borders
		if {![info exists Classy::borders]} {
			catch {destroy .classy__.borders}
			toplevel .classy__.borders
			Classy::update Classy::geometry_borders
			set Classy::borders [Classy::geometry_borders .classy__.borders]
			wm withdraw .classy__.borders
			destroy .classy__.borders
		}
		return $Classy::borders
	}
	set w [lindex $args 0]
	set geom [wm geometry $w]
	scan $geom "%dx%d+%d+%d" width height left top
	set contentsTop [winfo rooty $w]
	set contentsLeft [winfo rootx $w]
	if {$tcl_platform(platform) ne "windows"} {
		if {$left < 0} {
			set left [expr {[winfo vrootwidth $w]+$left-$width}]
		}
		if {$top < 0} {
			set top [expr {[winfo vrootheight $w]+$top-$height}]
		}
	}
	set bx [expr {$contentsLeft - $left}]
	set by [expr {$contentsTop - $top}]
	return [list $bx $by]
}

proc Classy::delproc {procname} {
	if {[info commands $procname] ne ""} {
		rename $procname {}
	}
}

proc Classy::filefilter {filter} {
	set dir [file dir $filter]
	if {[file readable $dir]} {return $filter}
	while {![file readable $dir]} {
		set dir [file dir $dir]
		if {[llength [file split $dir]] <= 1} break
	}
	return $dir/[file tail $filter]
}

proc Classy::nop args {}
