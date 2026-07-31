#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Progress
# ----------------------------------------------------------------------
#doc Progress title {
#Progress
#} index {
# New widgets
#} shortdescr {
# show progress of some process
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a widget in which the progress of some action will be displayed.
# The -steps option gives the number of steps needed to progess through for
# completion of the task. The program using the progressbar calls the "next" method
# each time a step of the task is completed.The prograssbar displays the
# percentage of steps done, vs the number of steps to do.
# The progressbar has the concept of subtasks: if the -steps value is a list, e.g. {2 5}
# the taks contains 2 main steps, each of which has 5 substeps. Progress in the subtask
# is given using the next method with the level parameter (here 1).
# The number of subtasks per level can be changed while running using the steps method:
# Using the -steps options will reset the counters. The counters can be reset to 0 at 
# any time using the reset method
# The display will be updated every -refresh miliseconds (if next is called enough)
#}
#doc {Progress options} h2 {
#	Progress specific options
#}
#doc {Progress command} h2 {
#	Progress specific methods
#}

bind Classy::Progress <Configure> {Classy::todo %W redraw}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Progress

Classy::Progress method init {args} {
	private $object w clicks progress
	set w [super init canvas]
	$w configure -width 100 -height 16 -relief sunken
	$w create rectangle 0 0 0 16 -fill green -tags bar
	$w create text 50 8 -text 0% -anchor c -tags percentage
	# REM Initialise variables and options
	# ------------------------------------
	set progress(0) 0

	# REM Configure initial arguments
	# -------------------------------
	$object configure -highlightthickness 0
	if {"$args" != ""} {eval $object configure $args}
	set clicks [clock clicks -milliseconds]
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Progress chainoptions {$object}

# backward compatibility option
#doc {Progress options -ticks} option {-ticks ticks Ticks} descr {
#}
Classy::Progress addoption -ticks {ticks Ticks 100} {
	$object configure -steps $value
}

#doc {Progress options -steps} option {-steps steps Steps} descr {
#}
Classy::Progress addoption -steps {steps Steps 100} {
	private $object options cancel
	if {[info exists cancel]} {
		$object _docancel
		error $cancel
	}
	set options(-ticks) [lindex $value 0]
	set options(-steps) $value
	$object reset
	$object redraw
}

#doc {Progress options -refresh} option {-refresh refresh Refresh} descr {
#}
Classy::Progress addoption -refresh {refresh Refresh 50} {
}

Classy::Progress addoption -cancelcommand {cancelCommand CancelCommand {}} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

# backward compatibility method
Classy::Progress method incr {{value 1}} {
	$object next 0 $value
}

#doc {Progress command set} cmd {
#pathname set value
#} descr {
#}
Classy::Progress method set {args} {
	set level 0
	if {[llength $args] == 1} {
		foreach {value} $args break
	} elseif {[llength $args] == 2} {
		foreach {level value} $args break
	} else {
		error "format is: $object set ?level? value"
	}
	private $object progress
	set progress($level) $value
	$object redraw
	Classy::notodo_update
}

#doc {Progress command get} cmd {
#pathname get 
#} descr {
#}
Classy::Progress method get {{level 0}} {
	private $object progress
	return $progress($level)
}

#doc {Progress command percentconfigure} cmd {
#pathname percentconfigure ?option? ?value? ...
#} descr {
# change the properties of the text displaying the percentage
#}
Classy::Progress method percentconfigure {args} {
	private $object w
	eval $w itemconfigure percentage $args
}

#doc {Progress command barconfigure} cmd {
#pathname barconfigure ?option? ?value? ...
#} descr {
# change the properties of the bar
#}
Classy::Progress method barconfigure {args} {
	private $object w
	eval $w itemconfigure bar $args
}

#doc {Progress command redraw} cmd {
#pathname redraw
#} descr {
# redraw progress bar
#}
Classy::Progress method redraw {} {
	private $object w
	set ratio [$object progress]
	set width [winfo width $object]
	set height [winfo height $object]
	$w coords bar 0 0 [expr {int($ratio*$width)}] $height
	$w coords percentage [expr {$width/2.0}] [expr {$height/2.0}]
	$w itemconfigure percentage -text "[expr int($ratio*100)]%"
}

Classy::Progress method progress {} {
	private $object progress options
	set stepslist [list_reverse $options(-steps)]
	set curlevel [expr {[llength $stepslist] - 1}]
	set ratio 0.0
	foreach steps $stepslist {
		set pos $progress($curlevel)
		if {![isint $pos]} {return 1.0}
		if {[llength $steps] == 1} {
			set steps [lindex $steps 0]
			if {$steps == 0} {
				set ratio 0.0
			} else {
				set ratio [expr {$pos/double($steps) + $ratio/double($steps)}]
			}
		} else {
 			set currentsize [lindex $steps $pos]
			if {[isint $currentsize]} {
				set total [lmath_sum $steps]
				if {$total == 0} {
					set ratio 1.0
				} else {
					set upto [lmath_sum [lrange $steps 0 [expr {$pos-1}]]]
					set ratio [expr {$upto/double($total) + $ratio*$currentsize/double($total)}]
				}
			} else {
				set ratio 1.0
			}
		}
		if {$ratio > 1.0} {set ratio 1.0}
		incr curlevel -1
	}
	return $ratio
}

Classy::Progress method steps {args} {
	private $object options progress
	set level 0
	if {[llength $args] == 1} {
		foreach {value} $args break
	} elseif {[llength $args] == 2} {
		foreach {level value} $args break
	} else {
		error "format is: $object steps ?level? value"
	}
	set len [llength $options(-steps)]
	if {$level >= $len} {
		set options(-steps) [list_concat $options(-steps) [list_fill [expr {$level-$len+1}] 1]]
	}
	for {set l $level} {$l <= $len} {incr l} {
		set progress($l) 0
	}
	lset options(-steps) $level $value
	set options(-ticks) [lindex $options(-steps) 0]
	Classy::todo $object redraw
}

Classy::Progress method reset {} {
	private $object progress options cancel
	unset -nocomplain cancel
	unset -nocomplain progress
	set level 0
	foreach l $options(-steps) {
		set progress($level) 0
		incr level
	}
	$object redraw
	Classy::notodo_update
	Classy::todo $object redraw
}

Classy::Progress method next {{level 0} {number 1}} {
	private $object options progress clicks cancel
	if {[info exists cancel]} {
		$object _docancel
		error $cancel
	}
	set len [llength $options(-steps)]
	for {set l [expr {$level+1}]} {$l < $len} {incr l} {
		set progress($l) 0
	}
	incr progress($level) $number
	set curclicks [clock clicks -milliseconds]
	if {$curclicks < $clicks} return
	$object redraw
	set clicks [expr {$curclicks + $options(-refresh)}]
	$object redraw
	Classy::notodo_update
}

Classy::Progress method checkcancel {} {
	private $object clicks
	if {[clock clicks -milliseconds] < $clicks} return
	$object redraw
	Classy::notodo_update
	if {![winfo exists $object]} {
		$object _docancel
		error "Progress canceled"
	}
	private $object cancel options
	if {[info exists cancel]} {
		$object _docancel
		error $cancel
	}
	set clicks [expr {[clock clicks -milliseconds] + $options(-refresh)}]
}

Classy::Progress method _docancel {} {
	private $object options cancel
	if {$options(-cancelcommand) ne ""} {
		uplevel #0 $options(-cancelcommand)
	}
}

Classy::Progress method cancel {{message "Progress canceled"}} {
	private $object cancel
	set cancel $message
}
