#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::RepeatButton
# ----------------------------------------------------------------------
#doc RepeatButton title {
#RepeatButton
#} index {
# Tk improvements
#} shortdescr {
# holding the button repeatidly executes it command
#} descr {
# creates a widget which behaves like a Tk button, but which repeats the 
# associated command when the user keeps the button pressed.
#}

#bind Classy::RepeatButton <<Action>> {Classy::startrepeat %W; break}
bind Classy::RepeatButton <<Action-ButtonPress>> {Classy::startrepeat %W; break}
#bind Classy::RepeatButton <Any-Leave> {Classy::cancelrepeat %W; break}
bind Classy::RepeatButton <Any-ButtonRelease> {Classy::cancelrepeat %W; break}

proc ::Classy::RepeatButton {object args} {
	eval {button $object} $args
	bindtags $object "Classy::RepeatButton [bindtags $object]"
}

proc ::Classy::startrepeat {w} {
	set ::Classy::repeat($w) on
	$w invoke
	after 200 [list ::Classy::repeat $w]
}

proc ::Classy::cancelrepeat {w} {
	unset -nocomplain ::Classy::repeat($w)
	after cancel [list ::Classy::repeat $w]
}

proc ::Classy::repeat {w} {
	if ![info exists ::Classy::repeat($w)] {return}
	$w invoke
	after 100 [list ::Classy::repeat $w]
}


