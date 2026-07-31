#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::OptionMenu
# ----------------------------------------------------------------------
#doc OptionMenu title {
#OptionMenu
#} index {
# New widgets
#} shortdescr {
# select between different values using a menu
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates an optionmenu, a widget in which the user can select between
# different values using a menu.
#}
#doc {OptionMenu options} h2 {
#	OptionMenu specific options
#}
#doc {OptionMenu command} h2 {
#	OptionMenu specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::OptionMenu

Classy::OptionMenu method init {args} {
	private $object var
	super init menubutton $object -text "" -menu $object.menu -anchor c
	set relief [option get $object relief Relief]
	if {[string equal $relief ""]} {set relief raised}
	set indicatoron [option get $object indicatorOn IndicatorOn]
	if {[string equal $indicatoron ""]} {set indicatoron 1}
	$object configure -relief $relief -indicatoron $indicatoron
	menu $object.menu -tearoff no
	
	# REM Create bindings
	# -------------------
	bind $object <<Action>> {
		if {$tk::Priv(inMenubutton) != ""} {
			tk::MbPost $tk::Priv(inMenubutton) %X %Y
		}
	}

	# REM Configure initial arguments
	# -------------------------------
	set var [privatevar $object textvariable]
	trace variable ::$var w [list $object _trace]
	if {"$args" != ""} {eval $object configure $args}
	$object _trace $var {} w
	return $object
}

Classy::OptionMenu method destroy {} {
	private $object options var
	trace vdelete ::$var w [list $object _trace]
	if {![string_equal [get options(-listvariable) ""] ""]} {
		trace vdelete ::$options(-listvariable) w [list $object _trace_list]
	}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::OptionMenu addoption -textvariable {textVariable TextVariable {}} {
	private $object options var
	catch {trace vdelete ::$var w [list $object _trace]}
	set var $value
	trace variable ::$var w [list $object _trace]
	set ::$var [get ::$var ""]
}

#doc {OptionMenu options -images} option {-images images Images} descr {
# This option can contain a list of images that will be displayed instead of text.
#}
Classy::OptionMenu addoption -images {images Images {}} {
	Classy::todo $object _mkmenu
}

#doc {OptionMenu options -command} option {-command command Command} descr {
#}
Classy::OptionMenu addoption -command {command Command {}}

#doc {OptionMenu options -list} option {-list list List} descr {
#}
Classy::OptionMenu addoption -list {list List {}} {
	Classy::todo $object _mkmenu
}

#doc {OptionMenu options -label} option {-label label Label} descr {
#}
Classy::OptionMenu addoption -label {label Label {}} {
	$object configure -text $value
}

#doc {OptionMenu options -listvariable} option {-listvariable listVariable ListVariable} descr {
#}
Classy::OptionMenu addoption -listvariable {listVariable ListVariable {}} {
	private $object options
	if {![string_equal [get options(-listvariable) ""] ""]} {
		trace vdelete ::$options(-listvariable) w [list $object _trace_list]
	}
	if {![string_equal $value ""]} {
		catch {$object configure -list [get ::$value]}
		trace variable ::$value w [list $object _trace_list]
	}
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::OptionMenu chainallmethods {$object} menubutton

Classy::OptionMenu method _mkmenu {} {
	private $object options var
	$object.menu delete 0 end
	if ![llength $options(-images)] {
		foreach val $options(-list) {
			$object.menu add command -label $val -command [varsubst {object val} {
				set [getprivate $object var] $val
				$object command
			}]
		}
	} else {
		foreach val $options(-list) image $options(-images) {
			$object.menu add command -image $image -command [varsubst {object val image} {
				set [getprivate $object var] $val
				$object configure -image $image
				$object command
			}]
		}
	}
}

Classy::OptionMenu method _trace {name1 name2 op} {
	private $object options var
	upvar ::$var value
	if {![info exists value]} {set value [lindex $options(-list) 0]}
	set pos [lsearch -exact $options(-list) $value]
	if {$options(-label) eq ""} {
		if ![llength $options(-images)] {
			$object configure -text $value
		} else {
			if {$pos == -1} return
			$object configure -image [lindex $options(-images) $pos]
		}
	}
}

Classy::OptionMenu method _trace_list {name1 name2 op} {
	private $object options var
	upvar ::$options(-listvariable) value
	$object configure -list $value
}

#doc {OptionMenu command get} cmd {
#pathname get 
#} descr {
#}
Classy::OptionMenu method get {} {
	private $object var
	get ::$var
}

#doc {OptionMenu command nocmdset} cmd {
#pathname nocmdset value
#} descr {
#}
Classy::OptionMenu method nocmdset {value} {
	private $object options var
	set list [getprivate $object options(-list)]
	set pos [lsearch -exact $list $value]
	if {$pos != -1} {
		set ::$var $value
	}
}

#doc {OptionMenu command set} cmd {
#pathname set value
#} descr {
#}
Classy::OptionMenu method set {value} {
	$object nocmdset $value
	$object command
}

#doc {OptionMenu command command} cmd {
#pathname command 
#} descr {
#}
Classy::OptionMenu method command {} {
	private $object options
	set cmd [get options(-command) ""]
	if [string length $cmd] {
		uplevel #0 $cmd [list [$object get]]
	}
}
