# *************************************************
#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# ChartGrid
# ----------------------------------------------------------------------
#doc ChartGrid title {
#ChartGrid
#} index {
# Charts
#} shortdescr {
# grid that can be displayed on canvas
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# <b>ChartGrid is not a widget type</b>. It is a class whose objects can 
# be associated with a canvas widget. When a ChartGrid instance is 
# associated with a canvas, it will draw a grid on this canvas. 
# Several ChartGrid, LineChart and BarChart objects can be associated
# with the same canvas.
#}
#doc {ChartGrid options} h2 {
#	ChartGrid specific options
#} descr {
# ChartGrid objects support the following options in its configure method
#<dl>
#<dt>-canvas<dd>name of canvas to draw the barchart
#<dt>-tag<dd>unique tag for all canvas items of the chart
#<dt>-area<dd>area in which to diplay the chart (a list of four numbers)
#<dt>-xrange<dd>xrange to display
#<dt>-yrange<dd>xrange to display
#<dt>-xstep<dd>numbers and gridlines are shown at startx+x*stepx
#<dt>-ystep<dd>numbers and gridlines are shown at starty+y*stepy
#<dt>-font<dd>font used for numbers
#<dt>-showx<dd>show numbers on x axis
#<dt>-showy<dd>show numbers on y axis
#</dl>
#}
#doc {ChartGrid command} h2 {
#	ChartGrid specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::ChartGrid

Classy::ChartGrid method init {args} {
	super init
	private $object options
	array set options {
		-canvas {} -tag {} -area {}
		-xrange {1 20} -yrange {0 20}
		-ystep 1 -xstep 1
		-font {helvetica 9}
		-showx 1 -showy 1
	}
	eval $object configure $args
	return $object
}

#doc {ChartGrid command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::ChartGrid method destroy {} {
	private $object options
	::Classy::busy
	$options(-canvas) delete $options(-tag)
	Classy::update Classy::ChartGrid-destroy idletasks
	::Classy::busy remove
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {ChartGrid command configure} cmd {
#pathname configure ?option? ?value? ?option value ...?
#} descr {
#}
Classy::ChartGrid method configure {args} {
	private $object options
	set len [llength $args]
	if {$len == 0} {
		return [array get options]
	} elseif {$len == 1} {
		return $options([lindex $args 0])
	} else {
		foreach {option value} $args {
			if ![info exists options($option)] {
				error "unknown option \"$option\""
			}
			set options($option) $value
			switch -- $option {
				-canvas {
					private $object options
					if {"$options(-tag)" == ""} {
						set options(-tag) chartgrid::$object
					}
					set options(-area) [list 25 10 [expr [winfo width $value]-10] [expr [winfo height $value]-25]]
					::Classy::todo $object redraw
				}
				-tag {
					::Classy::todo $object redraw
				}
				-area {
					::Classy::todo $object redraw
				}
				-font {
					::Classy::todo $object redraw
				}
				-xrange {
					::Classy::todo $object redraw
				}
				-ystep {
					::Classy::todo $object redraw
				}
				-xstep {
					::Classy::todo $object redraw
				}
				-yrange {
					private $object cury
					set yb [lindex $value 0]
					set cury $yb
					::Classy::todo $object redraw
				}
				-showx {
					if [true $value] {
						set options($option) 1
					}
					::Classy::todo $object redraw
				}
				-showy {
					if [true $value] {
						set options($option) 1
					}
					::Classy::todo $object redraw
				}
			}
		}
	}
}

Classy::ChartGrid method _drawgrid {} {
	private $object options
	set canvas $options(-canvas)
	if ![winfo exists $canvas] return
	set tag $options(-tag)

	set xstart [lindex $options(-area) 0]
	set ystart [lindex $options(-area) 1]
	set width [expr [lindex $options(-area) 2] - $xstart]
	if {$width<=0} return
	set height [expr [lindex $options(-area) 3] - $ystart]
	if {$height<=0} return
	set xsize [expr double([lindex $options(-xrange) 1] - [lindex $options(-xrange) 0])]
	set xscale [expr double($width)/$xsize]
	set ysize [expr double([lindex $options(-yrange) 1] - [lindex $options(-yrange) 0])]
	set yscale [expr double($height)/$ysize]

	set under [$canvas find above $tag]
	catch {$canvas delete $tag}

	# Draw grid and numbers on x axis
	set rxstep $options(-xstep)
	while {[expr $rxstep*$xscale]<10} {
		set rxstep [expr 10*$rxstep]
	}
	set xnum [expr {round($xsize/$rxstep+1)}]
	set linepos [list_ffill $xnum $xstart [expr $rxstep*$xscale]]
	set textpos [list_ffill $xnum [expr $xstart+0.5*($rxstep*$xscale)] [expr $rxstep*$xscale]]
	set xpos [lindex $options(-xrange) 0]
	for {set i 0} {$i<$xnum} {incr i} {
		set x [lindex $linepos $i]
		$canvas create line $x $ystart $x [expr $ystart+$height] -fill gray -tags [list $tag classy::chartgrid]
		$canvas create line $x [expr $ystart+$height] $x [expr $ystart+$height+4] -tags [list $tag classy::chartgrid]
		if $options(-showx) {$canvas create text $x [expr $ystart+$height+5] -text $xpos -anchor ne -justify center -tags [list $tag classy::chartgrid] -font $options(-font)}
		set xpos [expr $xpos+$rxstep]
	}

	# Draw grid and numbers on y axis
	set rystep $options(-ystep)
	while {[expr $rystep*$yscale]<10} {
		set rystep [expr 10*$rystep]
	}
	set ynum [expr {round($ysize/$rystep+1)}]
	set pos [list_ffill $ynum [expr $ystart+$height] [expr -$rystep*$yscale]]
	set ypos [lindex $options(-yrange) 0]
	for {set i 0} {$i<$ynum} {incr i} {
 		set y [lindex $pos $i]
		$canvas create line $xstart $y [expr $xstart+$width] $y -fill gray -tags [list $tag classy::chartgrid]
		$canvas create line [expr $xstart-4] $y $xstart $y -tags [list $tag classy::chartgrid]
		if $options(-showy) {$canvas create text [expr $xstart-6] $y -anchor e -text $ypos -tags [list $tag classy::chartgrid] -font $options(-font)}
		set ypos [expr $ypos+$rystep]
	}
	# Draw x axis
	$canvas create line [expr $xstart-4] [expr $ystart+$height] [expr $xstart+$width] [expr $ystart+$height] -tags [list $tag classy::chartgrid]
	# Draw y axis
	$canvas create line $xstart $ystart $xstart [expr $ystart+$height+4] -tags [list $tag classy::chartgrid]

	if {"$under" != ""} {
		$canvas lower $tag $under
	}
	set drawable 1
}


#doc {ChartGrid command redraw} cmd {
#pathname redraw
#} descr {
#}
Classy::ChartGrid method redraw {args} {
	::Classy::busy
	$object _drawgrid
	Classy::update Classy::ChartGrid-redraw idletasks
	::Classy::busy remove
}

