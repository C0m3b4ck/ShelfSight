#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# ::Classy::BarChartDialog
# ----------------------------------------------------------------------
#doc BarChartDialog title {
#BarChartDialog
#} index {
# Charts
#} shortdescr {
# Dialog presenting a barchart and several options for its display
#} descr {
# subclass of <a href="Dialog.html">Dialog</a><br>
#}
#doc {BarChartDialog options} h2 {
#	BarChartDialog specific options
#}
#doc {BarChartDialog command} h2 {
#	BarChartDialog specific methods
#}

bind Classy::BarChartDialog <Configure> [list %W _autoscale]

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Classy::Dialog subclass ::Classy::BarChartDialog

Classy::BarChartDialog method init {args} {
	super init -resize {1 1}
	set w $object.options
	$object add print "Print" "$object print"
	$object add rangeconfig "Configure Ranges" "$object rangeconfigure"
	$object add dataconfig "Configure Data" "$object dataconfigure"
	frame $w.view
	canvas $w.canvas -bg white
	scrollbar $w.vbar -orient vertical -command "$object yview "
	scrollbar $w.hbar -orient horizontal -command "$object xview "
	grid $w.vbar -in $w.view -row 0 -column 0 -sticky ns
	grid $w.canvas -in $w.view -row 0 -column 1 -sticky nwse
	grid $w.hbar -row 1 -column 1 -in $w.view -sticky we
	grid columnconfigure $w.view 1 -weight 1
	grid rowconfigure $w.view 0 -weight 1
	frame $w.controls
	bind $w.canvas <Configure> [list $object _autoscale]
	checkbutton $w.autoscale -text "Autoscale" -variable [privatevar $object options(-autoscale)] \
		-onvalue 1 -offvalue 0 -command "$object _autoscale"
	checkbutton $w.stacked -text "Stacked" -variable [privatevar $object.options.chart options(-stacked)] \
		-onvalue 1 -offvalue 0 -command "$object _newvalues"
	checkbutton $w.percent -text "Percentages" -variable [privatevar $object.options.chart options(-percentages)]\
		-onvalue 1 -offvalue 0 -command "$object _newvalues"
	Classy::NumEntry $w.displace -label "Displace" -width 5 -min {-1} -max 1 -increment 0.1 \
		-command "$object _newvalues" -textvariable [privatevar $object.options.chart options(-displace)]
	$w.displace nocmdset 0
	Classy::NumEntry $w.barwidth -label "Barwidth" -width 5 -min 0 -max 1 -increment 0.1 \
		-command "$object _newvalues" -textvariable [privatevar $object.options.chart options(-barwidth)]
	$w.barwidth nocmdset 1
	grid $w.autoscale $w.stacked $w.percent $w.displace $w.barwidth -in $w.controls -sticky we
	pack $w.view -fill both -expand yes
	pack $w.controls -fill y
	Classy::update Classy::BarChartDialog-init idletasks
	Classy::ChartGrid new $w.grid -canvas $w.canvas -xrange {0 20} -yrange {0 100}
	Classy::BarChart new $w.chart -tag barchart -canvas $w.canvas -xrange {0 20} -yrange {0 100}
	# REM Create bindings
	# -------------------
	bind $w.canvas <<Action>> "$w.chart configure -legendpos {%x %y}"
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	Classy::update Classy::BarChartDialog-init2 idletasks
	$object _setscroll
	return $object
}

Classy::BarChartDialog component canvas {$object.options.canvas}
Classy::BarChartDialog component chart {$object.options.chart}
Classy::BarChartDialog component grid {$object.options.grid}

# ------------------------------------------------------------------
#  Widget destruction
# ------------------------------------------------------------------
Classy::BarChartDialog method destroy {} {
	catch {$object.options.grid destroy}
	catch {$object.options.chart destroy}
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

#doc {BarChartDialog options -autoscale} option {-autoscale autoScale AutoScale} descr {
#}
Classy::BarChartDialog addoption -autoscale {autoScale AutoScale 1} {
	set value [true $value]
	Classy::todo $object _autoscale
}

#doc {BarChartDialog options -xrange} option {-xrange xRange XRange} descr {
#}
Classy::BarChartDialog addoption -xrange {xRange XRange {0 20}} {
	set range [$object.options.chart configure -xrange]
	set min [lindex $range 0]
	set max [lindex $range 1]
	if {$min < [lindex $value 0]} {
		set min [lindex $value 0]
	}
	if {$max > [lindex $value 1]} {
		set max [lindex $value 1]
	}
	$object.options.grid configure -xrange [list $min $max]
	$object.options.chart configure -xrange [list $min $max]
	$object _setscroll
}

#doc {BarChartDialog options -yrange} option {-yrange yRange YRange} descr {
#}
Classy::BarChartDialog addoption -yrange {yRange YRange {0 100}} {
	set range [$object.options.chart configure -yrange]
	set min [lindex $range 0]
	set max [lindex $range 1]
	if {$min < [lindex $value 0]} {
		set min [lindex $value 0]
	}
	if {$max > [lindex $value 1]} {
		set max [lindex $value 1]
	}
	$object.options.grid configure -yrange [list $min $max]
	$object.options.chart configure -yrange [list $min $max]
	$object _setscroll
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::BarChartDialog method _newvalues {args} {
	private $object keepyrange keepchartheight
	set w $object.options
	if {[$w.chart configure -percentages] == 1} {
		$w.chart configure -yrange {0 100}
		$w.grid configure -yrange {0 100}
	}
	$w.chart redraw
	$object.options.canvas raise Classy::BarChart
}

#doc {BarChartDialog command dataset} cmd {
#pathname dataset name data
# A barchart can have several ranges of data. Each range has a name.
# This method is used to set (or change) the data in a range.
#} descr {
#}
Classy::BarChartDialog method dataset {name data} {
	$object.options.chart dataset $name $data
}

#doc {BarChartDialog command dataget} cmd {
#pathname dataget name
#} descr {
# returns the current data in range $name
#}
Classy::BarChartDialog method dataget {name} {
	$object.options.chart dataget $name
}

#doc {BarChartDialog command datadelete} cmd {
#pathname datadelete name
#} descr {
# delete the range with name $name
#}
Classy::BarChartDialog method datadelete {name} {
	$object.options.chart datadelete $name
}

#doc {BarChartDialog command switchdata} cmd {
#pathname switchdata name
#} descr {
#}
Classy::BarChartDialog method switchdata {item} {
	private $object data config
	set chart $object.options.chart
	if [info exists data($item)] {
		$chart dataset $item [set data($item)]
		eval {$chart barconfigure $item} [set config($item)]
		unset data($item)
		unset config($item)
	} else {
		set data($item) [$chart dataget $item]
		set temp [$chart barconfigure $item]
		set config($item) [list_merge [list_subindex $temp 0] [list_subindex $temp 4]]
		$chart datadelete $item
	}
}

#doc {BarChartDialog command dataconfigure} cmd {
#pathname dataconfigure
#} descr {
# pop up a dialog to change the properties of the barchart data
#}
Classy::BarChartDialog method dataconfigure {} {
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
			set color [lindex [$chart barconfigure "$element" -fill] 4]
			set color [Classy::getcolor -initialcolor $color -title "$element fill color"]
			$chart barconfigure "$element" -fill $color
			$b configure -bg $color
		}]
		$b configure -bg [lindex [$chart barconfigure "$element" -fill] 4]
		button $w.line$num -text "Line color" -command [varsubst {b chart element} {
			set color [lindex [$chart barconfigure "$element" -outline] 4]
			set color [Classy::getcolor -initialcolor $color -title "$element fill color"]
			$chart barconfigure "$element" -outline $color
			$b configure -fg $color
		}]
		$b configure -fg [lindex [$chart barconfigure "$element" -outline] 4]
		Classy::NumEntry $w.width$num -label "Line width" -width 5 \
			-command [list $chart barconfigure $element -width]
		$w.width$num	set [lindex [$chart barconfigure $element -width] 4]
		grid $w.label$num $w.fill$num $w.line$num $w.width$num -sticky we
		incr num
	}
}

#doc {BarChartDialog command rangeconfigure} cmd {
#pathname rangeconfigure 
#} descr {
# pop up a dialog to change the properties of the barchart ranges
#}
Classy::BarChartDialog method rangeconfigure {} {
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
		$object _setscroll
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
	checkbutton $w.vertical -text "Vertical labels" \
		-onvalue vertical -offvalue horizontal \
		-variable [privatevar $object.options.chart options(-labelorient)] \
		-command "$chart redraw"
	button $w.fill -text "Fill drawing" -command [list $object _fill $w]
	grid $w.viewl - -sticky we
	grid $w.view - -sticky we
	grid $w.fulll - -sticky we
	grid $w.full - -sticky we
	grid $w.areal - -sticky we
	grid $w.area - -sticky we
	grid $w.fill $w.vertical -sticky we
	grid columnconfigure $w 0 -weight 1
	grid columnconfigure $w 1 -weight 1
}

Classy::BarChartDialog method _autoscale	{} {
	private $object options
	if ![string length [info commands $object.options.chart]] return
	if $options(-autoscale) {
		Classy::todo $object _fill
	}
}

Classy::BarChartDialog method _fill	{{w {}}} {
	set area [$object.options.chart configure -area]
	set x [lindex $area 0]
	set y [lindex $area 1]
	set mx [expr {[winfo width $object.options.canvas]-$x}]
	set my [expr {[winfo height $object.options.canvas]-$y-25}]
	if {"$w" != ""} {
		$w.area.xmax nocmdset $mx
		$w.area.ymax nocmdset $my
	}
	$object chartconfigure -area [list $x $y $mx $my]
	$object.options.canvas raise Classy::BarChart
	$object _setscroll
}

#doc {BarChartDialog command chartconfigure} cmd {
#pathname chartconfigure ?option? ?value? ?options value ...?
#} descr {
# change the <a href="BarChart.html">options of the displayed barchart</a>
#}
Classy::BarChartDialog method chartconfigure {args} {
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
					$object.options.grid configure $option $value
					$object.options.chart configure $option $value
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

#doc {BarChartDialog command xview} cmd {
#pathname xview ?args?
#} descr {
#}
Classy::BarChartDialog method xview {args} {
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
	$object _setscroll
}

#doc {BarChartDialog command yview} cmd {
#pathname yview ?args?
#} descr {
#}
Classy::BarChartDialog method yview {args} {
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
	$object _setscroll
}

Classy::BarChartDialog method _setscroll {args} {
	private $object options
	set xrange [$object.options.chart configure -xrange]
	set xwidth [expr [lindex $options(-xrange) 1] - [lindex $options(-xrange) 0]]
	$object.options.hbar	set [expr [lindex $xrange 0]/double($xwidth)] [expr [lindex $xrange 1]/double($xwidth)]
	set yrange [$object.options.chart configure -yrange]
	set ywidth [expr [lindex $options(-yrange) 1] - [lindex $options(-yrange) 0]]
	$object.options.vbar	set [expr 1.0-[lindex $yrange 1]/double($ywidth)] [expr 1.0-[lindex $yrange 0]/double($ywidth)]
	$object.options.canvas raise Classy::BarChart
}

Classy::BarChartDialog method print {{tag all} args} {
	set w $object.options.canvas
	Classy::update Classy::BarChartDialog-print idletasks
	foreach {x1 y1 x2 y2} [$w bbox all] break
	set m [winfo pixels $w 1c]
	set x1 [expr {$x1 - $m}]
	set y1 [expr {$y1 - $m}]
	set x2 [expr {$x2 + $m}]
	set y2 [expr {$y2 + $m}]
	if {![Classy::Printer dialog]} return
	Classy::Printer printcanvas -printregion [list $x1 $y1 $x2 $y2] $w
	Classy::Printer print
	Classy::update Classy::BarChartDialog-print2 idletasks
}
