#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ColorSample
# ----------------------------------------------------------------------
#doc ColorSample title {
#ColorSample
#} index {
# Selectors
#} shortdescr {
# Select a color from a number of sample colors
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# select color from a number of sample colors
#}
#doc {ColorSample options} h2 {
#	ColorSample specific options
#} descr {
#}
#doc {ColorSample command} h2 {
#	ColorSample specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::ColorSample

Classy::ColorSample method init {args} {
	# REM Create object
	# -----------------
	super init
	set Classycolors [Classy::optionget $object colorList ColorList]
	set row 0
	set len 0
	foreach rowcolors $Classycolors {
		set col 0
		foreach color $rowcolors {
			label $object.cell$row,$col -anchor c -relief raised \
				-bg $color -width 5 -height 5
			bind $object.cell$row,$col <<Action>> "$object set $color"
			grid $object.cell$row,$col -row $row -column $col -sticky nwse
			incr col
		}
		if {$col>$len} {set len $col}
		grid rowconfigure $object $row -weight 1
		incr row
	}
	if [info exists color] {unset color}
	for {set col 0} {$col<$len} {incr col} {
		grid columnconfigure $object $col -weight 1
	}
	# REM Initialise variables and options
	# ------------------------------------
	private $object color
	set color white
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {ColorSample options -command} option {-command command Command} descr {
# command to be executed when the color is changed
#}
Classy::ColorSample addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {ColorSample command set} cmd {
#pathname set value
#} descr {
# set current color to $value
#}
Classy::ColorSample method set {value} {
	private $object color options
	set color $value
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

#doc {ColorSample command get} cmd {
#pathname get 
#} descr {
# get current color
#}
Classy::ColorSample method get {} {
	private $object color
	return $color
}


