#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::AutoScrollbar
# ----------------------------------------------------------------------
#doc AutoScrollbar title {
#AutoScrollbar
#} index {
# Tk improvements
#} shortdescr {
# <a gref="Entry.html">Classy::Entry</a> limited to numbers, and with up and down buttons
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# Classy::AutoScrollbar creates a scrollbar that is practically identical to 
# the default Tk scrollbar, but will automaticall display and undisplay when needed.
# This works only when mapped using the grid or pack geometry manager
#}
#doc {AutoScrollbar options} h2 {
#	AutoScrollbar specific options
#}
#doc {AutoScrollbar command} h2 {
#	AutoScrollbar specific methods
#}

bind Classy::AutoScrollbar <Map> {%W _map}

Widget subclass Classy::AutoScrollbar

Classy::AutoScrollbar method init {args} {
	private $object w time
	set w [super init scrollbar]

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
	set time 0
}

Classy::AutoScrollbar addoption -state {state State auto} {
	private $object state
	if {![inlist {auto shown hidden} $value]} {
		error "unknown state $value, must be one of: auto, shown, hidden"
	}
	if {$value eq "shown"} {
		$object _show
	} elseif {$value eq "hidden"} {
		$object _hide
	}
}

Classy::AutoScrollbar chainoptions {$object}
Classy::AutoScrollbar chainallmethods {$object} scrollbar

Classy::AutoScrollbar method set {args} {
	private $object geomdata w time options changecount prevargs
	if {$args eq [get prevargs ""]} return
	set prevargs $args
	if {![info exists changecount]} {set changecount 0}
	if {[get options(-state) ""] eq "auto"} {
		set state [expr {[winfo manager $object] ne ""}]
		foreach {min max} $args {}
		if {($min <= 0)&&($max >= 1)} {
			set newstate 0
		} else {
			set newstate 1
		}
		if {$state != $newstate} {
			set newtime [clock seconds]
			set diff [expr {$newtime-$time}]
			if {$newstate == 0} {
				if {$diff < 1} {
					incr changecount
					# check whether we are changing state to fast, which indicates that we
					# are probably in a refresh loop, if so, stop the loop by keeping
					# the scrollbar mapped
					if {$changecount > 5} {
						puts "stopped AutoScrollbar loop"
						set newstate 1
					}
				} else {
					set changecount 0
				}
			}
			if {$newstate && [info exists geomdata]} {
				$object _show
			} elseif {!$newstate} {
				$object _hide
			}
			set time $newtime
		}
	}
	return [eval $w set $args]
}

Classy::AutoScrollbar method redraw {args} {
	set cmd [$object cget -command]
	eval $object set [eval $cmd]
}

Classy::AutoScrollbar method _show {} {
	private $object geomdata
	if {![info exists geomdata]} {return}
	eval [join $geomdata \;]
	unset geomdata
}

Classy::AutoScrollbar method _hide {} {
	private $object geomdata
	switch -exact -- [winfo manager $object] {
		grid {
			lappend geomdata "[list grid $object] [grid info $object]"
			grid forget $object
		}
		pack {
			foreach x [pack slaves [winfo parent $object]] {
			    lappend geomdata "[list pack $x] [pack info $x]"
			}
			pack forget $object
		}
		{} {}
		default {
			error "Classy::AutoScrollbar $object only supports grid and pack geometry managers"
		}
	}
}

Classy::AutoScrollbar method _map {} {
	set w [winfo toplevel $object]
	wm geometry $w [wm geometry $w]
}

