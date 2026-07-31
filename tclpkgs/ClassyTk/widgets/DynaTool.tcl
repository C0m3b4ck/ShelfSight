#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::DynaTool
# ----------------------------------------------------------------------
#doc DynaTool title {
#DynaTool
#} index {
# Common tools
#} shortdescr {
# Toolbar widget: nice little buttons in a row
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# The DynaTool widgets are toolbars, for which the contents are managed by
# the DynaTool class in an easy and dynamic way.
# DynaTool can handle several tooltypes.
#<p>
# Each tooltype is defined by a <a href="../classy_dynatool.html">definition in a simple format</a>. 
# DynaTool can create one or more toolbars for each
# tooltype. When the definition of the tooltype is changed
# all toolbars of that type will be changed accordingly.
#<p>
# Toolbar definitions for tooltype are usually controlled from the
# Toolbars part of the <a href="../classy_configure.html">configuration 
# system</a>.
#<p>
# A toolbar managed by DynaTool can control several widgets: The commands 
# associated with the toolbar can include a %W, that on invocation is
# changed to the current cmdw (command widget). The cmdw of a toolbar can be
# changed at any time.
#}

option add *Classy::DynaTool.HighlightThickness 0 widgetDefault
if {[string equal $tcl_platform(platform) windows]} {
	option add *Classy::DynaTool.Relief groove widgetDefault
	option add *Classy::DynaTool.BorderWidth 2 widgetDefault
	option add *Classy::ToolSeparator.width 2 widgetDefault
	option add *Classy::ToolSeparator.height 2 widgetDefault
} else {
	option add *Classy::DynaTool.Relief raised widgetDefault
	option add *Classy::DynaTool.BorderWidth 1 widgetDefault
	option add *Classy::ToolSeparator.width 4 widgetDefault
	option add *Classy::ToolSeparator.height 4 widgetDefault
}

option add *Classy::ToolSeparator.highLightThickness 0 widgetDefault
option add *Classy::ToolSeparator.BorderWidth 1 widgetDefault
option add *Classy::ToolSeparator.Relief sunken widgetDefault

option add *Classy::DynaTool.Button.padY 0 widgetDefault
option add *Classy::DynaTool.Button.relief flat widgetDefault
option add *Classy::DynaTool.Checkbutton.padY 0 widgetDefault
option add *Classy::DynaTool.Checkbutton.OffRelief flat widgetDefault
option add *Classy::DynaTool.Radiobutton.padY 0 widgetDefault
option add *Classy::DynaTool.Radiobutton.OffRelief flat widgetDefault
option add *Classy::DynaTool.Menubutton.padY 0 widgetDefault
option add *Classy::DynaTool.Menubutton.Relief flat widgetDefault
option add *Classy::DynaTool.Menubutton.IndicatorOn 0 widgetDefault
option add *Classy::DynaTool.*.highLightThickness 1 widgetDefault

proc Classy::DynaTool_Enter {w} {
	catch {
		set ::Classy::dynatool_hl [$w cget -highlightbackground]
		$w configure -highlightbackground [$w cget -highlightcolor]
		switch [winfo class $w] {
			Button - Menubutton {
				$w configure -relief raised
			}
			Radiobutton - Checkbutton {
				$w configure -offrelief raised -relief raised
			}
		}
	}
}

proc Classy::DynaTool_Leave {w} {
	catch {
		$w configure -highlightbackground $::Classy::dynatool_hl
		switch [winfo class $w] {
			Button - Menubutton {
				$w configure -relief flat
			}
			Radiobutton - Checkbutton {
				if {[$w cget -indicatoron]} {
					$w configure -offrelief flat -relief flat
				} else {
					$w configure -offrelief flat -relief sunken
				}
			}
		}
	}
}

bind Classy::DynaTool <Configure> "Classy::todo %W redraw"
bind Classy::DynaToolEntry <Enter> "Classy::DynaTool_Enter %W"
bind Classy::DynaToolEntry <Leave> "Classy::DynaTool_Leave %W"

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::DynaTool

Classy::DynaTool method init {args} {
	# REM Create object
	# -----------------
	super init
	$object configure
	# REM Create bindings
	# -------------------
	# REM Initialise variables
	# ------------------------
	private $object data
	unset -nocomplain data(slaves)
	set data(type) ""
	set data(cmdw) ""
	set data(checks) ""
	# REM Configure initial arguments
	# -------------------------------
	.classy__.dummyb configure -text Hello
	if {"$args" != ""} {eval $object configure $args}
	if {![get data(nodisplay) 0]} {
		if {[$object cget -orient] eq "horizontal"} {
			set w [expr {2*[winfo reqwidth .classy__.dummyb]-5}]
			set h [expr {[winfo reqheight .classy__.dummyb]-5}]
		} else {
			set w [expr {[winfo reqwidth .classy__.dummyb]-5}]
			set h [expr {2*[winfo reqheight .classy__.dummyb]-5}]
		}
		[Classy::window $object] configure -width $w -height $h
	}
	Classy::todo $object redraw
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::DynaTool chainoptions {$object}

#doc {DynaTool options -type} option {-type type Type} descr {
# sets the type of the tool
#}
Classy::DynaTool addoption -type {type Type {}} {
	private $class tooldata
	private $object options
	if {![info exists tooldata($value)]} {
		set file [file join $::Classy::dira(appuser) toolbar $value]
		set tooldata($value) [file_read $file]
	}
	set error [catch {$object _create $value $tooldata($value)} result]
	if {$error} {
		set errorInfo $::errorInfo
		foreach level {appdef user def} {
			set tooldata($value) [Classy::Config get toolbar $value $level]
			set error2 [catch {$object _create $value $tooldata($value)}]
			if {!$error2} break
		}
	}
#	if {$error} {error "$result"}
	if {$error} {return -code error -errorinfo $errorInfo "$result"}
	set options(-type) $value
}

Classy::DynaTool addoption -cmdw {cmdw Cmdw {}} {
	$object cmdw $value
}

Classy::DynaTool addoption -width {width Width 0} {
	[Classy::window $object] configure -width $value
	Classy::todo $object redraw
}

Classy::DynaTool addoption -height {height Height 0} {
	[Classy::window $object] configure -height $value
	Classy::todo $object redraw
}

#doc {DynaTool options -orient} option {-orient orient Orient} descr {
# sets the orientation of the tool; can be horizontal or vertical
#}
Classy::DynaTool addoption -orient {orient Orient horizontal} {
	if {![inlist {horizontal vertical} $value]} {error "wrong option \"$value\": must be horizontal or vertical"}
	Classy::todo $object redraw
}

#doc {DynaTool options -max} option {-max max Max} descr {
# sets the maximum number of lines (or columns) the buttonbar will take when wrapping
#}
Classy::DynaTool addoption -max {max Max {}} {
	if {[string length $value]} {
		if {![isint $value]} {error "-max value should be an integer or empty"}
	}
	Classy::todo $object redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

#doc {DynaTool define} cmd {
#pathname define tooltype ?data?
#} descr {
# set the <a href="../classy_dynatool.html">definition describing the tools</a> that will be generated 
# for $tooltype.
# If data is not given, the toolbar definition for $tooltype will be returned.
# Definition of toolbars is usually done in the
# <a href="../classy_configure.html">configuration system</a>.
# You will usually not invoke this method, as the definition of 
# tooltype that isn't managed yet will be automatically fetched and defined
# when creating a new toolbar.
#}
Classy::DynaTool classmethod define {tooltype {data {}}} {
	private $class tooldata keep
	if {[info exists tooldata($tooltype)]} {
		set keep $tooldata($tooltype)
	} else {
		unset -nocomplain keep
	}
	if {"$data" != ""} {
		set tooldata($tooltype) $data
		$class redraw $tooltype
	} else {
		return $tooldata($tooltype)
	}
}

#doc {DynaTool redraw} cmd {
#pathname redraw tooltype
#} descr {
# redraw toolbars of type $tooltype
#}
Classy::DynaTool classmethod redraw {tooltype} {
	private $class tooldata keep
	if {[catch {$class _refresh $tooltype} result]} {
		global errorInfo
		set error $errorInfo
		if {[info exists keep]} {
			set tooldata($tooltype) $keep
			$class _refresh $tooltype
			append result "\nRestored old tool"
		}
		error $result $error
	}
}

#doc {DynaTool types} cmd {
#pathname types ?pattern? 
#} descr {
#}
Classy::DynaTool classmethod types {{pattern *}} {
	private $class tooldata
	set list ""
	foreach dir $Classy::dirs {
		foreach tool [dirglob [file join $dir toolbar] *] {
			if {[string match $pattern $tool]} {
				list_addnew list $tool
			}
		}
	}
	foreach tool [array names ::Classy::configtoolbar] {
		if {[string match $pattern $tool]} {
			list_addnew list $tool
		}
	}
	foreach tool [array names tooldata $pattern] {
		if {[string match $pattern $tool]} {
			list_addnew list $tool
		}
	}
	return $list
}

#doc {DynaTool get} cmd {
#pathname get tooltype
#} descr {
# returns the definition of $tooltype
#}
Classy::DynaTool classmethod get {tooltype} {
	private $class tooldata
	return [join $tooldata($tooltype) "\n"]
}

#doc {DynaTool deletetool} cmd {
#pathname deletetool tool
#} descr {
# delete $tool managed by DynaTool
#}
Classy::DynaTool method destroy {} {
	private $object data
	unset -nocomplain tools($object)
	unset -nocomplain data(slaves)
	unset -nocomplain data(type)
	unset -nocomplain data(cmdw)
	unset -nocomplain data(checks)
}

#doc {DynaTool delete} cmd {
#pathname delete tooltype
#} descr {
# delete the definition and all toolbars of $tooltype
#}
Classy::DynaTool classmethod delete {tooltype} {
	private $class tooldata tools
	if {![info exists tooldata($tooltype)]} {
		error "Couldn't delete $tooltype; it is not a tooltype managed by $object."
	}
	if {[info exists tools($tooltype)]} {
		foreach tool $tools($tooltype) {
			destroy $tool
		}
		unset tools($tooltype)
	}
}

Classy::DynaTool classmethod _refresh {tooltype} {
	private $class tools
	set code 0
	set result ""
	if {[info exists tools($tooltype)]} {
		foreach tool $tools($tooltype) {
			if {[winfo exists $tool]} {
				set code [catch {$tool configure -type $tooltype} result]
			} else {
				set tools($tooltype) [list_remove tools($tooltype) $tool]
			}
		}
	}
	if $code {error $result}
	return $result
}

#doc {DynaTool cmdw} cmd {
#pathname cmdw tool {cmdw {}}
#} descr {
# change the current cmdw for $tool to $cmdw. If the cmdw argument is
# not given, the method returns the current cmdw for $tool.
#}
Classy::DynaTool method cmdw {{cmdw {}} {force 0}} {
	private $object data options
	if {"$cmdw"==""} {
		return $data(cmdw)
	} else {
		if {!$force && [info exists data(cmdw)]} {
			if {"$data(cmdw)"=="$cmdw"} {return $cmdw}
		}
		set data(cmdw) $cmdw
		if {[info exists data(checks)]} {
			if {[string length $cmdw]} {
				set command [string_change $data(checks) [list %% % %W $cmdw]]
				uplevel #0 $command
			}
		}
		set options(-cmdw) $cmdw
		return $cmdw
	}
}

#doc {DynaTool invoke} cmd {
#pathname invoke curtool index
#} descr {
# invoke the item given by $index in the tool
#}
Classy::DynaTool method invoke {index} {
	$object.b$index invoke
}

#doc {DynaTool reqwidth} cmd {
#pathname reqwidth tool
#} descr {
#}
Classy::DynaTool method reqwidth {} {
	private $object data options
	set x 0
	if {![info exists data(slaves)]} {return 0}
	if {[string_equal $options(-orient) horizontal]} {
		foreach slave $data(slaves) {
			incr x [expr {[winfo reqwidth $slave]}]
		}
		return [expr {$x+2*[$object cget -bd]+1}]
	} else {
		foreach slave $data(slaves) {
			set cx [winfo reqheight $slave]
			if {$cx > $x} {set x $cx}
		}
		return [expr {$x+2*[$object cget -bd]+1}]
	}
}

#doc {DynaTool reqheight} cmd {
#pathname reqheight tool
#} descr {
#}
Classy::DynaTool method reqheight {} {
	private $object data options
	set y 0
	if {![info exists data(slaves)]} {return 0}
	if {[string_equal $options(-orient) vertical]} {
		foreach slave $data(slaves) {
			incr y [winfo reqheight $slave]
		}
		return [expr {$y+2*[$object cget -bd]+1}]
	} else {
		foreach slave $data(slaves) {
			set cy [winfo reqheight $slave]
			if {$cy > $y} {set y $cy}
		}
		return [expr {$y+2*[$object cget -bd]+1}]
	}
}

Classy::DynaTool method rebind {keep} {
	bind $object <Configure> $keep
}

Classy::DynaTool method _create {value definition} {
	private $object data options
	private $class tooldata tools
	set prev $options(-type)
	if {[info exists tools($prev)]} {
		set tools($prev) [list_remove $tools($prev) $object]
	}
	list_addnew tools($value) $object
	set cmdw $data(cmdw)
	set num 0
	set data(checks) {}
	eval destroy [winfo children $object]
	unset -nocomplain data(slaves)
	set list {}
	foreach line [cmd_split $definition] {
		if {"[lindex $line 0]" == "if"} {
			if {[uplevel #0 [list expr [lindex $line 1]]]} {
				eval lappend list [cmd_split [lindex $line 2]]
			} else {
				eval lappend list [cmd_split [lindex $line 4]]
			}
		} else {
			lappend list $line
		}
	}
	if {[lsearch -regexp $list "^\[\t \]*nodisplay\[\t \]*\$"] != -1} {
		set data(nodisplay) 1
		[Classy::window $object] configure -height 1 -width 1
		return
	} else {
		set data(nodisplay) 0
	}
	foreach current $list {
		if {"$current" == ""} continue
		set type [list_shift current]
		incr num
		set key b$num
		set id [list_shift current]
		set help [list_shift current]
		if {"$type"=="action"} {
			set command [list_shift current]
			set command [string_change $command [list %% % %W "\[$object cmdw\]"]]
			if {![catch {set image [Classy::geticon $id reload]}]} {
				button $object.$key -image $image -command [list Classy::check $command]
			} else {
				button $object.$key -text $id -command [list Classy::check $command]
			}
			bindtags $object.$key [list_concat [bindtags $object.$key] Classy::DynaToolEntry]
			lappend data(slaves) $object.$key
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="actionrepeat"} {
			set command [list_shift current]
			set command [string_change $command [list %% % %W "\[$object cmdw\]"]]
			if {![catch {set image [Classy::geticon $id reload]}]} {
				Classy::RepeatButton $object.$key -image $image -command [list Classy::check $command]
			} else {
				Classy::RepeatButton $object.$key -text $id -command [list Classy::check $command]
			}
			bindtags $object.$key [list_concat [bindtags $object.$key] Classy::DynaToolEntry]
			lappend data(slaves) $object.$key
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="check"} {
			set command [list_shift current]
			if {![catch {set image [Classy::geticon $id reload]}]} {
				checkbutton $object.$key -image $image -indicatoron 0
			} else {
				checkbutton $object.$key -text $id
			}
			set command [string_change $command [list %w $object.$key]]
			set tempcmd [string_change $command [list %% % %W $cmdw]]
			if {[string length $cmdw]} {
				eval $object.$key configure $tempcmd
			}
			append data(checks) "$object.$key configure $command\n"
			lappend data(slaves) $object.$key
			bindtags $object.$key [list_concat [bindtags $object.$key] Classy::DynaToolEntry]
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="radio"} {
			set command [list_shift current]
			set command [string_change $command [list %w $object.$key]]
			set tempcmd [string_change $command [list %% % %W $cmdw]]
			if {![catch {set image [Classy::geticon $id reload]}]} {
				eval {radiobutton $object.$key -image $image -indicatoron 0} $tempcmd
			} else {
				eval {radiobutton $object.$key -text $id} $tempcmd
			}
			append data(checks) "$object.$key configure $command\n"
			lappend data(slaves) $object.$key
			bindtags $object.$key [list_concat [bindtags $object.$key] Classy::DynaToolEntry]
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="widget"} {
			$id $object.$key
			set command [list_shift current]
			set command [string_change $command [list %w $object.$key]]
			set tempcmd [string_change $command [list %% % %W $cmdw]]
			eval $object.$key configure $tempcmd
			append data(checks) "$object.$key configure $command\n"
			lappend data(slaves) $object.$key
			bindtags $object.$key [list_concat [bindtags $object.$key] Classy::DynaToolEntry]
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="tool"} {
			set cmd [$id $object.$key]
			if {"$cmdw" != ""} {
				eval [string_change $cmd [list %% % %W $cmdw]]
			}
			append data(checks) "$cmd\n"
			lappend data(slaves) $object.$key
			bindtags $object.$key [list_concat [bindtags $object.$key] Classy::DynaToolEntry]
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="label"} {
			if {![catch {set image [Classy::geticon $id reload]}]} {
				label $object.$key -image $image
			} else {
				label $object.$key -text $id
			}
			lappend data(slaves) $object.$key
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="optionmenu"} {
			set command [list_shift current]
			Classy::OptionMenu $object.$key -list {}
			set command [string_change $command [list %w $object.$key]]
			set tempcmd [string_change $command [list %% % %W $cmdw]]
			if {[string length $cmdw]} {
				eval $object.$key configure $tempcmd
			}
			append data(checks) "$object.$key configure $command\n"
			lappend data(slaves) $object.$key
			bindtags $object.$key [list_concat [bindtags $object.$key] Classy::DynaToolEntry]
			set ecmd [string_change [list_shift current] [list %w $object.$key]]
			if {$ecmd ne ""} {append data(checks) "$ecmd\n"}
		} elseif {"$type"=="separator"} {
			lappend data(slaves) [frame $object.sep$num -class Classy::ToolSeparator]
		} elseif {[regexp ^# $type]} {
			continue
		} elseif {"$type" == ""} {
			continue
		} else {
			error "Unknown entrytype $type" 
		}
		Classy::Balloon add $object.$key $help
	}
	# $object _placetopfirst
	# update idletasks
	$object cmdw $cmdw 1
	if {[Classy::busy status $object]} {set busy 1} else {set busy 0}
	Classy::todo $object redraw $busy
}

Classy::DynaTool method redraw {{busy 0}} {
	private $object data options
	if {![info exists data(slaves)]} {return 0}
	# Classy::update Classy::DynaTool-redraw idletasks
	set keep [bind $object <Configure>]
	bind $object <Configure> {}
	set line 1
	if {[string_equal $options(-orient) horizontal]} {
		set width [expr [winfo width $object]-2*[$object cget -bd]-1]
		if {$width < 4} {
			set width [winfo screenwidth $object]
		}
		set y 0
		set mh 0
		set x 0
		set xs ""
		set curslaves ""
		foreach slave $data(slaves) {
			if {![winfo exists $slave]} {
				continue
			} else {
				set w [expr {[winfo reqwidth $slave]}]
				set h [expr {[winfo reqheight $slave]}]
				if {$h>$mh} {set mh $h}
			}
			set temp [expr $x+$w]
			if {$temp>$width} {
				foreach temp $curslaves {
					place $temp -height $mh
				}
				set curslaves ""
				incr line
				if {[string length $options(-max)] && ($line > $options(-max))} break
				set x 0
				incr y $mh
				set mh $h
			}
			lappend curslaves $slave
			place forget $slave
			place $slave -x $x -y $y -in $object
			raise $slave
			incr x $w
		}
		foreach temp $curslaves {
			place $temp -height $mh
		}
		set y [expr {$y+$mh}]
		if {$options(-height) > 0} {
			[Classy::window $object] configure -height $options(-height)
		} else {
			[Classy::window $object] configure -height [expr {$y+2*[$object cget -bd]}]
		}
	} else {
		set height [expr [winfo height $object]-2*[$object cget -bd]-1]
		if {$height < 4} {set height [winfo screenheight $object]}
		set x 0
		set mw 0
		set y 0
		set ys ""
		set curslaves ""
		foreach slave $data(slaves) {
			if {![winfo exists $slave]} {
				continue
			} else {
				set w [winfo reqwidth $slave]
				set h [winfo reqheight $slave]
				if {$w>$mw} {set mw $w}
			}
			set temp [expr $y+$h]
			if {$temp>$height} {
				foreach temp $curslaves {
					place $temp -width $mw
				}
				set curslaves ""
				incr line
				if {[string length $options(-max)] && ($line > $options(-max))} break
				set y 0
				incr x $mw
				set mw $w
			}
			lappend curslaves $slave
			place forget $slave
			place $slave -x $x -y $y -in $object
			raise $slave
			incr y $h
		}
		foreach temp $curslaves {
			place $temp -width $mw
		}
		set x [expr {$x+$mw}]
		if {$options(-width) > 0} {
			[Classy::window $object] configure -width $options(-width)
		} else {
			[Classy::window $object] configure -width [expr {$x+2*[$object cget -bd]}]
		}
	}
	if {$busy} {
		Classy::busy remove $object
		Classy::busy add $object
	}
	Classy::todo $object rebind $keep
}

