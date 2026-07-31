proc zoomtool {w} {
	radiobutton $w -image [Classy::geticon zoom] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value zoom -command {zoom_start %W}
	}]
}

proc texttool {w} {
	radiobutton $w -image [Classy::geticon text] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value text -command {text_start %W}
	}]
}

proc linetool {w} {
	radiobutton $w -image [Classy::geticon line] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value line -command {line_start %W}
	}]
}

proc polytool {w} {
	radiobutton $w -image [Classy::geticon poly] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value polygon -command {polygon_start %W}
	}]
}

proc recttool {w} {
	radiobutton $w -image [Classy::geticon rect] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value rectangle -command {rectangle_start %W}
	}]
}

proc ovaltool {w} {
	radiobutton $w -image [Classy::geticon oval] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value oval -command {oval_start %W}
	}]
}

proc arctool {w} {
	radiobutton $w -image [Classy::geticon arc] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value arc -command {arc_start %W}
	}]
}

proc rotatetool {w} {
	checkbutton $w -image [Classy::geticon rotate] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(rotate)] -command {rotate_set %W}
	}]
}

proc selecttool {w} {
	radiobutton $w -image [Classy::geticon select] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(tool)] -value select -command {select_start %W}
	}]
}

proc locktool {w} {
	checkbutton $w -image [Classy::geticon unlock] -selectimage [Classy::geticon lock] -indicatoron no -highlightthickness 0
	return [varsubst w {
		$w configure -variable [privatevar %W current(scalelock)]
	}]
}

#proc fillcolortool {w} {
#	button $w -text fill -highlightthickness 0
#	return [varsubst w {
#		$w configure -command {fillcolor %W}
#	}]
#}

