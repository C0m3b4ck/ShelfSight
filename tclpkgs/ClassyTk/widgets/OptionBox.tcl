#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::OptionBox
# ----------------------------------------------------------------------
#doc OptionBox title {
#OptionBox
#} index {
# New widgets
#} shortdescr {
# select between different values
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates an optionbox, a widget in which the user can select between
# different values using radiobuttons.
#}
#doc {OptionBox options} h2 {
#	OptionBox specific options
#}
#doc {OptionBox command} h2 {
#	OptionBox specific methods
#}

option add *Classy::OptionBox.relief raised widgetDefault
#option add *Classy::OptionBox.label.anchor w widgetDefault
option add *Classy::OptionBox.label.relief flat widgetDefault
option add *Classy::OptionBox.box.relief flat widgetDefault
option add *Classy::OptionBox.box.highlightThickness 0 widgetDefault

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::OptionBox

Classy::OptionBox method init {args} {
	super init frame $object -highlightthickness 0 -class Classy::OptionBox
	label $object.label -text ""
	frame $object.box
	pack $object.label -side left
	pack $object.box -side right -fill x -expand yes
	
	# REM Initialise variables
	# ------------------------
	private $object var num
	set num 1
	set var {}
	
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	catch {$object.label configure -bg [Classy::realcolor [getprivate $object options(-labelbackground)]]}
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {OptionBox options -label} option {-label label Label} descr {
#}
Classy::OptionBox addoption -label {label Label {}} {
	$object.label configure -text $value
}

#doc {OptionBox options -labelbackground} option {-labelbackground labelBackground LabelBackground} descr {
# background color of label
#}
Classy::OptionBox addoption -labelbackground {labelBackground LabelBackground Background} {
	catch {$object.label configure -bg [Classy::realcolor $value]}
}

#doc {OptionBox options -orient} option {-orient orient Orient} descr {
# must be vertical or horizontal
#}
Classy::OptionBox addoption -orient {orient Orient horizontal} {
	if {"$value" == "vertical"} {
		set children [winfo children $object.box]
		pack $object.label -side top -fill x -expand yes
		pack $object.box -side bottom -fill x -expand yes
		foreach child $children {
			pack $child -side top -fill x
		}
	} elseif {"$value" == "stacked"} {
		set children [winfo children $object.box]
		pack $object.label -side top -fill both
		pack $object.box -side right -fill x -expand yes
		foreach child $children {
			pack $child -side left -fill x
		}
	} else {
		set children [winfo children $object.box]
		pack $object.label -side left -fill both
		pack $object.box -side right -fill x -expand yes
		foreach child $children {
			pack $child -side left -fill x
		}
	}
}

#doc {OptionBox options -variable} option {-variable variable Variable} descr {
#}
Classy::OptionBox addoption -variable {variable Variable {}} {
	if {"$value" == ""} {
		set newval [privatevar $object var]
	} else {
		set newval $value
	}
	foreach radiobtn [winfo children $object.box] {
		$radiobtn configure -variable $newval
	}
	
}

#doc {OptionBox options -command} option {-command command Command} descr {
# associate a command with the OptionBox.
#}
Classy::OptionBox addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {OptionBox command add} cmd {
#pathname add item text ?option value ...?
#} descr {
#}
Classy::OptionBox method add {item text args} {
	private $object options num
	if {"$options(-variable)" == ""} {
		set varname [privatevar $object var]
	} else {
		set varname $options(-variable)
	}
	incr num
	radiobutton $object.box.b$num -relief flat -anchor w\
		-variable $varname -text $text -value $item -command [list $object _command $object.box.b$num]
	if {"$options(-orient)" == "vertical"} {
		pack $object.box.b$num -side top -fill x
	} else {
		pack $object.box.b$num -side left -fill x
	}
	if {"$args" != ""} {eval $object.box.b$num configure $args}
	return $object.box.b$num
}

#doc {OptionBox command set} cmd {
#pathname set item
#} descr {
#}
Classy::OptionBox method set {item} {
	private $object options num
	if {"$options(-variable)" == ""} {
		set varname [privatevar $object var]
	} else {
		set varname $options(-variable)
	}
	uplevel #0 [list set $varname $item]
}

#doc {OptionBox command get} cmd {
#pathname get 
#} descr {
#}
Classy::OptionBox method get {} {
	private $object options
	if {"$options(-variable)" == ""} {
		set varname [privatevar $object var]
	} else {
		set varname $options(-variable)
	}
	if ![catch {set result [set ::$varname]} result] {
		return $result
	} else {
		return {}
	}
}

#doc {OptionBox command items} cmd {
#pathname items 
#} descr {
#}
Classy::OptionBox method items {} {
	set list ""
	foreach b [winfo children $object.box] {
		lappend list [$b cget -value]
	}
	return $list
}

#doc {OptionBox command button} cmd {
#pathname button item
#} descr {
#}
Classy::OptionBox method button {item} {
	foreach b [winfo children $object.box] {
		if {"[$b cget -value]" == "$item"} {return $b}
	}
	return ""
}

Classy::OptionBox method _command {w} {
	private $object options
	if [llength [get options(-command) ""]] {
		uplevel #0 [get options(-command) ""] [$w cget -value]
	}
}

# Classy::selectoption -title Test -initialvalue 2 {{First choice} 1 {Second choice} 2}
proc Classy::selectoption {args} {
# set args {{First choice} 1 {Second choice} 2}
	set opt(-initialvalue) ""
	set opt(-title) "Select option"
	cmd_args "Classy::selectoption" {
		-initialvalue {any "Initial selection" {}}
		-title {any "Title of the dialog" "Select option"}
	} {list} $args
	if {$opt(-initialvalue) eq ""} {
		set ::Classy::selectoption [lindex $list 1]
	} else {
		set ::Classy::selectoption $opt(-initialvalue)
	}
	set w .classy__.optiondialog
	destroy $w
	Classy::Dialog $w -title $opt(-title) -keepgeometry 0 -resize {0 0} -closecommand {destroy .classy__.optiondialog ; error "nothing selected"}
	$w add go OK {} default
	set w $w.options
	Classy::OptionBox $w.optionbox -label "$opt(-title)" -orient vertical -variable ::Classy::selectoption
	foreach {text value} $list {
		$w.optionbox add $value $text
	}
	pack $w.optionbox -fill x
	tkwait window .classy__.optiondialog
	return $::Classy::selectoption
}
