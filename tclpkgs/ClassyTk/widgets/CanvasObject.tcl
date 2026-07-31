# *************************************************
#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# CanvasObject
# ----------------------------------------------------------------------
#doc CanvasObject title {
#CanvasObject
#} index {
# Charts
#} shortdescr {
# grid that can be displayed on canvas
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# <b>A CanvasObject is not a widget type</b>. It is a class whose objects can 
# be associated with a canvas widget. When a CanvasObject instance is 
# associated with a canvas, it will draw on this canvas. 
# Several CanvasObject objects can be associated
# with the same canvas.
#}
#doc {CanvasObject options} h2 {
#	CanvasObject specific options
#} descr {
# BarcHart objects support the following options in its configure method
#<dl>
#<dt>-canvas<dd>name of canvas to draw the barchart
#<dt>-area<dd>area in which to diplay the chart (a list of four numbers)
#<dt>-boxwidth<dd>display a rectangle with this width showing the area 
#<dt>-boxcolor<dd>color of area rectangle
#</dl>
#}
#doc {CanvasObject command} h2 {
#	CanvasObject specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Class subclass Classy::CanvasObject

Classy::CanvasObject method init {args} {
	super init
	private $class actions
	private $object options id
	array set options {
		-canvas {} -area {}
		-boxwidth 1 -boxcolor black
	}
	set id ""
	array set actions {
		-canvas {
			private $object options id
			set options(-area) [list 25 10 [expr [winfo width $value]-10] [expr [winfo height $value]-25]]
			::Classy::todo $object redraw
			::Classy::todo $object _redrawbox
		}
		-tag {
			if {"options(-canvas)" == ""} return
			::Classy::todo $object redraw
		}
		-area {
			if {"options(-canvas)" == ""} return
			::Classy::todo $object redraw
			::Classy::todo $object _redrawbox
		}
		-boxwidth {
			if {"options(-canvas)" == ""} return
			::Classy::todo $object _redrawbox
		}
		-boxcolor {
			if {"options(-canvas)" == ""} return
			::Classy::todo $object _redrawbox
		}
	}
	eval $object configure $args
	return $object
}


#doc {CanvasObject command destroy} cmd {
#pathname destroy 
#} descr {
#}
Classy::CanvasObject method destroy {} {
	private $object options
	$options(-canvas) delete $options(-tag)
	Classy::update Classy::CanvasObject-destroy idletasks
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::CanvasObject method _redrawbox {} {
	private $object options id
	if {$options(-boxwidth) != 0} {
		if {"$id" == ""} {
			set id [eval {$options(-canvas) create rectangle} $options(-area) -tags __co::$object]
		} else {
			eval $options(-canvas) coords $id $options(-area)
		}
		$options(-canvas) itemconfigure $id -width $options(-boxwidth) -outline $options(-boxcolor)
	} else {
		if {"$id" != ""} {
			$options(-canvas) delete $id
			set id ""
		}
	}
}

#doc {CanvasObject command configure} cmd {
#pathname configure ?option? ?value? ?option value ...?
#} descr {
#}
Classy::CanvasObject method configure {args} {
	private $class actions
	private $object options id
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
			if {(![info exists $actions($option)])&&([llength $actions($option)]>0)} {
				eval $actions($option)
			}
			set options($option) $value
		}
	}
}

#doc {CanvasObject command cget} cmd {
#pathname cget option
#} descr {
#}
Classy::CanvasObject method cget {option} {
	private $object options
	return $options($option)
}

#doc {CanvasObject command redraw} cmd {
#pathname redraw
#} descr {
#}
Classy::CanvasObject method redraw {args} {
}

