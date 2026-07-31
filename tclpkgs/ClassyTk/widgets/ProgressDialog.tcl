#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ProgressDialog
# ----------------------------------------------------------------------
#doc ProgressDialog title {
#ProgressDialog
#} index {
# Dialogs
#} shortdescr {
# show progress of some proces in a dialog
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a dialog in which the ProgressDialog of some action will be displayed.
# The ProgressDialog will be displayed as the fraction of ticks passed (
# ticks are passed by invoking the incr method), compared to the number 
# of ticks to go (-ticks options).
#}
#doc {ProgressDialog options} h2 {
#	ProgressDialog specific options
#}
#doc {ProgressDialog command} h2 {
#	ProgressDialog specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass Classy::ProgressDialog

Classy::ProgressDialog method init {args} {
	private $object clicks refresh
	super init -title "Progress" -keepgeometry 0
	Classy::Message $object.options.message -text "Progress" -justify center -width 300 -growonly 1
	Classy::Progress $object.options.progress
	pack $object.options.message -fill x
	pack $object.options.progress -fill x
	# REM Initialise variables and options
	# ------------------------------------
	# REM Configure initial arguments
	# -------------------------------
	$object configure -closecommand [list $object cancel] -width 300
	$object.options.progress configure -cancelcommand [list $object destroy]
	$object persistent add close
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy::ProgressDialog component message {$object.options.message}
Classy::ProgressDialog component progress {$object.options.progress}
# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::ProgressDialog chainoptions {$object.options.progress}

#doc {ProgressDialog options -message} option {-message ? ?} descr {
#}
Classy::ProgressDialog addoption -message {text Text Progress} {
	$object.options.message configure -text $value
	Classy::todo $object resize
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ProgressDialog chainmethods {set get incr percentconfigure barconfigure redraw progress steps clear next checkcancel} {$object.options.progress}

Classy::ProgressDialog method cancel {{message "Progress canceled"}} {
	$object.options.progress cancel $message
}

Classy::ProgressDialog method resize {} {
	$object.options.progress checkcancel
	super resize
}
