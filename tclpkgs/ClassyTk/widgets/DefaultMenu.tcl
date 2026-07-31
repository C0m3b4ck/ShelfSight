#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::DefaultMenu
# ----------------------------------------------------------------------
#doc DefaultMenu title {
#DefaultMenu
#} index {
# Common tools
#} shortdescr {
# button with menu to select from user definable defaults
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a button which pops up a <a href="SelectDialog.html">selection 
# dialog</a> from which the user can choose between different
# default values, or add new ones.
#}
#doc {DefaultMenu options} h2 {
#	DefaultMenu specific options
#} descr {
#}
#doc {DefaultMenu command} h2 {
#	DefaultMenu specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::DefaultMenu

bind Classy::DefaultMenu <<Action-ButtonPress>> "%W menu"
bind Classy::DefaultMenu <Any-ButtonRelease> "%W _action"
bind Classy::DefaultMenu <Motion> "%W _motion %X %Y"

Classy::DefaultMenu method init {args} {
	super init button $object -relief raised -image [::Classy::geticon default.xbm] -takefocus 0
	bindtags $object [lreplace [bindtags $object] 1 0 Classy::DefaultMenu]
	# REM Evaluate arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {DefaultMenu options -command} option {-command command Command} descr {
# This command will be executed when the user selects a value from
# the DefaultMenu.
#}
Classy::DefaultMenu addoption -command {command Command {}}

#doc {DefaultMenu options -getcommand} option {-getcommand getCommand GetCommand} descr {
# This command will be executed upon invoking the menu. The return value 
# will be placed in the Add entry. This value can be added easily to
# the list of default values to choose from
#}
Classy::DefaultMenu addoption -getcommand {getCommand GetCommand {}}

#doc {DefaultMenu options -key} option {-key key Key} descr {
# key by which the default system will be queried and changed
#}
Classy::DefaultMenu addoption -key {key Key {}}


# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::DefaultMenu chainallmethods {$object} button

Classy::DefaultMenu method conf {args} {
	eval $object configure $args
}

#doc {DefaultMenu command get} cmd {
#pathname get 
#} descr {
# get the currently selected value.
#}
Classy::DefaultMenu method get {} {
	.classy__.defaultmenu get
}

Classy::DefaultMenu method _init {} {
	set w .classy__.defaultmenu
	catch {destroy $w}
	if ![winfo exists $w] {
		Classy::SelectDialog $w -cache 1 -title "Select Value" \
			-command "#" -addcommand "#" -deletecommand "#" -addvariable [privatevar $object add]
	}
	after cancel "$w place"
	wm geometry $w +1000000+1000000
	wm withdraw $w
}

#doc {DefaultMenu command menu} cmd {
#pathname menu 
#} descr {
# invoke the DefaultMenu menu
#}
Classy::DefaultMenu method menu {} {
	private $object posted focus add options
	set w .classy__.defaultmenu
	if ![winfo exists $w] {$object _init}
	set focus [focus -displayof $object]
	set w .classy__.defaultmenu
	$w configure -command "$object removemenu" \
		-addcommand "$object add" \
		-deletecommand "$object remove" \
		-closecommand "$object removemenu"
	$w fill [Classy::Default get app $options(-key)]
	set add [eval $options(-getcommand)]
	set posted 0
	.classy__.defaultmenu.options.list activate 0
	focus .classy__.defaultmenu.options.list
	after idle "$object place"
}

#doc {DefaultMenu command add} cmd {
#pathname add value
#} descr {
# add $value to the associated defaults list
#}
Classy::DefaultMenu method add {val} {
	Classy::Default add app [getprivate $object options(-key)] $val
	return [list $val 0]
}


#doc {DefaultMenu command remove} cmd {
#pathname remove value
#} descr {
# remove $value from the associated defaults list
#}
Classy::DefaultMenu method remove {val} {
	Classy::Default remove app [getprivate $object options(-key)] $val
}

#doc {DefaultMenu command removemenu} cmd {
#pathname removemenu 
#} descr {
# remove the DefaultMenu menu from the screen
#}
Classy::DefaultMenu method removemenu {args} {
	private $object focus options
	focus $focus
	wm withdraw .classy__.defaultmenu
	.classy__.defaultmenu hide
	Classy::Default set geometry $object [Classy::Default get geometry .classy__.defaultmenu]
	if {("[get options(-command) ""]" != "") && ("$args" != "")} {
		uplevel 1 [get options(-command) ""] $args
	}
}

#doc {DefaultMenu command place} cmd {
#pathname place 
#} descr {
#}
Classy::DefaultMenu method place {} {
	Classy::update Classy::DefaultMenu-place idletasks
	set w [winfo reqwidth .classy__.defaultmenu]
	set h [winfo reqheight .classy__.defaultmenu]
	wm minsize .classy__.defaultmenu $w $h
	set geom [Classy::Default get geometry $object]
	if [regexp {^([0-9]+)x([0-9]+)} $geom temp xs ys] {
		if {$xs>$w} {set w $xs}
		if {$ys>$h} {set h $ys}
	}
	wm geometry .classy__.defaultmenu ${w}x${h}
	# position
	set maxx [expr [winfo vrootwidth .classy__.defaultmenu]-$w]
	set maxy [expr [winfo vrootheight .classy__.defaultmenu]-$h]
	set x [expr {[winfo rootx $object]-[winfo width .classy__.defaultmenu]}]
	set y [winfo rooty $object]
	if {$x<0} {set x 0}
	if {$y<0} {set y 0}
	if {$x>$maxx} {set x $maxx}
	if {$y>$maxy} {set y $maxy}
	wm geometry .classy__.defaultmenu +$x+$y
	wm deiconify .classy__.defaultmenu
	raise .classy__.defaultmenu
	wm geometry .classy__.defaultmenu +$x+$y
}

Classy::DefaultMenu method _action {} {
	private $object posted
	set w .classy__.defaultmenu
	if {"$posted"==".classy__.defaultmenu.options.list.list"} {
		$w invoke go
		$object removemenu
	} elseif {"$posted"=="$w.actions.close"} {
		$w invoke close
	} elseif {"$posted"=="$w.actions.add"} {
		$w invoke add
	}
}

Classy::DefaultMenu method _motion {X Y} {
	private $object posted
	set posted [winfo containing $X $Y]
	if {"$posted"==".classy__.defaultmenu.options.list.list"} {
		set x [expr $X-[winfo rootx .classy__.defaultmenu.options]]
		set y [expr $Y-[winfo rooty .classy__.defaultmenu.options]]
		set index [.classy__.defaultmenu index @$x,$y]
		.classy__.defaultmenu activate $index
		.classy__.defaultmenu set $index
	}
}


