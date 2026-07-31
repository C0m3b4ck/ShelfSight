#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# Classy::Browser
# ----------------------------------------------------------------------
#doc Browser title {
#Browser
#} index {
# New widgets
#} shortdescr {
# generic browser widget
#} descr {
#}
#doc {Browser options} h2 {
#	Browser specific options
#}
#doc {Browser command} h2 {
#	Browser specific methods
#}

# ------------------------------------------------------------------
#  Widget creation
# ------------------------------------------------------------------

Widget subclass Classy::Browser

bind Classy::Browser <Configure> {[Classy::mainw %W] redraw}

Classy::Browser method init {args} {
	# REM Create object
	# -----------------
	super init
	canvas $object.c -xscrollcommand [list $object.hbar set]
	Classy::rebind $object.c $object
	scrollbar $object.vbar -command [list $object _view] -orient vertical
	scrollbar $object.hbar -command [list $object _view] -orient horizontal
	grid $object.c -row 0 -sticky nwse
	grid $object.hbar -row 1 -sticky we
	grid columnconfigure $object 0 -weight 1
	grid columnconfigure $object 1 -weight 0
	grid rowconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 0
	# REM Create bindings
	# -------------------
	# REM Initialise variables
	# ------------------------
	private $object curpos display
	set curpos 0
	set display(font) [Classy::optionget $object font Font BoldFont]
	set display(datafont) [Classy::optionget $object dataFont Font Font]
	# REM Configure initial arguments
	# -------------------------------
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy::Browser component canvas {$object.c}
# ------------------------------------------------------------------
#  Widget destroy
# ------------------------------------------------------------------

# ------------------------------------------------------------------
#  Widget options
# ------------------------------------------------------------------

Classy::Browser chainoptions {$object.c}
Classy::Browser chainoption -background {$object} -background {$object.c} -background
Classy::Browser chainoption -highlightbackground {$object} -highlightbackground {$object.c} -highlightbackground
Classy::Browser chainoption -highlightcolor {$object} -highlightcolor {$object.c} -highlightcolor

Classy::Browser addoption -minx {minX MinX 0} {
	Classy::todo $object redraw
}

Classy::Browser addoption -miny {minY MinY 0} {
	Classy::todo $object redraw
}

Classy::Browser addoption -padx {padX PadX 4} {
	Classy::todo $object redraw
}

Classy::Browser addoption -pady {padY PadY 4} {
	Classy::todo $object redraw
}

Classy::Browser addoption -padtext {padText PadText 4} {
	Classy::todo $object redraw
}

Classy::Browser addoption -font {font Font {}} {
	private display
	if {"$value" == ""} {
		set display(font) [Classy::optionget $object.c font Font BoldFont]
	} else {
		set display(font) [Classy::realfont $value]
	}
	Classy::todo $object redraw
}

Classy::Browser addoption -datafont {dataFont Font {}} {
	private display
	if {"$value" == ""} {
		set display(datafont) [Classy::optionget $object.c dataFont Font BoldFont]
	} else {
		set display(datafont) [Classy::realfont $value]
	}
	Classy::todo $object redraw
}

Classy::Browser addoption -data {data Data {}} {
	private $object sizes
	unset -nocomplain sizes
	Classy::todo $object redraw
}

Classy::Browser addoption -dataunder {dataUnder DataUnder 0} {
	set value [true $value]
	Classy::todo $object redraw
}

Classy::Browser addoption -dataalign {dataAlign DataAlign l} {
	Classy::todo $object redraw
}

Classy::Browser addoption -order {order Order column} {
	switch $value {
		column {
			grid forget $object.vbar
			grid $object.hbar -row 1 -column 0 -sticky we
		}
		row {
			grid forget $object.hbar
			grid $object.vbar -row 0 -column 1 -sticky ns
		}
		list {
			grid forget $object.hbar
			grid $object.vbar -row 0 -column 1 -sticky ns
		}
		default {
			error "unknown value \"$value\" for option -order: must be row, column or list"
		}
	}
	Classy::todo $object redraw
}

Classy::Browser addoption -gettext {getText GetText {}} {
	Classy::todo $object redraw
}

Classy::Browser addoption -getimage {getImage GetImage {}} {
	Classy::todo $object redraw
}

Classy::Browser addoption -getdata {getData GetData {}} {
	Classy::todo $object redraw
}

Classy::Browser addoption -list {list List {}} {
	private $object curpos active
	set curpos 0
	set active [lindex $value 0]
	Classy::todo $object redraw
}

# ------------------------------------------------------------------
#  Methods
# ------------------------------------------------------------------

Classy::Browser chainallmethods {$object.c} canvas

Classy::Browser method redraw {} {
	private $object options curpos endpos step
	Classy::update Classy::Browser-redraw idletasks
	switch $options(-order) {
		list {$object _redrawlist}
		column {$object _redrawcolumn}
		row {$object _redrawrow}
	}
	Classy::canceltodo $object redraw
}

Classy::Browser method _redrawrow {} {
	private $object options curpos endpos step dline display
	set minx $options(-minx)
	set miny $options(-miny)
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	$w delete all
	if {"$options(-list)" == ""} return
	set startx $padx
	set starty $pady
	set list [lrange $options(-list) $curpos end]
	set endpos $curpos
	set step 1
	set sh [winfo height $object.c]
	set sw [winfo width $object.c]
	set x $startx
	set y $starty
	set ny $y
	set notfirst 0
	set step 0
	set endpos $curpos
	unset -nocomplain dline
	set dline(num) 0
	foreach name $list {
		if {"$options(-gettext)" == ""} {
			set text $name
		} else {
			set text [eval $options(-gettext) {$name}]
		}
		if {"$options(-getimage)" == ""} {
			set image [Classy::geticon sm_file]
		} else {
			set image [eval $options(-getimage) {$name}]
		}
		set bx $x
		set by $y
		set id [$w create image $x $y -anchor nw -image $image -tags [list _$name image img_$name]]
		set bbox [$w bbox $id]
		set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
		set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
		if {$width < $minx} {
			set width $minx
		}
		if {$height < $miny} {
			set height $miny
		}
		set id [$w create text [expr {$x+$padtext}] [expr {$y+$height+$padtext}] \
			-anchor nw -justify center -text $text \
			-tags [list _$name text text_$name t] -font $display(font)]
		set bbox [$w bbox $id]
		set temp [expr {$y + $height + [expr {[lindex $bbox 3]-[lindex $bbox 1]}] + $padtext + $pady}]
		if {$temp > $ny} {set ny $temp}
		set temp [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
		if {$temp > $width} {
			set x [expr {$x + $temp + $padx}]
		} else {
			set x [expr {$x + $width + $padx}]
		}
		if $options(-dataunder) {
			set ny [$object _drawdataunder $x $ny $name $id]
			set x [list_shift ny]
		}
		incr endpos
		if {$notfirst&&($x > $sw)} {
			set notfirst 0
			set movex [expr {$startx - $bx}]
			$w move _$name $movex [expr {$ny - $by}]
			set bbox [$w bbox _$name]
			set x [expr {$x+$movex}]
			set y $ny
			if {$ny > $sh} break
			incr dline(num)
		}
		if {$dline(num) == 0} {incr step}
		set notfirst 1
		lappend dline($dline(num)) $name
	}
	$object _drawselection
	$object active set
	$object _setbar
}

Classy::Browser method _redrawcolumn {} {
	private $object options curpos endpos step sel dline display
	set minx $options(-minx)
	set miny $options(-miny)
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	$w delete all
	if {"$options(-list)" == ""} return
	set startx $padx
	set starty $pady
	set list [lrange $options(-list) $curpos end]
	set sh [winfo height $object.c]
	set sw [winfo width $object.c]
	set x $startx
	set y $starty
	set nx $x
	set notfirst 0
	set endpos $curpos
	set step 0
	set selfg [Classy::optionget $object selectForeground Background gray]
	set selbg [Classy::optionget $object selectBackground Foreground gray]
	unset -nocomplain dline
	set dline(num) 0
	foreach name $list {
		if {"$options(-gettext)" == ""} {
			set text $name
		} else {
			set text [eval $options(-gettext) {$name}]
		}
		if {"$options(-getimage)" == ""} {
			set image [Classy::geticon sm_file]
		} else {
			set image [eval $options(-getimage) {$name}]
		}
		set bx $x
		set by $y
		set id [$w create image $x $y -anchor nw -image $image -tags [list _$name image img_$name]]
		set bbox [$w bbox $id]
		set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
		set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
		if {$width < $minx} {
			$w move $id [expr {($minx - $width)/2}] 0
			set width $minx
		}
		if {$height < $miny} {
			$w move $id 0 [expr {($miny - $height)/2}]
			set height $miny
		}
		set id [$w create text [expr {$x+$width+$padtext}] [expr {$y+$height/2}] \
			-anchor w -text $text \
			-tags [list _$name text text_$name t] -font $display(font)]
		set bbox [$w bbox $id]
		set temp [expr {$x + $width + [expr {[lindex $bbox 2]-[lindex $bbox 0]}] + $padtext + $padx}]
		if {$temp > $nx} {set nx $temp}
		set y [expr {$y + $height + $pady}]
		if $options(-dataunder) {
			$w move $id 0 [expr {-$height/2}]
			$w itemconfigure $id -anchor nw
			set y [$object _drawdataunder $nx $y $name $id]
			set nx [list_shift y]
		}
		if {($y > $sh)&&$notfirst} {
			if !$options(-dataunder) {
				set nx [$object _drawdata $nx $names $items]
			}
			$w move _$name [expr {$nx - $bx}] [expr {$starty - $by}]
			set names {}
			set items {}
			set notfirst 0
			set bbox [$w bbox _$name]
			set x $nx
			set y [expr {[lindex $bbox 3]+$pady}]
			if {$x > $sw} break
			incr dline(num)
		}
		if {$dline(num) == 0} {incr step}
		lappend names $name
		incr endpos
		lappend items $id
		set notfirst 1
		lappend dline($dline(num)) $name
	}
	if !$options(-dataunder) {
		set nx [$object _drawdata $nx $names $items]
	}
	$object _drawselection
	$object active set
	$object _setbar
}

Classy::Browser method _panestart {w x y} {
	private $object pane
	set current [$object.c find withtag current]
	set pane(item) $current
	set pane(px) $x
	set coords [$object.c coords $current]
	set pane(ph) [lindex $coords end]
	eval $object.c coords $current [lreplace $coords end end 10000]
}

Classy::Browser method _panemove {w x y} {
	private $object pane
	$object.c move $pane(item) [expr $x-$pane(px)] 0
	set pane(px) $x
}

Classy::Browser method _panestop {w x y} {
	private $object options pane psize
	$object.c move $pane(item) [expr $x-$pane(px)] 0
	set pane(px) $x
	set id [lindex [$object.c itemcget $pane(item) -tags] 1]
	regsub {^pane_} $id {} id
	if {"$id" == "name"} {
		set psize($id) $x
	} else {
		set bbox [$object.c coords bg_$id]
		set psize($id) [expr {$x-[lindex $bbox 0]-2*$options(-padtext)}]
	}
	if {$psize($id)<5} {
		set psize($id) 5
	}
	$object.c configure -cursor {}
	$object redraw
}

Classy::Browser method _paneremove {w x y} {
	private $object pane psize
	set current [$object.c find withtag current]
	set id [lindex [$object.c itemcget $current -tags] 1]
	regsub {^pane_} $id {} id
	unset -nocomplain psize($id)
	$object.c configure -cursor {}
	$object redraw
}

Classy::Browser method _redrawlist {} {
	private $object options curpos endpos step psize sel display
	set minx $options(-minx)
	set miny $options(-miny)
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	$w delete all
	set startx $padx
	set starty $pady
	set list [lrange $options(-list) $curpos end]
	set endpos $curpos
	set step 1
	set sh [winfo height $object.c]
	set sw [winfo width $object.c]
	set x $startx
	set y $starty
	set nx $x
	set notfirst 0
	set items {}
	if !$options(-dataunder) {
		set id [$w create text $x $y \
			-anchor w -text name \
			-tags [list {} label_text] -font $display(font)]
		set bbox [$w bbox $id]
		set height [expr {[lindex $bbox 3]-[lindex $bbox 1]}]
		set width [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
		set hh [expr {$height/2}]
		set id [$w create line 0 [expr $y-$hh] $padtext [expr $y-$hh] $padtext [expr $y+$hh] \
			-tags [list {} pane_name pane] -width 2]
		if [info exists psize(name)] {$object.c itemconfigure $id -fill red}
		foreach dt $options(-data) {
			$w create text 0 $y -anchor e -text $dt -tags [list {} label_$dt d$dt] -font $display(font)
			set id [$w create line 0 [expr $y-$hh] $padtext [expr $y-$hh] $padtext [expr $y+$hh] \
				-tags [list {} pane_$dt pane] -width 2]
			if [info exists psize($dt)] {$object.c itemconfigure $id -fill red}
		}
		set y [expr {$y + $height + $pady}]
		$object.c move all 0 [expr {$height/2}]
		$object.c bind pane <Enter> [list $object.c configure -cursor sb_h_double_arrow]
		$object.c bind pane <Leave> [list $object.c configure -cursor {}]
		$object.c bind pane <<Action>> [list $object _panestart %W %x %y]
		$object.c bind pane <<Action-Motion>> [list $object _panemove %W %x %y]
		$object.c bind pane <<Action-ButtonRelease>> [list $object _panestop %W %x %y]
		$object.c bind pane <<Adjust>> [list $object _paneremove %W %x %y]
	}
	foreach name $list {
		if {"$options(-gettext)" == ""} {
			set text $name
		} else {
			set text [eval $options(-gettext) {$name}]
		}
		if {"$options(-getimage)" == ""} {
			set image [Classy::geticon sm_file]
		} else {
			set image [eval $options(-getimage) {$name}]
		}
		if {"$options(-getdata)" == ""} {
			set data {}
		} else {
			set data [eval $options(-getdata) {$name}]
		}
		set imid [$w create image $x $y -anchor nw -image $image -tags [list _$name image name img_$name]]
		set imbbox [$w bbox $imid]
		set height [expr {[lindex $imbbox 3]-[lindex $imbbox 1]}]
		set width [expr {[lindex $imbbox 2]-[lindex $imbbox 0]}]
		if {$width < $minx} {
			$w move $imid [expr {($minx - $width)/2}] 0
			set width $minx
		}
		if {$height < $miny} {
			$w move $imid 0 [expr {($miny - $height)/2}]
			set height $miny
		}
		set temp [expr {$y + $height + 2*$pady}]
		set ty [expr {$y+$height/2}]
		set id [$w create text [expr {$x+$width+$padtext}] $ty \
			-anchor w -text $text \
			-tags [list _$name text name text_$name t] -font $display(font)]
		lappend items $id
		set bbox [$w bbox $id]
		set temp [expr {$x + $width + [expr {[lindex $bbox 2]-[lindex $bbox 0]}] + $padtext + $padtext}]
		if {$temp > $nx} {set nx $temp}
		if !$options(-dataunder) {
			foreach dt $options(-data) d $data {
				$w create text 0 $ty \
					-anchor e -text $d -tags [list _$name d$dt ${dt}_$name t] -font $display(datafont)
			}
		}
		set y [expr {$y + $height + $pady}]
		if $options(-dataunder) {
			$w move $id 0 [expr {-$height/2+$padtext}]
			$w itemconfigure $id -anchor w
			set y [$object _drawdataunder $nx $y $name $id]
			set nx [list_shift y]
		}
		incr endpos
		if {$y > $sh} break
	}
	set cy $y
	set bgcol [$object.c cget -bg]
	if !$options(-dataunder) {
		if [info exists psize(name)] {
			set pos [expr {$psize(name)+$padtext}]
		} else {
			set bbox [$object.c bbox text]
			set pos [expr {[lindex $bbox 2]+$padtext}]
		}
		set id [$object.c create rectangle 0 0 $pos $sh -fill $bgcol -outline $bgcol -tags {{} bg_name}]
		$object.c move pane_name [expr {$pos-2*$padtext}] 0
		$object.c lower $id
		foreach dt $options(-data) d $data {
			if [info exists psize($dt)] {
				set size $psize($dt)
			} else {
				set bbox [$object.c bbox d$dt]
				set size [expr {[lindex $bbox 2]-[lindex $bbox 0]}]
			}
			if {"$options(-dataalign)"=="l"} {
				$object.c create rectangle \
					[expr {$pos-$padtext}] 0 [expr {$pos+$size+$padtext}] $sh \
					-tags [list {} bg_$dt] -fill $bgcol -outline $bgcol
				$object.c itemconfigure d$dt -anchor w
				$object.c move d$dt $pos 0
				$object.c move pane_$dt [expr {$pos+$size-$padtext}] 0
				set pos [expr {$pos+$size+$padtext}]
				$object.c raise bg_$dt
				$object.c raise d$dt
			} else {
				set pos [expr {$pos+$size}]
				$object.c create rectangle \
					[expr {$pos-$size-$padtext}] 0 [expr {$pos+$padtext}] $sh \
					-tags [list {} bg_$dt] -fill $bgcol -outline $bgcol
				$object.c move d$dt $pos 0
				$object.c move pane_$dt $pos 0
				set pos [expr {$pos+$padtext}]
				$object.c lower d$dt
				$object.c lower bg_$dt
			}
		}
		set id [$object.c create rectangle $pos 0 \
			$sw $sh -tags [list {} bg_end] -fill $bgcol -outline $bgcol]
		$object.c raise $id
		$object.c raise pane
		if {"$options(-dataalign)"=="r"} {
			$object.c lower name
			$object.c lower bg_name
		}
	}
	$object _drawselection
	$object active set
	$object _setbar
}

Classy::Browser method _drawdataunder {nx ny name id} {
	private $object options display
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	set bbox [$w bbox $id]
	set tempy [lindex $bbox 3]
	set tempx [lindex $bbox 0]
	if {"$options(-getdata)" == ""} {
		set data {}
	} else {
		set data [eval $options(-getdata) {$name}]
	}
	foreach dt $options(-data) d $data {
		set tempid [$w create text $tempx $tempy \
			-anchor nw -text $d -tags [list _$name d$dt ${dt}_$name t] -font $display(datafont)]
		set bbox [$w bbox $tempid]
		set tempy [lindex $bbox 3]
		set temp [expr {$tempx + [expr {[lindex $bbox 2]-[lindex $bbox 0]}] + $padx}]
		if {$temp > $nx} {set nx $temp}
	}
	set tempy [expr {$tempy+$pady}]
	if {$tempy > $ny} {set ny $tempy}
	return [list $nx $ny]
}

Classy::Browser method _drawselection {} {
	private $object options curpos endpos sel
	$object.c delete selection
	set sw [winfo width $object.c]
	set selfg [Classy::optionget $object selectForeground Background gray]
	set selbg [Classy::optionget $object selectBackground Foreground gray]
	$object.c itemconfigure t -fill black
	foreach name [lrange $options(-list) $curpos $endpos] {
		if [info exists sel($name)] {
			if {("$options(-order)" == "list")&&!$options(-dataunder)} {
				$object.c itemconfigure text_$name -fill $selfg
				set bbox [$object.c bbox img_$name]
				if {"$bbox" != ""} {
					set id [$object.c create rectangle \
						[lindex $bbox 0] [lindex $bbox 1] $sw [lindex $bbox 3]\
						-tags [list _$name name selection] -fill $selbg -outline $selbg]
					$object.c lower $id img_$name
				}
			} else {
				foreach item [$object.c find withtag _$name] {
					catch {$object.c itemconfigure $item -fill $selfg}
				}
				set bbox [$object.c bbox _$name]
				if {"$bbox" != ""} {
					set id [eval $object.c create rectangle $bbox \
						{-tags [list _$name selection] -fill $selbg -outline $selbg}]
					$object.c lower $id _$name
				}
			}
		}
	}
}

Classy::Browser method _drawdata {nx names items} {
	private $object options display
	set padx $options(-padx)
	set pady $options(-pady)
	set padtext $options(-padtext)
	set w $object.c
	set i 0
	set names [lrange $names 0 [expr [llength $items]-1]]
	foreach dt $options(-data) {
		set cx [expr {$nx-$padx+$padtext}]
		set nitems ""
		foreach item $items name $names {
			if {"$options(-getdata)" == ""} {
				set data {}
			} else {
				set data [eval $options(-getdata) {$name}]
			}
			set d [lindex $data $i]
			set y [lindex [$object.c coords $item] 1]
			set id [$w create text $cx $y \
				-anchor w -text $d -tags [list _$name d$dt ${dt}_$name t] -font $display(datafont)]
			set bbox [$w bbox $id]
			lappend nitems $id
			set temp [expr {$cx + [expr {[lindex $bbox 2]-[lindex $bbox 0]}]}]
			if {$temp > $nx} {set nx $temp}
		}
		foreach name $names item $nitems {
			$w coords $item $nx [lindex [$object.c coords $item] 1]
			$w itemconfigure $item -anchor e
		}
		incr i
		set nx [expr {$nx + $padx}]
	}
	return $nx
}

Classy::Browser method name {index {y {}}} {
	if {"$y" != ""} {
		set index [lindex [$object.c find overlapping $index $y $index $y] end]
	}
	set name [lindex [$object itemcget $index -tags] 0]
	return [string range $name 1 end]
}

Classy::Browser method type {index {y {}}} {
	if {"$y" != ""} {
		set index [lindex [$object.c find overlapping $index $y $index $y] end]
	}
	set tags [$object itemcget $index -tags]
	return [lindex $tags 1]
}

Classy::Browser method _view {args} {
	private $object options curpos endpos step
	set pagesize [expr {$endpos - $curpos}]
	set pos $curpos
	set size $pagesize
	set min 0
	set max [expr {[llength $options(-list)]-1}]
	switch [lindex $args 0] {
		"" {
			set end [expr {double($pos + $size)/$max}]
			if {$end > 1} {set end 1}
			return [list [expr {double($pos)/$max}] $end]
		}
		moveto {
			set fraction [lindex $args 1]
			set pos [expr $fraction*$max]
		}
		scroll {
			set number [lindex $args 1]
			set what [lindex $args 2]
			if {"$what"=="pages"} {
				set pos [expr {$pos + $number*$pagesize}]
			} else {
				set pos [expr {$pos + $number*$step}]
			}
		}
	}
	if {$pos > $max} {set pos $max}
	if {$pos < 0} {set pos 0}
	set curpos [expr {int($pos)}]
	$object redraw
}

Classy::Browser method _setbar {} {
	private $object options curpos endpos step
	set curlow $curpos
	set curhigh $endpos
	set min 0
	set max [expr {[llength $options(-list)]}]
	if {$curlow < $min} {set curlow $min}
	if {$curhigh < $min} {set curhigh $min}
	if {$curlow > $max} {set curlow $max}
	if {$curhigh > $max} {set curhigh $max}
	set realw [expr {$max - $min}]
	if {"$options(-order)" == "column"} {
		$object.hbar set [expr {double($curlow)/$realw}] [expr {double($curhigh)/$realw}]
	} else {
		$object.vbar set [expr {double($curlow)/$realw}] [expr {double($curhigh)/$realw}]
	}
}

Classy::Browser method selection {option args} {
	private $object options sel
	set list $options(-list)
	switch $option {
		clear {
			switch [llength $args] {
				0 {
					unset -nocomplain sel
				}
				1 {
					set name [lindex $args 0]
					set pos [lsearch -exact $list $name]
					if {$pos == -1} {
						return -code error "cannot select \"$name\": not in list"
					}
					unset -nocomplain sel($name)
				}
				2 {
					set pos [lsearch -exact $list [lindex $args 0]]
					if {$pos == -1} {
						return -code error "cannot select \"[lindex $args 0]\": not in list"
					}
					set end [lsearch -exact $list [lindex $args 1]]
					if {$end == -1} {
						return -code error "cannot select \"[lindex $args 1]\": not in list"
					}
					foreach name [lrange $list $pos $end] {
						unset -nocomplain sel($name)
					}
				}
				default {
						return -code error "wrong # args: should be \"$object selection clear ?first? ?last?\""
				}
			}
		}
		set {
			switch [llength $args] {
				0 {
					foreach name $list {
						set sel($name) 1
					}
				}
				1 {
					set name [lindex $args 0]
					set pos [lsearch -exact $list $name]
					if {$pos == -1} {
						return -code error "cannot select \"$name\": not in list"
					}
					set sel($name) 1
				}
				2 {
					set pos [lsearch -exact $list [lindex $args 0]]
					if {$pos == -1} {
						return -code error "cannot select \"[lindex $args 0]\": not in list"
					}
					set end [lsearch -exact $list [lindex $args 1]]
					if {$end == -1} {
						return -code error "cannot select \"[lindex $args 1]\": not in list"
					}
					foreach name [lrange $list $pos $end] {
						set sel($name) 1
					}
				}
				default {
						return -code error "wrong # args: should be \"$object selection set ?first? ?last?\""
				}
			}
		}
		includes {
			return [info exists sel([lindex $args 0])]
		}
		add {
			foreach name $args {
				if {[lsearch -exact $list $name] == -1} {
					return -code error "cannot select \"$name\": not in list"
				}
				set sel($name) 1
			}
		}
		delete {
			foreach name $args {
				unset -nocomplain sel($name)
			}
		}
		get {
			return [array names sel]
		}
		default {
			return -code error "unknown option \"$option\": should be one of clear, set includes, add, delete or get"
		}
	}
	Classy::todo $object _drawselection
}

Classy::Browser method edit {name type command} {
	private $object edit options id display
	if ![winfo exists $object.e] {
		entry $object.e -textvariable [privatevar $object edit] -relief sunken -bd 1
	}
	foreach el [$object.c find withtag _$name] {
		set t [lindex [$object.c itemcget $el -tags] 1]
		if {"$t" == "$type"} {
			set item $el
			break
		}
	}
	if ![info exists item] {
		return -code error "item not found"
	}
	set bbox [$object.c bbox $item]
	set x [lindex $bbox 0]
	set y [lindex $bbox 1]
	set h [expr {[lindex $bbox 3]-[lindex $bbox 1]+2}]
	if {"$type" == "text"} {
		$object.e configure -font $display(font)
	} else {
		$object.e configure -font $display(datafont)
	}
	switch $options(-order) {
		list {
			if !$options(-dataunder) {
				if {"$type" == "text"} {
					set coords [$object.c coords pane_name]
					set w [expr {[lindex $coords 0]-[lindex $bbox 0]+2}]
				} else {
					set coords [$object.c coords bg_$type]
					set w [expr {[lindex $coords 2]-[lindex $coords 0]}]
					$object.e configure -font $display(datafont)
				}
			} else {
				set w [expr {[winfo width $object.c]-$x-5}]
			}
		}
		column {
			set w [expr {[lindex $bbox 2]-[lindex $bbox 0]+2}]
		}
		row {
			set w [expr {[lindex $bbox 2]-[lindex $bbox 0]+2}]
		}
	}
	set edit [$object.c itemcget $item -text]
	catch {$object.c delete $id}
	set id [$object.c create window $x $y -anchor nw -window $object.e -width $w -height $h]
	bind $object.e <Return> [list $object _stopedit $command]	
}

Classy::Browser method _stopedit {command} {
	private $object edit id command
	$object.c delete $id
	uplevel #0 $command {$edit}
}

Classy::Browser method active {{option get} args} {
	private $object active
	switch $option {
		set {
			$object.c delete active
			if {"$args" != ""} {
				set active [lindex $args 0]
			}
			$object.c delete active
			set bbox [$object.c bbox _$active]
			if {"$bbox" != ""} {
				eval $object.c create rectangle $bbox {-tags {{} active} -outline darkgray}
			}
			return $active
		}
		get {
			return $active
		}
	}
}

Classy::Browser method move {dir} {
	private $object options active dline curpos endpos
	if {"$options(-order)" == "row"} {
		switch $dir {
			down {set dir right}
			up {set dir left}
			left {set dir up}
			right {set dir down}
		}
	}
	switch $dir {
		down {
			set pos [lsearch -exact $options(-list) $active]
			incr pos
			set result [lindex $options(-list) $pos]
			if {$pos >= [expr {$endpos-1}]} {
				if {$endpos != [llength $options(-list)]} {
					$object _view scroll 1 units
				}
			}
		}
		up {
			set pos [lsearch -exact $options(-list) $active]
			incr pos -1
			set result [lindex $options(-list) $pos]
			if {$pos < $curpos} {
				if {$curpos != 0} {
					$object _view scroll -1 units
				}
			}
		}
		left {
			for {set i 0} {$i <= $dline(num)} {incr i} {
				set pos [lsearch -exact $dline($i) $active]
				if {$pos != -1} break
			}
			if {$pos == -1} return
			if {$i==0} {
				if {$curpos == 0} return
				$object _view scroll -1 units
				Classy::update Classy::Browser-move idletasks
			} else {
				incr i -1
			}
			set result [lindex $dline($i) $pos]
			if {"$result" == ""} {
				set result [lindex $dline($i) end]
			}
		}
		right {
			for {set i 0} {$i <= $dline(num)} {incr i} {
				set pos [lsearch -exact $dline($i) $active]
				if {$pos != -1} break
			}
			if {$pos == -1} return
			if {$i >= [expr {$dline(num)-1}]} {
				if {$endpos == [llength $options(-list)]} return
				$object _view scroll 1 units
				Classy::update Classy::Browser-move idletasks
			} else {
				incr i
			}
			set result [lindex $dline($i) $pos]
			if {"$result" == ""} {
				set result [lindex $dline($i) end]
			}
		}
	}
	if {"$result" != ""} {
		$object active set $result
	}
}


