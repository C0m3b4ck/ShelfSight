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
	tk::ButtonDown %W
}

bind Button <<Adjust-ButtonRelease>> {
	tk::ButtonUp %W
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

proc tk::ListboxBeginSelect {w el} {
    variable ::tk::Priv
	if {[$w cget -selectmode]  == "multiple"} {
		if [$w selection includes $el] {
			$w selection clear $el
		} else {
			$w selection set $el
		}
	} elseif {[$w cget -selectmode] == "persistent"} {
		set tk::Priv(listboxSelection) [$w curselection]
		set tk::Priv(listboxPrev) $el
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
		set tk::Priv(listboxSelection) {}
		set tk::Priv(listboxPrev) $el
	}
    event generate $w <<ListboxSelect>>
}

# tk::ListboxMotion --
#
# This procedure is called to process mouse motion events while
# button 1 is down.  It may move or extend the selection, depending
# on the listbox's selection mode.
#
# Arguments:
# w -		The listbox widget.
# el -		The element under the pointer (must be a number).

proc tk::ListboxMotion {w el} {
    variable ::tk::Priv
	if {$el == $tk::Priv(listboxPrev)} {
		return
	}
	set anchor [$w index anchor]
	switch [$w cget -selectmode] {
	browse {
		$w selection clear 0 end
		$w selection set $el
		set tk::Priv(listboxPrev) $el
	    event generate $w <<ListboxSelect>>
	}
	extended {
	    set i $Priv(listboxPrev)
	    if {$i eq {}} {
		set i $el
		$w selection set $el
	    }
	    if {[$w selection includes anchor]} {
		$w selection clear $i $el
		$w selection set anchor $el
	    } else {
		$w selection clear $i $el
		$w selection clear anchor $el
	    }
	    if {![info exists Priv(listboxSelection)]} {
		set Priv(listboxSelection) [$w curselection]
	    }
	    while {($i < $el) && ($i < $anchor)} {
		if {[lsearch $Priv(listboxSelection) $i] >= 0} {
		    $w selection set $i
		}
		incr i
	    }
	    while {($i > $el) && ($i > $anchor)} {
		if {[lsearch $Priv(listboxSelection) $i] >= 0} {
		    $w selection set $i
		}
		incr i -1
	    }
	    set Priv(listboxPrev) $el
	    event generate $w <<ListboxSelect>>
	}
	persistent {
		set i $tk::Priv(listboxPrev)
		if [$w selection includes anchor] {
			$w selection clear $i $el
			$w selection set anchor $el
		} else {
			$w selection clear $i $el
			$w selection clear anchor $el
		}
		while {($i < $el) && ($i < $anchor)} {
			if {[lsearch $tk::Priv(listboxSelection) $i] >= 0} {
				$w selection set $i
			}
			incr i
		}
		while {($i > $el) && ($i > $anchor)} {
			if {[lsearch $tk::Priv(listboxSelection) $i] >= 0} {
				$w selection set $i
			}
			incr i -1
		}
		set tk::Priv(listboxPrev) $el
	    event generate $w <<ListboxSelect>>
	}
	}
}

# tk::ListboxBeginExtend --
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

proc tk::ListboxBeginExtend {w el} {
	set mode [$w cget -selectmode]
    if {$mode eq "extended"} {
		if {[$w selection includes anchor]} {
		    ListboxMotion $w $el
		} else {
		    # No selection yet; simulate the begin-select operation.
		    ListboxBeginSelect $w $el
		}
    } elseif {$mode eq "persistent"} {
		if {[$w selection includes anchor]} {
		    ListboxMotion $w $el
		} else {
		    # No selection yet; simulate the begin-select operation.
		    ListboxBeginSelect $w $el
		}
	}
}

# tk::ListboxExtendUpDown --
#
# Does nothing unless we're in extended or persistent selection mode;  in this
# case it moves the location cursor (active element) up or down by
# one element, and extends the selection to that point.
#
# Arguments:
# w -		The listbox widget.
# amount -	+1 to move down one item, -1 to move back one item.

proc tk::ListboxExtendUpDown {w amount} {
    variable ::tk::Priv
	set mode [$w cget -selectmode]
    if {$mode eq "extended"} {
	    set active [$w index active]
	    if {![info exists Priv(listboxSelection)]} {
			$w selection set $active
			set Priv(listboxSelection) [$w curselection]
	    }
	    $w activate [expr {$active + $amount}]
	    $w see active
	    ListboxMotion $w [$w index active]
	} elseif {$mode eq "persistent"} {
		if [$w selection includes active] {
			$w selection clear active
		} else {
			$w selection set active
		}
		$w activate [expr [$w index active] + $amount]
		$w see active
	}
}

# tk::ListboxDataExtend
#
# This procedure is called for key-presses such as Shift-KEndData.
# If the selection mode isn't multiple or extend then it does nothing.
# Otherwise it moves the active element to el and, if we're in
# extended mode, extends the selection to that point.
#
# Arguments:
# w -		The listbox widget.
# el -		An integer element number.

proc tk::ListboxDataExtend {w el} {
	set mode [$w cget -selectmode]
	if {[$mode eq "extended"} {
		$w activate $el
		$w see $el
		if {[$w selection includes anchor]} {
			tk::ListboxMotion $w $el
		}
	} elseif {$mode eq "persistent"} {
		$w activate $el
		$w see $el
		if [$w selection includes anchor] {
			tk::ListboxMotion $w $el
		}
	} elseif {$mode eq "multiple"} {
		$w activate $el
		$w see $el
	}
}


