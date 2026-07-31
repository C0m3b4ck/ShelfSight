#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::NumInputDialog
# ----------------------------------------------------------------------
#doc NumInputDialog title {
#NumInputDialog
#} index {
# Dialogs
#} shortdescr {
# Dialog with one entry
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a Dialog with an Entry widget.
#}
#doc {NumInputDialog options} h2 {
#	NumInputDialog specific options
#}
#doc {NumInputDialog command} h2 {
#	NumInputDialog specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::NumInputDialog

Classy::NumInputDialog method init {args} {
	super init
	Classy::NumEntry $object.options.entry -label File
	grid $object.options.entry -sticky we
	grid columnconfigure $object.options 0 -weight 10
	$object add go "Go" [list $object _command] default
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	focus $object.options.entry.entry
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------


#doc {FileSelect options -command} option {-command command Command} descr {
#}
Classy::NumInputDialog addoption	-command [list command Command {}] {}

#doc {NumInputDialog options -default} option {-default default Default} descr {
#}
Classy::NumInputDialog chainoption -default {$object.options.entry} -default

#doc {NumInputDialog options -combo} option {-combo combo Combo} descr {
#}
Classy::NumInputDialog chainoption -combo {$object.options.entry} -combo

#doc {NumInputDialog options -combopreset} option {-combopreset comboPreset ComboPreset} descr {
#}
Classy::NumInputDialog chainoption -combopreset {$object.options.entry} -combopreset

#doc {NumInputDialog options -buttontext} option {-buttontext buttonText Text} descr {
#}
Classy::NumInputDialog chainoption -buttontext {$object.actions.go} -text

#doc {NumInputDialog options -label} option {-label label Label} descr {
#}
Classy::NumInputDialog chainoption -label {$object.options.entry} -label

#doc {NumInputDialog options -textvariable} option {-textvariable textVariable variable} descr {
#}
Classy::NumInputDialog chainoption -textvariable {$object.options.entry} -textvariable

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {NumInputDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::NumInputDialog method get {} {
	return [$object.options.entry get]
}

#doc {NumInputDialog command set} cmd {
#pathname set value
#} descr {
#}
Classy::NumInputDialog method set {value} {
	$object.options.entry set $value
}

Classy::NumInputDialog method _command {} {
	private $object options
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}
