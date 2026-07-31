#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ProgressWidget
# ----------------------------------------------------------------------
#doc ProgressWidget title {
#ProgressWidget
#} index {
# Dialogs
#} shortdescr {
# show progress of some proces in a dialog
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# creates a widget in which the ProgressWidget of some action will be displayed.
# When not active, the widget just shows a message label. When active, it also shows
# a progress bar and a cancel button.
# The ProgressWidget will be displayed as the fraction of ticks passed (
# ticks are passed by invoking the incr method), compared to the number 
# of ticks to go (-ticks options).
#}
#doc {ProgressWidget options} h2 {
#	ProgressWidget specific options
#}
#doc {ProgressWidget command} h2 {
#	ProgressWidget specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::ProgressWidget

Classy::ProgressWidget method init {args} {
	private $object clicks refresh
	super init
	label $object.title
	button $object.cancel -text Cancel -command [list $object cancel] -cursor arrow
	Classy::Progress $object.progress -width 200
	label $object.message -text "" -justify left -anchor w
	pack $object.message -side left -fill x
	# REM Initialise variables and options
	# ------------------------------------
	# REM Configure initial arguments
	# -------------------------------
	$object configure -highlightthickness 0
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy::ProgressWidget component message {$object.message}
Classy::ProgressWidget component progress {$object.progress}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

foreach ::Classy::option {
	-refresh -steps -ticks -closeenough -confine -cursor -height
} {
	Classy::ProgressWidget chainoption $::Classy::option {$object.progress} $::Classy::option
}

foreach ::Classy::option {
	width background bd bg borderwidth highlightbackground highlightcolor highlightthickness
} {
	Classy::ProgressWidget chainoption -progress_$::Classy::option {$object.progress} -$::Classy::option
}

Classy::ProgressWidget chainoption -title {$object.title} -text

#doc {ProgressWidget options -message} option {-message ? ?} descr {
#}
Classy::ProgressWidget chainoption -message {$object.message} -text

#doc {ProgressWidget options -title} option {-title ? ?} descr {
#}
Classy::ProgressWidget chainoption -title {$object.title} -text

Classy::ProgressWidget addoption -cancelcommand {cancelCommand cancelCommand {}} {
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ProgressWidget chainmethods {set get incr percentconfigure barconfigure redraw progress steps clear next checkcancel} {$object.progress}

Classy::ProgressWidget method stop {args} {
	pack forget $object.progress
	$object.progress reset
	pack forget $object.cancel
	set title [$object.title cget -text]
	if {[llength $args]} {set message [lindex $args 0]} else {set message "$title finished"}
	pack forget $object.title
	$object.message configure -text $message
}

Classy::ProgressWidget method start {{title Progress} {message {}} args} {
	$object.progress reset
	$object.title configure -text $title
	$object.message configure -text $message
	if {[llength $args]} {
		$object steps 0 [lindex $args 0]
	}
	pack forget $object.title
	pack forget $object.message
	pack $object.title -side left
	pack $object.cancel -side left
	pack $object.progress -side left
	pack $object.message -side left -fill x
}

Classy::ProgressWidget method cancel {args} {
	private $object options
	set title [$object.title cget -text]
	if {[llength $args]} {set message [lindex $args 0]} else {set message "$title canceled"}
	$object stop $message
	$object.progress cancel
	if {$options(-cancelcommand) ne ""} {
		eval $options(-cancelcommand)
	}
}

Classy::ProgressWidget method active {} {
	expr {![catch {pack info $object.progress}]}
}
