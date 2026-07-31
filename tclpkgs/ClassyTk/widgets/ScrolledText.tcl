#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ScrolledText
# ----------------------------------------------------------------------
#doc ScrolledText title {
#ScrolledText
#} index {
# Tk improvements
#} shortdescr {
# ClassyTk Text with auto scroll bars
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a Classy::Text with automatic scrollbars.
#}
#doc {ScrolledText command} h2 {
#	ScrolledText specific methods
#}

if {[string equal $tcl_platform(platform) windows]} {
	option add *Classy::ScrolledText.Relief sunken widgetDefault
	option add *Classy::ScrolledText.BorderWidth 1 widgetDefault
	option add *Classy::ScrolledText.text.Relief flat widgetDefault
	option add *Classy::ScrolledText.text.BorderWidth 0 widgetDefault
}
option add *Classy::ScrolledText.highlightThickness 0 widgetDefault

catch {auto_load Classy::Text}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::ScrolledText

Classy::ScrolledText method init {args} {
	# REM Create object
	# -----------------
	super init
	Classy::Text $object.text -wrap none -xscrollcommand [list $object.xscroll set] -yscrollcommand [list $object.yscroll set]
	Classy::AutoScrollbar $object.xscroll -orient horizontal -command  [list $object.text xview]
	Classy::AutoScrollbar $object.yscroll -orient vertical -command  [list $object.text yview]
	bindtags $object [lreplace [bindtags $object] 2 0 Classy::Text]
	Classy::rebind $object.text $object
	grid $object.text -column 0 -row 0 -sticky nwse
	grid $object.yscroll -column 1 -row 0 -sticky nwse
	grid $object.xscroll -column 0 -row 1 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1

	private $object redraw
	set redraw 0
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
#	Classy::todo $object redraw
	$object.text configure -changedcommand [list $object _changed]
#	bind $object.text <Configure> [list Classy::todo $object redraw]
	return $object
}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
#doc {Text options -changedcommand} option {-changedcommand changedcommand Changedcommand} descr {
#}
Classy::ScrolledText addoption -changedcommand {changedcommand Changedcommand {}}

Classy::ScrolledText chainoptions {$object.text}
Classy::ScrolledText chainoption -background {$object} -background {$object.text} -background
Classy::ScrolledText chainoption -highlightbackground {$object} -highlightbackground {$object.text} -highlightbackground
Classy::ScrolledText chainoption -highlightcolor {$object} -highlightcolor {$object.text} -highlightcolor

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ScrolledText chainallmethods {$object.text} Classy::Text

Classy::ScrolledText method redraw {} {
	# left here for backwards compatibility reasons
}

Classy::ScrolledText method _changed {textchanged} {
	private $object options
	set cmd $options(-changedcommand)
	if {[string length $cmd]} {
		uplevel #0 $cmd $textchanged
	}
}
