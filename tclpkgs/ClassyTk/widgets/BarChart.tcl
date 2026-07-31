# *************************************************
#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# BarChart
# ----------------------------------------------------------------------
#doc BarChart title {
#BarChart
#} index {
# Charts
#} shortdescr {
# Barchart that can be drawn on a canvas
#} descr {
# subclass of <a href="Class.html">Class</a><br>
# <b>A BarChart object is not a widget</b>. It is a class whose objects can 
# be associated with a canvas widget. When a BarChart instance is 
# associated with a canvas, it will draw a barchart on this canvas. 
# Several BarChart (and LineChart and ChartGrid) objects can be associated
# with the same canvas.
#}
#doc {BarChart options} h2 {
# BarChart options
#} descr {
# BarcHart objects support the following options in its configure method
#<dl>
#<dt>-canvas<dd>name of canvas to draw the barchart
#<dt>-tag<dd>unique tag for all canvas items of the chart
#<dt>-area<dd>area in which to diplay the chart (a list of four numbers)
#<dt>-datastart<dd>start position of data display
#<dt>-xrange<dd>xrange to display
#<dt>-yrange<dd>xrange to display
#<dt>-barwidth<dd>width of the bars, expressed as a fraction of the size available between 2 bars
#<dt>-displace<dd>when several dataranges are available, they wil be shifted by the value given here
#<dt>-percentages<dd>show data as percentages
#<dt>-stacked<dd>stack dataranges
#<dt>-legend<dd>display a legend
#<dt>-legendpos<dd>position to display the legend
#<dt>-legendfont<dd>font used for the legend
#<dt>-labels<dd>a list of labels that can be associated with the data
#<dt>-labelorient<dd>orient the labels: horizontal or vertical
#<dt>-labelfont<dd>font used for the labels
#<dt>-labelgap<dd>only show labels for every labelgap bar
#</dl>
#}
#doc {BarChart command} h2 {
#	BarChart methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::BarChart

Classy::BarChart method init {args} {
	super init
	private $object options
	array set options {
		-canvas {} -tag {} -area {}
		-datastart 0
		-xrange {1 20} -yrange {0 20}
		-barwidth 1 -displace 0
		-percentages no -stacked no
		-legend 1 -legendpos {30 10} -legendfont {helvetica 10}
		-labels {} -labelorient horizontal -labelfont {helvetica 10} -labelgap {}
	}
	setprivate $object order ""
	set options(-tag) "barchart:$object"
	eval $object configure $args
	return $object
}

#doc {BarChart command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::BarChart method destroy {} {
	private $object options
	::Classy::busy
	$options(-canvas) delete $options(-tag)
	Classy::update Classy::BarChart-destroy idletasks
	::Classy::busy remove
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {BarChart command configure} cmd {
#pathname configure ?option? ?value? ?option value ...?
#} descr {
# change the BarChart configuration options
#}
Classy::BarChart method configure {args} {
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
						set options(-tag) barchart::$object
					}
					Classy::update Classy::BarChart-configure idletasks
					set options(-area) [list 25 10 [expr [winfo width $value]-10] [expr [winfo height $value]-25]]
					::Classy::todo $object redraw
				}
				-tag {
					::Classy::todo $object redraw
				}
				-area {
					::Classy::todo $object redraw
				}
				-stacked {
					::Classy::todo $object redraw
				}
				-datastart {
					::Classy::todo $object redraw
				}
				-percentages {
					::Classy::todo $object redraw
				}
				-xrange {
					::Classy::todo $object redraw
				}
				-yrange {
					::Classy::todo $object redraw
				}
				-barwidth {
					if {$value>1} {set options(-barwidth) 1}
					if {$value<0} {set options(-barwidth) 0}
					::Classy::todo $object redraw
				}
				-displace {
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


#doc {BarChart command dataset} cmd {
#pathname dataset name values
#} descr {
# A barchart can have several ranges of data. Each range has a name.
# This method is used to set (or change) the data in a range.
# $values is a list of values that give the value for each data item. Optionally labels
# can be set with the labelist_set method
#}
Classy::BarChart method dataset {name values} {
	private $object data tag options order
	if ![info exists data($name)] {
		$object _create $name [llength $order]
		lappend order $name
#	if {"$order" != ""} {
#		$canvas lower $tag($name) $tag([lindex $order end])
#	}
	}
	set data($name) $values
	::Classy::todo $object redraw
}

Classy::BarChart method _create {name num} {
	private $object data tag options
	set canvas $options(-canvas)
	if {"$canvas" == ""} return
	set colors [Classy::optionget . colorList ColorList]
	regsub -all {{|}} $colors {} colors
	set color [lindex $colors $num]
	if {"$color" == ""} {
		set color black
	}
	set tag($name) [$canvas create polygon 1 1 2 2 3 3 -outline black -fill $color \
		-tags [list $options(-tag) Classy::BarChart data]]
}


#doc {BarChart command dataget} cmd {
#pathname dataget name
#} descr {
# returns the current data in range $name
#}
Classy::BarChart method dataget {name} {
	private $object data tag
	return $data($name)
}


#doc {BarChart command labelist_set} cmd {
#pathname labelist_set labels
#} descr {
# sets the labels associated with the barchart
#}
Classy::BarChart method labelist_set {values} {
	private $object labels
	if {"$values"==""} {
		unset labels
	}
	set labels $values
	::Classy::todo $object redraw
}


#doc {BarChart command delete} cmd {
#pathname delete name
#} descr {
# delete the range with name $name
#}
Classy::BarChart method delete {name} {
	private $object data tag options order
	$options(-canvas) delete $options(-tag)
	unset data($name)
	unset tag($name)
	set order [list_remove $order $name]
	::Classy::todo $object redraw
}


#doc {BarChart command hidden} cmd {
#pathname hidden name ?value?
#} descr {
# query or set hidden state of datarange name
#}
Classy::BarChart method hidden {name {value {}}} {
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


#doc {BarChart command ranges} cmd {
#pathname ranges
#} descr {
# returns the names of all ranges in the chart
#}
Classy::BarChart method ranges {} {
	private $object order
	return $order
}


#doc {BarChart command barconfigure} cmd {
#pathname barconfigure name ?option? ?value? ?option value ...?
#} descr {
# change the display properties of a range. The same options as for the canvas polygon item are
# available
#}
Classy::BarChart method barconfigure {name args} {
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

Classy::BarChart method _drawlegend {} {
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
		-tags [list $options(-tag) $options(-tag)::legend Classy::BarChart] \
		-anchor nw -font $options(-legendfont)]
	set bbox [$canvas bbox $options(-tag)::legend]
	set h [expr ([lindex $bbox 3]-[lindex $bbox 1])/[llength $names]]
	set y [expr $legendy+1]
	set hs [expr $h-2]
	foreach name $names {
		set conf [$canvas itemconfigure $tag($name)]
		set conf [list_merge [list_subindex $conf 0] [list_subindex $conf 4]]
		set temp [expr $legendx+10]
		eval $options(-canvas) create polygon $legendx $y $temp $y $temp [expr $y+$hs] $legendx [expr $y+$hs] $conf {-tags [list $options(-tag) $options(-tag)::legend Classy::BarChart]}
		set y [expr $y+$h]
	}
	set temp [eval $canvas create rectangle [$canvas bbox $options(-tag)::legend] {-fill white -tags [list $options(-tag) $options(-tag)::legend Classy::BarChart]}]
	$canvas lower $temp $id
}

Classy::BarChart method _drawlabels {} {
	private $object options hidden
    ::Classy::canceltodo $object _drawlabels
	set canvas $options(-canvas)
	if ![winfo exists $canvas] return
	if {"$options(-area)" == ""} return
	set width [expr [lindex $options(-area) 2] - [lindex $options(-area) 0]]
	if {$width<=0} return

	$canvas delete $options(-tag)::labels
	set labels $options(-labels)
	set datastart [expr [lindex $options(-xrange) 0]-$options(-datastart)]
	set dataend [expr [lindex $options(-xrange) end]-$options(-datastart)]
	set labels [lrange $labels $datastart $dataend]
	if {"$labels" == ""} return

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
			-tags [list $options(-tag) $options(-tag)::labels Classy::BarChart]
		set x [expr $x + $xscale*$gap]
	}
}

Classy::BarChart method _drawdata {} {
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
	set datastart [expr [lindex $options(-xrange) 0]-$options(-datastart)]
	set dataend [expr [lindex $options(-xrange) end]-$options(-datastart)]

	set ldisplace [expr $options(-displace)*$xscale]
	set number [llength $order]
	set d [lrange $data([lindex $order 0]) $datastart $dataend]
	set dlen [llength $d]
	if [true $options(-stacked)]&&($number>1) {
		set prev [list_fill $dlen 0]
		set ldisplace 0
	}
	if [true $options(-percentages)]&&($number>1)  {
		set perc [list_fill $dlen 100]
		set list $order
		set totals [lrange $data([list_pop list 0]) $datastart $dataend]
		foreach name $list {
			set totals [lmath_calc $totals + [lrange $data($name) $datastart $dataend]]
		}
		set totals [list_regsub {^0.0$} $totals {1.0}]
	}
	set pos 0
	set yb [list_fill $dlen 0]
	set x1 [list_ffill $dlen $pos 1]
	set x2 [list_ffill $dlen $options(-barwidth) 1]
	set x [list_merge [list_merge $x1 $x2] [list_merge $x1 $x2]]
	set lower ""
	foreach name $order {
		if [info exists hidden($name)] continue
		set d [lrange $data($name) $datastart $dataend]
		if [true $options(-stacked)]&&($number>1) {
			set d [lmath_calc $prev + $d]
			set prev $d
		}
		if [true $options(-percentages)]&&($number>1) {
			set d [lmath_calc $d * $perc]
			set d [lmath_calc $d / $totals]
		}
		set d [lmath_between $d [lindex $options(-yrange) 0] [lindex $options(-yrange) 1]]
		set y [list_merge [list_merge $yb $d] [list_merge $d $yb]]
		eval $canvas coords $tag($name) [list_merge $x $y]
		$canvas scale $tag($name) 0 0 $xscale -$yscale
		if {$datastart<0} {
			set xmove [expr $xstart+$pos-$datastart*$xscale]
		} else {
			set xmove [expr $xstart+$pos]
		}
		set ymove [expr $ystart+[lindex $options(-yrange) 1]*$yscale]
		$canvas move $tag($name) $xmove $ymove
		if {"$lower" != ""} {
			$canvas lower $tag($name) $lower
		}
		set lower $tag($name)
		set pos [expr $pos+$ldisplace]
	}
}


#doc {BarChart command redraw} cmd {
#pathname redraw
#} descr {
#}
Classy::BarChart method redraw {args} {
	private $object options
	if {"$options(-canvas)" == ""} return
	::Classy::busy
	::Classy::canceltodo $object _drawdata _drawlegend _drawlabels
	$object _drawdata
	$object _drawlegend
	$object _drawlabels
	::Classy::busy remove
}

