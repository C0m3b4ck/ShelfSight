#Functions

proc text_action {w x y} {
	set object [getobj $w]
	private $object current canvas
	focus $canvas
	$canvas select clear
	set x [$canvas canvasx $x]
	set y [$canvas canvasy $y]
	if [info exists current(item)] {
		if {"[$canvas itemcget $current(item) -text]" == ""} {
			$canvas delete $current(item)
		}
	}
	foreach item [$canvas find overlapping $x $y $x $y] {
		if {"[$canvas type $item]" == "text"} {
			set current(item) $item
			$canvas focus $current(item)
			$canvas icursor $current(item) @$x,$y
			$canvas select from $current(item) @$x,$y
			$canvas selection set $current(item)
			return
		}
	}
	set current(item) [$canvas create text $x $y -anchor nw]
	$canvas focus $current(item)
	$canvas icursor $current(item) 0
	$canvas selection set $current(item)
}

proc text_start w {
	set object [getobj $w]
	private $object current canvas
	catch {unset current(item)}
	$canvas selection set {}
	bindtags $canvas [list DrawText $canvas Classy::Menu_MainMenu Classy::Canvas Canvas .mainw all]
	set current(tool) text
	extratool $object {}
	changecursor $canvas xterm
}

proc text_key {w value} {
	set object [getobj $w]
	private $object current canvas
	if {"[$canvas select item]" != ""} {set select 1} else {set select 0}
	switch $value {
		cut {
			if $select {
				set text [$canvas itemcget $current(item) -text]
				set fpos [$canvas index $current(item) sel.first]
				set epos [$canvas index $current(item) sel.last]
				clipboard clear -displayof $canvas
				clipboard append -displayof $canvas [string range $text $fpos $epos]
				$canvas dchars $current(item) $fpos $epos
				$canvas select clear
			}
		}
		copy {
			if $select {
				set text [$canvas itemcget $current(item) -text]
				set fpos [$canvas index $current(item) sel.first]
				set epos [$canvas index $current(item) sel.last]
				clipboard clear -displayof $canvas
				clipboard append -displayof $canvas [string range $text $fpos $epos]
			}
		}
		paste {
			$canvas insert $current(item) insert [selection get -displayof $canvas \
					-selection CLIPBOARD]
		}
		backspace {
			$canvas dchars $current(item) [expr {[$canvas index $current(item) insert]-1}]
		}
		delete {
			if $select {
				$canvas dchars $current(item) sel.first sel.last
				$canvas select clear
			} else {
				$canvas dchars $current(item) insert
			}
		}
		left {
			if $select {$canvas select clear}
			$canvas icursor $current(item) [expr {[$canvas index $current(item) insert]-1}]
		}
		right {
			if $select {$canvas select clear}
			$canvas icursor $current(item) [expr {[$canvas index $current(item) insert]+1}]
		}
		up {
			if $select {$canvas select clear}
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			set spos [lindex $list 1]
			set len [expr {$pos-$spos}]
			set npos [expr {[lindex $list 0]+$len}]
			if {$npos > $spos} {set npos $spos}
			$canvas icursor $current(item) $npos
		}
		down {
			if $select {$canvas select clear}
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			set spos [lindex $list 1]
			set len [expr {$pos-$spos}]
			set max [lindex $list 3]
			incr max
			if {$len != 0} {
				set npos [expr {[lindex $list 2]+$len}]
			} else {
				set npos $max
			}
			if {$npos > $max} {set npos $max}
			$canvas icursor $current(item) $npos
		}
		linestart {
			if $select {$canvas select clear}
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			set npos [lindex $list 1]
			if {$npos == $pos} {set npos [lindex $list 0]}
			incr npos
			$canvas icursor $current(item) $npos
		}
		lineend {
			if $select {$canvas select clear}
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			$canvas icursor $current(item) [lindex $list 2]
		}
		textstart {
			$canvas icursor $current(item) 0
		}
		textend {
			$canvas icursor $current(item) end
		}
		default {
			$canvas insert $current(item) insert $value
		}
	}
	$canvas selection redraw
}

proc text_select {w value args} {
	set object [getobj $w]
	private $object current canvas
	focus $canvas
	if {"[$canvas select item]" != ""} {set select 1} else {set select 0}
	if !$select {
		$canvas select from $current(item) insert
		$canvas select to $current(item) insert
	}
	switch $value {
		drag {
			set x [$canvas canvasx [lindex $args 0]]
			set y [$canvas canvasy [lindex $args 1]]
			set npos [$canvas index $current(item) @$x,$y]
		}
		left {
			if !$select {$canvas select from $current(item) insert}
			set npos [expr {[$canvas index $current(item) insert]-1}]
			$canvas icursor $current(item) $npos
		}
		right {
			if !$select {$canvas select from $current(item) insert}
			set npos [expr {[$canvas index $current(item) insert]+1}]
			$canvas icursor $current(item) $npos
		}
		up {
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			set spos [lindex $list 1]
			set len [expr {$pos-$spos}]
			set npos [expr {[lindex $list 0]+$len}]
			if {$npos > $spos} {set npos $spos}
			$canvas icursor $current(item) $npos
		}
		down {
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			set spos [lindex $list 1]
			set len [expr {$pos-$spos}]
			set max [lindex $list 3]
			incr max
			if {$len != 0} {
				set npos [expr {[lindex $list 2]+$len}]
			} else {
				set npos $max
			}
			if {$npos > $max} {set npos $max}
			$canvas icursor $current(item) $npos
		}
		linestart {
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			set npos [lindex $list 1]
			if {$npos == $pos} {set npos [lindex $list 0]}
			incr npos
			$canvas icursor $current(item) $npos
		}
		lineend {
			set pos [$canvas index $current(item) insert]
			set text [$canvas itemcget $current(item) -text]
			set list [text_findline $text $pos]
			set npos [lindex $list 2]
			$canvas icursor $current(item) $npos
		}
		textstart {
			$canvas icursor $current(item) 0
			set npos [$canvas index $current(item) insert]
		}
		textend {
			$canvas icursor $current(item) end
			set npos [$canvas index $current(item) insert]
		}
		all {
			$canvas select from $current(item) 0
			set npos [$canvas index $current(item) end]
		}
		none {
			$canvas select clear
			return
		}
	}
	set pos [$canvas index $current(item) sel.first]
	if {$npos > $pos} {
		incr npos -1
	}
	$canvas select to $current(item) $npos
}

proc text_findline {text pos} {
	set spos [string last "\n" [string range $text 0 $pos]]
	set ppos [string last "\n" [string range $text 0 [expr {$spos-1}]]]
	set dist [string first "\n" [string range $text $pos end]]
	if {$dist == -1} {
		set npos [string length $text]
		set nnpos [string length $text]
	} else {
		set npos [expr {$pos+$dist}]
		set dist [string first "\n" [string range $text [expr {$npos+1}] end]]
		if {$dist == -1} {
			set nnpos [string length $text]
		} else {
			set nnpos [expr {$npos+$dist}]
		}
	}
	return [list $ppos $spos $npos $nnpos]
}

