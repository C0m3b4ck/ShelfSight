# -------------------- Tools --------------------

proc filltool {w} {
	button $w -image [Classy::geticon fill]
	return [varsubst w {
		$w configure -command [list object_fill %W]
	}]
}

proc outlinetool {w} {
	button $w -image [Classy::geticon outline]
	return [varsubst w {
		$w configure -command [list object_outline %W]
	}]
}

proc fonttool {w} {
	button $w -image [Classy::geticon font]
	return [varsubst w {
		$w configure -command [list object_font %W]
	}]
}

proc contenttool {w} {
	Classy::Entry $w -label Text -width 6
	return [varsubst w {
		$w configure -command [list object_text %W] -textvariable [privatevar [getobj %W] current(-text)]
	}]
}

proc widthtool {w} {
	Classy::NumEntry $w -label Width -min 0 -increment 0.5 -warn 0 -width 4
	return [varsubst w {
		$w configure -command [list object_width %W] -textvariable [privatevar [getobj %W] current(-width)]
	}]
}

proc xtool {w} {
	Classy::NumEntry $w -label X -min 0 -increment 0.5 -warn 0 -width 5
	return [varsubst w {
		$w configure -command [list object_x %W] -textvariable [privatevar [getobj %W] current(px)]
	}]
}

proc ytool {w} {
	Classy::NumEntry $w -label Y -min 0 -increment 0.5 -warn 0 -width 5
	return [varsubst w {
		$w configure -command [list object_y %W] -textvariable [privatevar [getobj %W] current(py)]
	}]
}

proc wtool {w} {
	Classy::NumEntry $w -label W -min 0 -increment 0.5 -warn 0 -width 5
	return [varsubst w {
		$w configure -command [list object_w %W] -textvariable [privatevar [getobj %W] current(pw)]
	}]
}

proc htool {w} {
	Classy::NumEntry $w -label H -min 0 -increment 0.5 -warn 0 -width 5
	return [varsubst w {
		$w configure -command [list object_h %W] -textvariable [privatevar [getobj %W] current(ph)]
	}]
}

proc smoothtool {w} {
	checkbutton $w -image [Classy::geticon smooth] -indicator off
	return [varsubst w {
		$w configure -command "object_smoothline %W \[get \[privatevar [getobj %W] current(-smooth)\]\]" -variable [privatevar [getobj %W] current(-smooth)]
	}]
}

proc arrowtool {w} {
	Classy::OptionMenu $w -indicator 0 \
		-list {none first last both} \
		-images [list [Classy::geticon arrow_none] [Classy::geticon arrow_left] [Classy::geticon arrow_right] [Classy::geticon arrow_both]]
	return [varsubst w {
		$w configure -command [list line_cap %W] -textvariable [privatevar [getobj %W] current(-arrow)]
	}]
}

proc capstyletool {w} {
	Classy::OptionMenu $w -indicator 0 \
		-list {but round projecting} \
		-images [list [Classy::geticon end_but] [Classy::geticon end_round] [Classy::geticon end_projecting]]
	return [varsubst w {
		$w configure -command [list line_cap %W] -textvariable [privatevar [getobj %W] current(-capstyle)]
	}]
}

proc joinstyletool {w} {
	Classy::OptionMenu $w -indicator 0 \
		-list {round miter bevel} \
		-images [list [Classy::geticon join_round] [Classy::geticon join_miter] [Classy::geticon join_bevel]]
	return [varsubst w {
		$w configure -command [list object_joinstyle %W] -textvariable [privatevar [getobj %W] current(-joinstyle)]
	}]
}

proc justifytool {w} {
	Classy::OptionMenu $w -indicator 0 \
		-list {left center right} \
		-images [list [Classy::geticon justify_left] [Classy::geticon justify_center] [Classy::geticon justify_right]]
	return [varsubst w {
		$w configure -command [list object_justify %W] -textvariable [privatevar [getobj %W] current(-justify)]
	}]
}

proc arrowshapetool {w} {
	button $w -image [Classy::geticon arrowshape] -command {arrowshapedialog .arrowshapedialog}
	return ""
}

proc arrowshapedialog {w} {
	catch {destroy $w}
	Classy::Dialog $w -title "Arrow shape"
	set c [get status(current) .mainw]
	Classy::NumEntry $w.options.l -label L -command [list line_cap $c] -textvariable [privatevar [getobj $c] current(arrow_l)]
	Classy::NumEntry $w.options.sl -label SL -command [list line_cap $c] -textvariable [privatevar [getobj $c] current(arrow_sl)]
	Classy::NumEntry $w.options.w -label W -command [list line_cap $c] -textvariable [privatevar [getobj $c] current(arrow_w)]
	pack $w.options.l $w.options.sl $w.options.w -fill x
}

proc tagstool {w} {
	Classy::Entry $w -label Tags -width 10
	return [varsubst w {
		$w configure -command [list object_tags %W] -textvariable [privatevar [getobj %W] current(-tags)]
	}]
}

proc selectstippletool {w} {
	Classy::Entry $w -label Select -combo 10 -combopreset {echo {selectstipple solid gray75 gray50 gray25}}
	return [varsubst w {
		$w configure -command [list [getobj %W].canvas configure -selectstipple] -textvariable [privatevar [getobj %W].canvas current(-selectstipple)]
	}]
}

# -------------------- Routines --------------------

proc object_width {w value} {
	set object [getobj $w]
	private $object canvas
	$canvas itemconfigure _sel -width $value
	$canvas itemconfigure _papercol -width 0
}

proc object_text {w value} {
	set object [getobj $w]
	private $object canvas
	$canvas itemconfigure _sel -text $value
}

proc object_outline {w} {
	set object [getobj $w]
	private $object canvas
	if 1 {
		Classy::getcolor -title "Outline color" -command [list object_changeoutline $object]
	} else {
		object_changeoutline [Classy::getcolor -title "Outline color"]
	}
}

proc object_changeoutline {object color} {
	private $object canvas
	$canvas itemconfigure _sel -outline $color
	$canvas itemconfigure _papercol -outline [$canvas cget -papercolor]
}

proc object_fill {w} {
	set object [getobj $w]
	private $object canvas
	if 1 {
		Classy::getcolor -title "Fill color" -command [list object_changefill $object]
	} else {
		object_changefill [Classy::getcolor -title "Fill color"]
	}
}

proc object_changefill {object color} {
	private $object canvas
	$canvas itemconfigure _sel -fill $color
	$canvas itemconfigure _papercol -fill [$canvas cget -papercolor]
}

proc object_font {w} {
	set object [getobj $w]
	private $object canvas current
	if [catch {$object.canvas itemcget $current(item) -font} font] {
		if [catch {$object.canvas itemcget _sel -font} font] {
			set font {helvetica 12}
		}
	}
	set font [Classy::getfont -font $font -command [list object_changefont $object]]
}

proc object_changefont {object font} {
	private $object canvas
	if [llength $font] {
		$canvas itemconfigure _sel -font $font
		$canvas selection redraw
	}
}

proc object_joinstyle {w value} {
	set object [getobj $w]
	private $object canvas
	$canvas itemconfigure _sel -joinstyle $value
}

proc object_justify {w value} {
	set object [getobj $w]
	private $object canvas
	$canvas itemconfigure _sel -justify $value
}

proc object_smoothline {w value} {
	set object [getobj $w]
	private $object canvas
	$canvas itemconfigure _sel -smooth $value
}

proc line_cap {w args} {
	set object [getobj $w]
	private $object current canvas
	if ![string length $current(arrow_l)] {set current(arrow_l) 15}
	if ![string length $current(arrow_w)] {set current(arrow_w) 5}
	if ![string length $current(arrow_sl)] {set current(arrow_sl) 10}
	$current(w) itemconfigure _sel -arrow $current(-arrow) \
		-capstyle $current(-capstyle) \
		-arrowshape [list $current(arrow_sl) $current(arrow_l) $current(arrow_w)]
}

proc update_config {object} {
	private $object current canvas
	if ![info exists current(item)] return
	set item $current(item)
	foreach option {-width -text -smooth -arrow -arrowshape -capstyle -joinstyle -tags} {
		catch {set current($option) [$current(w) itemcget $item $option]}
	}
	set current(-tags) [list_sub $current(-tags) -exclude [list_find -regexp $current(-tags) ^_]]
	set current(-tags) [list_remove $current(-tags) current]
	if [info exists current(-arrowshape)] {
		set current(arrow_sl) [lindex $current(-arrowshape) 0]
		set current(arrow_l) [lindex $current(-arrowshape) 1]
		set current(arrow_w) [lindex $current(-arrowshape) 2]
	}
	set bbox [$canvas bbox _sel]
	set current(pw) [expr {[lindex $bbox 2]-[lindex $bbox 0]-4}]
	set current(ph) [expr {[lindex $bbox 3]-[lindex $bbox 1]-4}]
	if [info exists current(cpos)] {
		set c [$current(w) coords $item]
		set pos [expr {2*$current(cpos)}]
		set current(px) [lindex $c $pos]
		incr pos
		set current(py) [lindex $c $pos]
	} else {
		set bbox [$current(w) bbox $item]
		set current(px) [lindex $bbox 0]
		set current(py) [lindex $bbox 1]
	}
}

proc object_tags {w newtags} {
	set object [getobj $w]
	private $object current canvas
	foreach item [$canvas selection get] {
		set tags [$canvas itemcget $item -tags]
		set tags [list_sub $tags [list_find -regexp $tags ^_]]
		set tags [list_concat $tags $newtags]
		$canvas itemconfigure $item -tags $tags
	}
}

proc bottom_objects {w tag} {
	set object [getobj $w]
	private $object canvas
	$canvas lower $tag
	$canvas raise $tag _paper
}

proc top_objects {w tag} {
	set object [getobj $w]
	private $object canvas
	$canvas raise $tag
}

proc lower_objects {w tag} {
	set object [getobj $w]
	private $object canvas
	$canvas dtag _temp _temp
	$canvas addtag _temp withtag $tag
	set items [$canvas find withtag $tag]
	set low [lindex $items 0]
	foreach item $items {
		eval $canvas addtag _temp overlapping [$canvas bbox $item]
	}
	set items [$canvas find withtag _temp]
	set pos [lsearch $items $low]
	if {$pos>0} {
		incr pos -1
		$canvas lower $tag [lindex $items $pos]
	}
	$canvas dtag _temp _temp
}

proc raise_objects {w tag} {
	set object [getobj $w]
	private $object canvas
	$canvas dtag temp temp
	$canvas addtag temp withtag $tag
	set items [$canvas find withtag $tag]
	set high [lindex $items end]
	foreach item $items {
		eval $canvas addtag temp overlapping [$canvas bbox $item]
	}
	set items [$canvas find withtag temp]
	set pos [lsearch $items $high]
	set len [llength $items]
	incr len -1
	if {$pos<$len} {
		incr pos 1
		$canvas raise $tag [lindex $items $pos]
	}
	$canvas dtag temp temp
}

proc object_x {w x} {
	set object [getobj $w]
	private $object current canvas
	set zoom [$canvas zoom]
	if [info exists current(cpos)] {
		set x [expr {$x*$zoom}]
		set y [expr {$current(py)*$zoom}]
		$canvas coord $current(item) $current(cpos) $x $y
		$canvas noundo coords _ind_$current(cpos) $x $y
		set current(x) $x
	} else {
		set x [expr {$x*$zoom}]
		set xmove [expr {$x-$current(x)}]
		$canvas move _sel $xmove 0
		set current(x) $x
	}
}

proc object_y {w y} {
	set object [getobj $w]
	private $object current canvas
	set zoom [$canvas zoom]
	if [info exists current(cpos)] {
		set x [expr {$current(px)*$zoom}]
		set y [expr {$y*$zoom}]
		$canvas coord $current(item) $current(cpos) $x $y
		$canvas noundo coords _ind_$current(cpos) $x $y
		set current(y) $y
	} else {
		set y [expr {$y*$zoom}]
		set ymove [expr {$y-$current(y)}]
		$canvas move _sel 0 $ymove
		set current(y) $y
	}
}

proc scale_sel {w x y xscale yscale} {
	set object [getobj $w]
	private $object current canvas
	$canvas scale _sel $x $y $xscale $yscale
	set list [list_remdup [list_subindex [$canvas mitemcget _sel -tags] 0]]
	$canvas current $current(item)
	update_config $object
}

proc object_w {w pw} {
	set object [getobj $w]
	private $object current canvas
	set bbox [$canvas bbox _sel]
	set x [lindex $bbox 0]
	set y [lindex $bbox 1]
	set currentpw [expr {[lindex $bbox 2]-$x-4}]
	set xscale [expr {double($pw)/$currentpw}]
	if $current(scalelock) {
		set yscale $xscale
	} else {
		set yscale 1
	}
	scale_sel $object $x $y $xscale $yscale
}

proc object_h {w ph} {
	set object [getobj $w]
	private $object current canvas
	set bbox [$canvas bbox _sel]
	set x [lindex $bbox 0]
	set y [lindex $bbox 1]
	set currentph [expr {[lindex $bbox 3]-$y-4}]
	set yscale [expr {double($ph)/$currentph}]
	if $current(scalelock) {
		set xscale $yscale
	} else {
		set xscale 1
	}
	scale_sel $object $x $y $xscale $yscale
}
