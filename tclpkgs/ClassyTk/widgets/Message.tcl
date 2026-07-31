#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Message
# ----------------------------------------------------------------------
#doc Message title {
#Message
#} index {
# Tk improvements
#} shortdescr {
# slightly improved message widget
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# The ClassyTk Message works like the Tk Message, but
# if the text to be displayed is larger than -max,
# the message is shown in a scrolled text. This means it adapts to
# large messages, and changes in display size properly, but it does
# not place small messages centered. By default
# -max is set to 0 (so the scrolled text is always used)
#}
#doc {Message options} h2 {
#	Message specific options
#}
#doc {Message command} h2 {
#	Message specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Message

Classy::Message method init {args} {
	private $object w
	set w [super init]
	$w configure -bd 0 -highlightthickness 0
	Classy::ScrolledText $object.t \
		-width 5 -height 1 -bd 0 -highlightthickness 0 \
		-state disable -wrap word
	frame $object.fx -width 0 -height 0
	frame $object.fy -width 0 -height 0
	grid $object.fy -row 0 -column 0 -rowspan 2
	grid $object.fx -row 0 -column 1
	grid $object.t -row 1 -column 1 -sticky nwse
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 1 -weight 1
	$object.t tag configure default -justify center
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
	return $object
}

Classy::Message method destroy {} {
	private $object options
	set var $options(-textvariable)
	trace vdelete ::$var w [list Classy::todo $object _trace]
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Message chainoptions {$object}

Classy::Message chainoption -fg {$object.t} -fg
Classy::Message chainoption -bg {$object} -bg {$object.t} -bg
Classy::Message chainoption -font {$object.t} -font
Classy::Message chainoption -wrap {$object.t} -wrap
Classy::Message chainoption -justify {$object.t} -justify

Classy::Message addoption -width {width Width {}} {
	private $object options
	set options(-width) $value
	$object checksize
}

Classy::Message addoption -height {height Height {}} {
	private $object options
	set options(-height) $value
	$object checksize
}

Classy::Message addoption -aspect {aspect Aspect 300} {
	private $object options
	set options(-aspect) $value
	$object checksize
}

Classy::Message addoption -text {text Text {}} {
	private $object options
	set options(-text) $value
	$object checksize
	Classy::todo $object redraw
}

Classy::Message addoption -growonly {growonly Growonly 0} {
}

Classy::Message addoption -textvariable {textvariable Text {}} {
	private $object options
	set var $options(-textvariable)
	catch {trace vdelete ::$var w [list Classy::todo $object _trace]}
	set var $value
	if {![info exists ::$var]} {set ::$var $options(-text)}
	trace variable ::$var w [list Classy::todo $object _trace]
	set ::$var [get ::$var ""]
	$object checksize
	Classy::todo $object redraw
}

Classy::Message addoption -justify {justify Justify center} {
	$object.t tag configure default -justify $value
}

Classy::Message addoption -max {max Max 0} {
}



# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Message chainallmethods {$object.t} message

Classy::Message method _trace {args} {
	private $object options
	$object configure -text [get ::$options(-textvariable) ""]
}

Classy::Message method redraw {args} {
	private $object options
	$object.t configure -state normal
	$object.t delete 1.0 end
	$object.t insert end [$object cget -text] default
	$object.t delete [$object.t index end]
	$object.t configure -state disabled
}

Classy::Message method checksize {args} {
	private $object options
	set text $options(-text)
	set aspect $options(-aspect)
	set font [$object.t cget -font]
	set bd [$object.t cget -bd]
	set c .classy__.canvas
	if {![winfo exists $c]} {
		canvas $c
	}
	if {$options(-height) ne ""} {
		set hgiven 1
		set h $options(-height)
	} else {
		set hgiven 0
	}
	if {$options(-width) ne ""} {
		set w $options(-width)
		set wgiven 1
	} else {
		set w 400
		set wgiven 0
	}
	if {[string length $text] > 1000} {set wgiven 1}
	if {!$wgiven || !$hgiven} {
		set temp [expr {$aspect/10}]
		if {$temp < 5} {set temp 5}
		set minaspect [expr {$aspect - $temp}]
		set maxaspect [expr {$aspect + $temp}]
		$c delete all
		set id [$c create text 100 100 -anchor nw -text $text\n -width [expr {$w-2*$bd-6}] -font $font]
		set inc [expr {$w/2}]
		while 1 {
			foreach {x1 y1 x2 y2} [$c bbox $id] break
			set cw [expr {$x2-$x1}]
			set ch [expr {$y2-$y1}]
			if {$wgiven} break
			if {$inc <= 2} break
			if {!$hgiven} {
				set caspect [expr {(100*$cw)/$ch}]
				if {$caspect < $minaspect} {
					incr w $inc
				} elseif {$caspect > $maxaspect} {
					set w [expr {$w - $inc}]
				} else {
					break;
				}
			} else {
				if {$h < $minaspect} {
					set w [expr {$w - $inc}]
				} elseif {$h > $maxaspect} {
					incr w $inc
				} else {
					break;
				}
			}
			$c itemconfigure $id -width $w
			set inc [expr {$inc/2}]
		}
		set h [expr {$ch+2*$bd+6}]
		if {!$hgiven && ($h > 200)} {set h 200}
		if {$options(-growonly)} {
			if {!$hgiven && ($h < [$object.fy cget -height])} {set h [$object.fy cget -height]}
			if {!$wgiven && ($w < [$object.fx cget -width])} {set w [$object.fy cget -width]}
		}
	}
	$object.fx configure -width $w
	$object.fy configure -height $h
	Classy::todo $object _delayed_redraw
}

Classy::Message method _delayed_redraw {} {
	Classy::todo $object.t redraw
}
