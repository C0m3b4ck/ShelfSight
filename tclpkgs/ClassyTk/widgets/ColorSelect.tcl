#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# ColorSelect
# ----------------------------------------------------------------------
#doc ColorSelect title {
#ColorSelect
#} index {
# Selectors
#} shortdescr {
# color select widget: choose your method
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# A colorselector where the user can select a color using
# different methods: sample, HSV, RGB or colorname
#}
#doc {ColorSelect options} h2 {
#	ColorSelect specific options
#} descr {
#}
#doc {ColorSelect command} h2 {
#	ColorSelect specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::ColorSelect

Classy::ColorSelect method init {args} {
	# REM Create object
	# -----------------
	super init
	Classy::ColorEntry $object.entry
	Classy::NoteBook $object.chooser
	Classy::ColorSample $object.sample
	Classy::ColorRGB $object.rgb
	Classy::ColorHSV $object.hsv
	$object.chooser manage Sample $object.sample -sticky nwse
	$object.chooser manage RGB $object.rgb  -sticky nwse
	$object.chooser manage HSV $object.hsv -sticky nwse
	$object.chooser select Sample
	pack $object.entry -fill x -side bottom
	pack $object.chooser -fill both -expand yes -side top
	set w [winfo reqwidth $object]
	::$object.chooser configure -width 150 -height 150
	::$object.chooser propagate off
	# REM Initialise variables
	# ------------------------
	private $object var
	set var {}
	# REM Create bindings
	# -------------------
	$object.entry configure -command [list $object _set entry]
	$object.sample configure -command [list $object _set sample]
	$object.rgb configure -command [list $object _set rgb]
	$object.hsv configure -command [list $object _set hsv]
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::ColorSelect chainoptions {$object}

#doc {ColorSelect options -label} option {-label ? ?} descr {
# text on the label of the colorselector
#}
Classy::ColorSelect chainoption -label {$object.chooser} -label

#doc {ColorSelect options -command} option {-command command Command} descr {
# command to be executed when the color is changed
#}
Classy::ColorSelect addoption -command {command Command {}} {}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ColorSelect command nocmdset} cmd {
#pathname nocmdset value
#} descr {
# set current color to $value, without executing -command
#}
Classy::ColorSelect method nocmdset {value} {
	private $object nocmdset
	set nocmdset 1
	$object.entry nocmdset $value
	$object.rgb nocmdset $value;
	$object.hsv nocmdset $value;
	unset -nocomplain nocmdset
}

#doc {ColorSelect command set} cmd {
#pathname set value
#} descr {
# set current color to $value
#}
Classy::ColorSelect method set {value} {
	private $object options
	$object.entry nocmdset $value
	$object.rgb nocmdset $value
	$object.hsv nocmdset $value
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

Classy::ColorSelect method _set {src value} {
	private $object nocmdset options
	if {"$src" != "hsv"} {$object.hsv nocmdset $value}
	if {"$src" != "entry"} {$object.entry nocmdset $value}
	if {"$src" != "rgb"} {$object.rgb nocmdset $value}
	if ![info exists nocmdset] {
		set command [get options(-command) ""]
		if {"$command" != ""} {
			uplevel #0 $command [list [$object get]]
		}
	}
}

#doc {ColorSelect command get} cmd {
#pathname get 
#} descr {
# set current color
#}
Classy::ColorSelect method get {} {
	return [$object.entry get]
}

#doc {ColorSelect command select} cmd {
#pathname select type
#} descr {
# set the current type of selector
#}
Classy::ColorSelect method select {type} {
	$object.chooser select $type
}

Classy::ColorSelect method _update {from} {
	private $object options
	uplevel #0 [get options(-command) ""]
}

