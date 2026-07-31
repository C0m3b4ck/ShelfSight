Widget subclass Classy::PagedCanvas

bind Classy::PagedCanvas <<Action-ButtonPress>> {focus %W}
Classy::bindmousewheel Classy::PagedCanvas 

Classy::PagedCanvas method init args {
	private $object pdata canvas
	setprivate $object canvas [super init canvas]
	array set pdata {
		page 1 drawable 1 object 1 breaksize 1 scale 1
		curpage 0 curdrawable 0 curx 0 cury 0 curtemplate {A4 portrait {2c 2c 17c 25.7c} {}}
	}
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

Classy::PagedCanvas chainoptions {$object}
Classy::PagedCanvas chainallmethods {$object} canvas

Classy::PagedCanvas method clear {{scale 1}} {
	private $object pdata canvas
	$canvas delete all
	set pdata(page) 1
	set pdata(drawables) {}
	set pdata(breaksize) 0
	set pdata(newline) 0
	set pdata(scale) $scale
	foreach name [array names pdata empty*] {
		unset pdata($name)
	}
}

Classy::PagedCanvas method _getscale {} {
	private $object pdata
	return $pdata(scale)
}

Classy::PagedCanvas method set_template {template} {
	private $object pdata
	set pdata(curtemplate) $template
}

Classy::PagedCanvas method addpage {{template {}} {pagedata {}}} {
	private $object canvas pdata
	if {$template eq ""} {
		set template $pdata(curtemplate)
	} else {
		set pdata(curtemplate) $template
	}
	set scale $pdata(scale)
	set pagex 0
	if {$pdata(page) == 1} {
		set pagey 0
	} else {
		set lastpage [expr {$pdata(page)-1}]
		set pagey [lindex [$canvas bbox page_$lastpage] end]
		set pagey [expr {$pagey+[winfo fpixels $object 5m]}]
	}
	foreach {pagesize orientation drawable code} {A4 portrait {2c 2c 19c 27.7c} {}} break
	foreach {pagesize orientation drawable code} $template break
	set pagesize [Classy::Printer pagesize $pagesize]
	foreach {width height} $pagesize break
	if {$orientation eq "landscape"} {
		set temp $width
		set width $height
		set height $temp
	} elseif {$orientation ne "portrait"} {
		error "unknown orientation $orientation: template format must be: pagesize portrait/landscape drawable_position code"
	}
	foreach {dx1 dy1 dx2 dy2} $drawable break
	foreach {v def} {width 595p height 842p dx1 2c dy1 2c dx2 -2c dy2 -2c} {
		if {[catch {winfo fpixels $object [get $v]} $v]} {
			set $v [winfo fpixels $object $def]
		}
	}
	if {$dx1 < 0} {set dx1 [expr {-$dx1}]}
	if {$dy1 < 0} {set dy1 [expr {-$dy1}]}
	if {$dx2 < 0} {set dx2 [expr {$width + $dx2}]}
	if {$dy2 < 0} {set dy2 [expr {$height + $dy2}]}
	if {$scale != 1} {
		foreach v {width height dx1 dy1 dx2 dy2} {
			set $v [expr {[get $v]*$scale}]
		}
	}
	set id [$canvas create rectangle 0 $pagey $width [expr {$pagey+$height}] -fill white -outline white -tags [list _paper page_$pdata(page)]]
	$canvas lower $id
	$canvas create rectangle $dx1 [expr {$pagey+$dy1}] $dx2 [expr {$pagey+$dy2}] -fill white -outline white -tags [list _drawable drawable_$pdata(page)]
	if {$code ne ""} {
		eval $code {$object $pdata(page) $pagedata}
	}
	set pdata(curpage) $pdata(page)
	set drawables [$canvas find withtag "_drawable&&drawable_$pdata(curpage)"]
	lappend pdata(drawables) $drawables
	foreach dr $drawables {
		set pdata(empty,$dr) 1
	}
	incr pdata(page)
	$object configure -scrollregion [$canvas bbox all]
	return [expr {$pdata(page)-1}]
}

# $object configure -scrollregion [$object bbox all]

#Classy::PagedCanvas method showpage {page} {
#	private $object canvas
#	set id [$canvas find withtag page_$page]
#	if {![isint $id]} return
#	set bbox [$canvas coords $id]
#	foreach {x y} $bbox break
#	$canvas move all [expr {-$x}] [expr {-$y}]
#	set bbox [$canvas coords $id]
#	$canvas configure -scrollregion $bbox
#}
#
#Classy::PagedCanvas method curpagenum {{page {}}} {
#	private $object pdata
#	if {$page eq ""} {
#		return $pdata(curpage)
#	} else {
#		set $pdata(curpage) $page
#	}
#}
#
#Classy::PagedCanvas method curpage {{page {}}} {
#	private $object pdata canvas
#	return [$canvas coords page_$pdata(curpage)]
#}
#
#Classy::PagedCanvas method curdrawable {} {
#	private $object pdata canvas
#	return [$canvas coords drawable_$pdata(curpage)]
#}
#
#Classy::PagedCanvas method cury {} {
#	private $object canvas pdata
#	$canvas dtag _temp
#	set drawable [$canvas coords drawable_$pdata(curpage)]
#	eval {$canvas addtag _temp enclosed} $drawable
#	$canvas dtag drawable_$pdata(curpage) _temp
#	set bbox [$canvas bbox _temp]
#	if {![llength $bbox]} {
#		return [lindex $drawable 1]
#	} else {
#		return [lindex $bbox end]
#	}
#}

Classy::PagedCanvas method _scaled_create {type arglist} {
	private $object canvas pdata
	set id [eval {$canvas} create $type $arglist]
	$canvas scale $id 0 0 $pdata(scale) $pdata(scale)
	switch $type {
		text {
			set font [Classy::zoomfont [$canvas itemcget $id -font] $pdata(scale)]
			set width [expr {[winfo fpixels $object [$canvas itemcget $id -width]] * $pdata(scale)}]
			$canvas itemconfigure $id -font $font -width $width
		}
		default {
			set width [expr {[winfo fpixels $object [$canvas itemcget $id -width]] * $pdata(scale)}]
			$canvas itemconfigure $id -width $width
		}
	}
	return $id
}

Classy::PagedCanvas method ccreate {type args} {
	$object _scaled_create $type $args
}

Classy::PagedCanvas method create {type args} {
	private $object canvas
	set id [$object _scaled_create $type $args]
	$canvas addtag _current withtag $id
	return $id
}

Classy::PagedCanvas method itemconfigure {tagOrId args} {
	private $object canvas pdata
	set len [llength $args]
	if {$len <= 1} {
		if {$len == 0} {
			set list [$canvas itemconfigure $tagOrId]
		} else {
			set list [list [$canvas itemconfigure $tagOrId $field]]
		}
		set pos 0
		foreach field [list_subindex $list 0] {
			if {$field eq "-font"} {
				lset list $pos 4 [Classy::zoomfont [lindex $list $pos 4] [expr {1.0/$pdata(scale)}]]
			} elseif {$field eq "-width"} {
				lset list $pos 4 [expr {[lindex $list $pos 4]/double($pdata(scale))}]
			}
			incr pos
		}
		if {$len == 0} {
			return $list
		} else {
			return [lindex $list 0]
		}
	} else {
		array set a $args
		if {[info exists a(-font)]} {
			set a(-font) [Classy::zoomfont $a(-font) $pdata(scale)]
		}
		if {[info exists a(-width)]} {
			set a(-width) [expr {$a(-width)*double($pdata(scale))}]
		}
		eval {$canvas} itemconfigure $tagOrId [array get a]
	}
}

Classy::PagedCanvas method itemcget {tagOrId field} {
	private $object canvas pdata
	set data [$canvas itemcget $tagOrId $field]
	if {$field eq "-font"} {
		return [Classy::zoomfont $data [expr {1.0/$pdata(scale)}]]
	} elseif {$field eq "-width"} {
		return [expr {$data/double($pdata(scale))}]
	} else {
		return $data
	}
}

Classy::PagedCanvas method bbox {args} {
	private $object canvas pdata
	set bbox [eval {$canvas} bbox $args]
	set result {}
	foreach el $bbox {
		lappend result [expr {$el/$pdata(scale)}]
	}
	return $result
}

Classy::PagedCanvas method coords {tagOrId args} {
	private $object canvas pdata
	if {[llength $args]} {
		if {[llength [lindex $args 0]] > 1} {set args [lindex $args 0]}
		set result {}
		foreach el $args {
			lappend result [expr {$el*$pdata(scale)}]
		}
		$canvas coords $tagOrId $result
	} else {
		set bbox [$canvas coords $tagOrId]
		set result {}
		foreach el $bbox {
			lappend result [expr {$el/$pdata(scale)}]
		}
		return $result
	}
}

Classy::PagedCanvas method _scaled_coords {tagOrId args} {
	private $object canvas pdata
	eval {$canvas coords $tagOrId} $args
}

Classy::PagedCanvas method move {tagOrId xAmount yAmount} {
	private $object canvas pdata
	set xAmount [expr {$xAmount * $pdata(scale)}]
	set yAmount [expr {$yAmount * $pdata(scale)}]
	$canvas move $tagOrId $xAmount $yAmount
}

Classy::PagedCanvas method text {args} {
	private $object pdata canvas
	array set style {font {helvetica 12} fill black x 0}
	set width [$object width]
	foreach {code value} $args {
		switch $code {
			text {
				foreach line [split $value \n] {
					$object create text $style(x) 0 -text $line -anchor nw -font $style(font) -fill $style(fill) -width $width
					$object break 1
				}
			}
			insert {
				set style(x) $value
			}
			font {
				set style(font) $value
			}
		}
	}
}

Classy::PagedCanvas method width {} {
	private $object pdata canvas
	set cd [lindex $pdata(drawables) 0]
	foreach {dx1 dy1 dx2 dy2} [$canvas coords $cd] break
	return [expr {($dx2-$dx1)/$pdata(scale)}]
}

Classy::PagedCanvas method height {} {
	private $object pdata canvas
	set cd [lindex $pdata(drawables) 0]
	foreach {dx1 dy1 dx2 dy2} [$canvas coords $cd] break
	return [expr {($dy2-$dy1)/$pdata(scale)}]
}

Classy::PagedCanvas method break {{breaksize 1}} {
	private $object pdata canvas
	if {$pdata(newline) > 0} {
		$canvas move _current 0 $pdata(newline)
		set pdata(newline) 0
	}
	set break [expr {[winfo fpixels $object $pdata(breaksize)]*$pdata(scale)}]
	set pdata(breaksize) $breaksize
	set cd [lindex $pdata(drawables) 0]
	set cbbox [$canvas bbox _current]
	if {![llength $cbbox]} return
	foreach {x1 y1 x2 y2} $cbbox break
	foreach {dx1 dy1 dx2 dy2} [$canvas coords $cd] break
	set dh [expr {$dy2-$dy1-$break}]
	if {![info exists pdata(empty,$cd)] && ($y2 > $dh)} {
		set break 0
		set pdata(drawables) [lrange $pdata(drawables) 1 end]
		if {![llength $pdata(drawables)]} {
			$object addpage
		}
		unset -nocomplain pdata(empty,$cd)
		set cd [lindex $pdata(drawables) 0]
		foreach {dx1 dy1 dx2 dy2} [$canvas coords $cd] break
	}
	$canvas move _current $dx1 [expr {$dy1+$break}]
	set newstart [expr {$dy1+$break+$y2}]
	if {$newstart > $dy2} {set newstart $dy2}
	$canvas coords $cd [list $dx1 $newstart $dx2 $dy2]
	unset -nocomplain pdata(empty,$cd)
	$canvas dtag _current
}

Classy::PagedCanvas method newline {{breaksize 1}} {
	private $object pdata canvas
	set break [expr {[winfo fpixels $object $breaksize]*$pdata(scale)}]
	set cbbox [$canvas bbox _current]
	if {![llength $cbbox]} return
	foreach {x1 y1 x2 y2} $cbbox break
	$canvas move _current 0 [expr {-$y2-$break}]
	set pdata(newline) [expr {$pdata(newline)+$y2+$break}]
}

Classy::PagedCanvas method newpage {{template {}}} {
	private $object pdata
	$object break 0
	set pdata(drawables) [lrange $pdata(drawables) 1 end]
	if {![llength $pdata(drawables)]} {
		$object addpage $template
	}
	
}

Classy::PagedCanvas method pageinfo {pagenum} {
	private $object canvas
	set coords [$canvas coords page_$pagenum]
	if {[llength $coords] != 4} {
		error "page $pagenum not present"
	}
	foreach {x1 y1 x2 y2} $coords break
	set height [expr {$y2 - $y1}]
	set width [expr {$x2 - $x1}]
	set pagesize [list $width $height]
	set result {}
	lappend result [Classy::Printer media $pagesize]
	if {[winfo fpixels $object $height] > [winfo fpixels $object $width]} {
		lappend result portrait
	} else {
		lappend result landscape
	}
}
