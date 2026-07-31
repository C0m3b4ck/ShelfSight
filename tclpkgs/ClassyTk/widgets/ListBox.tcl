#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ListBox
# ----------------------------------------------------------------------
#doc ListBox title {
#ListBox
#} index {
# Tk improvements
#} shortdescr {
# listbox with auto scroll bars, and other extras
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a listbox with automatic scrollbars, and some handy extra options.
#}
#doc {ListBox command} h2 {
#	ListBox specific methods
#}

if {[string equal $tcl_platform(platform) windows]} {
	option add *Classy::ListBox.Relief sunken widgetDefault
	option add *Classy::ListBox.BorderWidth 1 widgetDefault
	option add *Classy::ListBox.list.Relief flat widgetDefault
	option add *Classy::ListBox.list.BorderWidth 0 widgetDefault
}

bind Classy::ListBox <<MExecute>> {[Classy::mainw %W] command}
bind Classy::ListBox <<Invoke>> {[Classy::mainw %W] command}
bind Classy::ListBox <<Action>> {[Classy::mainw %W] activate @%x,%y}
bind Classy::ListBox <<ListboxSelect>> {[Classy::mainw %W] _browse}
bind Classy::ListBox <<Up>> {[Classy::mainw %W] _updown -1; break}
bind Classy::ListBox <<Down>> {[Classy::mainw %W] _updown 1; break}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::ListBox

Classy::ListBox method init {args} {
	# REM Create object
	# -----------------
	super init
	listbox $object.list -xscrollcommand [list $object.xscroll set] -yscrollcommand [list $object.yscroll set] \
		-highlightthickness 0 -listvariable [privatevar $object listvar]
	bind $object.list <<ListboxSelect>> [list $object _setvar]
	Classy::AutoScrollbar $object.xscroll -command [list $object.list xview] -orient horizontal
	Classy::AutoScrollbar $object.yscroll -command [list $object.list yview] -orient vertical
	$object.xscroll set 0.0 1.0
	$object.yscroll set 0.0 1.0
	bindtags $object [lreplace [bindtags $object] 2 0 Listbox]
	Classy::rebind $object.list $object
	grid $object.list -column 0 -row 1 -sticky nwse
	grid $object.yscroll -column 1 -row 1 -sticky nwse
	grid $object.xscroll -column 0 -row 2 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 1
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy::ListBox method destroy {} {
	private $object options
	if {![string_equal [get options(-selvariable) ""] ""]} {
		trace vdelete ::$options(-selvariable) w [list $object _traceselvar]
	}
	if {![string_equal [get options(-valuesvariable) ""] ""]} {
		trace vdelete ::$options(-valuesvariable) w [list $object _tracevaluesvar]
	}
	if {![string_equal [get options(-listvariable) ""] ""]} {
		trace vdelete ::$options(-listvariable) w [list $object _filter]
	}
	if {![string_equal [get options(-filtervariable) ""] ""]} {
		trace vdelete ::$options(-filtervariable) w [list $object _filter]
	}
}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
Classy::ListBox chainoptions {$object.list}
Classy::ListBox chainoption -background {$object} -background {$object.list} -background
Classy::ListBox chainoption -highlightbackground {$object} -highlightbackground {$object.list} -highlightbackground
Classy::ListBox chainoption -highlightcolor {$object} -highlightcolor {$object.list} -highlightcolor

#doc {ListBox options -content} option {-content content Content} descr {
#}
Classy::ListBox addoption -content {content Content {}} {
	private $object listvar
	set listvar $value
	Classy::todo $object _filter
#	$object.list delete 0 end
#	foreach el $value {
#		$object.list insert end $el
#	}
}

#doc {ListBox options -values} option {-values values Values} descr {
#}
Classy::ListBox addoption -values {values Values {}} {
}

#doc {ListBox options -command} option {-command command Command} descr {
#}
Classy::ListBox addoption -command {command Command {}} {
}

#doc {ListBox options -browsecommand} option {-browsecommand browseCommand BrowseCommand} descr {
#}
Classy::ListBox addoption -browsecommand {browseCommand BrowseCommand {}} {
}

#doc {ListBox options -endcommand} option {-endcommand endCommand EndCommand} descr {
#}
Classy::ListBox addoption -endcommand {endCommand EndCommand {}} {
}

#doc {ListBox options -selvariable} option {-selvariable selVariable SelVariable} descr {
#}
Classy::ListBox addoption -selvariable {selVariable SelVariable {}} {
	private $object options
	if {![string_equal [get options(-selvariable) ""] ""]} {
		trace vdelete ::$options(-selvariable) w [list $object _traceselvar]
	}
	if {![string_equal $value ""]} {
		catch {eval {$object set} [get ::$value]}
		trace variable ::$value w [list $object _traceselvar]
	}
}

#doc {ListBox options -valuesvariable} option {-valuesvariable valuesVariable ValuesVariable} descr {
#}
Classy::ListBox addoption -valuesvariable {valuesVariable ValuesVariable {}} {
	private $object options
	if {![string_equal [get options(-valuesvariable) ""] ""]} {
		trace vdelete ::$options(-valuesvariable) w [list $object _tracevaluesvar]
	}
	if {![string_equal $value ""]} {
		trace variable ::$value w [list $object _tracevaluesvar]
	}
}

Classy::ListBox addoption -listvariable {listVariable Variable {}} {
	private $object options
	if {![string_equal [get options(-listvariable) ""] ""]} {
		trace vdelete ::$options(-listvariable) w [list $object _filter]
	}
	if {![string_equal $value ""]} {
		trace variable ::$value w [list $object _filter]
	}
	Classy::todo $object _redraw
}

#doc {ListBox options -filtervariable} option {-filtervariable filterVariable FilterVariable} descr {
#}
Classy::ListBox addoption -filtervariable {filterVariable FilterVariable {}} {
	private $object options
	if {![string_equal [get options(-filtervariable) ""] ""]} {
		trace vdelete ::$options(-filtervariable) w [list $object _filter]
	}
	if {![string_equal $value ""]} {
		trace variable ::$value w [list $object _filter]
	}
	Classy::todo $object _redraw
}

#doc {ListBox options -label} option {-label label Label} descr {
#}
Classy::ListBox addoption -label {label Label {}} {
	private $object options
	Classy::todo $object _redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ListBox chainallmethods {$object.list} listbox

#doc {ListBox command get} cmd {
#pathname get ?first? ?last?
#} descr {
#}
Classy::ListBox method get {args} {
	private $object options
	set len [llength $args]
	if {![llength $options(-values)]} {
		if {$len == 0} {
			set list ""
			foreach pos [$object.list curselection] {
				lappend list [$object.list get $pos]
			}
			return $list
		} elseif {$len == 1} {
			return [$object.list get [lindex $args 0]]
		} elseif {$len == 2} {
			return [$object.list get [lindex $args 0] [lindex $args 1]]
		} else {
			return -code error "wrong # args: should be \"$object get ?first? ?last?\""
		}
	} else {
		if {$options(-filtervariable) eq "" || [get ::$options(-filtervariable)] eq ""} {
			set values $options(-values)
		} else {
			upvar #0 ::$options(-filtervariable) filter
			set fulllist [$object _fulllist]
			set poss [list_find -regexp $fulllist $filter]
			set values [list_sub $options(-values) $poss]
		}
		if {$len == 0} {
			return [list_sub $values [$object.list curselection]]
		} elseif {$len == 1} {
			return [lindex $values [$object.list index [lindex $args 0]]]
		} elseif {$len == 2} {
			return [lrange $values [$object.list index [lindex $args 0]] [$object.list index [lindex $args 1]]]
		} else {
			return -code error "wrong # args: should be \"$object get ?first? ?last?\""
		}
	}
}

#doc {ListBox command set} cmd {
#pathname set ?el? ...
#} descr {
#}
Classy::ListBox method set {args} {
	private $object options
	#set c [$object cget -content]
	set c [$object get 0 end]
	set poslist {}
	foreach el $args {
		set pos [lsearch -exact $c $el]
		if {$pos == -1} {error "element \"$el\" not in listbox"}
		lappend poslist $pos
	}
	$object selection clear 0 end
	foreach pos $poslist {
		$object.list selection set $pos
	}
	if {![string equal $options(-selvariable) ""]} {
		Classy::todo $object _setvar
	}
}

Classy::ListBox method activate {args} {
	private $object options
	focus $object.list
	set pos []
	if [catch {eval $object.list index $args} pos] {
		set c [$object cget -content]
		set pos [lsearch -exact $c [lindex $args 0]]
	}
	$object.list activate $pos
	if {![string equal $options(-selvariable) ""]} {
		Classy::todo $object _setvar
	}
	if {![string equal $options(-browsecommand) ""]} {
		uplevel #0 $options(-browsecommand) [list [$object get active]]
	}
}

Classy::ListBox method _browse {args} {
	private $object options
	if {"$options(-browsecommand)" != ""} {
		uplevel #0 $options(-browsecommand) [list [$object get active]]
	}
}

Classy::ListBox method insert {index args} {
	private $object options
	if {![string_equal [get options(-listvariable) ""] ""]} {
		upvar #0 $options(-listvariable) listvar
	} else {
		upvar #0 [privatevar $object options(-content)] listvar
	}
	if {![info exists listvar]} {set listvar {}}
	set pos [$object.list index $index]
	set listvar [eval {linsert $listvar $pos} $args]
	if {![string_equal [get options(-valuesvariable) ""] ""]} {
		upvar #0 $options(-valuesvariable) valuesvar
	} else {
		upvar #0 [privatevar $object options(-values)] valuesvar
	}
	if {[info exists valuesvar]} {
		set valuesvar [eval {linsert $valuesvar $pos} $args]
	}
	Classy::todo $object _filter
}

Classy::ListBox method delete {args} {
	private $object options
	set items [eval {$object.list get} $args]
	uplevel #0 $object.list delete $args
	if {![string_equal [get options(-listvariable) ""] ""]} {
		upvar #0 $options(-listvariable) listvar
	} else {
		upvar #0 [privatevar $object options(-content)] listvar
	}
	if {![info exists listvar]} {set listvar {}}
	if {![string_equal [get options(-valuesvariable) ""] ""]} {
		upvar #0 $options(-valuesvariable) valuesvar
	} else {
		upvar #0 [privatevar $object options(-values)] valuesvar
	}
	foreach item $items {
		set pos [lsearch $listvar $item]
		list_pop listvar $pos
		if {[info exists valuesvar]} {
			list_pop valuesvar $pos
		}
	}
}

Classy::ListBox method command {} {
	private $object options
	set command [get options(-command) ""]
	if {"$command" != ""} {	
		uplevel #0 $command [list [$object get]]
	}
}

Classy::ListBox method _setvar {} {
	private $object options
	if {![string equal $options(-selvariable) ""]} {
		upvar #0 $options(-selvariable) value
		set temp [$object get]
		if {![info exists value] || ![string equal $value $temp]} {
			set value $temp
		}
	}
}

Classy::ListBox method _traceselvar {name1 name2 op} {
	private $object options
	upvar ::$options(-selvariable) value
	eval {$object set} $value
}

Classy::ListBox method _tracevaluesvar {name1 name2 op} {
	private $object options
	upvar ::$options(-valuesvariable) value
	$object configure -values $value
}

Classy::ListBox method _fulllist {args} {
	private $object options
	if {$options(-listvariable) eq ""} {
		return $options(-content)
	} else {
		return [get ::$options(-listvariable)]
	}
}

Classy::ListBox method _redraw {} {
	private $object options
	destroy $object.label
	destroy $object.filter
	if {$options(-filtervariable) ne ""} {
		set label $options(-label)
		if {$label eq ""} {set label Filter}
		Classy::Entry $object.filter -textvariable $options(-filtervariable) -combosize 10 -label Filter
		grid $object.filter -column 0 -row 0 -columnspan 2 -sticky nwse
		$object.list configure -listvariable [privatevar $object listvar]
	} else {
		$object.list configure -listvariable $options(-listvariable)
		if {$options(-label) ne ""} {
			label $object.label -text $options(-label)
			grid $object.label -column 0 -row 0 -columnspan 2 -sticky nwse
		}
	}
	Classy::todo $object _filter
}

Classy::ListBox method _filter {args} {
	private $object options listvar
	if {$options(-filtervariable) eq ""} {
		set filter {}
	} else {
		set filter [get ::$options(-filtervariable) ""]
	}
	set fulllist [$object _fulllist]
	if {[get filter ""] eq ""} {
		set listvar $fulllist
	} else {
		set poss [list_find -regexp $fulllist $filter]
		set listvar [list_sub $fulllist $poss]
	}
	$object selection clear 0 end
}

Classy::ListBox method curselection {{values 0}} {
	private $object selection
	if {$values} {
		return [list_sub [$object get 0 end] [$object.list curselection]]
	} else {
		return [$object.list curselection]
	}
}

Classy::ListBox method see {{index {}}} {
	private $object data
	if {[catch {$object index $index} okindex]} {
		set okindex [lsearch -exact [$object get 0 end] $index]
	}
	if {$okindex == -1} {error "element \"$index\" not in listbox"}
	$object.list see $okindex
}

Classy::ListBox method _updown {dir} {
	private $object options
	set docmd 0
	if {$options(-endcommand) ne ""} {
		set pos [expr {[$object.list index active]+$dir}]
		if {$dir > 0} {
			set len [$object.list index end]
			if {$pos >= $len} {
				set docmd 1
			}
		} elseif {$pos < 0} {
			set docmd 1
		}
	}
	if {$docmd} {
		uplevel #0 $options(-endcommand) $dir
	} else {
		tk::ListboxUpDown $object.list $dir
	}
}
