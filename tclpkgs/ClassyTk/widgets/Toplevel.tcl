#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Toplevel
# ----------------------------------------------------------------------
#doc Toplevel title {
#Toplevel
#} index {
# Tk improvements
#} shortdescr {
# toplevel with geometry management and destroy command
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# Toplevel produces "intelligent" toplevels. They have a simple option to
#make them resizable or not. They automatically assume a reasonable
#minimum size based on their content (The Toplevel will be placed on the
#screen and its size calculated at the first idle moment after Toplevel 
#creation. The Toplevel will place itself so that the mouse pointer is 
#is positioned over it, without being place partly out of the screen.
#If it is resized, it can remember its size for the next display.
#}
#doc {Toplevel options} h2 {
#	Toplevel specific options
#}
#doc {Toplevel command} h2 {
#	Toplevel specific methods
#}

option add *Classy::Toplevel.HighlightThickness 0 widgetDefault
if {$tcl_platform(platform) ne "windows"} {
	bind Classy::Toplevel <Configure> {Classy::todo %W checksize}
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Toplevel


Classy::Toplevel method init {args} {
	# REM Create object
	# -----------------
	super init toplevel
	set placement [option get $object dialogPlacement DialogPlacement]
	switch $placement {
		smart {
			wm geometry $object +1000000+1000000
			wm positionfrom $object program
			wm withdraw $object
		}
		default {
			wm withdraw $object
		}
	}
	wm group $object .
	wm protocol $object WM_DELETE_WINDOW [list $object destroy]
	# REM Create bindings
	# -------------------
	# REM Initialise variables
	# ------------------------
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::todoprio 100 $object place
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------
# REM Adding options

#doc {Toplevel options -destroycommand} option {-destroycommand ? ?} descr {
#commands invoked when destroying the toplevel
#}
Classy::Toplevel addoption -destroycommand {destroyCommand DestroyCommand {}}

#doc {Toplevel options -keepgeometry} option {-keepgeometry keepGeometry KeepGeometry} descr {
#remember size of Toplevel for next creation
#}
Classy::Toplevel addoption -keepgeometry {keepGeometry KeepGeometry 1} {
	if {"$value" eq "all"} {
		set value 1
	} else {
		set value [true $value]
	}
}

#doc {Toplevel options -keepposition} option {-keepposition keepPosition KeepPosition} descr {
#remember size of Toplevel for next creation
#}
Classy::Toplevel addoption -position {position Position pointer} {
	if {![inlist {previous pointer middle} $value]} {
		error "wrong option \"$value\" for -position, must be one of: previous, pointer, middle"
	}
}

#doc {Toplevel options -cache} option {-cache cache Cache} descr {
#hide the Toplevel instead of destroying it when it is closed
#}
Classy::Toplevel addoption -cache {cache Cache 0} {
	set value [true $value]
}

#doc {Toplevel options -title} option {-title Title Title} descr {
#}
Classy::Toplevel addoption -title {title Title "Toplevel"} {
	wm title $object $value
	return $value
}

#doc {Toplevel options -resize} option {-resize resize Resize} descr {
#list of 2 values determining whether the Toplevel is resizable in x
#and y direction. If they are 0, the window is not resizable in that direction.
#When 1 it is resizable, with the requested size being the minimum size.
#When more than 2, the window is resizable, with the minimum size being 
#the value given
#}
Classy::Toplevel addoption -resize {resize Resize {1 1}} {
	set x [lindex $value 0]
	set y [lindex $value 1]
	set minw [winfo reqwidth $object]
	set minh [winfo reqheight $object]
	if {$x>1} {set minw $x ; set x 1}
	if {$y>1} {set minh $y ; set y 1}
	wm resizable $object $x $y
	wm minsize $object $minw $minh
	Classy::todoprio 100 $object place
	return $value
}

#doc {Toplevel options -autoraise} option {-autoraise autoRaise AutoRaise} descr {
#}
Classy::Toplevel addoption -autoraise {autoRaise AutoRaise 0} {
	if $value {
		raise $object
	}
	return $value
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {Toplevel command hide} cmd {
#pathname hide 
#} descr {
#hide the Toplevel
#}
Classy::Toplevel method hide {} {
	if {[winfo ismapped $object]} {
		Classy::Default set geometry $object [winfo geometry $object]
		wm withdraw $object
	}
}

#doc {Toplevel command place} cmd {
#pathname place 
#} descr {
#display the Toplevel in a proper position, size, ...
#}
Classy::Toplevel method place {} {
	private $object options
	set error [catch {
	global tcl_platform
	set placement [option get $object dialogPlacement DialogPlacement]
	Classy::update Classy::Toplevel-place idletasks
	set keeppos 0
	foreach {w h minw minh} [$object checksize] break
	set keepgeometry $options(-keepgeometry)
	set position $options(-position)
	if {$keepgeometry} {
		set geom [Classy::Default get geometry $object]
		if {[regexp {^([-0-9]+)x([-0-9]+)\+([-0-9]+)\+([-0-9]+)} $geom temp prevw prevh prevx prevy]} {
			if {$keepgeometry} {
				if {$prevw > $minw} {set w $prevw} else {set w $minw}
				if {$prevh > $minh} {set h $prevh} else {set h $minh}
			}
		}
	}
	set px [winfo pointerx .]
	set py [winfo pointery .]
	# find borders
	set maxx [winfo screenwidth $object]
	set maxy [winfo screenheight $object]
	set minx 0
	set miny 0
	set windowingsystem [tk windowingsystem]
	if {$tcl_platform(platform) eq "windows"} {
		foreach {tx1 ty1 tx2 ty2} [Classy::TaskbarPos] break
		if {$tx1 > 0} {
			set maxx $tx1
		} elseif {$tx2 < $maxx} {
			set minx $tx2
		} elseif {$ty1 > 0} {
			set maxy $ty1
		} elseif {$ty2 < $maxy} {
			set miny $ty2
		}
	} elseif {$windowingsystem eq "macintosh" || $windowingsystem eq "aqua"} {
		set miny 20
	}
	# set position (not taking into account borders)
	foreach {borderx bordery} [Classy::geometry_borders] break
	if {$position eq "previous"} {
		if {[info exists prevx] && [info exists prevy]} {
			set x $prevx
			set y $prevy
		} else {
			set x [expr {$px- $w/2}]
			set y [expr {$py - $h/2}]
		}
	} elseif {$position eq "pointer"} {
		set x [expr {$px- $w/2}]
		set y [expr {$py - $h/2}]
	} else {
		set x [expr {$maxx/2 - $w/2}]
		set y [expr {$maxy/2 - $h/2}]
	}
	if {$x < $minx} {set x $minx} elseif {$x > $maxx} {set x $maxx}
	if {$y < $miny} {set y $miny} elseif {$y > $maxy} {set y $maxy}
	# map, check borders, and take borders into account
	if {$w < 10} {set w 10}
	if {$h < 10} {set h 10}
	set x [expr {$x-$borderx}]
	set y [expr {$y-$bordery}]
	set maxx [expr {$maxx-$w-2*$borderx}]
	set maxy [expr {$maxy-$h-$bordery-$borderx}]
	if {$x < $minx} {set x $minx} elseif {$x > $maxx} {set x $maxx}
	if {$y < $miny} {set y $miny} elseif {$y > $maxy} {set y $maxy}
	switch $placement {
		smart {
			wm geometry $object ${w}x${h}+$x+$y
			if {![winfo viewable $object]} {
				wm deiconify $object
			}
			raise $object
		}
		win {
			wm deiconify $object
			wm geometry $object ${w}x${h}+$x+$y
			raise $object
		}
		newsmart {
			wm geometry $object ${w}x${h}+$x+$y
			wm deiconify $object
			wm geometry $object ${w}x${h}+$x+$y
			raise $object
		}
		Tk {
			wm deiconify $object
			wm geometry $object ${w}x${h}
			raise $object
		}
		default {
			wm geometry $object ${w}x${h}+$x+$y
			if {![winfo viewable $object]} {
				wm deiconify $object
			}
			raise $object
		}
	}
	} info]
	if {$error} {
		puts $info
		error $info
		return
	}
}

#doc {Toplevel command resize} cmd {
#pathname resize 
#} descr {
#}
Classy::Toplevel method resize {} {
	wm minsize $object [winfo reqwidth $object] [winfo reqheight $object]
	wm geometry $object [winfo reqwidth $object]x[winfo reqheight $object]
}

Classy::Toplevel method checksize {} {
	private $object options
	bind Classy::Toplevel <Configure> {}
	set resize $options(-resize)
	set grid [wm grid $object]
	if {"$grid" == ""} {
		set minw [winfo reqwidth $object]
		set minh [winfo reqheight $object]
	} else {
		set minw [lindex $grid 0]
		set minh [lindex $grid 1]
	}
	set w $minw
	set h $minh
	set rx [lindex $resize 0]
	set ry [lindex $resize 1]
	if {$rx>1} {set minw $rx ; set rx 1}
	if {$ry>1} {set minh $ry ; set ry 1}
	wm resizable $object $rx $ry
	wm minsize $object $minw $minh
	set curw [winfo width $object]
	set curh [winfo height $object]
	if {($curw < $minw)||($curh < $minh)} {
		if {$curw < $minw} {set curw $minw}
		if {$curh < $minh} {set curh $minh}
		wm geometry $object ${curw}x$curh
	}
	Classy::update Classy::Toplevel-checksize
	if {$::tcl_platform(platform) ne "windows"} {
		bind Classy::Toplevel <Configure> {Classy::todo %W checksize}
	}
	return [list $w $h $minw $minh]
}

# ------------------------------------------------------------------
#  destructor
# ------------------------------------------------------------------

#doc {Toplevel command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::Toplevel method destroy {} {
	private $object options
	if ![winfo ismapped $object] return
	if {"[wm grid $object]" == ""} {
		set geom [winfo geometry $object]
	} else {
		set geom [wm geometry $object]
	}
	Classy::Default set geometry $object $geom
	uplevel #0 $options(-destroycommand)
}

