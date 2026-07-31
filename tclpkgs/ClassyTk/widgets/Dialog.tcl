#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Dialog
# ----------------------------------------------------------------------
#doc Dialog title {
#Dialog
#} index {
# Dialogs
#} shortdescr {
# dialog with intelligent placing, easy adding of buttons, ...
#} descr {
# subclass of <a href="Toplevel.html">Toplevel</a><br>
# Dialog produces "intelligent" dialog. They have a simple option to
#make them resizable or not. They automatically assume a reasonable
#minimum size based on their content (The dialog will be placed on the
#screen and its size calculated at the first idle moment after dialog 
#creation. The dialog will place itself so that the mouse pointer is 
#is positioned over it, without being placed partly out of the screen.
#If it is resized, it remembers its size for the next display.
#<p>
#By default, the dialog has a "Cancel" button that destroys the dialog
#on invocation. Other buttons can be added easily using the add method.
#Invoking a command by clicking on a button (or using a key shortcut)
#will close the dialog, unless the button is persistent, or was 
#invoked using the Adjust mouse button.
#The dialog has one component named options, which is a frame in
#which optionmenus, entries, etc. can be placed. 
#}
#doc {Dialog options} h2 {
#	Dialog specific options
#}
#doc {Dialog command} h2 {
#	Dialog specific methods
#}

option add *Classy::Dialog.options.relief raised widgetDefault
option add *Classy::Dialog.options.highlightThickness 0 widgetDefault
option add *Classy::Dialog.actions.relief raised widgetDefault
option add *Classy::Dialog.actions.highlightThickness 0 widgetDefault

#bind Classy::DialogButton <FocusIn> {}
bind Classy::DialogButton <Enter> {
	tk::ButtonEnter %W
}
bind Classy::DialogButton <Leave> {
	tk::ButtonLeave %W
}
bind Classy::DialogButton <<Action>> {
	Classy::DialogButtonDown %W
}
bind Classy::DialogButton <<Adjust>> {
	Classy::DialogButtonDown %W
}
bind Classy::DialogButton <<Action-ButtonRelease>> {
	Classy::DialogButtonUp %W Action
}
bind Classy::DialogButton <<Adjust-ButtonRelease>> {
	Classy::DialogButtonUp %W Adjust
}
bind Classy::DialogButton <<Invoke>> {
	Classy::DialogButtonInvoke %W
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Toplevel subclass Classy::Dialog

Classy::Dialog method init {args} {
	# REM Create object
	# -----------------
	super init
	Classy::Dialog private options(-title) {title Title "Dialog"}
	frame $object.options -highlightthickness 0
	frame $object.actions -highlightthickness 0
	button $object.actions.close -text "Cancel"
	bindtags $object.actions.close [list_regsub Button [bindtags $object.actions.close] Classy::DialogButton]
	pack $object.actions.close -side right -expand yes -padx 5 -pady 10
	grid $object.options -sticky nwse
	grid $object.actions -sticky we
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -minsize [winfo reqheight $object.actions]

	# REM Create bindings
	# -------------------
	bind $object <Escape> "$object invoke close"

	# REM Initialise variables
	# ------------------------
	setprivate $object shortcuts ""

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy::Dialog component options {$object.options}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
# REM Adding options


#doc {Dialog options -closecommand} option {-closecommand CloseCommand closeCommand} descr {
#commands invoked when invoking the "Cancel" button
#}
Classy::Dialog chainoption -closecommand {$object.actions.close} -command

#doc {Dialog options -closebutton} option {-closebutton closeButton CloseButton} descr {
#include "Cancel" button
#}
Classy::Dialog addoption -closebutton {closeButton CloseButton 1} {
	if {[true $value]} {
		pack $object.actions.close -side right -expand yes -padx 5 -pady 10
	} else {
		pack forget $object.actions.close
	}
}

#doc {Dialog options -help} option {-help help Help} descr {
# add a help button. A file with the name helpvalue.html will
# be shown in a help window whein the button is invoked
#}
Classy::Dialog addoption -help {help Help {}} {
	if [string match $value ""] {
		catch {destroy $object.actions.help}
	} else {
		catch {button $object.actions.help -text "Help" -underline 0 }
		$object.actions.help configure -command "Classy::help $value"
		pack $object.actions.help -side right -expand yes -padx 5 -pady 10
		bind $object <<Help>> "$object invoke help"
		bind $object <Control-h> "$object invoke help"
	}
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Dialog command add} cmd {
#pathname add button text command ?default?
#} descr {
# add a button with name $button to the dialog. The button will display
# the $text. When it is invoked, $command will be executed.
# If the word default is added, the button will be displayed differently
# and invoked by default (eg. when pressing Enter).
#}
Classy::Dialog method add {button text command args} {
	if {"$args" == "default"} {
		button $object.actions.$button -default active -text $text -command $command
		bindtags $object.actions.$button [list_regsub Button [bindtags $object.actions.$button] Classy::DialogButton]
		pack $object.actions.$button -side left -expand yes
		bind $object <KeyPress-Return> "$object invoke $button"
	} else {
		private $object shortcuts persistent
		button $object.actions.$button -text $text -command $command
		bindtags $object.actions.$button [list_regsub Button [bindtags $object.actions.$button] Classy::DialogButton]
		pack $object.actions.$button -side left -expand yes -padx 5 -pady 10
		set text [string tolower $text]
		set pos 0
		set len [string length $text]
		while {[lsearch -exact $shortcuts [string index $text $pos]]!=-1} {
		incr pos
			if {$pos==$len} return
		}
		if {"$args" != ""} {
			bind $object $args "$object invoke $button"
		}
		bind $object <Control-[string index $text $pos]> "$object invoke $button"
		bind $object <Alt-[string index $text $pos]> "$object invoke $button Adjust"
		$object.actions.$button configure -underline $pos
		lappend shortcuts [string index $text $pos]
		lappend persistent $button
	}
	return $object.actions.$button
}

#doc {Dialog command remove} cmd {
#pathname delete button
#} descr {
# remove the button with name $button to the dialog.
#}
Classy::Dialog method delete {button} {
	private $object shortcuts persistent
	destroy $object.actions.$button
	catch {set persistent [list_remove $persistent $button]}
}

#doc {Dialog command rename} cmd {
#pathname rename button newname
#} descr {
# rename the button with name $button to the dialog to $newname.
#}
Classy::Dialog method rename {button newname} {
	private $object shortcuts persistent
	set w $object.actions.$button
	set conf [$object button $button]
	eval {$object add $newname} $conf
	pack $object.actions.$newname -before $w
	$object delete $button
	catch {set persistent [list_remove $persistent $button]}
}

#doc {Dialog command button} cmd {
#pathname button ?button?
#} descr {
# returns a list of buttons; if button is given, returns the parameters given to this button.
#}
Classy::Dialog method button {{button {}}} {
	if {"$button" == ""} {
		set result ""
		foreach b [winfo children $object.actions] {
			regsub ^$object\\.actions\\. $b {} b
			lappend result $b
		}
		return $result
	} else {
		set result [list [$object.actions.$button cget -text] [$object.actions.$button cget -command]]
		if {"[$object.actions.$button cget -default]" == "active"} {
			lappend result default
		}
		return $result
	}
}

#doc {Dialog command persistent} cmd {
#pathname persistent ?option button ...?
#} descr {
#Without arguments, the method returns a list of all persistent buttons
#Option can be:
#<ul>
#<li><b>set</b>: make only the given buttons persistent
#<li><b>add</b>: make the given buttons persistent
#<li><b>remove</b>: make the given buttons not persistent
#</ul>
#}
Classy::Dialog method persistent {{option {}} args} {
	private $object persistent
	if ![info exists persistent] {set persistent ""}
	if {"$option"==""} {
		return $persistent
	}
	if {"[lindex $args 0]"=="-all"} {
		set all [winfo children $object.actions]
		set all [list_remove $all $object.actions.default $object.actions.close $object.actions.help]
		set args [list_regsub {^.*\.} $all {}]
	}
	switch $option {
		set {
			set persistent $args
		}
		add {
			eval list_addnew persistent $args
		}
		remove {
			set persistent [list_lremove $persistent $args]
		}
		default {
			error "bad option \"$option\": must be set, add or remove"
		}
	}
	return $persistent
}

#doc {Dialog command invoke} cmd {
#pathname invoke button ?Action/Adjust?
#} descr {
#}
Classy::Dialog method invoke {item {button Action}} {
	private $object persistent
	$object.actions.$item invoke
	if {("$item"!="help")&&("$button"!="Adjust")} {
		if [info exists persistent] {
			if {[lsearch -exact $persistent $item]==-1} {
				Classy::todo $object close
			}
		} else {
			Classy::todo $object close
		}
	}
}

#doc {Dialog command close} cmd {
#pathname close 
#} descr {
#}
Classy::Dialog method close {} {
	if [winfo exists $object] {
		if ![getprivate $object options(-cache)] {
			catch {destroy $object}
		} else {
			$object hide
		}
	}
}

Classy::Dialog method _addstart {} {
	private $object addnum
	if {![info exists addnum]} {
		set addnum 1
	} else {
		incr addnum
	}
	return $addnum
}

#doc {Dialog command header} cmd {
#pathname header text
#} descr {
#}
Classy::Dialog method header {title} {
	private $object optionw
	if {![info exists optionw]} {$object col 1}
	set addnum [$object _addstart]
	label $optionw.title$addnum -font [Classy::realfont BoldFont] -text $title -justify left
	grid $optionw.title$addnum -sticky w -columnspan 4
}

#doc {Dialog command col} cmd {
#pathname col colnum
#} descr {
#}
Classy::Dialog method col {colnum {weight 1}} {
	private $object optionw
	regsub {\.col[0-9]+$} [get optionw $object.options] {} optionw
	if {[winfo exists $optionw.col$colnum]} {
		set optionw $optionw.col$colnum
		return $optionw.col$colnum
	}
	frame $optionw.col$colnum -highlightthickness 0
	grid columnconfigure $optionw.col$colnum 2 -weight 1
	grid $optionw.col$colnum -row 0 -column $colnum -sticky nwse
	grid columnconfigure $optionw $colnum -weight $weight
	grid rowconfigure $optionw 0 -weight 1
	set optionw $optionw.col$colnum
}

#doc {Dialog command tab} cmd {
#pathname tab tabname
#} descr {
#}
Classy::Dialog method tab {tabname} {
	private $object optionw tabs
	set tab $object.options.tab
	if {![winfo exists $tab]} {
		Classy::NoteBook $tab -width 100
		grid $tab -row 0 -column 0 -sticky nwse
		grid columnconfigure $object.options 0 -weight 1
		grid rowconfigure $object.options 0 -weight 1
	}
	if {![info exists tabs($tabname)]} {
		if {![info exists tabs()]}  {set tabs() 0} else {incr tabs()}
		set optionw $tab.stab$tabs()
		set tabs($tabname) $optionw
		frame $optionw -highlightthickness 0
		$tab manage $tabname $optionw
	} else {
		set optionw $tabs($tabname)
	}
	$tab select $tabname
	return [$object col 1]
}

proc Classy::Dialog_sort {dir w {command {}}} {
	upvar #0 [$w cget -listvariable] list
	set sel [$w curselection]
	$w selection clear 0 end
	switch $dir {
		up {
			foreach pos $sel {
				if {$pos <= 0} continue
				set el [list_pop list $pos]
				incr pos -1
				set list [linsert $list $pos $el]
				$w selection set $pos
			}
		}
		down {
			set len [expr {[llength $list]-1}]
			foreach pos [list_reverse $sel] {
				if {$pos >= $len} continue
				set el [list_pop list $pos]
				incr pos 1
				set list [linsert $list $pos $el]
				$w selection set $pos
			}
		}
		top {
			set temp [list_sub $list $sel]
			set list [list_sub $list -exclude $sel]
			set list [list_concat $temp $list]
			$w selection set 0 [expr {[llength $temp]-1}]
		}
		bottom {
			set len [expr {[llength $list]-1}]
			set temp [list_sub $list $sel]
			set list [list_sub $list -exclude $sel]
			set list [list_concat $list $temp]
			$w selection set [expr {$len - [llength $temp]+1}] end
		}
	}
	if {$command ne ""} {
		uplevel #0 $command
	}
}

#doc {Dialog command option} cmd {
#pathname option type label args
#} descr {
# The option commands allows easy configuration of a dialog, adding tabs, text and num entries, fonts, ...
# <b>label</b> is shown before the entry field. <b>variable</b> contains the value that is entered. If 
# you want presets, just fill in the variable.
#Supported types:
#<dl>
#<dt>option <b>entry</b> label variable ?options?<dt>
#<dd>text entry, supports Classy::Entry options</dd>
#<dt>option <b>numentry</b> label variable ?options?<dt>
#<dd>text entry, supports Classy::NumEntry options</dd>
#<dt>option <b>radio</b> label variable text value ?text value? ?-- options?<dt>
#<dd>Set of radiobuttons given by a text value pairs. after a -- options can be given, these can be any options supported by radiobutton</dd>
#<dt>option <b>vradio</b> label variable text value ?text value? ?-- options?<dt>
#<dd>sample as radio, but radiobuttons are arranged vertically</dd>
#<dt>option <b>check</b> label variable text ?variable text? ?-- options?<dt>
#<dd>similar to radio, but with checkbuttons</dd>
#<dt>option <b>vcheck</b> label variable text ?variable text? ?-- options?<dt>
#<dd>similar to vradio, but with checkbuttons</dd>
#<dt>option <b>button</b> label command<dt>
#<dd>a button with associated command</dd>
#<dt>option <b>buttons</b> label buttonlabel command ?buttonlabel command?<dt>
#<dd>several buttons with associated command</dd>
#<dt>option <b>file</b> label variable ?options?<dt>
#<dd>entry for file selection (with browse button)</dd>
#<dt>option <b>dir</b> label variable ?options?<dt>
#<dd>entry for directory selection (with browse button)</dd>
#<dt>option <b>select</b> label variable listvariable<dt>
#<dd>select from a number of choices, the choices are a list stored in the variable listvariable</dd>
#<dt>option <b>listbox</b> label variable listvariable ?selectmode? ?options?<dt>
#<dd>selection in a listbox, choices given in listvariable</dd>
#<dt>option <b>frame</b> ?options?<dt>
#<dd>frame to fill up to your liking</dd>
#<dt>option <b>message</b> variable<dt>
#<dd>Classy::Message based option, value in variable is shown as message</dd>
#<dt>option <b>label</b> variable<dt>
#<dd>Just a line of text</dd>
#<dt>option <b>messagedirect</b> messagetext<dt>
#<dd>show message, not via variable, so it will not change</dd>
#<dt>option <b>sort</b> label variable ?options?<dt>
#<dd>variable contains a list that can be sorted by the user</dd>
#<dt>option <b>text</b> label variable command ?options?<dt>
#<dd>enter text, supports options of Classy::Selector (text type)</dd>
#<dt>option <b>...</b> label variable ?options?<dt>
#<dd>folowing types are also supported:
# int line string text color font key mouse menu toolbar anchor justify bool orient relief select sticky image bitmap<br>
# with the same options as Classy::Selector
#</dd>
#</dl>
#}
Classy::Dialog method option {type label args} {
	private $object optionw
	if {![info exists optionw]} {$object col 1}
	set addnum [$object _addstart]
	if {([llength $args] > 1)} {
		if {[lindex $args end-1] eq "-help"} {
			set help [lindex $args end]
			set args [lrange $args 0 end-2]
		}
	}
	frame $optionw.spacer$addnum -width 20 -highlightthickness 0
	label $optionw.label$addnum -text $label -justify left -anchor nw
	if {[info exists help]} {
		Classy::Balloon add $optionw.label$addnum $help 100
	}
	frame $optionw.frame$addnum -highlightthickness 0
	if {$type eq "entry"} {
		if {[llength $args] < 1} {error "format is: $object option entry label variable ?options?"}
		set var [list_shift args]
		Classy::Entry $optionw.entry$addnum -textvariable $var
	} elseif {$type eq "numentry"} {
		if {[llength $args] < 1} {error "format is: $object option numentry label variable ?options?"}
		set var [list_shift args]
		Classy::NumEntry $optionw.entry$addnum -textvariable $var
	} elseif {[inlist {radio vradio} $type]} {
		if {$type eq "radio"} {set side left} else {set side top}
		if {[llength $args] < 2} {error "format is: $object option radio label variable text value ?text value? ?-- options?"}
		frame $optionw.entry$addnum -highlightthickness 0
		set pos [lsearch -exact $args --]
		if {$pos != -1} {
			set options [lrange $args [expr {$pos+1}] end]
			set args [lrange $args 0 [expr {$pos-1}]]
		} else {
			set options {}
		}
		if {![expr {[llength $args] % 2}]} {set help [list_pop args]} else {set help ""}
		Classy::Message $optionw.entry$addnum.help -text $help -width 1 -height 1
		pack $optionw.entry$addnum.help -side right -expand yes -fill both
		set num 1
		set var [list_shift args]
		foreach {text value} $args {
			radiobutton $optionw.entry$addnum.r$num -variable $var -text $text -value $value
			if {[llength $options]} {eval {$optionw.entry$addnum.r$num configure} $options}
			pack $optionw.entry$addnum.r$num -side $side
			incr num
		}
		set args {}
	} elseif {[inlist {check vcheck} $type]} {
		if {$type eq "check"} {set side left} else {set side top}
		if {[llength $args] < 2} {error "format is: $object option check label variable text ?variable text? ?-- options?"}
		set pos [lsearch -exact $args --]
		if {$pos != -1} {
			set options [lrange $args [expr {$pos+1}] end]
			set args [lrange $args 0 [expr {$pos-1}]]
		} else {
			set options {}
		}
		if {[expr {[llength $args] % 2}]} {set help [list_pop args]} else {set help ""}
		frame $optionw.entry$addnum -highlightthickness 0
		Classy::Message $optionw.entry$addnum.help -text $help -width 1 -height 1
		pack $optionw.entry$addnum.help -side right -expand yes -fill both
		set num 1
		foreach {var text} $args {
			checkbutton $optionw.entry$addnum.r$num -variable $var -text $text
			if {[llength $options]} {eval {$optionw.entry$addnum.r$num configure} $options}
			pack $optionw.entry$addnum.r$num -side $side
			incr num
		}
		set args {}
	} elseif {$type eq "button"} {
		if {[llength $args] < 1} {error "format is: $object option button label command"}
		set num 1
		set cmd [list_shift args]
		button $optionw.entry$addnum -text $label -command $cmd
		$optionw.label$addnum configure -text ""
		if {[llength $args]} {eval {$optionw.entry$addnum configure} $args}
		set args {}
	} elseif {$type eq "buttons"} {
		if {[llength $args] < 2} {error "format is: $object option button label buttonlabel command ?buttonlabel command?"}
		set num 1
		frame $optionw.entry$addnum -highlightthickness 0
		foreach {text cmd} $args {
			button $optionw.entry$addnum.r$num -text $text -command $cmd
			pack $optionw.entry$addnum.r$num -side left
			incr num
		}
		set args {}
	} elseif {[inlist {file dir} $type]} {
		if {[llength $args] < 1} {error "format is: $object option file label variable ?options?"}
		set var [list_shift args]
		Classy::FileEntry $optionw.entry$addnum -textvariable $var -selecttype $type
	} elseif {$type eq "select"} {
		if {[llength $args] < 2} {error "format is: $object option select label variable listvariable ?options?"}
		set var [list_shift args]
		set listvar [list_shift args]
		Classy::OptionMenu $optionw.entry$addnum -textvariable $var -listvariable $listvar
	} elseif {$type eq "listbox"} {
		if {[llength $args] < 2} {error "format is: $object option listbox label variable listvariable ?selectmode? ?options?"}
		set var [list_shift args]
		set list [list_shift args]
		set keep [get ::$var]
		Classy::ListBox $optionw.entry$addnum -selvariable $var -listvariable $list -height 4 -selectmode extended -exportselection 0
#		set ::$var $keep
		grid rowconfigure $optionw [lindex [grid size $optionw] 1] -weight 1
	} elseif {$type eq "frame"} {
		if {[llength $args] < 0} {error "format is: $object option frame ?options?"}
		grid $optionw.spacer$addnum $optionw.label$addnum $optionw.frame$addnum -sticky nwse
		grid $optionw.frame$addnum -columnspan 2
	} elseif {$type eq "message"} {
		if {[llength $args] < 0} {error "format is: $object option message variable"}
		set var [list_shift args]
		Classy::Message $optionw.entry$addnum -textvariable $var
	} elseif {$type eq "label"} {
		if {[llength $args] < 0} {error "format is: $object option label variable"}
		set var [list_shift args]
		label $optionw.entry$addnum -textvariable $var
	} elseif {$type eq "messagedirect"} {
		if {[llength $args] < 0} {error "format is: $object option message messagetext args"}
		set messagetext [list_shift args]
		eval {Classy::Message $optionw.entry$addnum -text $messagetext} $args
	} elseif {$type eq "labeldirect"} {
		if {[llength $args] < 0} {error "format is: $object option label text args"}
		set text [list_shift args]
		eval {label $optionw.entry$addnum -text $text} $args
	} elseif {$type eq "text"} {
		if {[llength $args] < 2} {error "format is: $object option text label variable textlabel ?options?"}
		set var [list_shift args]
		set textlabel [list_shift args]
		Classy::Selector $optionw.entry$addnum -variable $var -type text -label $textlabel
		grid rowconfigure $optionw [lindex [grid size $optionw] 1] -weight 1
	} elseif {$type eq "sort"} {
		if {[llength $args] < 1} {error "format is: $object option sort label variable command args"}
		set var [list_shift args]
		set command [list_shift args]
		frame $optionw.entry$addnum -highlightthickness 0
		Classy::ListBox $optionw.entry$addnum.list -listvariable $var \
			-highlightthickness 0 -selectmode extended -exportselection 0
		grid $optionw.entry$addnum.list -sticky nwse -rowspan 5
		grid columnconfigure $optionw.entry$addnum 0 -weight 1
		grid rowconfigure $optionw.entry$addnum 4 -weight 1
		set row 0
		foreach key {top up down bottom} {
			button $optionw.entry$addnum.$key -text $key -command [list Classy::Dialog_sort $key $optionw.entry$addnum.list $command]
			grid $optionw.entry$addnum.$key -column 1 -row $row -sticky nwse
			incr row
		}
		grid rowconfigure $optionw [lindex [grid size $optionw] 1] -weight 1
	} elseif {[inlist {int line string text color font key mouse menu toolbar anchor justify bool orient relief select sticky image bitmap} [lindex $type 0]]} {
		if {[llength $args] < 1} {error "format is: $object option $type label variable ?...?"}
		set var [list_shift args]
		Classy::Selector $optionw.entry$addnum -variable $var -type $type
	} else {
		error "Unknown type $type, must be one of: entry, numentry, button, file, select, radio, vradio, check, vcheck, listbox, frame, int, line, string, text, color, font, key, label, labeldirect, mouse, menu, message, messagedirect, sort, toolbar, anchor, justify, bool, orient, relief, select, sticky, image, bitmap"
	}
	if {[llength $args]} {
		eval {$optionw.entry$addnum configure} $args
	}
	if {$type eq "frame"} {
		grid $optionw.spacer$addnum $optionw.label$addnum $optionw.frame$addnum -sticky nwse
		grid $optionw.frame$addnum -columnspan 2
		return $optionw.frame$addnum
	} else {
		grid $optionw.spacer$addnum $optionw.label$addnum $optionw.entry$addnum $optionw.frame$addnum -sticky nwse
		return [list $optionw.entry$addnum $optionw.frame$addnum]
	}
}

# patches from the original code in button.tcl

proc Classy::DialogButtonDown w {
	global tk::Priv
	set tk::Priv(relief) [lindex [$w config -relief] 4]
	if {[$w cget -state] != "disabled"} {
		set tk::Priv(buttonWindow) $w
		$w config -relief sunken
	}
}

proc Classy::DialogButtonUp {w button} {
	global tk::Priv
	if {$w == $tk::Priv(buttonWindow)} {
		set tk::Priv(buttonWindow) ""
		$w config -relief $tk::Priv(relief)
		if {($w == $tk::Priv(window))
				&& ([$w cget -state] != "disabled")} {
			regexp {\.([^.]*)$} $w temp leaf
			uplevel #0 [list [winfo toplevel $w] invoke $leaf $button]
		}
	}
}

proc Classy::DialogButtonInvoke w {
	if {[$w cget -state] != "disabled"} {
		set oldRelief [$w cget -relief]
		set oldState [$w cget -state]
		$w configure -state normal -relief sunken
		Classy::update Classy::DialogButtonInvoke idletasks
		after 100
		$w configure -state $oldState -relief $oldRelief
		regexp {\.([^.]*)$} $w temp leaf
		uplevel #0 [list [winfo toplevel $w] invoke $leaf]
	}
}

# ------------------------------------------------------------------
#  destructor
# ------------------------------------------------------------------

Classy::Dialog classmethod destroy {} {
	rename ::Classy::DialogButtonInvoke {}
	rename ::Classy::DialogButtonUp {}
	rename ::Classy::DialogButtonDown {}
}


