#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Entry
# ----------------------------------------------------------------------
#doc Entry title {
#Entry
#} index {
# Tk improvements
#} shortdescr {
#entry with label, constraints, command, defaultmenu
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# The ClassyTk entry has all the options and commands of the Tk entry, but
# with a few extras
#<ul>
#<li>optional label
#<li>invoke command upon pressing Enter
#<li>constraints
#<li>validate command (executed upon each change)
#<li>a <a href="DefaultMenu.html">DefaultMenu</a> can be added to
# store and reselecte values easily. These default values are stored
# by the <a href="Default.html">Default</a> system as type app.
#</ul>
#}
#doc {Entry options} h2 {
#	Entry specific options
#}
#doc {Entry command} h2 {
#	Entry specific methods
#}

option add *Classy::Entry.highlightThickness 0 widgetDefault
option add *Classy::Entry*Frame.highlightThickness 0 widgetDefault
option add *Classy::Entry*Frame.borderWidth 0 widgetDefault
option add *Classy::Entry.label.anchor w widgetDefault
option add *Classy::Entry.label.highlightThickness 0 widgetDefault
option add *Classy::Entry.label.borderWidth 0 widgetDefault
option add *Classy::Entry.frame.entry.highlightThickness 0 widgetDefault
option add *Classy::Entry.frame.entry.borderWidth 1 widgetDefault
option add *Classy::Entry.frame.entry.relief sunken widgetDefault
option add *Classy::Entry.entry.width 5 widgetDefault
option add *Classy::Entry.entry.relief flat widgetDefault
option add *Classy::Entry.entry.borderWidth 0 widgetDefault
option add *Classy::Entry.entry.highlightThickness 1 widgetDefault
option add *Classy::Entry.defaults.combo.borderWidth 1 widgetDefault
option add *Classy::Entry.defaults.combo.relief raised widgetDefault
option add *Classy::Entry.defaults.combo.list.relief sunken widgetDefault
option add *Classy::Entry.defaults.combo.list.borderWidth 1 widgetDefault

bind Classy::Entry <Key-Return> {
	if [[Classy::mainw %W] command] break
}

bind Classy::Entry <Key-Down> {
	[Classy::mainw %W] combo_draw
}

bind Classy::Entry <<Empty>> {
	[Classy::mainw %W] nocmdset ""
}
bind Classy::Entry <<Default>> {
	if [winfo exists [Classy::mainw %W].defaults] {[Classy::mainw %W].defaults menu}
}
bind Classy::Entry <<Drop>> {
	[Classy::mainw %W] insert insert [Classy::DragDrop get]
}
bind Classy::Entry <<Drag-Motion>> {
	tk::EntryButton1 [Classy::mainw %W] %x
}
bind Classy::Entry <<MXPaste>> {[Classy::mainw %W] paste;break}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Entry
Classy::Entry method init {args} {
	private $object w
	# REM Create object
	# -----------------
	set w [super init]
	frame $object.frame -takefocus 0
	frame $object.frame.entry -takefocus 0
	pack $object.frame -expand yes -fill x -side left
	pack $object.frame.entry -expand yes -fill x -side left
	entry $object.entry
	Classy::rebind $object.entry $object
	pack $object.entry -in $object.frame.entry -side left -expand yes -fill x
	# REM Create bindings
	# -------------------
	# REM Initialise variables
	# ------------------------
	setprivate $object previous {}
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todo $object _redrawentry
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::Entry chainoptions {$object.entry}
Classy::Entry chainoption -background {$object} -background {$object.entry} -background
Classy::Entry chainoption -highlightbackground {$object} -highlightbackground {$object.entry} -highlightbackground
Classy::Entry chainoption -highlightcolor {$object} -highlightcolor {$object.entry} -highlightcolor
Classy::Entry chainoption -borderwidth {$object.frame.entry} -borderwidth
Classy::Entry chainoption -relief {$object.frame.entry} -relief

#doc {Entry options -state} option {-state state State} descr {
# Specifies  one of three states for the entry:  normal,
# disabled or combo.  If the entry  is  disabled  then  the
# value  may not be changed using widget commands and
# no insertion cursor will be displayed, even if  the
# input focus is in the widget. The combo state allows
# changes using the combo list, but not by editing.
#}
Classy::Entry addoption -state {state State normal} {
	private $object options
	if ![inlist {normal disabled combo} $value] {
		return -code error "bad state value \"$value\": must be normal, disabled or combo"
	}
	switch $value {
		combo {
			if {[string_equal $options(-combo) ""]&&[string_equal $options(-combopreset) ""]} {
				return -code error "state \"combo\" not allowed on entry without -combo or -combopreset option"
			}
			$object.entry configure -state disabled
			if [winfo exists $object.defaults] {$object.defaults configure -state normal}
		}
		default {
			$object.entry configure -state $value
			if [winfo exists $object.defaults] {$object.defaults configure -state $value}
			if [string_equal $value disabled] {
				if [winfo exists $object.label] {$object.label configure -fg [Classy::realcolor disabledForeground]}
			} else {
				if [winfo exists $object.label] {$object.label configure -fg [Classy::realcolor Foreground]}
			}
		}
	}
}

#doc {Entry options -orient} option {-orient orient Orient} descr {
# determines the position of the label relative to the entry: horizontal or vertical
#}
Classy::Entry addoption -orient {orient Orient horizontal} {
	set value [Classy::orient $value]
	Classy::todo $object _redrawentry
}

#doc {Entry options -combosize} option {-combosize comboSize ComboSize} descr {
# max size of list to choose from (if larger use scrollbar)
#}
Classy::Entry addoption -combosize {comboSize ComboSize 10} {
}

#doc {Entry options -combopreset} option {-combopreset comboPreset ComboPreset} descr {
# if set, the value will be executed as a command, and the result will give a number of values
# that will be added to the combo list if they are not present already.
#}
Classy::Entry addoption -combopreset {comboPreset ComboPreset {}} {
}

#doc {Entry options -combo} option {-combo combo Combo} descr {
# make entry into a combo box, The value of -combo can be a number, in which case it gives
# the number of previous values in the entry are kept as choice, or a Tcl command. If
# the value is not a number, it will be used as a Tcl command that will be executed
# upon invocation of the combo button. The resulting list will be offered as choice in
# the combo list.
#}
Classy::Entry addoption -combo {combo Combo {}} {
	private $object options
	if ![string_equal $options(-default) ""] {
		return -code error "-combo and default options cannot be combined"
	}
	set w $object.defaults
	if {("$value"=="")&&([winfo exists $w])} {
		destroy $w
		return $value
	} elseif ![winfo exists $w] {
		button $w -image [Classy::geticon combo]
		pack $object.defaults -in $object.frame.entry -side right -fill both
	}
	$w configure -command [list $object combo_draw]
	set w $object.defaults.combo
	if ![winfo exists $w] {
		toplevel $w
		listbox $w.list \
			-selectmode browse \
			-background [$object cget -bg] \
			-yscrollcommand [list $w.vsb set] \
			-exportselection false \
			-borderwidth 0 \
			-width 1
		scrollbar $w.vsb \
			-highlightthickness 0 \
			-command [list $w.list yview]
		pack $w.list -side left -fill both -expand yes
		pack $w.vsb -side left -fill y
		wm overrideredirect $w 1
		wm transient $w [winfo toplevel $object]
		wm group $w [winfo parent $object]
		wm resizable $w 0 0
		wm withdraw $w
#		bind $w.list <FocusOut> [list $object _combo_remove]
		bind $w.list <Leave> [list $object _combo_remove]
		bind $w.list <<Escape>> [list $object _combo_remove]
	}
}

#doc {Entry options -default} option {-default default Default} descr {
# If not empty, a <a href="DefaultMenu.html">DefaultMenu</a> will be 
# added to store and reselecte values of the entry easily. These 
# default values are stored by the <a href="Defaults.html">Defaults</a> system 
# as type app. The default option gives the key for getting and 
# setting values.
#}
Classy::Entry addoption -default {default Default {}} {
	private $object options
	set w $object.defaults
	if [string_equal $value ""] {
		if [winfo exists $w] {
			destroy $w
		}
		return $value
	}
	if ![string_equal $options(-combo) ""] {
		return -code error "-combo and default options cannot be combined"
	}
	if ![winfo exists $w] {
		Classy::DefaultMenu $w -key $value \
			-command "$object set" \
			-getcommand "$object get"
		pack $object.defaults -in $object.frame.entry -side right
	} else {
		$w configure -key $value
	}
	return $value
}

#doc {Entry options -label} option {-label label Label} descr {
# text to be displayed in the entry label. If this is empty, no label will bne displayed.
#}
Classy::Entry addoption -label {label Label {}} {
	private $object options
	if [winfo exists $object.label] {destroy $object.label}
	if {"$value" != ""} {
		label $object.label -bg [Classy::realcolor $options(-labelbackground)] -padx 3
		pack $object.label -before $object.frame -side left -fill both
		$object.label configure -text $value
		if {"$options(-orient)"!="horizontal"} {
			pack $object.label -side top -fill both
			pack $object.frame -side bottom -expand yes -fill both
		}
	} else {
		if [winfo exists $object.label] {destroy $object.label}
	}
	return $value
}

#doc {Entry options -labelbackground} option {-labelbackground labelBackground LabelBackground} descr {
# background color of label
#}
Classy::Entry addoption -labelbackground {labelBackground LabelBackground Background} {
	if [winfo exists $object.label] {$object.label configure -bg [Classy::realcolor $value]}
}

#doc {Entry options -command} option {-command command Command} descr {
# associate a command with the entry. When the Action key (usually Enter) is pressed 
# in the entry, the widget will invoke a Tcl command by concatenating the given 
# command and the value in the entry widget. The command will be executed in global
# scope. If you want to use temporary variables without poluting the global namesspace,
# the <a href="convenience.html">Extral invoke</a> command might interest you.
#}
Classy::Entry addoption -command {command Command {}}

#doc {Entry options -constraint} option {-constraint constraint Constraint} descr {
# the value in the entry must match the regular expression given here.
# No constraint is applied when it is set to the empty string.
#}
Classy::Entry addoption -constraint {constraint Constraint {}} {
	Classy::todo $object _confvalidate
}

#doc {Entry options -validate} option {-validate validate Validate} descr {
# If the given option is one of none, focus, focusin, focusout, key or all, validation
# the native tk validation scheme that was introduced in tk 8.4 will be used.
# <br>
# Otherwise the older ClassyTk validation will be used:
# When editing a value in the Classy::Entry,
# the command given in the validate option will be invoked.
# The following percent substitutions (is in the new tk validation) can be used:
# %P (new value of entry, if allowed), %s (previous value), %d (type of action:), %i (index), %S (text string being inserted/deleted), %W (name of widget)
#<b>
#}
Classy::Entry addoption -validate {validate Validate {}} {
	Classy::todo $object _confvalidate
}

Classy::Entry addoption -validatecommand {validateCommand ValidateCommand {}} {
	Classy::todo $object _confvalidate
}

#doc {Entry options -labelwidth} option {-labelwidth labelWidth LabelWidth} descr {
# width of the label
#}
Classy::Entry addoption -labelwidth {labelWidth LabelWidth {}} {
	Classy::todo $object _redrawentry
}

#doc {Entry options -warn} option {-warn warn Warn} descr {
# The option -warn can be true or false. If it is false (or 0), the entry will
# never contain a value not matching the constraint. It warn is true, it is possible
# to enter a value not matching the constraint, but there will be visual warning.
#}
Classy::Entry addoption -warn {warn warn 1} {
	set value [true $value]
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Entry chainallmethods {$object.entry} entry

#doc {Entry command nocmdset} cmd {
#pathname nocmdset value
#} descr {
# set the entry to value without invoking the command associated with the entry
#}
Classy::Entry method nocmdset {val} {
	private $object noconstrain
	set noconstrain 1
	$object.entry delete 0 end
	$object.entry insert 0 $val
	$object.entry xview end
	unset noconstrain
}

#doc {Entry command set} cmd {
#pathname set value
#} descr {
# set the entry to value.
#}
Classy::Entry method set {val} {
	private $object options
	if {$options(-validatecommand) eq ""} {
		set ok [$object constrain $object [$object get] $val {} {} {}]
		if {!$ok} return
	}
	$object nocmdset $val
	$object command
}

#doc {Entry command get} cmd {
#pathname get 
#} descr {
# get the current contents of the entry
#}
Classy::Entry method get {} {
	return [$object.entry get]
}

#doc {Entry command command} cmd {
#pathname command 
#} descr {
# invoke the command associated with the entry
#}
Classy::Entry method command {} {
	private $object options
	if [isint $options(-combo)] {
		$object _combo_add
	}
	set command [get options(-command) ""]
	if ![string_equal $command ""] {
		uplevel #0 $command [list [$object.entry get]]
		return 1
	} else {
		return 0
	}
}	

Classy::Entry method _combo_add {} {
	private $object options
	set history [Classy::Default get app combo,$object]
	set value [$object.entry get]
	set history [list_remove $history $value]
	list_unshift history $value
	set history [lrange $history 0 $options(-combo)]
	Classy::Default set app combo,$object $history
}	

Classy::Entry method _confvalidate {} {
	private $object options
	if {$options(-validatecommand) ne ""} {
		$object.entry configure -validate $options(-validate) -validatecommand "after idle {%W config -validate %v} ; $options(-validatecommand)"
	} else {
		$object.entry configure -validate key -validatecommand "after idle {%W config -validate %v}; [list $object constrain %W %s %P %d %i %S]"
	}
}

#doc {Entry command constrain} cmd {
#pathname constrain ?warn?
#} descr {
# check whether the value matches the regular expression given by the -constraint option
#}
Classy::Entry method constrain {W previous new d i S} {
	private $object options previouscol noconstrain
	if {[info exists noconstrain]} {return 1}
	set warn $options(-warn)
	set ok 1
	if {[llength $options(-validate)]} {
		set cmd [string_change $options(-validate) [list %W $object %s $previous %P $new %i $i %S $S]]
		if {[catch {uplevel #0 $cmd} ok]} {
			set error $ok
			set ok 0
		}
		if {![string length $ok]} {set ok 1}
		if {[true $ok]} {set ok 1}
		if {$ok == 2} {
			set warn 1
			set ok 0
		}
	}
	if {$ok == 1} {
		set constraint $options(-constraint)
		if [string length $constraint] {
			set ok [regexp $constraint $new]
		}
	}
	if {$ok} {
		if [info exists previouscol] {
			$object.entry configure -fg $previouscol
			unset previouscol
		}
	} else {
		if {$warn == 0} {
			if {[info exists error]} {error $error}
			return 0
		} elseif {![info exists previouscol]} {
			set previouscol [$object.entry cget -fg]
			$object.entry configure -fg red
		}
		if {[info exists error]} {error $error}
	}
	return 1
}	

Classy::Entry method _redrawentry {} {
	private $object options
	if {"$options(-labelwidth)" != ""} {
		if [winfo exists $object.label] {$object.label configure -width $options(-labelwidth)}
	}
	if [string match "hor*" "$options(-orient)"] {
		if [winfo exists $object.label] {pack $object.label -side left}
		pack $object.frame -side left -expand yes -fill x
		return horizontal
	} else {
		if [winfo exists $object.label] {pack $object.label -side top -fill x}
		pack $object.frame -side bottom -expand yes -fill x
		return vertical
	}
}

Classy::Entry method paste {} {
	$object.entry insert insert [selection get -displayof $object]
}

Classy::Entry method previous {} {
	return [getprivate $object previous]
}

Classy::Entry method _combo_remove {args} {
	set w $object.defaults.combo
	wm withdraw $w
	focus $object.entry
	return
}

Classy::Entry method _combo_action {args} {
	private $object options
	set w $object.defaults.combo
	$object.entry configure -state normal
	$object set [$w.list get active]
	if [string_equal $options(-state) combo] {
		$object.entry configure -state disabled
	} else {
		$object.entry configure -state $options(-state)
	}
	$object _combo_remove
}

Classy::Entry method combo_draw {args} {
	private $object options
	if [string_equal $options(-combo) ""] {
		return
	} elseif [isint $options(-combo)] {
		set history [Classy::Default get app combo,$object]
		set list $history
	} else {
		set list [uplevel #0 $options(-combo)]
	}
	if [llength $options(-combopreset)] {
		set prelist [uplevel #0 $options(-combopreset)]
		set prelist [list_lremove $prelist $list]
		set list [list_concat $list $prelist]
	}
	set w $object.defaults.combo
	if [winfo ismapped $w] {
		wm withdraw $w
		focus $object.entry
		return
	}
	$w.list delete 0 end
	eval $w.list insert end $list
	set mainw $object.frame.entry
	set xpos [winfo rootx $mainw]
#	set ypos [expr {[winfo rooty $mainw] + [winfo height $mainw] - [winfo height $mainw]}]
	set ypos [winfo rooty $mainw]
	set width [winfo width $mainw]
	set maxheight [expr {[winfo screenheight $mainw] - $ypos}]
	set noscroll 0
	if [isint $options(-combosize)] {
		set size $options(-combosize)
		if {[llength $list] < $size} {
			set size [llength $list]
			set noscroll 1
		}
		$w.list configure -height $size
		set h [winfo reqheight $w.list]
		if {$h < $maxheight} {
			set maxheight $h
			if $noscroll {set noscroll 2}
		}
	}
	if {$noscroll == 2} {
		pack forget $w.vsb
	} else {
		pack $w.vsb -side left -fill y
	}
	bind $w.list <<Invoke>> [list $object _combo_action]
	bind $w.list <<Action-Motion>> [list $w.list activate @%x,%y]
	bind $w.list <<Action>> [list $w.list activate @%x,%y]
	bind $w.list <<Action-ButtonRelease>> [list $object _combo_action]
	bind $w.list <<Return>> [list $object _combo_action]
	if {"$::tcl_platform(platform)"=="windows"} {
		wm deiconify $w
		Classy::update Classy::Entry-combo_draw idletasks
		wm geometry $w ${width}x$maxheight+$xpos+$ypos
	} else {
		wm geometry $w ${width}x$maxheight+$xpos+$ypos
		wm deiconify $w
	}
	raise $w
	focus $w.list
	$w.list activate 0
}

