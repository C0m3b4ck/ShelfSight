#Functions

proc select_action {object ox oy args} {
	catch {destroy .adjustselectiondialog}
	set object [getobj $object]
	private $object current canvas
	focus $canvas
	global status
	set status(current) $canvas
	set current(w) $canvas
	set current(object) [getobj $canvas]
	set x [$canvas canvasx $ox]
	set y [$canvas canvasy $oy]
	set list [$canvas find overlapping [expr {$x-1}] [expr {$y-1}] [expr {$x+1}] [expr {$y+1}]]
	set item [lindex $list end]
	set tags [$canvas itemcget $item -tags]
	set drawing [lindex $tags 0]
	select_item $current(object) $item $x $y $args
}

proc waddpoint {object {p 0}} {
	set object [getobj $object]
	private $object current canvas
	set coords [$canvas coords $current(item)]
	foreach {px py} $coords {break}
	set i 2
	foreach {x y} [lrange $coords 2 end] {
		if {[expr abs([distancetoline $px $py $x $y $current(x) $current(y)])]<2.0} {
			eval $canvas coords $current(item) [linsert $coords $i $current(x) $current(y)]
			break
		}
		set px $x
		set py $y
		incr i 2
	}
	if $p {
		if {[expr abs([distancetoline $px $py [lindex $coords 0] [lindex $coords 1] $current(x) $current(y)])]<2.0} {
			lappend coords $current(x) $current(y)
			eval $canvas coords $current(item) $coords
		}
	}
}

proc select_exec {object ox oy args} {
	set object [getobj $object]
	private $object canvas current
	uplevel #0 [list private $object current]
	set current(w) $canvas
	set current(object) [getobj $canvas]
	set x [$canvas canvasx $ox]
	set y [$canvas canvasy $oy]
	set list [$canvas find overlapping [expr {$x-1}] [expr {$y-1}] [expr {$x+1}] [expr {$y+1}]]
	set item [lindex $list end]
	select_item $current(object) $item $x $y $args
	switch [$canvas type $item] {
		line {
			waddpoint $object
			$canvas selection redraw
		}
		polygon {
			waddpoint $object 1
			$canvas selection redraw
		}
		default {
			rotate_switch $canvas $ox $oy
		}
	}
}

proc select_item {object item x y args} {
	set object [getobj $object]
	private $object canvas current
	set current(x) $x
	set current(y) $y
	set zoom [$canvas zoom]
	set current(px) [expr {$x/$zoom}]
	set current(py) [expr {$y/$zoom}]
	if {[llength $item] != 0} {
		set group [$canvas findgroup $item]
		set current(group) $group
		set tags [$canvas itemcget $item -tags]
		if {"[lindex $tags 0]" == "_ind"} {
			set current(action) coords
			regexp {[0-9]+$} [lindex $tags 1] cpos
			set pos [lsearch [get current(cpos) ""] $cpos]
			if {"$args" != "add"} {
				if {$pos == -1} {
					$canvas noundo itemconfigure _ind -foreground red
					set current(cpos) $cpos
					$canvas noundo itemconfigure _ind_$cpos -foreground blue
				}
			} else {
				if {$pos != -1} {
					set current(cpos) [lreplace $current(cpos) $pos $pos]
					$canvas noundo itemconfigure _ind_$cpos -foreground red
				} else {
					lappend current(cpos) $cpos
					$canvas noundo itemconfigure _ind_$cpos -foreground blue
				}
			}
			set current(coords) [$canvas coords $current(item)]
			undocheck $object
		} elseif {"[lindex $tags 0]" == "_rotatepos"} {
			set current(action) rotatepos
			set current(citem) $item
		} elseif {"[lindex $tags 0]" == "_sb"} {
			set current(action) scale
			set current(name) [lindex $tags 1]
			set current(citem) $item
			set bbox [$canvas bbox _sel]
			foreach {current(x1) current(y1) current(x2) current(y2)} $bbox {break}
			set current(ratio) [expr {double($current(y2)-$current(y1))/($current(x2)-$current(x1))}]
		} else {
			catch {unset current(citem)}
			catch {unset current(cpos)}
			set current(item) $item
			if {"$args" != "add"} {
				if ![inlist [$canvas itemcget $item -tags] _sel] {
					if {"$group" != ""} {
						$canvas selection set $group
					} else {
						$canvas selection set $item
					}
				}
				if [inlist {text oval rectangle} [$canvas type $item]] {
					$canvas current $item
				} else {
					$canvas current $item ind
				}
			} else {
				if ![inlist [$canvas itemcget $item -tags] _sel] {
					if {"$group" != ""} {
						$canvas selection add $group
					} else {
						$canvas selection add $item
					}
					if [inlist {text oval rectangle} [$canvas type $item]] {
						$canvas current $item
					} else {
						$canvas current $item ind
					}
				} else {
					if {"$group" != ""} {
						$canvas selection remove $group
					} else {
						$canvas selection remove $item
					}
					$canvas current {}
				}
			}
			set current(action) move
			update_config $object
		}
		undocheck $object
	} else {
		if {"$args" != "add"} {
			$canvas selection set {}
			$canvas current {}
			set current(rotate) 0
			rotate_set $canvas
		}
		$canvas selector $x $y $x $y
		set current(action) sel
	}
}

proc sqangle {x1 y1 x2 y2} {
	if {$x1==$x2} {
		if {$y1>$y2} {return 90} else {return -90}
	} elseif {$x1>$x2} {
		set angle [expr atan(($y2-$y1)/($x2-$x1))+3.14159265]
	} else {
		set angle [expr atan(($y2-$y1)/($x2-$x1))]
	}
	if {$angle==0} {
		return 0
	} else {
		set angle [expr -$angle*180/3.14159265]
		while {$angle<0} {set angle [expr $angle+360.0]}
		return $angle
	}
}

proc select_drag {object x y} {
	set object [getobj $object]
	private $object current canvas
	catch {after cancel $current(id)}
	set current(id) [after idle select_updatedrag $canvas]
}

proc select_updatedrag {object} {
	set object [getobj $object]
	private $object current canvas
	set x [expr [winfo pointerx $canvas]-[winfo rootx $canvas]]
	set y [expr [winfo pointery $canvas]-[winfo rooty $canvas]]
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	set zoom [$canvas zoom]
	set current(px) [expr {$x/$zoom}]
	set current(py) [expr {$y/$zoom}]
	if ![info exists current(action)] return
	if {"$current(action)" == "sel"} {
		$canvas selector $current(x) $current(y) $x $y
	} elseif {"$current(action)" == "coords"} {
		set mx [expr {$x-$current(x)}]
		set my [expr {$y-$current(y)}]
		foreach cpos $current(cpos) {
			$canvas move _ind_$cpos $mx $my
			set p1 [expr {2 * $cpos}]
			set p2 [expr {$p1 + 1}]
			foreach {cx cy} [$canvas coords _ind_$cpos] {}
			set current(coords) [lreplace $current(coords) $p1 $p2 $cx $cy]
		}
		eval $canvas coords $current(item) $current(coords)
		set current(x) $x
		set current(y) $y
	} elseif {"$current(action)" == "scale"} {
		switch $current(name) {
			_sb_nw {
				if !$current(scalelock) {
					$canvas noundo selection draw [list $x $y $current(x2) $current(y2)]
				} else {
					set width [expr {$current(x2) - $x}]
					set height [expr {$current(y2) - $y}]
					set nheight [expr {$width*$current(ratio)}]
					if {$nheight < $height} {
						set nx $x
						set ny [expr {$current(y2) - $nheight}]
					} else {
						set nwidth [expr {$height/$current(ratio)}]
						set nx [expr {$current(x2) - $nwidth}]
						set ny $y
					}
					$canvas noundo selection draw [list $nx $ny $current(x2) $current(y2)]
				}
			}
			_sb_se {
				if !$current(scalelock) {
					$canvas noundo selection draw [list $current(x1) $current(y1) $x $y]
				} else {
					set width [expr {$x - $current(x1)}]
					set height [expr {$y - $current(y1)}]
					set nheight [expr {$width*$current(ratio)}]
					if {$nheight < $height} {
						set nx $x
						set ny [expr {$current(y1) + $nheight}]
					} else {
						set nwidth [expr {$height/$current(ratio)}]
						set nx [expr {$current(x1) + $nwidth}]
						set ny $y
					}
					$canvas noundo selection draw [list $current(x1) $current(y1) $nx $ny]
				}
			}
			_sb_ne {
				if !$current(scalelock) {
					$canvas noundo selection draw [list $current(x1) $y $x $current(y2)]
				} else {
					set width [expr {$x - $current(x1)}]
					set height [expr {$current(y2) - $y}]
					set nheight [expr {$width*$current(ratio)}]
					if {$nheight < $height} {
						set nx $x
						set ny [expr {$current(y2) - $nheight}]
					} else {
						set nwidth [expr {$height/$current(ratio)}]
						set nx [expr {$current(x1) + $nwidth}]
						set ny $y
					}
					$canvas noundo selection draw [list $current(x1) $ny $nx $current(y2)]
				}
			}
			_sb_sw {
				if !$current(scalelock) {
					$canvas noundo selection draw [list $x $current(y1) $current(x2) $y]
				} else {
					set width [expr {$current(x2) - $x}]
					set height [expr {$y - $current(y1)}]
					set nheight [expr {$width*$current(ratio)}]
					if {$nheight < $height} {
						set nx $x
						set ny [expr {$current(y1) + $nheight}]
					} else {
						set nwidth [expr {$height/$current(ratio)}]
						set nx [expr {$current(x2) - $nwidth}]
						set ny $y
					}
					$canvas noundo selection draw [list $nx $current(y1) $current(x2) $ny]
				}
			}
			_sb_n {$canvas noundo selection draw [list $current(x1) $y $current(x2) $current(y2)]}
			_sb_s {$canvas noundo selection draw [list $current(x1) $current(y1) $current(x2) $y]}
			_sb_e {$canvas noundo selection draw [list $current(x1) $current(y1) $x $current(y2)]}
			_sb_w {$canvas noundo selection draw [list $x $current(y1) $current(x2) $current(y2)]}
		}
	} elseif {"$current(action)" == "rotatepos"} {
		$canvas noundo coords $current(citem) $x $y
	} else {
		if !$current(rotate) {
			$canvas move _sel [expr {$x-$current(x)}] [expr {$y-$current(y)}]
		} else {
			set rx [$canvas coords _rotatepos]
			set ry [list_pop rx]
			set a [expr [sqangle $rx $ry $x $y]-[sqangle $rx $ry $current(x) $current(y)]]
			$canvas rotate _sel $rx $ry $a
			$canvas selection redraw
		}
		set current(x) $x
		set current(y) $y
	}
}

proc select_release {object x y args} {
	set object [getobj $object]
	private $object current canvas
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	set zoom [$canvas zoom]
	set current(px) [expr {$x/$zoom}]
	set current(py) [expr {$y/$zoom}]
	if ![info exists current(action)] {
		undocheck $object
		return
	}
	if {"$current(action)" == "sel"} {
		set items [$canvas find enclosed $current(x) $current(y) $x $y]
		$canvas selection add $items
		catch {unset groups}
		foreach item $items {
			set tags [$canvas gettags $item]
			set g [lindex $tags 0]
			if [info exists groups($g)] continue
			foreach tag [list_reverse $tags] {
				if [regexp ^_g $tag] {
					set groups($tag) 1
					break
				}
			}
		}
		foreach group [array names groups] {
			$canvas selection add $group
		}
		$canvas selector -100 -100 -100 -100
	} elseif {"$current(action)" == "scale"} {
		if {($current(x) == $x) && ($current(y) == $y)} {
			return
		} else {
			set nw [$canvas coords _sb_nw]
			set se [$canvas coords _sb_se]
			set c [$canvas selection coords]
			set xscale [expr {([lindex $se 0]-[lindex $nw 0]) / ($current(x2)-$current(x1))}]
			set yscale [expr {([lindex $se 1]-[lindex $nw 1]) / ($current(y2)-$current(y1))}]
			switch $current(name) {
				_sb_n - _sb_nw {set x $current(x2) ; set y $current(y2)}
				_sb_s - _sb_se {set x $current(x1) ; set y $current(y1)}
				_sb_e - _sb_ne {set x $current(x1) ; set y $current(y2)}
				_sb_w - _sb_sw {set y $current(y1) ; set x $current(x2)}
			}
			$canvas scale _sel $x $y $xscale $yscale
			set list [list_remdup [list_subindex [$canvas mitemcget _sel -tags] 0]]
			catch {$canvas current $current(item)}
			update_config $object
		}
	} elseif {"$current(action)" == "coords"} {
		foreach cpos $current(cpos) {
			set p1 [expr {2 * $cpos}]
			set p2 [expr {$p1 + 1}]
			foreach {cx cy} [$canvas coords _ind_$cpos] {}
			set current(coords) [lreplace $current(coords) $p1 $p2 $cx $cy]
		}
		eval $canvas coords $current(item) $current(coords)
		$canvas selection redraw
		foreach cpos $current(cpos) {
			$canvas noundo itemconfigure _ind_$cpos -foreground blue
		}
		undocheck $object
	} elseif {"$current(action)" == "rotatepos"} {
	} else {
		undocheck $object
	}
	unset current(action)
}

proc select_abort {object x y} {
	set object [getobj $object]
	private $object current canvas
	catch {unset current(action)}
	$canvas selection redraw
	return -code break
}

proc select_start {object {mode {}}} {
	set object [getobj $object]
	private $object current canvas
	catch {unset current(item)}
	$canvas selection set {}
	$canvas current {}
	if ![string length $mode] {
		bindtags $canvas [list Select $canvas Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
		set current(tool) select
	} else {
		bindtags $canvas [list SelectElement $canvas Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
		set current(tool) $mode
	}
	extratool $object {}
	changecursor $canvas {}
}

proc distancetoline {x1 y1 x2 y2 x y} {
	set side 1
	if {$x1 == $x2} {
		# Vertical edge.
		set cx $x1
		set cy $y
		if {$y1 < $y2} {
			if {$x > $cx} {set side -1}
		} else {
			if {$x < $cx} {set side -1}
		}
		if {$side == -1} {
			return [expr {-abs($cx-$x)}]
		} else {
			return [expr {abs($cx-$x)}]
		}
	} elseif {$y1 == $y2} {
		# Horizontal edge.
		set cy $y1
		set cx $x
		if {$x1 < $x2} {
			if {$y < $cy} {set side -1}
		} else {
			if {$y > $cy} {set side -1}
		}
		if {$side == -1} {
			return [expr {-abs($cy-$y)}]
		} else {
			return [expr {abs($cy-$y)}]
		}
	} else {
		# The edge is neither horizontal nor vertical.  Convert the
		# edge to a line equation of the form y = m1*x + b1.  Then
		# compute a line perpendicular to this edge but passing
		# through the point, also in the form y = m2*x + b2.
		set m1 [expr {($y2 - $y1)/($x2 - $x1)}]
		set b1 [expr {$y1 - $m1*$x1}]
		set m2 [expr {-1.0/$m1}]
		set b2 [expr {$y - $m2*$x}]
		set cx [expr {($b2 - $b1)/($m1 - $m2)}]
		set cy [expr {$m1*$cx + $b1}]
		set ty [expr {$m1*$x + $b1}]
		if {$y < $ty} {set side -1}
		if {$x1 > $x2} {set side [expr {-$side}]}
		if {$side == -1} {
			return [expr {-hypot($x - $cx, $y - $cy)}]
		} else {
			return [expr {hypot($x - $cx, $y - $cy)}]
		}
	}
}
