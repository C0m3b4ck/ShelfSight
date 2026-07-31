#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::MultiFrame
# ----------------------------------------------------------------------
#doc MultiFrame title {
#MultiFrame
#} index {
# New widgets
#} shortdescr {
# placeholder for several frames
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
#}
#doc {MultiFrame command} h2 {
#	MultiFrame specific methods
#}

bind Classy::MultiFrame <Configure> {Classy::todo %W redraw}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::MultiFrame

Classy::MultiFrame method init {args} {
	# REM Create object
	# -----------------
	super init
	grid rowconfigure $object 0 -weight 1
	grid columnconfigure $object 0 -weight 1
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object redraw
	return $object.view.frame
}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------
Classy::MultiFrame method destroy {} {
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {MultiFrame command redraw} cmd {
#pathname redraw 
#} descr {
#}
Classy::MultiFrame method redraw {} {
	if {"[grid slaves $object]" == ""} {
		if {"[winfo children $object]" == ""} return
		grid [lindex [winfo children $object] 0] -row 0 -column 0 -sticky nwse
	}
}

#doc {MultiFrame command command} cmd {
#pathname select command name command
#} descr {
#}
Classy::MultiFrame method command {label command} {
	private $object cmds
	set cmds($label) $command
}

#doc {MultiFrame command select} cmd {
#pathname select label
#} descr {
#}
Classy::MultiFrame method select {label} {
	private $object cmds
	if [info exists cmds($label)] {
		uplevel #0 $cmds($label)
	}	
	catch {grid forget [grid slaves $object]}
	grid $object.$label -row 0 -column 0 -sticky nwse
}

