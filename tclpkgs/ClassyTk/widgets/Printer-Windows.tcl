if {"[info commands Classy::Export]" != ""} {

package require hdc
package require printer

Classy::Printer classmethod list {args} {
	printer list
}

Classy::Printer classmethod open {{printer {}}} {
	private $class hdc pagenum pdata
	if {$printer eq ""} {set printer [lindex [$class list] 0]}
	set hdc [printer open -name $printer]
	unset -nocomplain pdata
	array set pdata [eval list_concat [printer attr]]
	set pagenum 1
	printer job start -name "ClassyTk print"
}

Classy::Printer classmethod _portraitsize {pagesize} {
	foreach {w h} [$class pagesize $pagesize portrait] break
	set pw [winfo fpixels .classy__.printcanvas $w]
	set ph [winfo fpixels .classy__.printcanvas $h]
	if {$pw > $ph} {
		set temp $ph
		set ph $pw
		set pw $temp
	}
	set scale [winfo fpixels .classy__.printcanvas 0.001i]
	set pw [expr {round($pw/$scale)}]
	set ph [expr {round($ph/$scale)}]
	return [list $pw $ph]
}

Classy::Printer classmethod pagesizes {{printer {}}} {
	return [list_unmerge [Classy::optionget . paperSizes PaperSizes]]
}

Classy::Printer classmethod configure {args} {
	private $class pdata
	set result ""
	if {[info exists {pdata(page dimensions)}]} {
		foreach {w h} ${pdata(page dimensions)} break
		set w [winfo fpixels .classy__.printcanvas [expr {$w/1000.0}]i]
		set h [winfo fpixels .classy__.printcanvas [expr {$h/1000.0}]i]
		set pdata(pagesize) [$class media [list $w $h]]
	}
	if {[info exists {pdata(page orientation)}]} {
		set pdata(orientation) $pdata(page orientation)
	}
	if {![llength $args]} {
		set fields [list_remove [array names pdata] {page dimensions} {page orientation} pagesize orientation]
		set fields [list_concat pagesize orientation $fields]
		foreach field $fields {
			regsub -all { } $field _ key
			lappend result -[get trans($key) $key] $pdata($field)
		}
		return $result
	} elseif {[llength $args] == 1} {
		return $pdata([string range [lindex $args 0] 1 end])
	} else {
		foreach {key value} $args {
			if {$key eq "-pagesize"} {
				set pagesize [$class _portraitsize $value]
				foreach {w h} [get {pdata(page dimensions)} {1 2}] break
				if {$w > $h} {
					set pagesize [list_sub $pagesize {1 0}]
				}
				printer attr -set [list [list {page dimensions} $pagesize]]
				set {pdata(page dimensions)} $pagesize
				set {pdata(pagesize)} $value
			} elseif {$key eq "-orientation"} {
				if {![inlist {landscape portrait} $value]} {error "unknown orientation $value"}
				set key {page orientation}
				if {$value ne [get pdata($key) ""]} {
					set attrlist {}
					foreach {w h} [get {pdata(page dimensions)} {1 2}] break
					lappend attrlist [list {page dimensions} [list $h $w]]
					set {pdata(page dimensions)} [list $h $w]
					lappend attrlist [list {page orientation} $value]
					set {pdata(page orientation)} $value
					set {pdata(orientation)} $value
					catch {
						set {pdata(page minimum margins)} [list_sub ${pdata(page minimum margins)} {1 0 3 2}]
						lappend attrlist [list {page minimum margins} ${pdata(page minimum margins)}]
						
					}
					catch {
						set {pdata(page margins)} [list_sub ${pdata(page margins)} {1 0 3 2}]
						lappend attrlist [list {page margins} ${pdata(page margins)}]
					}
					printer attr -set $attrlist
				}
				set {pdata(pagesize)} $value
			} else {
				if {![info exists pdata($key)]} {error "Unknown option $key"}
				regsub -all _ $key { } key
				printer attr -set [list [list [$key 1 end] $value]]
			}
		}
		if {[info exists todoorient]} {
		}
		array set pdata [eval list_concat [printer attr]]
	}
}

Classy::Printer classmethod dialog {args} {
	private $class hdc pagenum pdata
	set flags 0
	foreach {hdc doprint} [printer dialog select -flags $flags] break
	if {!$doprint} {return 0}
	unset -nocomplain pdata
	array set pdata [eval list_concat [printer attr]]
	set pagenum 1
	set flags 0
	printer job start -name "ClassyTk print"
	return 1
}

Classy::Printer classmethod printcanvas {args} {
	private $class hdc pagenum pages pdata prescale
	if {[get pdata(-printer) ""] eq "Print to file"} {
		eval $class ps_printcanvas $args
		return
	}
	array set opt {-scale fit -tile 0 -tag all}
	cmd_args [list $class printcanvas] {
		-printregion {{x1 y1 x2 x2} "region of canvas to print"}
		-scale {any "how to scale if printregion and page do not match: \"fit\" or number giving scale"}
		-tile {switch "tile if does not fit page"}
		-tag {name "only print canvas items with given tag"}
	} {canvas} $args
	if {![catch {set scale [$canvas _getscale]}]} {
		if {$scale != 1} {
			set prescale 1
		} else {
			set prescale 10
		}
	} elseif {![info exists prescale]} {
		set prescale 10
	}
	if {![info exists opt(-printregion)]} {
		set opt(-printregion) [$canvas cget -scrollregion]
		if {[llength $opt(-printregion)] != 4} {
			set opt(-printregion) [$canvas bbox $opt(-tag)]
		}
	}
	if {![info exists pagenum]} {
		error "Classy::Printer dialog needs to be called first"
	}
	foreach {pw ph} ${pdata(page dimensions)} break
	set pw [winfo fpixels $canvas [expr {$pw/1000.0}]i]
	set ph [winfo fpixels $canvas [expr {$ph/1000.0}]i]
	if {$prescale != 1} {
		$class _copycanvas $canvas $opt(-printregion) $prescale $opt(-tag)
		set canvas .classy__.printcanvas
	}
	foreach {ox oy x2 y2} $opt(-printregion) break
	set ox [expr {round($prescale*[winfo fpixels $canvas $ox])}]
	set oy [expr {round($prescale*[winfo fpixels $canvas $oy])}]
	set x2 [expr {$prescale*[winfo fpixels $canvas $x2]}]
	set y2 [expr {$prescale*[winfo fpixels $canvas $y2]}]
	if {$opt(-scale) eq "fit"} {
		set scalex [expr {round(100*$pw/($x2-$ox))/100.0}]
		set scaley [expr {round(100*$ph/($y2-$oy))/100.0}]
		if {$scalex < $scaley} {
			set scaley $scalex
		} elseif {$scaley < $scalex} {
			set scalex $scaley
		}
	} elseif {[isdouble $opt(-scale)]} {
		set scalex [expr {double($opt(-scale))/$prescale}]
		set scaley [expr {double($opt(-scale))/$prescale}]
	} else {
		error "-scale option must be \"fit\" or a number"
	}
	if {$opt(-tile)} {
		set scaledw [expr {($x2-$ox)*$scalex}]
		set scaledh [expr {($y2-$oy)*$scaley}]
		if {($scaledw < $pw) && ($scaledh < $ph)} {
			set opt(-tile) 0
		}
	}
	if {!$opt(-tile)} {
		printer page start
		Classy::Export hdc $canvas $hdc -originx $ox -originy $oy -scalex $scalex -scaley $scaley -tag $opt(-tag)
		printer page end
		incr pagenum
	} else {
		foreach {ml mt mr mb} ${pdata(page minimum margins)} break
		set ml [winfo fpixels $canvas [expr {$ml/1000.0}]i]
		set mt [winfo fpixels $canvas [expr {$mt/1000.0}]i]
		set mr [winfo fpixels $canvas [expr {$mr/1000.0}]i]
		set mb [winfo fpixels $canvas [expr {$mb/1000.0}]i]
		set overlapx [expr {round(($ml+$mr+[winfo fpixels $canvas 1c])/$scalex)}]
		if {$overlapx < 5} {set overlapx 5}
		set stepx [expr {round($pw/$scalex-$overlapx)}]
		set overlapy [expr {round(($mt+$mb+[winfo fpixels $canvas 1c])/$scaley)}]
		if {$overlapy < 5} {set overlapy 5}
		set stepy [expr {round($ph/$scaley-$overlapy)}]
		for {set y $oy} {$y < $y2} {incr y $stepy} {
			for {set x $ox} {$x < $x2} {incr x $stepx} {
				printer page start
				Classy::Export hdc $canvas $hdc -originx $x -originy $y -scalex $scalex -scaley $scaley -tag $opt(-tag)
				printer page end
				incr pagenum
			}
		}
	}
}

Classy::Printer classmethod print {args} {
	private $class hdc pagenum pdata
	if {[get pdata(-printer) ""] eq "Print to file"} {
		set o [open $pdata(-file) w]
		eval $class ps_print $o $args
		return
	}
	if {![info exists pagenum]} {
		error "Classy::Printer dialog needs to be called first"
	}
	printer job end
	catch {printer close}
	unset pagenum
}

Classy::Printer classmethod close {args} {
	catch {printer close}
}

Classy::Printer classmethod copycanvas {args} {
	array set opt {-tag all -scale 1 -originx 0 -originy 0}
	cmd_args [list $class printcanvas] {
		-scale {any "how to scale"}
		-tag {name "only print canvas items with given tag"}
		-originx {number "x origin"}
		-originy {number "y origin"}
	} {canvas} $args
	set scale $opt(-scale)
	if {$opt(-scale) >= 0.1} {set prescale 10}
	if {$prescale != 1} {
		$class _copycanvas $canvas {} $prescale $opt(-tag)
		set canvas .classy__.printcanvas
		set opt(-scale) [expr {$opt(-scale)/$prescale}]
		set ox [expr {$opt(-originx)*$prescale}]
		set oy [expr {$opt(-originy)*$prescale}]
	} else {
		set ox $opt(-originx)
		set oy $opt(-originy)
	}
	$canvas move all [expr {-$ox}] [expr {-$oy}]
	set error [catch {
		Classy::Export clipboard $canvas -tag $opt(-tag) -scale $opt(-scale) -originx 0 -originy 0
	} result]
	$canvas move all $ox $oy
	if {$error} {error $result}
}

}
