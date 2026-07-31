#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ColorEntry
# ----------------------------------------------------------------------
#doc ColorEntry title {
#ColorEntry
#} index {
# Selectors
#} shortdescr {
# entry which shows color
#} descr {
# subclass of <a href="Entry.html">Entry</a><br>
# has the same options and methods as <a href="Entry.html">Entry</a>,
# but has a display to show the color in the entry when the Enter key
# is pressed.
#}

option add *Classy::ColorEntry.highlightThickness 0 widgetDefault
option add *Classy::ColorEntry*Frame.highlightThickness 0 widgetDefault
option add *Classy::ColorEntry*Frame.borderWidth 0 widgetDefault
option add *Classy::ColorEntry.entry.relief sunken widgetDefault
option add *Classy::ColorEntry.label.anchor w widgetDefault
option add *Classy::ColorEntry.entry.width 5 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Entry subclass Classy::ColorEntry

Classy::ColorEntry method init {args} {
	super init -combo 10 -combopreset [list $object colors]
	bindtags $object [lreplace [bindtags $object] 2 0 Classy::Entry]
	bindtags $object.entry [lreplace [bindtags $object.entry] 3 0 Classy::Entry]
	frame $object.sample -relief raised -width 25 -borderwidth 2
	pack $object.sample -side left -expand yes -fill both
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ColorEntry method nocmdset {val} {
	$object.entry delete 0 end
	$object.entry insert 0 $val
	$object.sample configure -background $val
}

Classy::ColorEntry method set {val} {
	$object.entry delete 0 end
	$object.entry insert 0 $val
	$object.sample configure -background $val
	$object command
}

Classy::ColorEntry method command {} {
	private $object options
	$object.sample configure -background [$object get]
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object.entry get]]
		return 1
	} else {
		return 0
	}
}	

Classy::ColorEntry method colors {args} {
	set list [Classy::optionget $object colorList ColorList]
	regsub -all \n $list { } list
	return [eval list_concat $list]
}
