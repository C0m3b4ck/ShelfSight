#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Paned
# ----------------------------------------------------------------------
#doc Paned title {
#Paned
#} index {
# New widgets
#} shortdescr {
# control the size of another widget
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a paned widget, which can be used to control the size
# of other widgets in a grid
#}
#doc {Paned options} h2 {
#	Paned specific options
#}

option add *Classy::Paned.hcursor sb_h_double_arrow widgetDefault
option add *Classy::Paned.vcursor sb_v_double_arrow widgetDefault
if {[string equal $tcl_platform(platform) windows]} {
	option add *Classy::Paned.width 2 widgetDefault
	option add *Classy::Paned.height 2 widgetDefault
	option add *Classy::Paned.Relief sunken widgetDefault
} else {
	option add *Classy::Paned.width 3 widgetDefault
	option add *Classy::Paned.height 3 widgetDefault
	option add *Classy::Paned.Relief raised widgetDefault
}
option add *Classy::Paned.BorderWidth 1 widgetDefault
option add *Classy::Paned.highlightThickness 0 widgetDefault

bind Classy::Paned <<Action>> {%W _start %X %Y}
bind Classy::Paned <<Action-Motion>> {%W _drag %X %Y}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Paned

Classy::Paned method init {args} {
	# REM Create object
	# -----------------
	super init

	private $object data
	set data(parent) [winfo parent $object]
	bindtags $data(parent) [concat Classy::Paned::$object [bindtags $data(parent)]]
	bind Classy::Paned::$object <Configure> [list $object snap]
	set data(snap) 0
	set data(gain) 0
	# REM Configure initial arguments
	# -------------------------------
	$object configure -cursor [option get $object hcursor HCursor]
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy::Paned method destroy {} {
	private $object data
	bindtags $data(parent) [list_remove [bindtags $data(parent)] Classy::Paned::$object]	
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {Paned options -orient} option {-orient orient Orient} descr {
#}
Classy::Paned addoption -orient {orient Orient horizontal} {
	if {"$value" == "vertical"} {
		$object configure -cursor [option get $object vcursor VCursor]
	} else {
		$object configure -cursor [option get $object hcursor HCursor]
	}
}

#doc {Paned options -window} option {-window window Window} descr {
#}
Classy::Paned addoption -window {window Window {}}

#doc {Paned options -command} option {-command command Command} descr {
#}
Classy::Paned addoption -command {command Command {}}

#doc {Paned options -minsize} option {-minsize minsize MinSize} descr {
#}
Classy::Paned addoption -minsize {minsize MinSize {}} 

#doc {Paned options -maxsize} option {-maxsize maxsize MaxSize} descr {
#}
Classy::Paned addoption -maxsize {maxsize MaxSize {}}

#doc {Paned options -gainfrom} option {-gainfrom gainFrom GainFrom} descr {
#}
Classy::Paned addoption -gainfrom {gainFrom GainFrom {}}

#doc {Paned options -snaptoborder} option {-snaptoborder snapToBorder snapToBorder} descr {
#}
Classy::Paned addoption -snaptoborder {snapToBorder snapToBorder 0} 

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Paned method size {{value {}}} {
	private $object data options
	set window $options(-window)
	if ![string length $window] return
	array set info [grid info $window]
	if [catch {set data(master) $info(-in)}] {return 0}
	if {"$options(-orient)"=="horizontal"} {
		set data(gridpos) $info(-column)
		if [string length $value] {
			set size [$object max $value]
			if ![string length $options(-minsize)] {
				set minsize [winfo reqwidth $options(-window)]
			} else {
				set minsize $options(-minsize)
			}
			if {$size < $minsize} {
				set size $minsize
			}
			set prevsize [grid columnconfigure $data(master) $data(gridpos) -minsize]
			if $data(gain) {
				set prevgainsize [winfo width $options(-gainfrom)]
				set gainx [winfo x $options(-gainfrom)]
				set ow [winfo width $object]
				set mw [winfo width $data(master)]
			}
			grid columnconfigure $data(master) $data(gridpos) -minsize $size
			if $data(gain) {
				set gainsize [expr {$prevgainsize - ($size - $prevsize)}]
				set gainmax [expr {$mw - $gainx + $prevsize - $size - $ow}]
				if {$gainsize >= $gainmax} {set gainsize $gainmax}
				if {$gainsize < 0} {set gainsize 0}
				grid columnconfigure $data(master) $data(gainpos) -minsize $gainsize
			}
			Classy::update Classy::Paned-size idletasks
			$object _command
			return $size
		} else {
			return [grid columnconfigure $data(master) $data(gridpos) -minsize]
		}
	} else {
		set data(gridpos) $info(-row)
		if [string length $value] {
			set size [$object max $value]
			if ![string length $options(-minsize)] {
				set minsize [winfo reqheight $options(-window)]
			} else {
				set minsize $options(-minsize)
			}
			if {$size < $minsize} {
				set size $minsize
			}
			set prevsize [grid rowconfigure $data(master) $data(gridpos) -minsize]
			if $data(gain) {
				set prevgainsize [winfo height $options(-gainfrom)]
				set gainy [winfo y $options(-gainfrom)]
				set oh [winfo height $object]
				set mh [winfo height $data(master)]
			}
			grid rowconfigure $data(master) $data(gridpos) -minsize $size
			if $data(gain) {
				set gainsize [expr {$prevgainsize - ($size - $prevsize)}]
				set gainmax [expr {$mh - $gainy + $prevsize - $size - $oh}]
				if {$gainsize >= $gainmax} {set gainsize $gainmax}
				if {$gainsize < 0} {set gainsize 0}
				grid rowconfigure $data(master) $data(gainpos) -minsize $gainsize
			}
			Classy::update Classy::Paned-size2 idletasks
			$object _command
			return $size
		} else {
			return [grid rowconfigure $data(master) $data(gridpos) -minsize]
		}
	}
}

Classy::Paned method _command {} {
	private $object options
	set command [get options(-command) ""]
	if {"$command"!=""} {eval $command}
}

Classy::Paned method max {{value {}}} {
	private $object data options
	set w $options(-window)
	if ![string length $w] return
	set parent [winfo parent $w]
	if {"$options(-orient)"=="horizontal"} {
		set x [winfo x $w]
		set pw [winfo width $parent]
		set max [expr {$pw-$x-[winfo width $object]}]
	} else {
		set y [winfo y $w]
		set ph [winfo height $parent]
		set max [expr {$ph-$y-[winfo height $object]}]
	}
	if {[string length $options(-maxsize)]&&($max > $options(-maxsize))} {
		set max $options(-maxsize)
	}
	if [string length $value] {
		if {$value < $max} {
			set data(snap) 0
			return $value
		} else {
			set data(snap) 1
			return $max
		}
	} else {
		return $max
	}
}

Classy::Paned method _start {x y} {
	private $object data options
	set window $options(-window)
	if ![string length $window] return
	set orient $options(-orient)
	if {"[winfo manager $window]"!="grid"} {error  "$window not managed by grid"}
	set temp [grid info $object]
	array set info [grid info $window]
	set data(master) $info(-in)
	set data(gain) 0
	if {"$orient"=="horizontal"} {
		set data(gridpos) $info(-column)
		if {[map_get $temp -column] < $info(-column)} {
			set data(rev) 1
		} else {
			set data(rev) 0
		}
		set data(pos) $x
		set data(startsize) [winfo width $window]
		set data(x) [winfo x $window]
		set data(size) [winfo width $window]
		set data(mastersize) [winfo width $data(master)]
		grid columnconfigure $data(master) $data(gridpos) -minsize $data(startsize)
		if [string length $options(-gainfrom)] {
			if {"[winfo manager $options(-gainfrom)]"!="grid"} {error  "$window not managed by grid"}
			set data(gainpos) [map_get [grid info $options(-gainfrom)] -column]
			if {[grid columnconfigure $data(master) $data(gainpos) -weight] == 0} {
				set data(gain) 1
			} else {
				set data(gain) 0
			}
		}
	} else {
		set data(gridpos) $info(-row)
		if {[map_get $temp -row] < $info(-row)} {
			set data(rev) 1
		} else {
			set data(rev) 0
		}
		set data(pos) $y
		set data(startsize) [winfo height $window]
		set data(y) [winfo y $window]
		set data(size) [winfo height $window]
		set data(mastersize) [winfo height $data(master)]
		grid rowconfigure $data(master) $data(gridpos) -minsize $data(startsize)
		if [string length $options(-gainfrom)] {
			if {"[winfo manager $options(-gainfrom)]"!="grid"} {error  "$window not managed by grid"}
			set data(gainpos) [map_get [grid info $options(-gainfrom)] -row]
			if {[grid rowconfigure $data(master) $data(gainpos) -weight] == 0} {
				set data(gain) 1
			} else {
				set data(gain) 0
			}
		}
	}
}

Classy::Paned method _drag {x y} {
	private $object data options
	if {![info exists data(rev)]} return
	if {"$options(-orient)"=="horizontal"} {
		if {!$data(rev)} {
			set size [expr $data(startsize)+$x-$data(pos)]
			set max [expr {$data(mastersize) - $data(x) - [winfo width $object]}]
		} else {
			set size [expr $data(startsize)-$x+$data(pos)]
			set max $data(mastersize)
		}
		Classy::todo $object size $size
	} else {
		if {!$data(rev)} {
			set size [expr $data(startsize)+$y-$data(pos)]
			set max [expr {$data(mastersize) - $data(y) - [winfo height $object]}]
		} else {
			set size [expr $data(startsize)-$y+$data(pos)]
			set max $data(mastersize)
		}
		Classy::todo $object size $size
	}
}

Classy::Paned method snap {} {
	private $object data options
	set size [$object size]
	set data(size) $size
	set max [$object max]
	if {$size > $max} {
		set newsize $max
		if $options(-snaptoborder) {
			set data(snap) 1
		}
	}
	if $options(-snaptoborder) {
		if $data(snap) {
			set newsize [$object max]
		}
	}
	if [info exists newsize] {
		Classy::todo $object size $newsize
	}
}
