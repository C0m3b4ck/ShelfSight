#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::ColorHSV
# ----------------------------------------------------------------------
#doc ColorHSV title {
#ColorHSV
#} index {
# Selectors
#} shortdescr {
# HSV color selection widget
#} descr {
# subclass of <a href="Widget.html">Widget</a><br>
# An HSV color selector for composing color values.
# A large part of this code has been inspired by the colorselect widget
# in the [Incr Tcl] 1.5 distribution
#}
#doc {ColorHSV options} h2 {
#	ColorHSV specific options
#} descr {
#}
#doc {ColorHSV command} h2 {
#	ColorHSV specific methods
#} descr {
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::ColorHSV

Classy::ColorHSV method init {args} {
	# REM Create object
	# -----------------
	super init
	scale $object.valV -orient vertical -from 100 -to 0
	pack $object.valV -fill y -side right
	canvas $object.valHS -borderwidth 0
	pack $object.valHS -expand yes -fill both -side left
	# REM Initialise variables and options
	# ------------------------------------
	private $object HSsize valH valS valV
	set HSsize 5
	set valH 0 
	set valS 0
	set valV 0
	# REM Create bindings
	# -------------------
	$object.valV configure -command "ClassyColorHSV___updateV $object"
	bind $object.valHS <Configure> "$object _drawHS"
	bind $object.valHS <<Action>> "$object _updateHS free %x %y"
	bind $object.valHS <<Action-Motion>> "$object _updateHS free %x %y"
	# REM Configure initial arguments
	# -------------------------------
	$object set white
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::ColorHSV chainoptions {$object}


#doc {ColorHSV options -size} option {-size size Size} descr {
# gives the desired size of the widget. (it is square, so no width and height.)
#}
Classy::ColorHSV addoption -size {size Size 400} {
	if {[winfo exists $object]} {
			$object.valHS configure -width $value -height $value
			$object _drawHS
	}
}

#doc {ColorHSV options -command} option {-command command Command} descr {
# command to be executed upon changing the color
#}
Classy::ColorHSV addoption -command {command Command {}}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------


#doc {ColorHSV command nocmdset} cmd {
#pathname set value
#} descr {
# set the current color to $value, without executing command
#}
Classy::ColorHSV method nocmdset {value} {
	private $object valV nocmd
	eval $object _set_rgb [winfo rgb $object $value]

	$object.valV config -command {}
	$object.valV set [lindex [split [expr $valV*100] .] 0]
	$object.valV configure -command "$object _updateV"
	if [winfo exists $object.valHS] {$object _drawHSpos}
}

#doc {ColorHSV command set} cmd {
#pathname set value
#} descr {
# set the current color to $value
#}
Classy::ColorHSV method set {value} {
	private $object options
	$object nocmdset $value
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

# ------------------------------------------------------------------
#  USAGE:  get
#
#  Returns the current color value.
# ------------------------------------------------------------------

#doc {ColorHSV command get} cmd {
#pathname get 
#} descr {
# get the current color
#}
Classy::ColorHSV method get {} {
	private $object valH valS valV
	return [$object _hsv2color $valH $valS $valV]
}

# ------------------------------------------------------------------
#  USAGE:  getHSV
#
#  Returns the current color value.
# ------------------------------------------------------------------

#doc {ColorHSV command getHSV} cmd {
#pathname getHSV 
#} descr {
# get the current color as a list of hue, saturation and value
#}
Classy::ColorHSV method getHSV {} {
	private $object valH valS valV
	return [list $valH $valS $valV]
}

# ------------------------------------------------------------------
#  METHOD:  _drawHS - update HS display in new window size
# ------------------------------------------------------------------
Classy::ColorHSV method _drawHS {} {
	private $object HSsize
	eval $object.valHS delete [$object.valHS find all]

	set w [winfo width $object.valHS]
	set wc [expr $w/2]
	set hc [expr [winfo height $object.valHS]/2]
	if {$hc<$wc} {set w [expr 2*$hc]}
	set blen [expr 0.85*$w/2]
	set slen [expr 0.1*$w/2]

	$object _drawCircle [expr $wc+$blen] $hc $slen {} red
	$object _drawCircle [expr $wc+0.5*$blen] [expr $hc-0.866*$blen] $slen {} yellow
	$object _drawCircle [expr $wc-0.5*$blen] [expr $hc-0.866*$blen] $slen {} green
	$object _drawCircle [expr $wc-$blen] $hc $slen {} cyan
	$object _drawCircle [expr $wc-0.5*$blen] [expr $hc+0.866*$blen] $slen {} blue
	$object _drawCircle [expr $wc+0.5*$blen] [expr $hc+0.866*$blen] $slen {} magenta

	$object _drawCircle $wc $hc $blen black white -tag main
	set HSsize $blen

	$object _drawHSpos
}

# ------------------------------------------------------------------
#  METHOD:  _drawGuide - draw special guides for fixed H/S values
# ------------------------------------------------------------------
Classy::ColorHSV method _drawGuide {mode} {
	private $object HSsize
	set wc [expr [winfo width $object.valHS]/2]
	set hc [expr [winfo height $object.valHS]/2]

	switch $mode {
		fixH {
			set xy [$object _hs2xy $valH 1.0]
			eval $object.valHS create line $wc $hc $xy \
					-width 3 -tags GUIDE
			eval $object.valHS create line $wc $hc $xy \
					-fill white -tags GUIDE
		}
		fixS {
			set len [expr $valS*$HSsize]
			set tags [$object _drawCircle $wc $hc $len white {}]
			foreach tag $tags {
					$object.valHS itemconfig $tag -tags GUIDE
			}
		}
		erase {
			$object.valHS delete GUIDE
		}
	}
}

# ------------------------------------------------------------------
#  METHOD:  _updateHS - update HS values from (x,y) coordinate
# ------------------------------------------------------------------
Classy::ColorHSV method _updateHS {mode x y} {
	private $object valH valS valV options
	set hs [$object _xy2hs $x $y]
	switch $mode {
		free {
			set valH [lindex $hs 0]
			set valS [lindex $hs 1]
		}
		fixH {
			set valS [lindex $hs 1]
		}
		fixS {
			set valH [lindex $hs 0]
		}
	}
	$object _drawHSpos

	update idletasks
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

# ------------------------------------------------------------------
#  METHOD:  _updateV - update V value from scale
# ------------------------------------------------------------------
Classy::ColorHSV method _updateV {val} {
	private $object valV options
	set valV [expr $val/100.0]
	$object _drawHSpos
	set command [get options(-command) ""]
	if {"$command" != ""} {
		uplevel #0 $command [list [$object get]]
	}
}

# ------------------------------------------------------------------
#  METHOD:  _drawHSpos - draw current HS position on HS display
# ------------------------------------------------------------------
Classy::ColorHSV method _drawHSpos {} {
	private $object HSsize valH valS valV
	$object.valHS delete MARKER

	set wc [expr [winfo width $object.valHS]/2]
	set hc [expr [winfo height $object.valHS]/2]
	set len [expr $valS*$HSsize]

	set tags [$object _drawCircle $wc $hc $len black {}]
	foreach tag $tags {
			$object.valHS itemconfig $tag -tags MARKER -width 3
	}
	$object.valHS raise GUIDE

	set xy [$object _hs2xy $valH $valS]
	set x [lindex $xy 0]
	set y [lindex $xy 1]
	set color [$object _hsv2color $valH $valS $valV]
	set tag [
			$object _drawCircle $x $y [expr 0.07*$HSsize] black $color
	]
	$object.valHS itemconfigure main -fill $color
	$object.valHS addtag MARKER withtag $tag
}

# ------------------------------------------------------------------
#  METHOD:  _drawCircle - draw circle into HS display
# ------------------------------------------------------------------
Classy::ColorHSV method _drawCircle {x y rad linec fillc args} {
	if {$fillc != ""} {
			set fill "-fill $fillc"
	} else {
			set fill "-fill {}"
	}
	if {$linec != ""} {
			set line "-outline $linec"
	} else {
			set line "-outline {}"
	}
	return [
			eval $object.valHS create oval \
					[expr $x-$rad] [expr $y-$rad] \
					[expr $x+$rad] [expr $y+$rad] \
					$fill $line $args
	]
}

# ------------------------------------------------------------------
#  METHOD:  _xy2hs - convert (x,y) on canvas to (hue,saturation)
#
#  INPUTS:  x = x-coordinate on canvas in pixels
#		   y = y-coordinate on canvas in pixels
# ------------------------------------------------------------------
Classy::ColorHSV method _xy2hs {x y} {
	private $object HSsize
	set dx [expr $x-([winfo width $object.valHS]/2)]
	set dy [expr ([winfo height $object.valHS]/2)-$y]

	if {$dx == 0.0} {
		if {$dy > 0} {
			set h 1.570795
		} else {
			set h 4.712385
		}
	} else {
		set h [expr atan($dy*1.0/$dx)]
	}
	if {$dy > 0} {
		if {$dx < 0} {
			set h [expr $h+3.14159]
		}
	} else {
		if {$dx < 0} {
			set h [expr $h+3.14159]
		} else {
			set h [expr $h+6.28318]
		}
	}
	set s [expr sqrt($dx*$dx+$dy*$dy)/$HSsize]
	if {$s > 1.0} {set s 1.0}
	return [list $h $s]
}

# ------------------------------------------------------------------
#  METHOD:  _hs2xy - convert (hue,saturation) to (x,y) on canvas
#
#  INPUTS:  h = hue angle in radians
#		   s = saturation value (0.0-1.0)
# ------------------------------------------------------------------
Classy::ColorHSV method _hs2xy {h s} {
	private $object HSsize
	set wc [expr [winfo width $object.valHS]/2]
	set hc [expr [winfo height $object.valHS]/2]

	return [list \
		[expr $wc+cos($h)*$s*$HSsize] \
		[expr $hc-sin($h)*$s*$HSsize] \
	]
}

# ------------------------------------------------------------------
#  METHOD:  _set_rgb - set current internal HSV values to RGB color
# ------------------------------------------------------------------
Classy::ColorHSV method _set_rgb {r g b} {
	private $object valH valS valV
	if {"$::tcl_platform(platform)" == "windows"} {
		set r [expr {$r/65280.0}]
		set g [expr {$g/65280.0}]
		set b [expr {$b/65280.0}]
	} else {
		set r [expr {$r/65535.0}]
		set g [expr {$g/65535.0}]
		set b [expr {$b/65535.0}]
	}
	set max 0
	if {$r > $max} {set max $r}
	if {$g > $max} {set max $g}
	if {$b > $max} {set max $b}
	set min 1
	if {$r < $min} {set min $r}
	if {$g < $min} {set min $g}
	if {$b < $min} {set min $b}
	set valV $max
	if {$max != 0} {
		set valS  [expr ($max-$min)/$max]
	} else {
		set valS 0
	}
	if {$valS != 0} {
		set rc [expr ($max-$r)/($max-$min)]
		set gc [expr ($max-$g)/($max-$min)]
		set bc [expr ($max-$b)/($max-$min)]
		if {$r == $max} {
			set valH [expr $bc-$gc]
		} elseif {$g == $max} {
			set valH [expr 2+$rc-$bc]
		} elseif {$b == $max} {
			set valH [expr 4+$gc-$rc]
		}
		set valH [expr $valH*1.0472]
		if {$valH < 0} {set valH [expr $valH+6.28318]}
	}
}

# ------------------------------------------------------------------
#  PROC:  _hsv2color - convert color value in HSV to #xxxxxx
# ------------------------------------------------------------------
Classy::ColorHSV method _hsv2color {h s v} {
	if {$s == 0} {
		set r $v
		set g $v
		set b $v
	} else {
		if {$h >= 6.28318} {set h [expr $h-6.28318]}
		set h [expr $h/1.0472]
		set f [expr $h-floor($h)]
		set p [expr $v*(1.0-$s)]
		set q [expr $v*(1.0-$s*$f)]
		set t [expr $v*(1.0-$s*(1.0-$f))]

		switch [lindex [split $h .] 0] {
			0 {set r $v; set g $t; set b $p}
			1 {set r $q; set g $v; set b $p}
			2 {set r $p; set g $v; set b $t}
			3 {set r $p; set g $q; set b $v}
			4 {set r $t; set g $p; set b $v}
			5 {set r $v; set g $p; set b $q}
		}
	}
	set rhex [$object _dec_to_hex [expr $r*255]]
	set ghex [$object _dec_to_hex [expr $g*255]]
	set bhex [$object _dec_to_hex [expr $b*255]]
	return #$rhex$ghex$bhex
}

Classy::ColorHSV method _dec_to_hex {val} {
	array set dec_to_hex_map {0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 a 11 b 12 c 13 d 14 e 15 f}
	set val [lindex [split $val .] 0]
	if {$val < 0} {set val 0}
	if {$val > 255} {set val 255}

	set dig1 [expr $val/16]
	set dig2 [expr $val-$dig1*16]
	return $dec_to_hex_map($dig1)$dec_to_hex_map($dig2)
}

