#
# ClassyTk
# --------- Peter De Rijk
#
# Misc patches to Tk
# -----------------------------------------------------------------
# Do the Xcopy at the insert and not at the current mouse position
bind Text <<MXPaste>> {
	if !$tkPriv(mouseMoved) {
		catch {
			%W insert insert [selection get -displayof %W]
		}
	}
}

# Second mouse button also works
bind Button <<Adjust>> {
	tkButtonDown %W
}

bind Button <<Adjust-ButtonRelease>> {
	tkButtonUp %W
}

# Listbox patches:
# These patches define the extra selectmode persistent which 
# does things the way I like it.

bind Listbox <<Top>> {
	%W activate 0
	%W see 0
	if {[%W cget -selectmode]  != "persistent"} {
		%W selection clear 0 end
		%W selection set 0
	}
}
bind Listbox <<Bottom>> {
	%W activate end
	%W see end
	if {[%W cget -selectmode]  != "persistent"} {
		%W selection clear 0 end
		%W selection set end
	}
}

proc tkListboxBeginSelect {w el} {
	global tkPriv
	if {[$w cget -selectmode]  == "multiple"} {
		if [$w selection includes $el] {
			$w selection clear $el
		} else {
			$w selection set $el
		}
	} elseif {[$w cget -selectmode] == "persistent"} {
		set tkPriv(listboxSelection) [$w curselection]
		set tkPriv(listboxPrev) $el
		$w selection anchor $el
		if [$w selection includes $el] {
			$w selection clear $el
		} else {
			$w selection set $el
		}
	} else {
		$w selection clear 0 end
		$w selection set $el
		$w selection anchor $el
		set tkPriv(listboxSelection) {}
		set tkPriv(listboxPrev) $el
	}
}

# tkListboxMotion --
#
# This procedure is called to process mouse motion events while
# button 1 is down.  It may move or extend the selection, depending
# on the listbox's selection mode.
#
# Arguments:
# w -		The listbox widget.
# el -		The element under the pointer (must be a number).

proc tkListboxMotion {w el} {
	global tkPriv
	if {$el == $tkPriv(listboxPrev)} {
		return
	}
	set anchor [$w index anchor]
	switch [$w cget -selectmode] {
	browse {
		$w selection clear 0 end
		$w selection set $el
		set tkPriv(listboxPrev) $el
	}
	extended {
		set i $tkPriv(listboxPrev)
		if [$w selection includes anchor] {
		$w selection clear $i $el
		$w selection set anchor $el
		} else {
		$w selection clear $i $el
		$w selection clear anchor $el
		}
		while {($i < $el) && ($i < $anchor)} {
		if {[lsearch $tkPriv(listboxSelection) $i] >= 0} {
			$w selection set $i
		}
		incr i
		}
		while {($i > $el) && ($i > $anchor)} {
		if {[lsearch $tkPriv(listboxSelection) $i] >= 0} {
			$w selection set $i
		}
		incr i -1
		}
		set tkPriv(listboxPrev) $el
	}
	persistent {
		set i $tkPriv(listboxPrev)
		if [$w selection includes anchor] {
			$w selection clear $i $el
			$w selection set anchor $el
		} else {
			$w selection clear $i $el
			$w selection clear anchor $el
		}
		while {($i < $el) && ($i < $anchor)} {
			if {[lsearch $tkPriv(listboxSelection) $i] >= 0} {
				$w selection set $i
			}
			incr i
		}
		while {($i > $el) && ($i > $anchor)} {
			if {[lsearch $tkPriv(listboxSelection) $i] >= 0} {
				$w selection set $i
			}
			incr i -1
		}
		set tkPriv(listboxPrev) $el
	}
	}
}

# tkListboxBeginExtend --
#
# This procedure is typically invoked on shift-button-1 presses.  It
# begins the process of extending a selection in the listbox.  Its
# exact behavior depends on the selection mode currently in effect
# for the listbox;  see the Motif documentation for details.
#
# Arguments:
# w -		The listbox widget.
# el -		The element for the selection operation (typically the
#		one under the pointer).  Must be in numerical form.

proc tkListboxBeginExtend {w el} {
	if {([$w cget -selectmode] == "extended")
		&& [$w selection includes anchor]} {
		tkListboxMotion $w $el
	}
	if {([$w cget -selectmode] == "persistent")
		&& [$w selection includes anchor]} {
		tkListboxMotion $w $el
	}
}

# tkListboxExtendUpDown --
#
# Does nothing unless we're in extended selection mode;  in this
# case it moves the location cursor (active element) up or down by
# one element, and extends the selection to that point.
#
# Arguments:
# w -		The listbox widget.
# amount -	+1 to move down one item, -1 to move back one item.

proc tkListboxExtendUpDown {w amount} {
	if {[$w cget -selectmode] == "extended"} {
		$w activate [expr [$w index active] + $amount]
		$w see active
		tkListboxMotion $w [$w index active]
	} elseif {[$w cget -selectmode] == "persistent"} {
		if [$w selection includes active] {
			$w selection clear active
		} else {
			$w selection set active
		}
		$w activate [expr [$w index active] + $amount]
		$w see active
	}
}

# tkListboxDataExtend
#
# This procedure is called for key-presses such as Shift-KEndData.
# If the selection mode isn't multiple or extend then it does nothing.
# Otherwise it moves the active element to el and, if we're in
# extended mode, extends the selection to that point.
#
# Arguments:
# w -		The listbox widget.
# el -		An integer element number.

proc tkListboxDataExtend {w el} {
	set mode [$w cget -selectmode]
	if {$mode == "extended"} {
		$w activate $el
		$w see $el
		if [$w selection includes anchor] {
			tkListboxMotion $w $el
		}
	} elseif {$mode == "persistent"} {
		$w activate $el
		$w see $el
		if [$w selection includes anchor] {
			tkListboxMotion $w $el
		}
	} elseif {$mode == "multiple"} {
		$w activate $el
		$w see $el
	}
}


