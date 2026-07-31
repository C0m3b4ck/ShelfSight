#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
# default bindings for Classy command widgets.
# ----------------------------------------------------------------------
#
# adapted from:
# This file defines the default bindings for Tk text widgets and provides
# procedures that help in implementing the bindings.
#
# @(#) text.tcl 1.36 95/06/28 10:24:23
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994-1995 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

#-------------------------------------------------------------------------
# Elements of tk::Priv that are used in this file:
#
# afterId -		If non-null, it means that auto-scanning is underway
#			and it gives the "after" id for the next auto-scan
#			command to be executed.
# char -		Character position on the line;  kept in order
#			to allow moving up or down past short lines while
#			still remembering the desired position.
# mouseMoved -		Non-zero means the mouse has moved a significant
#			amount since the button went down (so, for example,
#			start dragging out a selection).
# prevPos -		Used when moving up or down lines via the keyboard.
#			Keeps track of the previous insert position, so
#			we can distinguish a series of ups and downs, all
#			in a row, from a new up or down.
# selectMode -		The style of selection currently underway:
#			char, word, or line.
# x, y -		Last known mouse coordinates for scanning
#			and auto-scanning.
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# The code below creates the default class bindings for entries.
#-------------------------------------------------------------------------

Classy::bindmousewheel Classy::CmdWidget

bind Classy::CmdWidget <<Drop>> {
	catch {%W textinsert [Classy::DragDrop get]}
}
bind Classy::CmdWidget <<Drag-Motion>> {
	%W position [::Classy::Tk_%W index @%x,%y]
}
bind Classy::CmdWidget <<Action>> {
	%W position [%W index @%x,%y]
}
bind Classy::CmdWidget <<Action-Motion>> {
	set tk::Priv(x) %x
	set tk::Priv(y) %y
	Classy::CmdWidget_SelectTo %W %x %y
}
bind Classy::CmdWidget <<MSelectWord>> {
	set tk::Priv(selectMode) word
	Classy::CmdWidget_SelectTo %W %x %y
}
bind Classy::CmdWidget <<MSelectLine>> {
	set tk::Priv(selectMode) line
	Classy::CmdWidget_SelectTo %W %x %y
}
bind Classy::CmdWidget <<MExtend>> {
	Classy::CmdWidget_ResetAnchor %W @%x,%y
	set tk::Priv(selectMode) char
	Classy::CmdWidget_SelectTo %W %x %y
}
bind Classy::CmdWidget <<MExtendWord>>	{
	set tk::Priv(selectMode) word
	Classy::CmdWidget_SelectTo %W %x %y
}
bind Classy::CmdWidget <<MExtendLine>>	{
	set tk::Priv(selectMode) line
	Classy::CmdWidget_SelectTo %W %x %y
}
bind Classy::CmdWidget <<Action-Leave>> {
	set tk::Priv(x) %x
	set tk::Priv(y) %y
	Classy::CmdWidget_AutoScan %W
}
bind Classy::CmdWidget <<Action-Enter>> {
	tk::CancelRepeat
}
bind Classy::CmdWidget <<Action-ButtonRelease>> {
	tk::CancelRepeat
}
if {$tcl_platform(platform) eq "windows"} {
	bind Classy::CmdWidget <<MXPaste>> {
		%W paste
	}
} else {
	bind Classy::CmdWidget <<MXPaste>> {
		%W paste PRIMARY
	}
}
bind Classy::CmdWidget <<Left>> {
	%W move left
}
bind Classy::CmdWidget <<Right>> {
	%W move right
}
bind Classy::CmdWidget <<Up>> {
	%W move up
}
bind Classy::CmdWidget <<Down>> {
	%W move down
}
bind Classy::CmdWidget <<SelectLeft>> {
	%W select left
}
bind Classy::CmdWidget <<SelectRight>> {
	%W select right
}
bind Classy::CmdWidget <<SelectUp>> {
	%W select up
}
bind Classy::CmdWidget <<SelectDown>> {
	%W select down
}
bind Classy::CmdWidget <<WordLeft>> {
	%W move wordleft
}
bind Classy::CmdWidget <<WordRight>> {
	%W move wordright
}
bind Classy::CmdWidget <<SelectWordLeft>> {
	%W select wordleft
}
bind Classy::CmdWidget <<SelectWordRight>> {
	%W select wordright
}
bind Classy::CmdWidget <<ParaUp>> {
	%W move uppara
}
bind Classy::CmdWidget <<ParaDown>> {
	%W move downpara
}
bind Classy::CmdWidget <<SelectParaUp>> {
	%W select uppara
}
bind Classy::CmdWidget <<SelectParaDown>> {
	%W select downpara
}
bind Classy::CmdWidget <<PageUp>> {
	%W move pageup
}
bind Classy::CmdWidget <<SelectPageUp>> {
	%W select pageup
}
bind Classy::CmdWidget <<ScrollPageUp>> {
	%W xview scroll -1 page
}
bind Classy::CmdWidget <<PageDown>> {
	%W move pagedown
}
bind Classy::CmdWidget <<SelectPageDown>> {
	%W select pagedown
}
bind Classy::CmdWidget <<ScrollPageDown>> {
	%W xview scroll 1 page
}

bind Classy::CmdWidget <<Home>> {
	%W move linestart
}
bind Classy::CmdWidget <<SelectHome>> {
	%W select linestart
}
bind Classy::CmdWidget <<End>> {
	%W move lineend
}
bind Classy::CmdWidget <<SelectEnd>> {
	%W select lineend
}
bind Classy::CmdWidget <<HistoryUp>> {
	%W historyup
}
bind Classy::CmdWidget <Up> {
	set insertline [lindex [split [%W index insert] .] 0]
	set startline [lindex [split [%W index cmdstart] .] 0]
	if {($insertline <= $startline) | ([%W index insert] eq [%W index end-1c])} {
		%W historyup
	} else {
		%W move up
	}
}
bind Classy::CmdWidget <<Top>> {
	%W move textstart
}
bind Classy::CmdWidget <<SelectTop>> {
	%W select textstart
}
bind Classy::CmdWidget <<Bottom>> {
	%W move textend
}
bind Classy::CmdWidget <<HistoryDown>> {
	%W historydown
}
bind Classy::CmdWidget <Down> {
	set insertline [lindex [split [%W index insert] .] 0]
	set endline [lindex [split [%W index end-1c] .] 0]
	if {$insertline >= $endline} {
		%W historydown
	} else {
		%W move down
	}
}
bind Classy::CmdWidget <<SelectBottom>> {
	%W select textend
}
bind Classy::CmdWidget <<Complete>> {
	%W complete
	break
}
bind Classy::CmdWidget <<CompleteFile>> {
	%W complete file
	break
}
bind Classy::CmdWidget <<CompleteVar>> {
	%W complete var
	break
}
bind Classy::CmdWidget <<SpecialFocusNext>> {
	focus [tk_focusNext %W]
}
bind Classy::CmdWidget <<SpecialFocusPrev>> {
	focus [tk_focusPrev %W]
}
bind Classy::CmdWidget <Control-i> {
	%W textinsert \t
}
bind Classy::CmdWidget <<Empty>> {
	%W clear
}
bind Classy::CmdWidget <Alt-Return> {
	%W textinsert "\n"
	break
}
bind Classy::CmdWidget <Return> {
	if {![%W do]} {
		%W textinsert "\n"
	}
	break
}
bind Classy::CmdWidget <Tab> {
	%W textinsert "\t"
	focus %W
    break
}
bind Classy::CmdWidget <Shift-Tab> {
    # Needed only to keep <Tab> binding from triggering;  doesn't
    # have to actually do anything.
    break
}
bind Classy::CmdWidget <<Delete>> {
	%W textdelete
}
bind Classy::CmdWidget <<BackSpace>> {
	%W backspace
}

bind Classy::CmdWidget <<StartSelect>> {
	%W select start
}
bind Classy::CmdWidget <Select> {
	%W select start
}
bind Classy::CmdWidget <<EndSelect>> {
	%W select end
}
bind Classy::CmdWidget <<SelectAll>> {
	%W select all
}
bind Classy::CmdWidget <<SelectNone>> {
	%W select none
}
bind Classy::CmdWidget <Insert> {
	catch {%W textinsert [selection get -displayof %W]}
}
bind Classy::CmdWidget <KeyPress> {
	%W textinsert %A
}
bind Classy::CmdWidget <<Menu>>	{
	%W menu %X %Y
}

# The new bindings

bind Classy::CmdWidget <<Copy>> {
	%W copy			
}												  
bind Classy::CmdWidget <<Cut>> {
	%W cut
}
bind Classy::CmdWidget <<Paste>> {
	%W paste
}
bind Classy::CmdWidget <<Undo>> {
	%W undo
}
bind Classy::CmdWidget <<Redo>> {
	%W redo
}

# Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
# Otherwise, if a widget binding for one of these is defined, the
# <KeyPress> class binding will also fire and insert the character,
# which is wrong.  Ditto for <Escape>.

bind Classy::CmdWidget <Alt-KeyPress> {# nothing }
bind Classy::CmdWidget <Meta-KeyPress> {# nothing}
bind Classy::CmdWidget <Control-KeyPress> {# nothing}
bind Classy::CmdWidget <Escape> {# nothing}
bind Classy::CmdWidget <KP_Enter> {# nothing}

set tk::Priv(prevPos) {}
# Classy::CmdWidget_SelectTo --
# This procedure is invoked to extend the selection, typically when
# dragging it with the mouse.  Depending on the selection mode (character,
# word, line) it selects in different-sized units.  This procedure
# ignores mouse motions initially until the mouse has moved from
# one character to another or until there have been multiple clicks.
#
# Arguments:
# w -		The text window in which the button was pressed.
# x -		Mouse x position.
# y - 		Mouse y position.
proc Classy::CmdWidget_SelectTo {w x y} {
	global tk::Priv

	set w ::Classy::Tk_$w
	set cur [$w index @$x,$y]
	if [catch {$w index anchor}] {
	$w mark set anchor $cur
	}
	set anchor [$w index anchor]
	if {[$w compare $cur != $anchor] || (abs($tk::Priv(pressX) - $x) >= 3)} {
	set tk::Priv(mouseMoved) 1
	}
	switch $tk::Priv(selectMode) {
	char {
		if [$w compare $cur < anchor] {
		set first $cur
		set last anchor
		} else {
		set first anchor
		set last [$w index "$cur + 1c"]
		}
	}
	word {
		if [$w compare $cur < anchor] {
		set first [$w index "$cur wordstart"]
		set last [$w index "anchor - 1c wordend"]
		} else {
		set first [$w index "anchor wordstart"]
		set last [$w index "$cur wordend"]
		}
	}
	line {
		if [$w compare $cur < anchor] {
		set first [$w index "$cur linestart"]
		set last [$w index "anchor - 1c lineend + 1c"]
		} else {
		set first [$w index "anchor linestart"]
		set last [$w index "$cur lineend + 1c"]
		}
	}
	}
	if {$tk::Priv(mouseMoved) || ($tk::Priv(selectMode) != "char")} {
	$w tag remove sel 0.0 $first
	$w tag add sel $first $last
	$w tag remove sel $last end
	Classy::update Classy::CmdWidget_SelectTo idletasks
	}
}

# Classy::CmdWidget_AutoScan --
# This procedure is invoked when the mouse leaves a text window
# with button 1 down.  It scrolls the window up, down, left, or right,
# depending on where the mouse is (this information was saved in
# tk::Priv(x) and tk::Priv(y)), and reschedules itself as an "after"
# command so that the window continues to scroll until the mouse
# moves back into the window or the mouse button is released.
#
# Arguments:
# w -		The text window.

proc Classy::CmdWidget_AutoScan {w} {
	global tk::Priv
	if {$tk::Priv(y) >= [winfo height $w]} {
		::Classy::Tk_$w yview scroll 2 units
	} elseif {$tk::Priv(y) < 0} {
		::Classy::Tk_$w yview scroll -2 units
	} elseif {$tk::Priv(x) >= [winfo width $w]} {
		::Classy::Tk_$w xview scroll 2 units
	} elseif {$tk::Priv(x) < 0} {
		::Classy::Tk_$w xview scroll -2 units
	} else {
		return
	}
	Classy::CmdWidget_SelectTo $w $tk::Priv(x) $tk::Priv(y)
	set tk::Priv(afterId) [after 50 Classy::CmdWidget_AutoScan $w]
}

# Classy::CmdWidget_ResetAnchor --
# Set the selection anchor to whichever end is farthest from the
# index argument.  One special trick: if the selection has two or
# fewer characters, just leave the anchor where it is.  In this
# case it doesn't matter which point gets chosen for the anchor,
# and for the things like Shift-Left and Shift-Right this produces
# better behavior when the cursor moves back and forth across the
# anchor.
#
# Arguments:
# w -		The text widget.
# index -	Position at which mouse button was pressed, which determines
#		which end of selection should be used as anchor point.

proc Classy::CmdWidget_ResetAnchor {w index} {
	global tk::Priv

	set w ::Classy::Tk_$w
	if {[$w tag ranges sel] == ""} {
	$w mark set anchor $index
	return
	}
	set a [$w index $index]
	set b [$w index sel.first]
	set c [$w index sel.last]
	if [$w compare $a < $b] {
	$w mark set anchor sel.last
	return
	}
	if [$w compare $a > $c] {
	$w mark set anchor sel.first
	return
	}
	scan $a "%d.%d" lineA chA
	scan $b "%d.%d" lineB chB
	scan $c "%d.%d" lineC chC
	if {$lineB < $lineC+2} {
	set total [string length [$w get $b $c]]
	if {$total <= 2} {
		return
	}
	if {[string length [$w get $b $a]] < ($total/2)} {
		$w mark set anchor sel.last
	} else {
		$w mark set anchor sel.first
	}
	return
	}
	if {($lineA-$lineB) < ($lineC-$lineA)} {
	$w mark set anchor sel.last
	} else {
	$w mark set anchor sel.first
	}
}


