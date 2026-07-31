#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Balloon
# ----------------------------------------------------------------------
#doc Balloon title {
# Balloon
#} index {
# Common tools
#} shortdescr {
# help pops up when staying over a widget
#} descr {
# subclass of <a href="Class.html">Class</a><br>
# associate help with a widget such as a button. A box with the help text in it
# will popup after staying for some time over the widget without doing anything.
# Balloon is not meant to be instanciated; the command can can rather be used
# directly from the class.
#}

option add *Balloon.BorderWidth 0 widgetDefault
option add *Balloon.HighlightThickness 0 widgetDefault
option add *Balloon.Font {Helvetica 6 normal} widgetDefault
option add *Balloon.text.BorderWidth 0 widgetDefault
option add *Balloon.text.Background #fdffb3 userDefault
option add *Balloon.text.HighlightThickness 0 widgetDefault
option add *Balloon.background black userDefault
option add *Balloon.borderWidth 0 widgetDefault

bind Classy::Balloon <Enter> {Classy::Balloon _schedule %W}
bind Classy::Balloon <Leave> {Classy::Balloon revoke}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::Balloon

if [winfo exists .classy__.balloon] {destroy .classy__.balloon}
toplevel .classy__.balloon -class Balloon -bd 1 -highlightthickness 0
wm withdraw .classy__.balloon
label .classy__.balloon.text -bd 0
pack .classy__.balloon.text -fill x -expand no
wm overrideredirect .classy__.balloon 1

# REM Initialise variables and options
# ------------------------------------
#doc {Balloon time} cmd {
#Balloon private time ms
#} descr {
# set the time (in miliseconds) to wait before the helptext gets displayed
#}
::Classy::Balloon private time 800

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Balloon classmethod destroy {} {
	destroy .classy__.balloon
	bind Classy::Balloon <Enter> {}
	bind Classy::Balloon <Leave> {}
}

#doc {Balloon add} cmd {
#Balloon add widget text
#} descr {
# add $text as help to the given widget
#}
Classy::Balloon classmethod add {widget text {time {}}} {
	private $class help timea
	if {"$text"==""} {
		if [info exists help($widget)] {
			unset help($widget)
			$class _rem_bindings $widget
		}
		unset -nocomplain timea($widget)
	} else {
		set help($widget) $text
		$class _add_bindings $widget
		if {$time ne ""} {set timea($widget) $time} else {unset -nocomplain timea($widget)}
	}
}

Classy::Balloon classmethod _add_bindings {widget} {
	set temp [bindtags $widget]
	if {![inlist $temp Classy::Balloon]} {
		lappend temp Classy::Balloon
		bindtags $widget $temp
	}
}

Classy::Balloon classmethod _rem_bindings {widget} {
	if {[catch {bindtags $widget} temp]} return
	if {[inlist $temp Classy::Balloon]} {
		set temp [list_remove $temp Classy::Balloon]
		bindtags $widget $temp
	}
}

#doc {Balloon display} cmd {
#Balloon display widget
#} descr {
# display the helptext associated with $widget
#}
Classy::Balloon classmethod display {widget} {
	private $class help curwidget
	if {![winfo exists $widget]} return
	if {![info exists help($widget)]} return
	if {![winfo exists .classy__.balloon]} {
		toplevel .classy__.balloon -class Balloon
		wm withdraw .classy__.balloon
		label .classy__.balloon.text
		pack .classy__.balloon.text -fill x -expand no -padx 1 -pady 1
		wm overrideredirect .classy__.balloon 1
	}
	.classy__.balloon.text configure -text $help($widget)
	wm geometry .classy__.balloon +[winfo rootx $widget]+[expr [winfo rooty $widget]+[winfo height $widget]]
	#Classy::update Classy::Balloon-display idletasks
	wm deiconify .classy__.balloon
	raise .classy__.balloon
	set curwidget $widget
}

#doc {Balloon revoke} cmd {
#Balloon revoke 
#} descr {
# remove the currently displayed helptext
#}
Classy::Balloon classmethod revoke {{widget {}}} {
	private $class id curwidget
	if {($widget ne "") && ($widget ne $curwidget)} return
	if {[info exists id]} {
		#Classy::update Classy::Balloon-revoke idletasks
		if {[info exists id]} {
			after cancel $id
			unset id
		}
		catch {wm withdraw .classy__.balloon}
	}
}

Classy::Balloon classmethod _schedule {widget} {
	private $class time id timea
	#Classy::update Classy::Balloon-schedule idletasks
	if {[info exists id]} {
		after cancel $id
	}
	set id [after [get timea($widget) $time] "$class display $widget"]
}
