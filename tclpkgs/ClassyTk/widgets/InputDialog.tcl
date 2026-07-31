#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::InputDialog
# ----------------------------------------------------------------------
#doc InputDialog title {
#InputDialog
#} index {
# Dialogs
#} shortdescr {
# Dialog with one entry
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a Dialog with an Entry widget.
#}
#doc {InputDialog options} h2 {
#	InputDialog specific options
#}
#doc {InputDialog command} h2 {
#	InputDialog specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::InputDialog

Classy::InputDialog method init {args} {
	super init
	Classy::Entry $object.options.entry -label File
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
Classy::InputDialog addoption	-command [list command Command {}] {}

#doc {InputDialog options -default} option {-default default Default} descr {
#}
Classy::InputDialog chainoption -default {$object.options.entry} -default

#doc {InputDialog options -combo} option {-combo combo Combo} descr {
#}
Classy::InputDialog chainoption -combo {$object.options.entry} -combo

#doc {InputDialog options -combopreset} option {-combopreset comboPreset ComboPreset} descr {
#}
Classy::InputDialog chainoption -combopreset {$object.options.entry} -combopreset

#doc {InputDialog options -buttontext} option {-buttontext buttonText Text} descr {
#}
Classy::InputDialog chainoption -buttontext {$object.actions.go} -text

#doc {InputDialog options -label} option {-label label Label} descr {
#}
Classy::InputDialog chainoption -label {$object.options.entry} -label

#doc {InputDialog options -textvariable} option {-textvariable textVariable variable} descr {
#}
Classy::InputDialog chainoption -textvariable {$object.options.entry} -textvariable

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {InputDialog command get} cmd {
#pathname get 
#} descr {
#}
Classy::InputDialog method get {} {
	return [$object.options.entry get]
}

#doc {InputDialog command set} cmd {
#pathname set value
#} descr {
#}
Classy::InputDialog method set {value} {
	$object.options.entry set $value
}

Classy::InputDialog method _command {} {
	private $object options
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

proc Classy::getpasswd {{previous {}}} {
	set w .classy__.getpasswd
	Classy::InputDialog $w
	set ::Classy::getpasswd $previous
	$w configure -title "Enter password" -label "Password" -textvariable ::Classy::getpasswd -closecommand {set ::Classy::getpasswd {}}
	$w.options.entry configure -show *
	tkwait window $w
	return $::Classy::getpasswd
}
