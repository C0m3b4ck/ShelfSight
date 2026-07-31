#!/bin/sh
# the next line restarts using wish \
exec wish "$0" ${1+"$@"}
package require Tk

set f [open patchtk.tcl w]
puts $f "if !\[info exists Classy::patchtk\] \{"
puts $f "set Classy::patchtk 1"

foreach item {
	FocusIn FocusOut Enter Leave Motion Key KeyPress ButtonPress ButtonRelease
	Key-KP_Enter Control-Key Meta-Key Alt-Key
	Button
	Key-Tab Shift-Key-Tab
} {
	set map(<$item>) <$item>
}
array set map {
	<Button-1> <<Action>>
	<ButtonRelease-1> <<Action-ButtonRelease>>
	<B1-Motion> <<Action-Motion>>
	<B1-Leave> <<Action-Leave>>
	<B1-Enter> <<Action-Enter>>
	<Double-Button-1> <<MSelectWord>>
	<Triple-Button-1> <<MSelectLine>>
	<Shift-Button-1> <<MExtend>>
	<Control-Button-1> <<MAdd>>
	<Double-Shift-Button-1> <<MExtendWord>>
	<Triple-Shift-Button-1> <<MExtendLine>>
	<Button-2> <<Adjust>>
	<ButtonRelease-2> <<MXPaste>>
	<B2-Motion> <<Adjust-Motion>>
	<B2-Leave> <<Adjust-Leave>>
	<B2-Enter> <<Adjust-Enter>>

	<Key-Left> <<Left>>
	<Shift-Key-Left> <<SelectLeft>>
	<Control-Key-Left> <<WordLeft>>
	<Control-Shift-Key-Left> <<SelectWordLeft>>
	<Key-Right> <<Right>>
	<Shift-Key-Right> <<SelectRight>>
	<Control-Key-Right> <<WordRight>>
	<Control-Shift-Key-Right> <<SelectWordRight>>
	<Key-Up> <<Up>>
	<Shift-Key-Up> <<SelectUp>>
	<Control-Key-Up> <<ParaUp>>
	<Control-Shift-Key-Up> <<SelectParaUp>>
	<Key-Down> <<Down>>
	<Shift-Key-Down> <<SelectDown>>
	<Control-Key-Down> <<ParaDown>>
	<Control-Shift-Key-Down> <<SelectParaDown>>
	<Key-Home> <<Home>>
	<Shift-Key-Home> <<SelectHome>>
	<Control-Key-Home> <<Top>>
	<Control-Shift-Key-Home> <<SelectTop>>
	<Key-End> <<End>>
	<Shift-Key-End> <<SelectEnd>>
	<Control-Key-End> <<Bottom>>
	<Control-Shift-Key-End> <<SelectBottom>>
	<Key-Prior> <<PageUp>>
	<Key-Next> <<PageDown>>
	<Shift-Key-Prior> <<SelectPageUp>>
	<Shift-Key-Next> <<SelectPageDown>>
	<Control-Key-Prior> <<ScrollPageUp>>
	<Control-Key-Next> <<ScrollPageDown>>

	<Key-Delete> <<Delete>>
	<Key-BackSpace> <<BackSpace>>
	<Control-Key-space> <<StartSelect>>
	<Control-Shift-Key-space> <<EndSelect>>
	<Control-Key-slash> <<SelectAll>>
	<Control-Key-backslash> <<SelectNone>>
	<Control-Key-t> <<Transpose>>
	<Control-Key-k> <<DeleteEnd>>
	<Meta-Key-f> <<WordRight>>
	<Meta-Key-b> <<WordLeft>>

	<Key-space> <<Invoke>>
	<<Cut>> <<Cut>>
	<<Paste>> <<Paste>>
	<<Copy>> <<Copy>>
	<<Clear>> <<Clear>>
	<Key-Escape> <<Escape>>
	<Key-Return> <<Return>>
	<Control-Key-Tab> <<TextFocusNext>>
	<Control-Shift-Key-Tab> <<TextFocusPrev>>
	<Key-Tab> <<FocusNext>>
	<<PrevWindow>> <<FocusPrev>>
}

unset -nocomplain oldbindings
unset -nocomplain newbindings
set list {Button Radiobutton Checkbutton Entry Listbox Menubutton Menu Scale Scrollbar Text all}

foreach type $list {
	foreach event [bind $type] {
		set temp [bind $type $event]
		if [info exists map($event)] {
			if {"$event" != "$map($event)"} {
				set oldbindings($type,$event) {}
			}
			set newbindings($type,$map($event)) $temp
		} else {
#			set oldbindings($type,$event) {}
		}
	}
}

foreach {type event} {
	Text <<Adjust>>
	Text <<Adjust-Motion>>
	Entry <<Adjust>> 
	Entry <<Adjust-Motion>>
	Entry <Tab>
} {
	unset -nocomplain newbindings($type,$event)
}

set newbindings(Entry,<<Empty>>) {%W delete 0 end}
foreach {type old new} {
	Text <<Return>> <Return>
	Text <<Escape>> <Escape>
	Text <<MAdd>> <<MIcursor>>
	Entry <<MAdd>> <<MIcursor>>
	Entry <<MXPaste>> <<Adjust-ButtonRelease>>
	Text <<MXPaste>> <<Adjust-ButtonRelease>>
	Scale <<MXPaste>> <<Adjust-ButtonRelease>>
	Scrollbar <<MAdd> <<MPosition>>
} {
	set temp [bind $type $old]
	set newbindings($type,$new) $temp
}

foreach binding [lsort [array names oldbindings]] {
	set binding [split $binding ","]
	puts $f [list bind [lindex $binding 0] [lindex $binding 1] {}]
}

foreach binding [lsort [array names newbindings]] {
	set split [split $binding ","]
	puts $f [list bind [lindex $split 0] [lindex $split 1] $newbindings($binding)]
}

puts $f "\}"
close $f

exit