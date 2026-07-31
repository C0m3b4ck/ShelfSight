#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Fold
# ----------------------------------------------------------------------
#doc Fold title {
#Fold
#} index {
# New widgets
#} shortdescr {
# foldable frame
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a foldable frame. The actual frame is available as component 
# content.
#}
#doc {Fold options} h2 {
#	Fold specific options
#}
#doc {Fold command} h2 {
#	Fold specific methods
#}

option add *Classy::Fold.relief flat widgetDefault
option add *Classy::Fold.knob.relief flat widgetDefault
option add *Classy::Fold.title.relief flat widgetDefault
option add *Classy::Fold.title.anchor w widgetDefault
option add *Classy::Fold.spacer.width 10 widgetDefault
option add *Classy::Fold.highlightthickness 0 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Fold

Classy::Fold method init {args} {
	# REM Create object
	# -----------------
	super init
	button $object.knob -image [Classy::geticon foldclosed.xbm] -command [list $object open]
	button $object.title -text "" -command {}
	frame $object.spacer
	frame $object.content -highlightthickness 0
	grid $object.knob $object.title - -sticky nwse
	grid columnconfigure $object 2 -weight 1
	grid rowconfigure $object 1 -weight 1
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}
Classy::Fold component content {$object.content}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {Fold options -closecommand} option {-closecommand closeCommand Command} descr {
#}
Classy::Fold addoption -closecommand {closeCommand Command {}}

#doc {Fold options -opencommand} option {-opencommand openCommand Command} descr {
#}
Classy::Fold addoption -opencommand {openCommand Command {}}

#doc {Fold options -title} option {-title title Title} descr {
#}
Classy::Fold addoption -title {title Title {}} {
	$object.title configure -text $value
}

#doc {Fold options -command} option {-command ? ?} descr {
#}
Classy::Fold chainoption -command {$object.title} -command

#doc {Fold options -space} option {-space ? ?} descr {
#}
Classy::Fold chainoption -space {$object.spacer} -width

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {Fold command open} cmd {
#pathname open 
#} descr {
#}
Classy::Fold method open {} {
	private $object options
	$object.knob configure -image [Classy::geticon foldopen.xbm] -command [list $object close]
	grid $object.spacer -column 1 -row 1 -sticky nwse
	grid $object.content -column 2 -row 1 -sticky nwse
	uplevel #0 $options(-opencommand)
}


#doc {Fold command close} cmd {
#pathname close 
#} descr {
#}
Classy::Fold method close {} {
	private $object options
	$object.knob configure -image [Classy::geticon foldclosed.xbm] -command [list $object open]
	grid forget $object.spacer
	grid forget $object.content
	uplevel #0 $options(-closecommand)
}

Classy::Fold method _children {} {
	return $object.content
}

