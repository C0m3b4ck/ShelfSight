#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# ::Classy::LineChartDialog
# ----------------------------------------------------------------------
#doc LineChartDialog title {
#LineChartDialog
#} index {
# Charts
#} shortdescr {
# Dialog with a linechart and some controls to change its display
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
# Creates a <a href="Dialog.html">Dialog</a> which displays a 
# linechart.
#}
#doc {LineChartDialog options} h2 {
#	LineChartDialog specific options
#}
#doc {LineChartDialog command} h2 {
#	LineChartDialog specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass ::Classy::LineChartDialog

::Classy::LineChartDialog method init {args} {
	super init -resize {1 1}
	set w $object.options
	$object add print "Print" [list $object print]
	$object add rangeconfig "Configure Ranges" "$object rangeconfigure"
	$object add dataconfig "Configure Data" "$object dataconfigure"

	frame $w.view
	canvas $w.canvas -bg white
	bind $w.canvas <Configure> [list $object _autoscale]
	scrollbar $w.vbar -orient vertical -command "$object yview "
	scrollbar $w.hbar -orient horizontal -command "$object xview "
	grid $w.vbar -in $w.view -row 0 -column 0 -sticky ns
	grid $w.canvas -in $w.view -row 0 -column 1 -sticky nwse
	grid $w.hbar -row 1 -column 1 -in $w.view -sticky we
	grid columnconfigure $w.view 1 -weight 1
	grid rowconfigure $w.view 0 -weight 1
	frame $w.controls
	pack $w.view -fill both -expand yes
	pack $w.controls -fill y

	Classy::update Classy::LineChartDialog-init idletasks
	Classy::ChartGrid new $w.grid -canvas $w.canvas -xrange {0 20} -yrange {0 100}
	Classy::LineChart new $w.chart -canvas $w.canvas -xrange {0 20} -yrange {0 100}

	# REM Create bindings
	# -------------------
	bind $w.canvas <<Action>> "$w.chart configure -legendpos {%x %y}"

	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::update Classy::LineChartDialog-init2 idletasks
	$object _setscroll
	return $object
}

::Classy::LineChartDialog component canvas {$object.options.canvas}
::Classy::LineChartDialog component chart {$object.options.chart}
::Classy::LineChartDialog component grid {$object.options.grid}

# ------------------------------------------------------------------
#  Widget destruction
# ------------------------------------------------------------------
Classy::LineChartDialog method destroy {} {
	catch {$object.options.grid destroy}
	catch {$object.options.chart destroy}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {LineChartDialog options -autoscale} option {-autoscale autoScale AutoScale} descr {
#}
Classy::LineChartDialog addoption -autoscale {autoScale AutoScale 1} {
	set value [true $value]
	Classy::todo $object _autoscale
}

#doc {LineChartDialog options -xrange} option {-xrange xRange XRange} descr {
#}
Classy::LineChartDialog addoption -xrange {xRange XRange {0 20}} {
	set range [$object.options.chart configure -xrange]
	set min [lindex $range 0]
	set max [lindex $range 1]
	if {$min < [lindex $value 0]} {
		set min [lindex $value 0]
	}
	if {$max > [lindex $value 1]} {
		set max [lindex $value 1]
	}
	$object.options.chart configure -xrange [list $min $max]
	$object.options.grid configure -xrange [list $min $max]
	$object _setscroll
}

#doc {LineChartDialog options -yrange} option {-yrange yRange YRange} descr {
#}
Classy::LineChartDialog addoption -yrange {yRange YRange {0 100}} {
	set range [$object.options.chart configure -yrange]
	set min [lindex $range 0]
	set max [lindex $range 1]
	if {$min < [lindex $value 0]} {
		set min [lindex $value 0]
	}
	if {$max > [lindex $value 1]} {
		set max [lindex $value 1]
	}
	$object.options.chart configure -yrange [list $min $max]
	$object.options.grid configure -yrange [list $min $max]
	$object _setscroll
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::LineChartDialog method _newvalues {} {
	private $object keepyrange keepchartheight
	set w $object.options
	if {[$w.chart configure -percentages] == 1} {
		$w.chart configure -yrange {0 100}
		$w.grid configure -yrange {0 100}
	}
	$w.chart redraw
}

#doc {LineChartDialog command dataset} cmd {
#pathname dataset name data
#} descr {
# A linechart can have several ranges of data. Each range has a name.
# This method is used to set (or change) the data in a range.
#}
Classy::LineChartDialog method dataset {name data} {
	$object.options.chart dataset $name $data
}

#doc {LineChartDialog command dataget} cmd {
#pathname dataget name
#} descr {
# returns the current data in range $name
#}
Classy::LineChartDialog method dataget {name} {
	$object.options.chart dataget $name
}

#doc {LineChartDialog command datadelete} cmd {
#pathname datadelete name
#} descr {
# delete the range with name $name
#}
Classy::LineChartDialog method datadelete {name} {
	$object.options.chart datadelete $name
}

#doc {LineChartDialog command switchdata} cmd {
#pathname switchdata item
#} descr {
#}
Classy::LineChartDialog method switchdata {item} {
	private $object data config
	set chart $object.options.chart
	if [info exists data($item)] {
		$chart dataset $item [set data($item)]
		eval {$chart lineconfigure $item} [set config($item)]
		unset data($item)
		unset config($item)
	} else {
		set data($item) [$chart dataget $item]
		set temp [$chart lineconfigure $item]
		set config($item) [list_merge [list_subindex $temp 0] [list_subindex $temp 4]]
		$chart datadelete $item
	}
}

#doc {LineChartDialog command dataconfigure} cmd {
#pathname dataconfigure
#} descr {
# pop up a dialog to change the properties of the linechart data
#}
Classy::LineChartDialog method dataconfigure {} {
	private $object width data
	set chart $object.options.chart
	Classy::Dialog $object.configure -title "Data configure" -keepgeometry no
	set w $object.configure.options
	set num 0
#	set elements "[$chart ranges] [array names data]"
	foreach element [$chart ranges] {
		set b $w.label$num
		checkbutton $w.label$num -onvalue 0 -offvalue 1 -text $element -anchor w \
			-variable [privatevar $object display$num]\
			-command "$object.options.chart hidden [list $element] \[set [privatevar $object display$num]\]"
		setprivate $object display$num [$object.options.chart hidden $element]
		button $w.fill$num -text "Fill color" -command [varsubst {b chart element} {
			set color [lindex [$chart lineconfigure "$element" -fill] 4]
			set color [Classy::getcolor -initialcolor $color -title "$element fill color"]
			$chart lineconfigure "$element" -fill $color
			$b configure -bg $color
		}]
		$b configure -bg [lindex [$chart lineconfigure "$element" -fill] 4]
		Classy::NumEntry $w.width$num -label "Line width" -width 5 \
			-command "$chart lineconfigure [list $element] -width"
		$w.width$num	set [lindex [$chart lineconfigure $element -width] 4]
		grid $w.label$num $w.fill$num $w.width$num -sticky we
		incr num
	}
}

#doc {LineChartDialog command rangeconfigure} cmd {
#pathname rangeconfigure 
#} descr {
# pop up a dialog to change the properties of the linechart ranges
#}
Classy::LineChartDialog method rangeconfigure {} {
	private $object options
	set w $object.options
	set chart $object.options.chart
	Classy::Dialog $object.rangeconfigure -title "Range configure" -keepgeometry no
	set w $object.rangeconfigure.options
	$object.rangeconfigure add go "Set Ranges" [varsubst {object w chart} {
		$object.options.chart configure \
			-yrange "[$w.view.ymin get] [$w.view.ymax get]" \
			-xrange "[$w.view.xmin get] [$w.view.xmax get]" \
			-area [list [$w.area.xmin get] [$w.area.ymin get] [$w.area.xmax get] [$w.area.ymax get]]
		$object.options.grid configure \
			-yrange "[$w.view.ymin get] [$w.view.ymax get]" \
			-xrange "[$w.view.xmin get] [$w.view.xmax get]" \
			-area [list [$w.area.xmin get] [$w.area.ymin get] [$w.area.xmax get] [$w.area.ymax get]]
		$object configure \
			-yrange "[$w.full.ymin get] [$w.full.ymax get]" \
			-xrange "[$w.full.xmin get] [$w.full.xmax get]"
		Classy::todo $object _setscroll
	}] default
	$object.rangeconfigure persistent add -all
	label $w.viewl -text "View area"
	frame $w.view
	label $w.fulll -text "Full area"
	frame $w.full
	label $w.areal -text "Drawing area"
	frame $w.area
	Classy::NumEntry $w.view.xmin -label "Min X" -width 5 -constraint int -min 0
	Classy::NumEntry $w.view.xmax -label "Max X" -width 5 -constraint int
	Classy::NumEntry $w.view.ymin -label "Min Y" -width 5 -constraint int
	Classy::NumEntry $w.view.ymax -label "Max Y" -width 5 -constraint int
	set viewxrange [$chart configure -xrange]
	set viewyrange [$chart configure -yrange]
	$w.view.xmin nocmdset [lindex $viewxrange 0]
	$w.view.xmax nocmdset [lindex $viewxrange 1]
	$w.view.ymin nocmdset [lindex $viewyrange 0]
	$w.view.ymax nocmdset [lindex $viewyrange 1]
	grid $w.view.xmin $w.view.xmax -sticky se
	grid $w.view.ymin $w.view.ymax -sticky se
	grid columnconfigure $w.view 0 -weight 1
	grid columnconfigure $w.view 0 -weight 1
	#
	Classy::NumEntry $w.full.xmin -label "Min X" -width 5 -constraint int -min 0
	Classy::NumEntry $w.full.xmax -label "Max X" -width 5 -constraint int
	Classy::NumEntry $w.full.ymin -label "Min Y" -width 5 -constraint int
	Classy::NumEntry $w.full.ymax -label "Max Y" -width 5 -constraint int
	set xrange $options(-xrange)
	set yrange $options(-yrange)
	$w.full.xmin nocmdset [lindex $xrange 0]
	$w.full.xmax nocmdset [lindex $xrange 1]
	$w.full.ymin nocmdset [lindex $yrange 0]
	$w.full.ymax nocmdset [lindex $yrange 1]
	grid $w.full.xmin $w.full.xmax -sticky se
	grid $w.full.ymin $w.full.ymax -sticky se
	grid columnconfigure $w.full 0 -weight 1
	grid columnconfigure $w.full 0 -weight 1
	#
	Classy::NumEntry $w.area.xmin -label "Min X" -width 5 -constraint int -min 0
	Classy::NumEntry $w.area.xmax -label "Max X" -width 5 -constraint int
	Classy::NumEntry $w.area.ymin -label "Min Y" -width 5 -constraint int
	Classy::NumEntry $w.area.ymax -label "Max Y" -width 5 -constraint int
	set area [$object.options.chart configure -area]
	$w.area.xmin nocmdset [lindex $area 0]
	$w.area.xmax nocmdset [lindex $area 2]
	$w.area.ymin nocmdset [lindex $area 1]
	$w.area.ymax nocmdset [lindex $area 3]
	grid $w.area.xmin $w.area.xmax -sticky se
	grid $w.area.ymin $w.area.ymax -sticky se
	grid columnconfigure $w.area 0 -weight 1
	grid columnconfigure $w.area 0 -weight 1
	#
	checkbutton $w.vertical -text "Vertical labels" \
		-onvalue vertical -offvalue horizontal \
		-variable [privatevar $object.options.chart options(-labelorient)] \
		-command "$chart redraw"
	checkbutton $w.autoscale -text "Autoscale" -variable [privatevar $object options(-autoscale)] \
		-onvalue 1 -offvalue 0 -command "$object _autoscale"
	button $w.fill -text "Fill drawing" -command [varsubst {w object} {
		$w.area.xmax nocmdset [expr [winfo width [$object component canvas]]-10]
		$w.area.ymax nocmdset [expr [winfo height [$object component canvas]]-25]
		$object chartconfigure -area [list [$w.area.xmin get] [$w.area.ymin get] [$w.area.xmax get] [$w.area.ymax get]]
		$object _setscroll
	}]
	#
	grid $w.viewl - -sticky we
	grid $w.view - -sticky we
	grid $w.fulll - -sticky we
	grid $w.full - -sticky we
	grid $w.areal - -sticky we
	grid $w.area - -sticky we
	grid $w.fill $w.autoscale -sticky we
	grid $w.vertical - -sticky we
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $w 1 -weight 1
}

#doc {LineChartDialog command chartconfigure} cmd {
#pathname chartconfigure ?option? ?value? ?option value ...?
#} descr {
# change the <a href="LineChart.html">options of the displayed linechart</a>
#}
Classy::LineChartDialog method chartconfigure {args} {
	set len [llength $args]
	if {$len==0} {
		return [concat [$object.options.chart configure] -axisfont [$object.options.grid configure -font]]
	} elseif {$len==1} {
		set option [lindex $args 0]
		switch -exact -- $option {
			-axisfont {
				$object.options.grid configure -font
			}
			-background {
				$object.options.canvas configure -background
			}
			default {
				$object.options.chart configure $option
			}
		}
	} else {
		foreach {option value} $args {
			switch -exact -- $option {
				-area -
				-xrange -
				-yrange { 
					$object.options.chart configure $option $value
					$object.options.grid configure $option $value
					$object _setscroll
				}
				-labels {
					$object.options.chart configure $option $value
					if {"$value" == ""} {
						$object.options.grid configure -showx 1
					} else {
						$object.options.grid configure -showx 0
					}
				}
				-background {
					$object.options.canvas configure -background $value
				}
				-axisfont {
					$object.options.grid configure -font $value
				}
				default {
					$object.options.chart configure $option $value
				}
			}
		}
	}
}

#doc {LineChartDialog command xview} cmd {
#pathname xview ?args?
#} descr {
#}
Classy::LineChartDialog method xview {args} {
	private $object options
	set chartxrange [$object.options.chart configure -xrange]
	set xrange $options(-xrange)
	set first [lindex $args 0]
	set xb [lindex $xrange 0]
	set xe [lindex $xrange 1]
	set size [expr $xe-$xb]
	set cursx [lindex $chartxrange 0]
	set curex [lindex $chartxrange 1]
	set cursize [expr $curex-$cursx]
	switch $first {
		"" {
			return [list $cursx $curex]
		}
		moveto {
			set fraction [lindex $args 1]
			set cursx [expr int($fraction*$size)]
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set cursx [expr $cursx+$number*$cursize]
			} else {
				set cursx [expr $cursx+$number]
			}
		}
	}
	if {[expr $cursx+$cursize]>$xe} {set cursx [expr $xe-$cursize]}
	if {$cursx<$xb} {set cursx $xb}
	$object.options.grid configure -xrange [list $cursx [expr $cursx+$cursize]]
	$object.options.chart configure -xrange [list $cursx [expr $cursx+$cursize]]
	Classy::todo $object _setscroll
}

#doc {LineChartDialog command yview} cmd {
#pathname yview ?args?
#} descr {
#}
Classy::LineChartDialog method yview {args} {
	private $object options
	set chartyrange [$object.options.chart configure -yrange]
	set yrange $options(-yrange)
	set first [lindex $args 0]
	set yb [lindex $yrange 0]
	set ye [lindex $yrange 1]
	set size [expr $ye-$yb]
	set cursy [lindex $chartyrange 0]
	set curey [lindex $chartyrange 1]
	set cursize [expr $curey-$cursy]
	switch $first {
		"" {
			return [list $cursy $curey]
		}
		moveto {
			set fraction [lindex $args 1]
			set cursy [expr int((1-$fraction)*$size)]
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set cursy [expr $cursy-$number*$cursize]
			} else {
				set cursy [expr $cursy-$number]
			}
		}
	}
	if {[expr $cursy+$cursize]>$ye} {set cursy [expr $ye-$cursize]}
	if {$cursy<$yb} {set cursy $yb}
	$object.options.grid configure -yrange [list $cursy [expr $cursy+$cursize]]
	$object.options.chart configure -yrange [list $cursy [expr $cursy+$cursize]]
	Classy::todo $object _setscroll
}

::Classy::LineChartDialog method _setscroll {args} {
	private $object options
	set xrange [$object.options.chart configure -xrange]
	set xwidth [expr [lindex $options(-xrange) 1] - [lindex $options(-xrange) 0]]
	$object.options.hbar	set [expr [lindex $xrange 0]/double($xwidth)] [expr [lindex $xrange 1]/double($xwidth)]
	set yrange [$object.options.chart configure -yrange]
	set ywidth [expr [lindex $options(-yrange) 1] - [lindex $options(-yrange) 0]]
	$object.options.vbar	set [expr 1.0-[lindex $yrange 1]/double($ywidth)] [expr 1.0-[lindex $yrange 0]/double($ywidth)]
	$object.options.canvas raise Classy::LineChart
}

Classy::LineChartDialog method _autoscale	{} {
	private $object options
	if ![string length [info commands $object.options.chart]] return
	if $options(-autoscale) {
		Classy::todo $object _fill
	}
}

Classy::LineChartDialog method _fill	{{w {}}} {
		set area [[$object component chart] configure -area]
		set x [lindex $area 0]
		set y [lindex $area 1]
		set mx [expr {[winfo width [$object component canvas]]-$x}]
		set my [expr {[winfo height [$object component canvas]]-$y-25}]
		if {"$w" != ""} {
			$w.area.xmax nocmdset $mx
			$w.area.ymax nocmdset $my
		}
		$object chartconfigure -area [list $x $y $mx $my]
		$object _setscroll
}

Classy::LineChartDialog method print {{tag all} args} {
	set w $object.options.canvas
	Classy::update Classy::LineChartDialog-print idletasks
	foreach {x1 y1 x2 y2} [$w bbox all] break
	set m [winfo pixels $w 1c]
	set x1 [expr {$x1 - $m}]
	set y1 [expr {$y1 - $m}]
	set x2 [expr {$x2 + $m}]
	set y2 [expr {$y2 + $m}]
	if {![Classy::Printer dialog]} return
	Classy::Printer printcanvas -printregion [list $x1 $y1 $x2 $y2] $w
	Classy::Printer print
	Classy::update Classy::LineChartDialog-print2 idletasks
}
