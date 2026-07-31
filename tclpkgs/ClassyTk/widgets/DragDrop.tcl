#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::DragDrop
# ----------------------------------------------------------------------
#doc DragDrop title {
#DragDrop
#} index {
# Common tools
#} shortdescr {
# class for handling drag and drop to and from widgets
#} descr {
# subclass of <a href="Class.html">Class</a><br>
# DragDrop is not a widget and is not intended to produce instances. 
# It is a class that manages drag and drop.
# A drop can be started using the command <br>
# <code>Classy::DragDrop start x y value ...<br></code>
# This should be bound to the  &lt;&lt;Drag&gt;&gt; event of the source window.
# <p>
# A window will be notified of a drop by the virtual event &lt;&lt;Drop&gt;&gt;, so<br>
# bind window &lt;&lt;Drop&gt;&gt; command<br>
# will execute the command when somethind is dropped on the window
# <p>
# The window is also notified of the current drag entering, moving in, or leaving the
# window by the &lt;&lt;Drag-Enter&gt;&gt; &lt;&lt;Drag-Motion&gt;&gt; and\
# &lt;&lt;Drag-Leave&gt;&gt; events, and can take apropriate actions.
# The program can get the data associated with the drag using the command <br>
# <code>Classy::DragDrop get ?type?</code>
#}
#doc {DragDrop command} h2 {
#	Config methods
#}

# ------------------------------------------------------------------
#  Class creation
# ------------------------------------------------------------------

Class subclass Classy::DragDrop

# ------------------------------------------------------------------
#  Class destroy
# ------------------------------------------------------------------

Classy::DragDrop classmethod destroy {} {
	$class abort
}
# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

bind Classy::DragDrop <Motion> {Classy::DragDrop move}
bind Classy::DragDrop <ButtonRelease> {Classy::DragDrop drop}
bind Classy::DragDrop <<Escape>> {Classy::DragDrop abort}
bind Classy::DragDrop <KeyRelease> {Classy::DragDrop configure -transfer copy}

#bind Classy::DragDrop <<Drag-Move>> {Classy::DragDrop configure -transfer move}
#bind Classy::DragDrop <<Drag-Link>> {Classy::DragDrop configure -transfer link}

#doc {DragDrop command start} cmd {
# Classy::DragDrop start x y value ?option value ...?<br>
#} descr {
# starts a drag. It clears all previously changed drag and drop settings to their
# default values or the ones supplied as options to the start classmethod.
# x and y must be the x and y position of the pointer on the screen: you can
# use %X and %Y in the event command to get these.
# $value is the default value given for the drop if no type is specified.
# the options are the same as for the Classy::DragDrop configure classmethod.
#}
Classy::DragDrop classmethod start {x y value args} {
	private $class data types ftypes
	set from [winfo containing $x $y]
	if [info exists data(from)] {
		bindtags $data(from) $data(bindtags)
		$data(from) configure -cursor $data(cursor)
		unset data(from)
	}
	unset -nocomplain types
	set types() {}
	unset -nocomplain ftypes
	set ftypes() {}
	set types() text/plain
	set types(text/plain) $value
	set data(transfer) none
	set data(prev) $from
	set data(from) $from
	set data(value) $value
	set data(cursor) [$from cget -cursor]
	set data(bindtags) [bindtags $from]
	set ftypes() {}
	foreach event [bind Classy::DragDrop_extra] {bind Classy::DragDrop_extra $event {}}
	set w .classy__.dragdrop
	if ![winfo exists $w] {
		toplevel $w -class Classy::DragDrop -width 10 -height 10
		wm withdraw $w
		wm geometry $w +10000+10000
		wm overrideredirect $w 1
		label $w.small -image [Classy::geticon plus] -borderwidth 0 -highlightthickness 0
		grid $w.small -row 0 -column 0 -sticky se
		label $w.l -image [Classy::geticon sm_file] -borderwidth 0 -highlightthickness 0
		grid $w.l -row 0 -column 0 -sticky se
		raise $w.small
		$w.l configure -cursor hand2
		bindtags $w Classy::DragDrop
	} else {
		$w.small configure -image [Classy::geticon plus] -borderwidth 0 -highlightthickness 0
		grid $w.small -row 0 -column 0 -sticky se
		$w.l configure -image [Classy::geticon sm_file] -borderwidth 0 -highlightthickness 0
		grid $w.l -row 0 -column 0 -sticky se
		raise $w.small
	}
	lower .classy__.dragdrop.small
	unset -nocomplain data(remote)
	if {[string first $args {-image {}}] == -1} {
	    wm geometry  $w +[expr {[winfo pointerx $w]+1}]+[expr {[winfo pointery $w]+1}]
		wm deiconify $w
	    raise $w
	}
	$from configure -cursor hand2
	eval $class configure $args
	bindtags $from {Classy::DragDrop_extra Classy::DragDrop}
    foreach app [list_remove [winfo interps] [tk appname]] {
		send -async -- $app ::Class::setprivate Classy::DragDrop data(prev) {{}}
		send -async -- $app ::Class::setprivate Classy::DragDrop data(remote) [list [tk appname]]
	}
	focus $from
	Classy::update Classy::DragDrop-start idletasks
}

#doc {DragDrop command configure} cmd {
# Classy::DragDrop configure ?option? ?value? ?option value...?<br>
#} descr {
# returns or changes the options for the current drag. following options are supported:
#<dl>
#<dt>-types {type data ?type data ...?}
#<dd>gives a list of types, and the data that should be returned when the drop site asks for the data.
#<dt>-ftypes {type function ?type function ...?}
#<dd>gives a list of types, and a function which will generate the data desired by the drop site. 
# The function will be executed at global level in the application where the drag originated.
#<dt>-transfer type
#<dd> type of transfer: $type can be none, copy, move or link
#<dt>-cursor cursor
#<dd> cursor of drag
#<dt>-image image
#<dd> dragged image
#</dl>
#}
Classy::DragDrop classmethod configure {args} {
	private $class data types ftypes
	if [info exists data(remote)] {
		send -async -- $data(remote) Classy::DragDrop configure $args
	} else {
		if {[llength $args] == 0} {
			set list {}
			foreach option {-types -ftypes -transfer -cursor -image} {
				lappend list $option [$class configure $option]
			}
			return $list
		} elseif {[llength $args] == 1} {
			set option [lindex $args 0]
			switch -- $option {
				-transfer {
					return $data(transfer)
				}
				-types {
					set list {}
					foreach type $types() {
						lappend list $type $types($type)
					}
					return $list
				}
				-ftypes {
					set list {}
					foreach type $ftypes() {
						lappend list $type $ftypes($type)
					}
					return $list
				}
				-cursor {
					return [$data(from) cget -cursor]
				}
				-image {
					if [info exists data(withdrawn)] {return {}}
					return [.classy__.dragdrop.l cget -image]
				}
				default {
					return -code error "Unknown option $option"
				}
			}
		}
		foreach {option value} $args {
			switch -- $option {
				-transfer {
					set data(transfer) $value
					switch $value {
						none {
							lower .classy__.dragdrop.small
						}
						copy {
							.classy__.dragdrop.small configure -image [Classy::geticon drag_copy]
							raise .classy__.dragdrop.small
						}
						move {
							.classy__.dragdrop.small configure -image [Classy::geticon drag_move]
							raise .classy__.dragdrop.small
						}
						link {
							.classy__.dragdrop.small configure -image [Classy::geticon drag_link]
							raise .classy__.dragdrop.small
						}
					}
				}
				-types {
					unset types
					set types() {}
					foreach {type d} $value {
						lappend types() $type
						set types($type) $d
					}
				}
				-ftypes {
					unset ftypes
					set ftypes() {}
					foreach {type d} $value {
						lappend ftypes() $type
						set ftypes($type) $d
					}
				}
				-cursor {
					$data(from) configure -cursor $value
				}
				-image {
					if {"$value" == ""} {
						wm withdraw .classy__.dragdrop
						set data(withdrawn) 1
					} else {
						.classy__.dragdrop.l configure -image $value
						wm deiconify .classy__.dragdrop
						raise .classy__.dragdrop
						unset -nocomplain data(withdrawn)
					}
				}
				default {
					return -code error "Unknown option $option"
				}
			}
		}
	}
}

#doc {DragDrop command types} cmd {
# Classy::DragDrop types ?pattern?<br>
#} descr {
# returns a list of all types supported by the current drag; optionally only those
# matching $pattern are returned
#}
Classy::DragDrop classmethod types {{pattern *}} {
	private $class data types ftypes
	if [info exists data(remote)] {
		return [send -- $data(remote) Classy::DragDrop types $pattern]
	} else {
		if {"$pattern" == "*"} {
			return [concat $types() $ftypes()]
		} else {
			set list ""
			foreach item [concat $types() $ftypes()] {
				if [string match $pattern $item] {lappend list $item}
			}
			return $list
		}
	}
}

#doc {DragDrop command get} cmd {
# Classy::DragDrop get ?type?<br>
#} descr {
# returns the data associated with with the type $type of the current drag.
# If no type is given, the default value is returned (the data given to the start classmethod.)
#}
Classy::DragDrop classmethod get {{type {}}} {
	private $class data types ftypes
	if [info exists data(remote)] {
		return [send -- $data(remote) Classy::DragDrop get $type]
	} else {
		if {"$type" == ""} {
			return $data(value)
		} else {
			if [info exists types($type)] {
				return $types($type)
			} elseif [info exists ftypes($type)] {
				return [uplevel #0 $ftypes($type)]
			} else {
				return -code error "Type \"$type\" not present"
			}
		}
	}
}

#doc {DragDrop command bind} cmd {
# Classy::DragDrop bind event ?command?
#} descr {
# with this classmethod, bindings can be added to the current drag, eg. to change the transfer type
# in response to a keypress. Note that the command must come after the drag was
# started with the start classmethod.
#}
Classy::DragDrop classmethod bind {args} {
	eval bind Classy::DragDrop_extra $args
}

Classy::DragDrop classmethod _events {app x y} {
	private $class data
	set dropw [winfo containing $x $y]
	if {"$data(prev)" != ""} {
		if {"$data(prev)" != "$dropw"} {
			set rx [expr {$x-[winfo rootx $data(prev)]}]
			set ry [expr {$y-[winfo rooty $data(prev)]}]
			event generate $data(prev) <<Drag-Leave>> -x $rx -y $ry
		}
	}
	if {"$dropw" == ""} {
		set data(prev) ""
		return ""
	}
	set rx [expr {$x-[winfo rootx $dropw]}]
	set ry [expr {$y-[winfo rooty $dropw]}]
	if {"$data(prev)" != "$dropw"} {
		event generate $dropw <<Drag-Enter>> -x $rx -y $ry
	}
	event generate $dropw <<Drag-Motion>> -x $rx -y $ry
	set data(prev) $dropw
}

#doc {DragDrop command abort} cmd {
# Classy::DragDrop abort<br>
#} descr {
# abort the current drag.
#}
Classy::DragDrop classmethod abort {} {
	private $class data
	if [info exists data(from)] {
		bindtags $data(from) $data(bindtags)
		$data(from) configure -cursor $data(cursor)
		unset data(from)
	}
	set w .classy__.dragdrop
	wm withdraw $w
	wm geometry $w +10000+10000
}

#doc {DragDrop command drop} cmd {
# Classy::DragDrop stop<br>
#} descr {
# make the drop. The user normally does not have to call this classmethod, as it is
# usually called by the bindings of DragDrop.
#}
Classy::DragDrop classmethod drop {} {
	private $class data
	if ![info exists data(from)] return
	bindtags $data(from) $data(bindtags)
	$data(from) configure -cursor $data(cursor)
	unset data(from)
	set w .classy__.dragdrop
	set x [winfo pointerx $w]
	set y [winfo pointery $w]
    wm geometry $w +[expr {[winfo pointerx $w]+1}]+[expr {[winfo pointery $w]+1}]
	wm withdraw $w
	wm geometry $w +10000+10000
	set dropw [winfo containing $x $y]
	if {"$dropw" != ""} {
		event generate $dropw <<Drop>>
	} else {
	    foreach appl [winfo interps] {
	        set dropw [send -- $appl winfo containing $x $y]
	        if {"$dropw" != ""} break
	    }
		if {"$dropw" != ""} {
			send -async -- $appl [list catch [list Classy::DragDrop _remote [tk appname]]]
			send -async -- $appl [list catch [list event generate $dropw <<Drop>>]]
		}
	}
}

#doc {DragDrop command move} cmd {
# Classy::DragDrop move<br>
#} descr {
# This classmethod is called while dragging. It updates the dragged window, and generates
# the Drag events. The user normally does not have to call this classmethod, as it is
# usually called by the bindings of DragDrop.
#}
Classy::DragDrop classmethod move {} {
	private $class data
	if ![info exists data(prev)] {
		$class abort
	}
	set w .classy__.dragdrop
	set x [winfo pointerx $w]
	set y [winfo pointery $w]
	if ![info exists data(withdrawn)] {
		wm geometry  $w +[expr {$x+1}]+[expr {$y+1}]
	}
	set data(app) {}
	set dropw [winfo containing $x $y]
	set curapp [tk appname]
	if {"$data(prev)" != ""} {
		if {"$data(prev)" != "$dropw"} {
			set rx [expr {$x-[winfo rootx $data(prev)]}]
			set ry [expr {$y-[winfo rooty $data(prev)]}]
			event generate $data(prev) <<Drag-Leave>> -x $rx -y $ry
		}
	}
	if {"$dropw" != ""} {
		set rx [expr {$x-[winfo rootx $dropw]}]
		set ry [expr {$y-[winfo rooty $dropw]}]
		set data(app) $curapp
		if {"$data(prev)" != "$dropw"} {
			event generate $dropw <<Drag-Enter>> -x $rx -y $ry
		}
		event generate $dropw <<Drag-Motion>> -x $rx -y $ry
	} else {
	    foreach app [list_remove [winfo interps] $curapp] {
			send -async -- $app Classy::DragDrop _events [list $curapp] $x $y
		}
	}
	set data(prev) $dropw
}

# event generate .e <<Drop>>

