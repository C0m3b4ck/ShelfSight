# *************************************************
#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# LineChart
# ----------------------------------------------------------------------
#doc LineChart title {
#LineChart
#} index {
# Charts
#} shortdescr {
# linechart class that can be drawn on a canvas
#} descr {
# subclass of <a href="Class.html">Class</a><br>
# <b>LineChart is not a widget type</b>. It is a class whose objects can 
# be associated with a canvas widget. When a LineChart instance is 
# associated with a canvas, it will draw a linechart on this canvas. 
# Several LineChart (and BarChart and ChartGrid) objects can be associated
# with the same canvas.
#}
#doc {LineChart options} h2 {
#	LineChart options
#} descr {
# LineChart objects support the following options in its configure method
#<dl>
#<dt>-canvas<dd>name of canvas to draw the chart
#<dt>-tag<dd>unique tag for all canvas items of the chart
#<dt>-area<dd>area in which to diplay the chart (a list of four numbers)
#<dt>-xrange<dd>xrange to display
#<dt>-yrange<dd>xrange to display
#<dt>-legend<dd>display a legend
#<dt>-legendpos<dd>position to display the legend
#<dt>-legendfont<dd>font used for the legend
#<dt>-labels<dd>a list of labels that can be associated with the data
#<dt>-labelorient<dd>orient the labels: horizontal or vertical
#<dt>-labelfont<dd>font used for the labels
#<dt>-labelgap<dd>only show labels for every labelgap bar
#</dl>
#}
#doc {LineChart command} h2 {
#	LineChart specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::LineChart

Classy::LineChart method init {args} {
	super init
	private $object options
	array set options {
		-canvas {} -tag {} -area {}
		-ystep 1 -xstep 1
		-xrange {1 20} -yrange {0 20}
		-legend 1 -legendpos {30 10} -legendfont {helvetica 10}
		-labels {} -labelorient horizontal -labelfont {helvetica 10} -labelgap {}
	}
	setprivate $object order ""
	set options(-tag) "LineChart:$object"
	eval $object configure $args
	return $object
}


#doc {LineChart command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::LineChart method destroy {} {
	private $object options
	::Classy::busy
	$options(-canvas) delete $options(-tag)
	Classy::update Classy::LineChart-destroy idletasks
	::Classy::busy remove
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {LineChart command configure} cmd {
#pathname configure ?option? ?value? ?option value ...?
#} descr {
# change the LineChart configuration options
#}
Classy::LineChart method configure {args} {
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
			set previous $options($option)
			set options($option) $value
			switch -- $option {
				-canvas {
					private $object options
					if {"$options(-tag)" == ""} {
						set options(-tag) LineChart::$object
					}
					Classy::update Classy::LineChart-configure idletasks
					set options(-area) [list 25 10 [expr [winfo width $value]-10] [expr [winfo height $value]-25]]
					::Classy::todo $object redraw
				}
				-tag {
					::Classy::todo $object redraw
				}
				-area {
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
					::Classy::todo $object redraw
				}
				-legend {
					::Classy::todo $object redraw
				}
				-legendpos {
					::Classy::todo $object _drawlegend
				}
				-legendfont {
					::Classy::todo $object _drawlegend
				}
				-labels {
					::Classy::todo $object _drawlabels
				}
				-labelorient {
					::Classy::todo $object _drawlabels
				}
				-labelfont {
					::Classy::todo $object _drawlabels
				}
				-labelgap {
					::Classy::todo $object _drawlabels
				}
			}
		}
	}
}


#doc {LineChart command dataset} cmd {
#pathname dataset name values
#} descr {
# A linechart can have several ranges of data. Each range has a name.
# This method is used to set (or change) the data in a range.
# $values is a list of x and y values consituting the positions of points on the line.
#}
Classy::LineChart method dataset {name values} {
	private $object data tag options order
	if ![info exists data($name)] {
		$object _create $name [llength $order]
		lappend order $name
	}
	set data($name) $values
	::Classy::todo $object redraw
}

Classy::LineChart method _create {name num} {
	private $object data tag options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	set colors [option get . colorList ColorList]
	regsub -all {{|}} $colors {} colors
	set color [lindex $colors $num]
	if {"$color" == ""} {
		set color black
	}
	set tag($name) [$canvas create line 1 1 2 2 -width 2 -fill $color \
		-tags [list $options(-tag) Classy::LineChart data]]
}

#doc {LineChart command dataget} cmd {
#pathname dataget name
#} descr {
# returns the current data in range $name
#}
Classy::LineChart method dataget {name} {
	private $object data tag
	return $data($name)
}


#doc {LineChart command labelist_set} cmd {
#pathname labelist_set labels
#} descr {
# sets the labels associated with the linechart
#}
Classy::LineChart method labelist_set {values} {
	private $object labels
	if {"$values"==""} {
		unset labels
	}
	set labels $values
	::Classy::todo $object redraw
}


#doc {LineChart command delete} cmd {
#pathname delete name
#} descr {
# delete the range with name $name
#}
Classy::LineChart method delete {name} {
	private $object data tag options order
	$options(-canvas) delete $options(-tag)
	unset data($name)
	unset tag($name)
	set order [list_remove $order $name]
	::Classy::todo $object redraw
}


#doc {LineChart command hidden} cmd {
#pathname hidden name ?value?
#} descr {
# query or set the hidden state of the datarange name
#}
Classy::LineChart method hidden {name {value {}}} {
	private $object data tag options order hidden
	switch $value {
		{} {
			return [info exists hidden($name)]
		}
		1 {
			set xstart [lindex $options(-area) 0]
			set ystart [lindex $options(-area) 1]
			set canvas $options(-canvas)
			if {"$canvas" == ""} {
				return -code error "No canvas defined"
			}
			$canvas coords $tag($name) $xstart $ystart $xstart $ystart
			set hidden($name) 1
			::Classy::todo $object redraw
		}
		0 {
			if [info exists hidden($name)] {unset hidden($name)}
			::Classy::todo $object redraw
		}
	}
}


#doc {LineChart command ranges} cmd {
#pathname ranges 
#} descr {
# returns the names of all ranges in the chart
#}
Classy::LineChart method ranges {} {
	private $object order
	return $order
}


#doc {LineChart command lineconfigure} cmd {
#pathname lineconfigure name ?option? ?value? ?option value ...?
#} descr {
# change the display properties of a range. The same options as for the canvas line item are
# available
#}
Classy::LineChart method lineconfigure {name args} {
	private $object tag options
	set canvas $options(-canvas)
	if {"$canvas" == ""} {
		return -code error "No canvas defined"
	}
	if ![info exists tag($name)] {
		return -code error "No such data: $name"
	}
	if {"$args"==""} {
		return [$canvas itemconfigure $tag($name)]
	} else {
		set result [eval {$canvas itemconfigure $tag($name)} $args]
	}
	::Classy::todo $object _drawlegend
	return $result
}

Classy::LineChart method _drawlegend {} {
	private $object tag options order hidden
	set canvas $options(-canvas)
	if ![winfo exists $canvas] return
	$canvas delete $options(-tag)::legend
	if ![true $options(-legend)] return
	if {"$order"==""} return
	set legendx [lindex $options(-legendpos) 0]
	set legendy [lindex $options(-legendpos) 1]

	set temp ""
	set names ""
	foreach name $order {
		if [info exists hidden($name)] continue
		append temp "$name\n"
		lappend names $name
	}
	set temp [string trimright $temp "\n"]
	set id [$canvas create text [expr $legendx+10] $legendy -text $temp \
		-tags [list $options(-tag) $options(-tag)::legend Classy::LineChart] \
		-anchor nw -font $options(-legendfont)]
	set bbox [$canvas bbox $options(-tag)::legend]
	set h [expr ([lindex $bbox 3]-[lindex $bbox 1])/[llength $names]]
	set y [expr $legendy+1]
	set hs [expr $h/2.0]
	foreach name $names {
		set conf [$canvas itemconfigure $tag($name)]
		set conf [list_merge [list_subindex $conf 0] [list_subindex $conf 4]]
		set temp [expr $legendx+10]
		eval $options(-canvas) create line \
			$legendx [expr $y+$hs] $temp [expr $y+$hs] \
			$conf {-tags [list $options(-tag) $options(-tag)::legend Classy::LineChart]}
		set y [expr $y+$h]
	}
	set temp [eval $canvas create rectangle [$canvas bbox $options(-tag)::legend] {-fill white -tags [list $options(-tag) $options(-tag)::legend Classy::LineChart]}]
	$canvas lower $temp $id
}

Classy::LineChart method _drawlabels {} {
	private $object options hidden
    ::Classy::canceltodo $object _drawlabels
	set canvas $options(-canvas)
	if ![winfo exists $canvas] return
	set width [expr [lindex $options(-area) 2] - [lindex $options(-area) 0]]
	if {$width<=0} return

	$canvas delete $options(-tag)::labels
#	set labels $options(-labels)
	set xmin [lindex $options(-xrange) 0]
	set xmax [lindex $options(-xrange) 1]
	set ymin [lindex $options(-yrange) 0]
	set ymax [lindex $options(-yrange) 1]
#	set labels [lrange $labels $datastart $dataend]
#	if {"$labels" == ""} return

	set xstart [lindex $options(-area) 0]
	set ystart [lindex $options(-area) 1]
	set width [expr [lindex $options(-area) 2] - $xstart]
	if {$width<0} return
	set height [expr [lindex $options(-area) 3] - $ystart]
	if {$height<0} return
	set xsize [expr double([lindex $options(-xrange) 1] - [lindex $options(-xrange) 0])]
	set xscale [expr double($width)/$xsize]
	set y [expr [lindex $options(-area) 3]+4]
	set x [lindex $options(-area) 0]
	if {$datastart<0} {
		set x [expr $x-$datastart*$xscale]
	}
	if {"$options(-labelgap)" == ""} {
		set gap [expr int([font measure $options(-labelfont) W]/$xscale)]
		if {$gap == 0} {
			set gap 1
		}
	} else {
		set gap $options(-labelgap)
	}
	if {$gap>1} {
		set labels [list_unmerge $labels [expr $gap-1]]
	}
	if {"$options(-labelorient)" == "vertical"} {
		set labels [list_regsub -all {(.)} $labels "\\1\n"]
	}
	foreach label $labels {
		$canvas create text $x $y -anchor nw -text $label -font $options(-labelfont) \
			-tags [list $options(-tag) $options(-tag)::labels Classy::LineChart]
		set x [expr $x + $xscale*$gap]
	}
}

Classy::LineChart method _drawdata {} {
	private $object data tag options order hidden
	::Classy::canceltodo $object _drawdata
	set canvas $options(-canvas)
	if ![winfo exists $canvas] return
	if {"$order"==""} {return}

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

	set minx [lindex $options(-xrange) 0]
	set maxx [lindex $options(-xrange) 1]
	set miny [lindex $options(-yrange) 0]
	set maxy [lindex $options(-yrange) 1]

	set lower ""
	foreach name $order {
		if [info exists hidden($name)] continue
		set pos 0
		set len [llength $data($name)]
		while {$pos < $len} {
			if {[lindex $data($name) $pos]>$minx} break
			incr pos 2
		}
		if {$pos >= $len} {
			$canvas coords $tag($name) -1 -1
			continue
		}
		set d ""
		if {$pos != 0} {
			set xp [lindex $data($name) [expr $pos-2]]
			set yp [lindex $data($name) [expr $pos-1]]
			set xc [lindex $data($name) $pos]
			set yc [lindex $data($name) [expr $pos+1]]
			set yp [expr ((double($yc)-$yp)/($xc-$xp))*($minx-$xp) + $yp]
			set xp $minx
			set range [lrange $data($name) $pos end]
		} else {
			set xp [lindex $data($name) 0]
			set yp [lindex $data($name) 1]
			set range [lrange $data($name) 2 end]
		}
		set prevlow 0
		set prevhigh 0
		if {$yp<$miny} {
			set prevlow 1
		} elseif {$yp>$maxy} {
			set prevhigh 1
		} else {
			lappend d $xp $yp
		}

		foreach {xc yc} $range {
			if {$xc>$maxx} {
				set yc [expr ((double($yc)-$yp)/($xc-$xp))*($maxx-$xp) + $yp]
				set xc $maxx
			}
			if {$yc<$miny} {
				if $prevhigh {
					lappend d [expr ((double($xp)-$xc)/($yp-$yc))*($maxy-$yc) + $xc] $maxy
					set prevhigh 0
				}
				if !$prevlow {
					lappend d [expr ((double($xc)-$xp)/($yc-$yp))*($miny-$yp) + $xp] $miny
					set prevlow 1
				}
			} elseif {$yc>$maxy} {
				if $prevlow {
					lappend d [expr ((double($xp)-$xc)/($yp-$yc))*($miny-$yc) + $xc] $miny
					set prevlow 0
				}
				if !$prevhigh {
					lappend d [expr ((double($xc)-$xp)/($yc-$yp))*($maxy-$yp) + $xp] $maxy
					set prevhigh 1
				}
			} else {
				if $prevlow {
					lappend d [expr ((double($xp)-$xc)/($yp-$yc))*($miny-$yc) + $xc] $miny
					set prevlow 0
				} elseif $prevhigh {
					lappend d [expr ((double($xp)-$xc)/($yp-$yc))*($maxy-$yc) + $xc] $maxy
					set prevhigh 0
				}
				lappend d $xc $yc
			}
			if {$xc==$maxx} break
			set xp $xc
			set yp $yc
		}
		eval $canvas coords $tag($name) $d
		$canvas scale $tag($name) 0 0 $xscale -$yscale
		$canvas move $tag($name) [expr $xstart-$minx*$xscale] [expr $ystart+$height+$miny*$yscale]
		if {"$lower" != ""} {
			$canvas lower $tag($name) $lower
		}
		set lower $tag($name)
	}
}


#doc {LineChart command redraw} cmd {
#pathname redraw
#} descr {
#}
Classy::LineChart method redraw {args} {
	private $object options
	if ![winfo exists $options(-canvas)] return
#	::Classy::busy
	::Classy::canceltodo $object _drawdata _drawlegend _drawlabels
	catch {$object _drawdata}
#	::Classy::busy remove
}

