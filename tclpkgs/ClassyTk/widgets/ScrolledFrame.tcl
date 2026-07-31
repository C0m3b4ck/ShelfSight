#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ScrolledFrame
# ----------------------------------------------------------------------
#doc ScrolledFrame title {
#ScrolledFrame
#} index {
# Tk improvements
#} shortdescr {
# frame with auto scroll bars
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# creates a view frame in which a component frame is displayed.
# If the component frame is larger than the view frame, scrollbars
# are automatically added.
# The component frame is available as component frame
#}
#doc {ScrolledFrame command} h2 {
#	ScrolledFrame specific methods
#}

if {[string equal $tcl_platform(platform) windows]} {
	option add *Classy::ScrolledFrame.Relief sunken widgetDefault
	option add *Classy::ScrolledFrame.BorderWidth 1 widgetDefault
	option add *Classy::ScrolledFrame.view.Relief flat widgetDefault
	option add *Classy::ScrolledFrame.view.BorderWidth 0 widgetDefault
}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------
Widget subclass Classy::ScrolledFrame

Classy::ScrolledFrame method init {args} {
	# REM Create object
	# -----------------
	super init
	canvas $object.view -width 100 -height 100 -bd 0 -highlightthickness 0
	$object.view configure -xscrollcommand [list $object.xscroll set] -yscrollcommand [list $object.yscroll set]
	Classy::AutoScrollbar $object.xscroll -command [list $object xview] -orient horizontal
	Classy::AutoScrollbar $object.yscroll -command [list $object yview] -orient vertical
	$object.xscroll set 0.0 1.0
	$object.yscroll set 0.0 1.0
	grid $object.view -column 0 -row 0 -sticky nwse
	grid $object.yscroll -column 1 -row 0 -sticky nwse
	grid $object.xscroll -column 0 -row 1 -sticky nwse
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1
	# make scrolled frame
	frame $object.view.frame
	$object.view create window 0 0 -anchor nw -window $object.view.frame -tags frame
	Classy::rebind $object.view.frame $object
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	bind $object.view <Configure> [list Classy::todo $object redraw]
	Classy::todo $object redraw
	return $object
}

Classy::ScrolledFrame component frame {$object.view.frame}

# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::ScrolledFrame chainoption -width {$object.view} -width
Classy::ScrolledFrame chainoption -height {$object.view} -height
Classy::ScrolledFrame chainoption -autoscrollx {$object.xscroll} -state
Classy::ScrolledFrame chainoption -autoscrolly {$object.yscroll} -state

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::ScrolledFrame method xview {args} {
	set result [eval $object.view xview $args]
	return $result
}

Classy::ScrolledFrame method yview {args} {
	set result [eval $object.view yview $args]
	return $result
}

Classy::ScrolledFrame method _checksize {args} {
	set minw [winfo reqwidth $object.view.frame]
	set w [winfo width $object]
	set border [expr {-2*[$object cget -bd] - 2*[$object cget -highlightthickness]}]
	incr w $border
	set scrw [winfo width $object.yscroll]
	set minh [winfo reqheight $object.view.frame]
	set h [winfo height $object]
	incr h $border
	set scrh [winfo height $object.xscroll]
	set xstate [$object.xscroll cget -state]
	set ystate [$object.yscroll cget -state]
	if {$minw > $w} {
		if {$xstate ne "hidden"} {
			$object.xscroll _show
			set h [expr {$h-$scrh}]
		}
		set w $minw
	} else {
		if {$xstate ne "shown"} {
			$object.xscroll _hide
		}
		set w $w
	}
	if {$minh > $h} {
		if {$ystate ne "hidden"} {
			$object.yscroll _show
			set h $minh
		}
	} else {
		if {$ystate ne "shown"} {
			$object.yscroll _hide
		}
		set h $h
	}
	$object.view itemconfigure frame -width $w -height $h
	$object.view configure -scrollregion [$object.view bbox frame]
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1
}

#doc {ScrolledFrame command redraw} cmd {
#pathname redraw 
#} descr {
#}
Classy::ScrolledFrame method redraw {} {
	$object _checksize
	$object.view configure -scrollregion [$object.view bbox frame]
}

Classy::ScrolledFrame method _children {} {
	return [winfo children $object.view.frame]
}

#doc {ScrolledFrame command see} cmd {
#pathname see window
#} descr {
# scroll so that window is visible
#}
Classy::ScrolledFrame method see {window} {
	set w $object.view.frame
	foreach {w h x y} [split [winfo geometry $window] x+] break
	set bbox [list $x $y [expr {$x+$w}] [expr {$y+$h}]]
	Classy::canvas_seebbox $object.view $bbox
}

