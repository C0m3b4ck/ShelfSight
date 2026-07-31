#
# ClassyTk Widgets 
# ----------------- Peter De Rijk
#
#
# default bindings for Classy text widgets
# ----------------------------------------------------------------------

# adapted from
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
#

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

bind Classy::Text <<Empty>> {
	catch {[Classy::mainw %W] delete 1.0 end};break
}
bind Classy::Text <<Drop>> {
	catch {[Classy::mainw %W] textinsert [Classy::DragDrop get]};break
}
bind Classy::Text <<Drag-Motion>> {
	[Classy::mainw %W] position [[Classy::mainw %W] index @%x,%y];break
}

bind Classy::Text <<Action>> {
	[Classy::mainw %W] position [[Classy::mainw %W] index @%x,%y];break
}
bind Classy::Text <<Action-Motion>> {
	set tk::Priv(x) %x
	set tk::Priv(y) %y
	Classy::Text_SelectTo [Classy::mainw %W] %x %y;break
}
bind Classy::Text <<MSelectWord>> {
	set tk::Priv(selectMode) word
	Classy::Text_SelectTo [Classy::mainw %W] %x %y
	catch {[Classy::mainw %W] mark set insert sel.first};break
}
bind Classy::Text <<MSelectLine>> {
	set tk::Priv(selectMode) line
	Classy::Text_SelectTo [Classy::mainw %W] %x %y
	catch {[Classy::mainw %W] mark set insert sel.first};break
}
bind Classy::Text <<MExtend>> {
	Classy::Text_ResetAnchor [Classy::mainw %W] @%x,%y
	set tk::Priv(selectMode) char
	Classy::Text_SelectTo [Classy::mainw %W] %x %y;break
}
bind Classy::Text <<MExtendWord>>	{
	set tk::Priv(selectMode) word
	Classy::Text_SelectTo [Classy::mainw %W] %x %y;break
}
bind Classy::Text <<MExtendLine>>	{
	set tk::Priv(selectMode) line
	Classy::Text_SelectTo [Classy::mainw %W] %x %y;break
}
bind Classy::Text <<Action-Leave>> {
	set tk::Priv(x) %x
	set tk::Priv(y) %y
	Classy::Text_AutoScan [Classy::mainw %W];break
}
bind Classy::Text <<Action-Enter>> {
	tk::CancelRepeat;break
}
bind Classy::Text <<Action-ButtonRelease>> {
	tk::CancelRepeat;break
}
bind Classy::Text <<Control-Action>> {
	[Classy::mainw %W] mark set insert @%x,%y;break
}
bind Classy::Text <<MXPaste>> {
	catch {[Classy::mainw %W] textinsert [selection get -displayof [Classy::mainw %W]];break}
}
bind Classy::Text <<Left>> {
	[Classy::mainw %W] move left;break
}
bind Classy::Text <<Right>> {
	[Classy::mainw %W] move right;break
}
bind Classy::Text <<Up>> {
	[Classy::mainw %W] move up;break
}
bind Classy::Text <<Down>> {
	[Classy::mainw %W] move down;break
}
bind Classy::Text <<SelectLeft>> {
	[Classy::mainw %W] select left;break
}
bind Classy::Text <<SelectRight>> {
	[Classy::mainw %W] select right;break
}
bind Classy::Text <<SelectUp>> {
	[Classy::mainw %W] select up;break
}
bind Classy::Text <<SelectDown>> {
	[Classy::mainw %W] select down;break
}
bind Classy::Text <<WordLeft>> {
	[Classy::mainw %W] move wordleft;break
}
bind Classy::Text <<WordRight>> {
	[Classy::mainw %W] move wordright;break
}
bind Classy::Text <<SelectWordLeft>> {
	[Classy::mainw %W] select wordleft;break
}
bind Classy::Text <<SelectWordRight>> {
	[Classy::mainw %W] select wordright;break
}
bind Classy::Text <<ParaUp>> {
	[Classy::mainw %W] move uppara;break
}
bind Classy::Text <<ParaDown>> {
	[Classy::mainw %W] move downpara;break
}
bind Classy::Text <<SelectParaUp>> {
	[Classy::mainw %W] select uppara;break
}
bind Classy::Text <<SelectParaDown>> {
	[Classy::mainw %W] select downpara;break
}
bind Classy::Text <<PageUp>> {
	[Classy::mainw %W] move pageup;break
}
bind Classy::Text <<SelectPageUp>> {
	[Classy::mainw %W] select pageup;break
}
bind Classy::Text <<ScrolPageUp>> {
	[Classy::mainw %W] xview scroll -1 page;break
}
bind Classy::Text <<PageDown>> {
	[Classy::mainw %W] move pagedown;break
}
bind Classy::Text <<SelectPageDown>> {
	[Classy::mainw %W] select pagedown;break
}
bind Classy::Text <<ScrollPageDown>> {
	[Classy::mainw %W] xview scroll 1 page;break
}

bind Classy::Text <<Home>> {
	[Classy::mainw %W] move linestart;break
}
bind Classy::Text <<SelectHome>> {
	[Classy::mainw %W] select linestart;break
}
bind Classy::Text <<End>> {
	[Classy::mainw %W] move lineend;break
}
bind Classy::Text <<SelectEnd>> {
	[Classy::mainw %W] select lineend;break
}
bind Classy::Text <<Top>> {
	[Classy::mainw %W] move textstart;break
}
bind Classy::Text <<SelectTop>> {
	[Classy::mainw %W] select textstart;break
}
bind Classy::Text <<Bottom>> {
	[Classy::mainw %W] move textend;break
}
bind Classy::Text <<SelectBottom>> {
	[Classy::mainw %W] select textend;break
}

bind Classy::Text <Tab> {
	[Classy::mainw %W] textinsert \t
	break
}
bind Classy::Text <Shift-Tab> {
	# Needed only to keep <Tab> binding from triggering;  doesn't
	# have to actually do anything.
}
bind Classy::Text <<SpecialFocusNext>> {
	focus [tk_focusNext [Classy::mainw %W]];break
}
bind Classy::Text <<SpecialFocusPrev>> {
	focus [tk_focusPrev [Classy::mainw %W]];break
}
bind Classy::Text <Control-i> {
	[Classy::mainw %W] textinsert \t;break
}
bind Classy::Text <<Return>> {
	[Classy::mainw %W] textinsert \n;break
}
bind Classy::Text <<Delete>> {
	[Classy::mainw %W] textdelete;break
}
bind Classy::Text <<BackSpace>> {
	[Classy::mainw %W] backspace;break
}

bind Classy::Text <<StartSelect>> {
	[Classy::mainw %W] select start;break
}
bind Classy::Text <Select> {
	[Classy::mainw %W] select start;break
}
bind Classy::Text <<EndSelect>> {
	[Classy::mainw %W] select end;break
}
bind Classy::Text <<SelectAll>> {
	[Classy::mainw %W] select all;break
}
bind Classy::Text <<SelectNone>> {
	[Classy::mainw %W] select none;break
}
bind Classy::Text <Insert> {
	catch {[Classy::mainw %W] textinsert [selection get -displayof [Classy::mainw %W]]};break
}
bind Classy::Text <KeyPress> {
	if {"%A"!="{}"} {
		[Classy::mainw %W] textinsert %A
	}
	break
}

# The new bindings

bind Classy::Text <<Copy>> {
	[Classy::mainw %W] copy;break
}												  
bind Classy::Text <<Cut>> {
	[Classy::mainw %W] cut;break
}
bind Classy::Text <<Paste>> {
	[Classy::mainw %W] paste;break
}
bind Classy::Text <<Undo>> {
	[Classy::mainw %W] undo;break
}
bind Classy::Text <<Redo>> {
	[Classy::mainw %W] redo;break
}

# Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
# Otherwise, if a widget binding for one of these is defined, the
# <KeyPress> class binding will also fire and insert the character,
# which is wrong.  Ditto for <Escape>.

bind Classy::Text <Alt-KeyPress> {# nothing }
bind Classy::Text <Meta-KeyPress> {# nothing}
bind Classy::Text <Control-KeyPress> {# nothing}
bind Classy::Text <Escape> {# nothing}
bind Classy::Text <KP_Enter> {# nothing}

# The MouseWheel will typically only fire on Windows.  However,
# someone could use the "event generate" command to produce one
# on other platforms.

Classy::bindmousewheel Classy::Text

set tk::Priv(prevPos) {}

# Classy::Text_SelectTo --
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
proc Classy::Text_SelectTo {w x y} {
	global tk::Priv

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
		Classy::update Classy::Text_SelectTo idletasks
	}
}

# Classy::Text_AutoScan --
# This procedure is invoked when the mouse leaves a text window
# with button 1 down.  It scrolls the window up, down, left, or right,
# depending on where the mouse is (this information was saved in
# tk::Priv(x) and tk::Priv(y)), and reschedules itself as an "after"
# command so that the window continues to scroll until the mouse
# moves back into the window or the mouse button is released.
#
# Arguments:
# w -		The text window.

proc Classy::Text_AutoScan {w} {
	global tk::Priv
	if {![winfo exists $w]} return
	if ![catch {winfo class $w} class] {
		if {"$class" == "Classy::Editor"} {
			set w $w.edit
		} elseif {"$class" == "Classy::ScrolledText"} {
			set w $w.text
		}
	}
	if {$tk::Priv(y) >= [winfo height $w]} {
		$w yview scroll 2 units
	} elseif {$tk::Priv(y) < 0} {
		$w yview scroll -2 units
	} elseif {$tk::Priv(x) >= [winfo width $w]} {
		$w xview scroll 2 units
	} elseif {$tk::Priv(x) < 0} {
		$w xview scroll -2 units
	} else {
		return
	}
	Classy::Text_SelectTo $w $tk::Priv(x) $tk::Priv(y)
	set tk::Priv(afterId) [after 50 Classy::Text_AutoScan $w]
}

# Classy::Text_ResetAnchor --
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

proc Classy::Text_ResetAnchor {w index} {
	global tk::Priv

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


