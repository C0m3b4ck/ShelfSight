array set papersizes {
{User defined} "595p 842p"
Letter       "612p 792p"
Tabloid      "792p 1224p"
Ledger       "1224p 792p"
Legal        "612p 1008p"
Statement    "396p 612p"
Executive    "540p 720p"
A0           "2380p 3368p"
A1           "1684p 2380p"
A2           "1190p 1684p"
A3           "842p 1190p"
A4           "595p 842p"
A5           "420p 595p"
B4           "729p 1032p"
B5           "516p 729p"
Folio        "612p 936p"
Quarto       "610p 780p"
10x14        "720p 1008p"
}

proc _pageinit {w} {
	global current
	$w.options.color set [$current(w) cget -papercolor]
	set size [$current(w) cget -papersize]
	regexp {^(.+)(-l|-p)$} $size temp size orient
	$w.options.size.select set $size
#	if [string_equal $size "User defined"] {
#		$w.options.size.width set [$current(w) cget -width]
#	}
}

proc _pageselect {w value} {
	$w.options.size.width nocmdset [lindex $::papersizes($value) 0]
	$w.options.size.height nocmdset [lindex $::papersizes($value) 1]
	_pageorient $w
}

proc _pagewidth {w} {
	set width [$w.options.size.width get]
	set height [$w.options.size.height get]
	foreach size [list_remove [array names ::papersizes] "User defined"] {
		if {[string_equal [lindex $::papersizes($size) 0] $width] && [string_equal [lindex $::papersizes($size) 1] $height]} {
			$w.options.size.orient set -p
			$w.options.size.select nocmdset $size
			return 1
		} elseif {[string_equal [lindex $::papersizes($size) 0] $height] && [string_equal [lindex $::papersizes($size) 1] $width]} {
			$w.options.size.orient set -l
			$w.options.size.select nocmdset $size
			return 1
		}
	}
	$w.options.size.select nocmdset "User defined"
	regsub {p$} $height {} nheight
	regsub {p$} $width {} nwidth
	if {$nheight > $nwidth} {
		$w.options.size.orient set -p
	} else {
		$w.options.size.orient set -l
	}
	return 1
}

proc _pageheight {w} {
	_pagewidth $w
}

proc _pageorient {w args} {
	set width [$w.options.size.width get]
	set height [$w.options.size.height get]
	regsub {p$} $height {} nheight
	regsub {p$} $width {} nwidth
	if [string_equal [$w.options.size.orient get] -p] {
		if {$nheight < $nwidth} {
			set temp $height
			set height $width
			set width $temp
		}
	} else {
		if {$nheight > $nwidth} {
			set temp $height
			set height $width
			set width $temp
		}
	}
	$w.options.size.width nocmdset $width
	$w.options.size.height nocmdset $height
}

proc _setpagesize {w} {
	global current
	set size [$w.options.size.select get]
	if ![string_equal $size "User defined"] {
		$current(w) configure -papersize $size[$w.options.size.orient get] -papercolor [$w.options.color get]
	} else {
		$current(w) configure -papersize "[$w.options.size.width get] [$w.options.size.height get]" -papercolor [$w.options.color get]
	}
}

proc pagesetup {w} {
	pagedialog .pagedialog
}
