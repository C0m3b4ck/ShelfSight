#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::FontSelect
# ----------------------------------------------------------------------
#doc FontSelect title {
#FontSelect
#} index {
# Selectors
#} shortdescr {
# to select a font
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a font selection widget
#}
#doc {FontSelect options} h2 {
#	FontSelect specific options
#}
#doc {FontSelect command} h2 {
#	FontSelect specific methods
#}

option add *Classy::FontSelect.relief raised widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::FontSelect

Classy::FontSelect method init {args} {
	# REM Create object
	# -----------------
	super init
	message $object.example -relief flat -justify center -width 1000 -text \
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n1234567890\n~!@#\$%^&*()_+-={}|:\"<>?[]\\;',./`"
	listbox $object.family -yscrollcommand "$object.vbar set" -exportselection no
	bind $object.family <<Action>> [list Classy::todo $object display]
	bind $object.family <<MExecute>> [list Classy::todo $object display]
	bind $object.family <<Invoke>> [list Classy::todo $object display]
	bind $object.family <Enter> [list focus $object.family]
	scrollbar $object.vbar -orient vertical -command [list $object.family yview]
	Classy::Entry $object.font -textvariable [privatevar $object font] -width 5\
		-label "Font" \
		-command "$object set ; Classy::todo $object display" \
		-combo 20
	Classy::NumEntry $object.size -textvariable [privatevar $object size] -width 5 \
		-command "Classy::todo $object display" \
		-min 0 -increment 1 \
		-label "Size" -orient stacked
	Classy::OptionBox $object.weight -label "Weight" -orient stacked -variable [privatevar $object weight]
	$object.weight add normal "Normal" -command "Classy::todo $object display"
	$object.weight add bold "Bold" -command "Classy::todo $object display"
	Classy::OptionBox $object.slant -label "Slant" -orient stacked -variable [privatevar $object slant]
	$object.slant add roman "Roman" -command "Classy::todo $object display"
	$object.slant add italic "Italic" -command "Classy::todo $object display"
	checkbutton $object.underline -text "Underline" -variable [privatevar $object underline] \
		-command "Classy::todo $object display"
	checkbutton $object.overstrike -text "Overstrike" -variable [privatevar $object overstrike] \
		-command "Classy::todo $object display"

	grid $object.font - - -sticky nwse
	grid $object.family $object.vbar $object.size -sticky nwse
	grid x x $object.weight -sticky nwse
	grid x x $object.slant -sticky nwse
	grid x x $object.underline -sticky nwse
	grid x x $object.overstrike -sticky nwse
	grid configure $object.family -rowspan 6
	grid configure $object.vbar -rowspan 6
	grid $object.example - - -sticky nwse

	grid rowconfigure $object 6 -weight 10
	grid columnconfigure $object 0 -weight 10
	grid columnconfigure $object 1 -weight 0
	grid columnconfigure $object 2 -weight 0

	# REM Initialise variables and options
	# ------------------------------------
	set families [lsort -unique [font families]]
	set pos [lsearch -exact $families helvetica]
	if {$pos==-1} {set pos 0}
	eval $object.family insert end $families
	$object.family activate $pos
	$object.family selection set $pos $pos
	$object.family see $pos
	$object.size set 12
	$object.weight set normal
	$object.slant set roman
	$object.underline deselect
	$object.overstrike deselect
	# REM Create bindings
	# -------------------

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object display
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

set ::Classy::families [lsort -unique [font families]]
set ::Classy::pos [lsearch -exact $::Classy::families helvetica]
if {$::Classy::pos==-1} {set ::Classy::pos 0}


#doc {FontSelect options -command} option {-command command Command} descr {
#}
Classy::FontSelect addoption -command {command Command {}}
Classy::FontSelect addoption -font [list font Font "[lindex $::Classy::families $::Classy::pos] 12 {normal roman}"] {
	$object set $value
}
unset ::Classy::families
unset ::Classy::pos
# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {FontSelect command get} cmd {
#pathname get 
#} descr {
#}
Classy::FontSelect method get {} {
	private $object font underline overstrike
	set font ""
	lappend font [$object.family get [$object.family curselection]]
	lappend font [$object.size get]
	lappend font [$object.weight get]
	set slant [$object.slant get]
	if {$slant ne "roman"} {
		lappend font $slant
	}
	if $underline {lappend font underline}
	if $overstrike {lappend font overstrike}
	return $font
}

#doc {FontSelect command set} cmd {
#pathname set ?newfont?
#} descr {
#}
Classy::FontSelect method set {{newfont {}}} {
	private $object options size weight slant overstrike underline font
	if {"$newfont"==""} {
		set newfont $font
	}
	set family [lindex $newfont 0]
	set size [lindex $newfont 1]
	if {"$size" == ""} {
		set size [font actual $newfont -size]
	}
	set qualifiers {}
	foreach list [lrange $newfont 2 end] {
		eval lappend qualifiers $list
	}
	set underline 0
	set overstrike 0
	set weight normal
	set slant roman
	foreach q $qualifiers {
		switch $q {
			underline {
				set underline 1
			}
			overstrike {
				set overstrike 1
			}
			bold {
				set weight bold
			}
			italic {
				set slant italic
			}
		}
	}
	set pos [lsearch -exact [string tolower [$object.family get 0 end]] [string tolower $family]]
	if {$pos == -1} {
		set family [font actual $family -family]
		set pos [lsearch -exact [$object.family get 0 end] $family]
	} else {
		set family [lindex [$object.family get 0 end] $pos]
	}
	$object.family activate $pos
	$object.family selection clear 0 end
	$object.family selection set $pos
	$object.family see $pos
	Classy::todo $object display
	set font [list $family $size $qualifiers]
	set options(-font) $font
	$object get
}

#doc {FontSelect command display} cmd {
#pathname display 
#} descr {
#}
Classy::FontSelect method display {args} {
	private $object options
	if ![winfo exists $object.example] {
		return
		Classy::todo $object display
	}
	set font [$object get]
	set family [lindex $font 0]
	if {"$family"==""} {set family Arial}
	set size [lindex $font 1]
	if {"$size"==""} {
		set size 12
	} else {
		set size [expr int($size+0.5)]
	}
	set style [list_concat [lrange $font 2 end]]
	if {"$style"==""} {set style normal}
	set font [lreplace $font 1 1 [expr {round($size)}]]
	$object.example configure -font $font
	uplevel #0 [get options(-command) ""]
}

