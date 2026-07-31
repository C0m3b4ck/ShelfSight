if ![info exists Classy::patchtk] {
set Classy::patchtk 1
bind Button <Button-1> {}
bind Button <ButtonRelease-1> {}
bind Button <Key-space> {}
bind Checkbutton <Button-1> {}
bind Checkbutton <Key-Return> {}
bind Checkbutton <Key-space> {}
bind Entry <<PasteSelection>> {}
bind Entry <B1-Enter> {}
bind Entry <B1-Leave> {}
bind Entry <B1-Motion> {}
bind Entry <B2-Motion> {}
bind Entry <Button-1> {}
bind Entry <Button-2> {}
bind Entry <ButtonRelease-1> {}
bind Entry <Control-Button-1> {}
bind Entry <Control-Key-Left> {}
bind Entry <Control-Key-Right> {}
bind Entry <Control-Key-a> {}
bind Entry <Control-Key-b> {}
bind Entry <Control-Key-backslash> {}
bind Entry <Control-Key-d> {}
bind Entry <Control-Key-e> {}
bind Entry <Control-Key-f> {}
bind Entry <Control-Key-h> {}
bind Entry <Control-Key-k> {}
bind Entry <Control-Key-slash> {}
bind Entry <Control-Key-space> {}
bind Entry <Control-Key-t> {}
bind Entry <Control-Shift-Key-Left> {}
bind Entry <Control-Shift-Key-Right> {}
bind Entry <Control-Shift-Key-space> {}
bind Entry <Double-Button-1> {}
bind Entry <Double-Shift-Button-1> {}
bind Entry <Key-BackSpace> {}
bind Entry <Key-Delete> {}
bind Entry <Key-End> {}
bind Entry <Key-Escape> {}
bind Entry <Key-Home> {}
bind Entry <Key-Insert> {}
bind Entry <Key-Left> {}
bind Entry <Key-Return> {}
bind Entry <Key-Right> {}
bind Entry <Key-Select> {}
bind Entry <Key-Tab> {}
bind Entry <Meta-Key-BackSpace> {}
bind Entry <Meta-Key-Delete> {}
bind Entry <Meta-Key-b> {}
bind Entry <Meta-Key-d> {}
bind Entry <Meta-Key-f> {}
bind Entry <Shift-Button-1> {}
bind Entry <Shift-Key-End> {}
bind Entry <Shift-Key-Home> {}
bind Entry <Shift-Key-Left> {}
bind Entry <Shift-Key-Right> {}
bind Entry <Shift-Key-Select> {}
bind Entry <Triple-Button-1> {}
bind Entry <Triple-Shift-Button-1> {}
bind Listbox <B1-Enter> {}
bind Listbox <B1-Leave> {}
bind Listbox <B1-Motion> {}
bind Listbox <B2-Motion> {}
bind Listbox <Button-1> {}
bind Listbox <Button-2> {}
bind Listbox <Button-4> {}
bind Listbox <Button-5> {}
bind Listbox <ButtonRelease-1> {}
bind Listbox <Control-Button-1> {}
bind Listbox <Control-Key-End> {}
bind Listbox <Control-Key-Home> {}
bind Listbox <Control-Key-Left> {}
bind Listbox <Control-Key-Next> {}
bind Listbox <Control-Key-Prior> {}
bind Listbox <Control-Key-Right> {}
bind Listbox <Control-Key-backslash> {}
bind Listbox <Control-Key-slash> {}
bind Listbox <Control-Shift-Key-End> {}
bind Listbox <Control-Shift-Key-Home> {}
bind Listbox <Control-Shift-Key-space> {}
bind Listbox <Double-Button-1> {}
bind Listbox <Key-Down> {}
bind Listbox <Key-End> {}
bind Listbox <Key-Escape> {}
bind Listbox <Key-Home> {}
bind Listbox <Key-Left> {}
bind Listbox <Key-Next> {}
bind Listbox <Key-Prior> {}
bind Listbox <Key-Right> {}
bind Listbox <Key-Select> {}
bind Listbox <Key-Up> {}
bind Listbox <Key-space> {}
bind Listbox <MouseWheel> {}
bind Listbox <Shift-Button-1> {}
bind Listbox <Shift-Key-Down> {}
bind Listbox <Shift-Key-Select> {}
bind Listbox <Shift-Key-Up> {}
bind Menu <Key-Down> {}
bind Menu <Key-Escape> {}
bind Menu <Key-Left> {}
bind Menu <Key-Return> {}
bind Menu <Key-Right> {}
bind Menu <Key-Up> {}
bind Menu <Key-space> {}
bind Menubutton <B1-Motion> {}
bind Menubutton <Button-1> {}
bind Menubutton <ButtonRelease-1> {}
bind Menubutton <Key-space> {}
bind Radiobutton <Button-1> {}
bind Radiobutton <Key-Return> {}
bind Radiobutton <Key-space> {}
bind Scale <B1-Enter> {}
bind Scale <B1-Leave> {}
bind Scale <B1-Motion> {}
bind Scale <B2-Enter> {}
bind Scale <B2-Leave> {}
bind Scale <B2-Motion> {}
bind Scale <Button-1> {}
bind Scale <Button-2> {}
bind Scale <ButtonRelease-1> {}
bind Scale <ButtonRelease-2> {}
bind Scale <Control-Button-1> {}
bind Scale <Control-Key-Down> {}
bind Scale <Control-Key-Left> {}
bind Scale <Control-Key-Right> {}
bind Scale <Control-Key-Up> {}
bind Scale <Key-Down> {}
bind Scale <Key-End> {}
bind Scale <Key-Home> {}
bind Scale <Key-Left> {}
bind Scale <Key-Right> {}
bind Scale <Key-Up> {}
bind Scrollbar <B1-B2-Motion> {}
bind Scrollbar <B1-Button-2> {}
bind Scrollbar <B1-ButtonRelease-2> {}
bind Scrollbar <B1-Enter> {}
bind Scrollbar <B1-Leave> {}
bind Scrollbar <B1-Motion> {}
bind Scrollbar <B2-Button-1> {}
bind Scrollbar <B2-ButtonRelease-1> {}
bind Scrollbar <B2-Enter> {}
bind Scrollbar <B2-Leave> {}
bind Scrollbar <B2-Motion> {}
bind Scrollbar <Button-1> {}
bind Scrollbar <Button-2> {}
bind Scrollbar <ButtonRelease-1> {}
bind Scrollbar <ButtonRelease-2> {}
bind Scrollbar <Control-Button-1> {}
bind Scrollbar <Control-Button-2> {}
bind Scrollbar <Control-Key-Down> {}
bind Scrollbar <Control-Key-Left> {}
bind Scrollbar <Control-Key-Right> {}
bind Scrollbar <Control-Key-Up> {}
bind Scrollbar <Key-Down> {}
bind Scrollbar <Key-End> {}
bind Scrollbar <Key-Home> {}
bind Scrollbar <Key-Left> {}
bind Scrollbar <Key-Next> {}
bind Scrollbar <Key-Prior> {}
bind Scrollbar <Key-Right> {}
bind Scrollbar <Key-Up> {}
bind Text <<PasteSelection>> {}
bind Text <B1-Enter> {}
bind Text <B1-Leave> {}
bind Text <B1-Motion> {}
bind Text <B2-Motion> {}
bind Text <Button-1> {}
bind Text <Button-2> {}
bind Text <Button-4> {}
bind Text <Button-5> {}
bind Text <ButtonRelease-1> {}
bind Text <Control-Button-1> {}
bind Text <Control-Key-Down> {}
bind Text <Control-Key-End> {}
bind Text <Control-Key-Home> {}
bind Text <Control-Key-Left> {}
bind Text <Control-Key-Next> {}
bind Text <Control-Key-Prior> {}
bind Text <Control-Key-Right> {}
bind Text <Control-Key-Tab> {}
bind Text <Control-Key-Up> {}
bind Text <Control-Key-a> {}
bind Text <Control-Key-b> {}
bind Text <Control-Key-backslash> {}
bind Text <Control-Key-d> {}
bind Text <Control-Key-e> {}
bind Text <Control-Key-f> {}
bind Text <Control-Key-h> {}
bind Text <Control-Key-i> {}
bind Text <Control-Key-k> {}
bind Text <Control-Key-n> {}
bind Text <Control-Key-o> {}
bind Text <Control-Key-p> {}
bind Text <Control-Key-slash> {}
bind Text <Control-Key-space> {}
bind Text <Control-Key-t> {}
bind Text <Control-Key-v> {}
bind Text <Control-Shift-Key-Down> {}
bind Text <Control-Shift-Key-End> {}
bind Text <Control-Shift-Key-Home> {}
bind Text <Control-Shift-Key-Left> {}
bind Text <Control-Shift-Key-Right> {}
bind Text <Control-Shift-Key-Tab> {}
bind Text <Control-Shift-Key-Up> {}
bind Text <Control-Shift-Key-space> {}
bind Text <Double-Button-1> {}
bind Text <Double-Shift-Button-1> {}
bind Text <Key-BackSpace> {}
bind Text <Key-Delete> {}
bind Text <Key-Down> {}
bind Text <Key-End> {}
bind Text <Key-Escape> {}
bind Text <Key-Home> {}
bind Text <Key-Insert> {}
bind Text <Key-Left> {}
bind Text <Key-Next> {}
bind Text <Key-Prior> {}
bind Text <Key-Return> {}
bind Text <Key-Right> {}
bind Text <Key-Select> {}
bind Text <Key-Tab> {}
bind Text <Key-Up> {}
bind Text <Meta-Key-BackSpace> {}
bind Text <Meta-Key-Delete> {}
bind Text <Meta-Key-b> {}
bind Text <Meta-Key-d> {}
bind Text <Meta-Key-f> {}
bind Text <Meta-Key-greater> {}
bind Text <Meta-Key-less> {}
bind Text <MouseWheel> {}
bind Text <Shift-Button-1> {}
bind Text <Shift-Key-Down> {}
bind Text <Shift-Key-End> {}
bind Text <Shift-Key-Home> {}
bind Text <Shift-Key-Left> {}
bind Text <Shift-Key-Next> {}
bind Text <Shift-Key-Prior> {}
bind Text <Shift-Key-Right> {}
bind Text <Shift-Key-Select> {}
bind Text <Shift-Key-Up> {}
bind Text <Triple-Button-1> {}
bind Text <Triple-Shift-Button-1> {}
bind all <<PrevWindow>> {}
bind all <Key-F10> {}
bind all <Key-Tab> {}
bind Button <<Action-ButtonRelease>> {
    tkButtonUp %W
}
bind Button <<Action>> {
    tkButtonDown %W
}
bind Button <<Invoke>> {
    tkButtonInvoke %W
}
bind Button <Enter> {
    tkButtonEnter %W
}
bind Button <Leave> {
    tkButtonLeave %W
}
bind Checkbutton <<Action>> {
	tkCheckRadioInvoke %W
    }
bind Checkbutton <<Invoke>> {
    tkCheckRadioInvoke %W
}
bind Checkbutton <<Return>> {
	if {!$tk_strictMotif} {
	    tkCheckRadioInvoke %W
	}
    }
bind Checkbutton <Enter> {
	tkButtonEnter %W
    }
bind Checkbutton <Leave> {
    tkButtonLeave %W
}
bind Entry <<Action-ButtonRelease>> {
    tkCancelRepeat
}
bind Entry <<Action-Enter>> {
    tkCancelRepeat
}
bind Entry <<Action-Leave>> {
    set tkPriv(x) %x
    tkEntryAutoScan %W
}
bind Entry <<Action-Motion>> {
    set tkPriv(x) %x
    tkEntryMouseSelect %W %x
}
bind Entry <<Action>> {
    tkEntryButton1 %W %x
    %W selection clear
}
bind Entry <<Adjust-ButtonRelease>> {}
bind Entry <<BackSpace>> {
    tkEntryBackspace %W
}
bind Entry <<Clear>> {
    %W delete sel.first sel.last
}
bind Entry <<Copy>> {
    if {![catch {tkEntryGetSelection %W} tkPriv(data)]} {
	clipboard clear -displayof %W
	clipboard append -displayof %W $tkPriv(data)
	unset tkPriv(data)
    }
}
bind Entry <<Cut>> {
    if {![catch {tkEntryGetSelection %W} tkPriv(data)]} {
	clipboard clear -displayof %W
	clipboard append -displayof %W $tkPriv(data)
	%W delete sel.first sel.last
	unset tkPriv(data)
    }
}
bind Entry <<Delete>> {
    if {[%W selection present]} {
	%W delete sel.first sel.last
    } else {
	%W delete insert
    }
}
bind Entry <<DeleteEnd>> {
    if {!$tk_strictMotif} {
	%W delete insert end
    }
}
bind Entry <<Empty>> {%W delete 0 end}
bind Entry <<End>> {
    tkEntrySetCursor %W end
}
bind Entry <<EndSelect>> {
    %W selection adjust insert
}
bind Entry <<Escape>> {# nothing}
bind Entry <<FocusNext>> {# nothing}
bind Entry <<Home>> {
    tkEntrySetCursor %W 0
}
bind Entry <<Left>> {
    tkEntrySetCursor %W [expr {[%W index insert] - 1}]
}
bind Entry <<MAdd>> {
    %W icursor @%x
}
bind Entry <<MExtend>> {
    set tkPriv(selectMode) char
    %W selection adjust @%x
}
bind Entry <<MExtendLine>> {
    set tkPriv(selectMode) line
    tkEntryMouseSelect %W %x
}
bind Entry <<MExtendWord>> {
    set tkPriv(selectMode) word
    tkEntryMouseSelect %W %x
}
bind Entry <<MIcursor>> {}
bind Entry <<MSelectLine>> {
    set tkPriv(selectMode) line
    tkEntryMouseSelect %W %x
    %W icursor 0
}
bind Entry <<MSelectWord>> {
    set tkPriv(selectMode) word
    tkEntryMouseSelect %W %x
    catch {%W icursor sel.first}
}
bind Entry <<Paste>> {
    global tcl_platform
    catch {
	if {[string compare $tcl_platform(platform) "unix"]} {
	    catch {
		%W delete sel.first sel.last
	    }
	}
	%W insert insert [selection get -displayof %W -selection CLIPBOARD]
	tkEntrySeeInsert %W
    }
}
bind Entry <<Return>> {# nothing}
bind Entry <<Right>> {
    tkEntrySetCursor %W [expr {[%W index insert] + 1}]
}
bind Entry <<SelectAll>> {
    %W selection range 0 end
}
bind Entry <<SelectEnd>> {
    tkEntryKeySelect %W end
    tkEntrySeeInsert %W
}
bind Entry <<SelectHome>> {
    tkEntryKeySelect %W 0
    tkEntrySeeInsert %W
}
bind Entry <<SelectLeft>> {
    tkEntryKeySelect %W [expr {[%W index insert] - 1}]
    tkEntrySeeInsert %W
}
bind Entry <<SelectNone>> {
    %W selection clear
}
bind Entry <<SelectRight>> {
    tkEntryKeySelect %W [expr {[%W index insert] + 1}]
    tkEntrySeeInsert %W
}
bind Entry <<SelectWordLeft>> {
    tkEntryKeySelect %W [tkEntryPreviousWord %W insert]
    tkEntrySeeInsert %W
}
bind Entry <<SelectWordRight>> {
    tkEntryKeySelect %W [tkEntryNextWord %W insert]
    tkEntrySeeInsert %W
}
bind Entry <<StartSelect>> {
    %W selection from insert
}
bind Entry <<Transpose>> {
    if {!$tk_strictMotif} {
	tkEntryTranspose %W
    }
}
bind Entry <<WordLeft>> {
    tkEntrySetCursor %W [tkEntryPreviousWord %W insert]
}
bind Entry <<WordRight>> {
    tkEntrySetCursor %W [tkEntryNextWord %W insert]
}
bind Entry <Alt-Key> {# nothing}
bind Entry <Control-Key> {# nothing}
bind Entry <Key-KP_Enter> {# nothing}
bind Entry <Key> {
    tkEntryInsert %W %A
}
bind Entry <Meta-Key> {# nothing}
bind Listbox <<Action-ButtonRelease>> {
    tkCancelRepeat
    %W activate @%x,%y
}
bind Listbox <<Action-Enter>> {
    tkCancelRepeat
}
bind Listbox <<Action-Leave>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkListboxAutoScan %W
}
bind Listbox <<Action-Motion>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkListboxMotion %W [%W index @%x,%y]
}
bind Listbox <<Action>> {
    if {[winfo exists %W]} {
	tkListboxBeginSelect %W [%W index @%x,%y]
    }
}
bind Listbox <<Adjust-Motion>> {
    %W scan dragto %x %y
}
bind Listbox <<Adjust>> {
    %W scan mark %x %y
}
bind Listbox <<Bottom>> {
    %W activate end
    %W see end
    %W selection clear 0 end
    %W selection set end
    event generate %W <<ListboxSelect>>
}
bind Listbox <<Copy>> {
    if {[string equal [selection own -displayof %W] "%W"]} {
	clipboard clear -displayof %W
	clipboard append -displayof %W [selection get -displayof %W]
    }
}
bind Listbox <<Down>> {
    tkListboxUpDown %W 1
}
bind Listbox <<End>> {
    %W xview moveto 1
}
bind Listbox <<EndSelect>> {
    tkListboxBeginExtend %W [%W index active]
}
bind Listbox <<Escape>> {
    tkListboxCancel %W
}
bind Listbox <<Home>> {
    %W xview moveto 0
}
bind Listbox <<Invoke>> {
    tkListboxBeginSelect %W [%W index active]
}
bind Listbox <<Left>> {
    %W xview scroll -1 units
}
bind Listbox <<MAdd>> {
    tkListboxBeginToggle %W [%W index @%x,%y]
}
bind Listbox <<MExtend>> {
    tkListboxBeginExtend %W [%W index @%x,%y]
}
bind Listbox <<MSelectWord>> {
    # Empty script
}
bind Listbox <<PageDown>> {
    %W yview scroll 1 pages
    %W activate @0,0
}
bind Listbox <<PageUp>> {
    %W yview scroll -1 pages
    %W activate @0,0
}
bind Listbox <<Right>> {
    %W xview scroll 1 units
}
bind Listbox <<ScrollPageDown>> {
    %W xview scroll 1 pages
}
bind Listbox <<ScrollPageUp>> {
    %W xview scroll -1 pages
}
bind Listbox <<SelectAll>> {
    tkListboxSelectAll %W
}
bind Listbox <<SelectBottom>> {
    tkListboxDataExtend %W [%W index end]
}
bind Listbox <<SelectDown>> {
    tkListboxExtendUpDown %W 1
}
bind Listbox <<SelectNone>> {
    if {[string compare [%W cget -selectmode] "browse"]} {
	%W selection clear 0 end
	event generate %W <<ListboxSelect>>
    }
}
bind Listbox <<SelectTop>> {
    tkListboxDataExtend %W 0
}
bind Listbox <<SelectUp>> {
    tkListboxExtendUpDown %W -1
}
bind Listbox <<Top>> {
    %W activate 0
    %W see 0
    %W selection clear 0 end
    %W selection set 0
    event generate %W <<ListboxSelect>>
}
bind Listbox <<Up>> {
    tkListboxUpDown %W -1
}
bind Listbox <<WordLeft>> {
    %W xview scroll -1 pages
}
bind Listbox <<WordRight>> {
    %W xview scroll 1 pages
}
bind Menu <<Down>> {
    tkMenuDownArrow %W
}
bind Menu <<Escape>> {
    tkMenuEscape %W
}
bind Menu <<Invoke>> {
    tkMenuInvoke %W 0
}
bind Menu <<Left>> {
    tkMenuLeftArrow %W
}
bind Menu <<Return>> {
    tkMenuInvoke %W 0
}
bind Menu <<Right>> {
    tkMenuRightArrow %W
}
bind Menu <<Up>> {
    tkMenuUpArrow %W
}
bind Menu <Button> {
    tkMenuButtonDown %W
}
bind Menu <ButtonRelease> {
   tkMenuInvoke %W 1
}
bind Menu <Enter> {
    set tkPriv(window) %W
    if {[string equal [%W cget -type] "tearoff"]} {
	if {[string compare "%m" "NotifyUngrab"]} {
	    if {[string equal $tcl_platform(platform) "unix"]} {
		tk_menuSetFocus %W
	    }
	}
    }
    tkMenuMotion %W %x %y %s
}
bind Menu <Key> {
    tkTraverseWithinMenu %W %A
}
bind Menu <Leave> {
    tkMenuLeave %W %X %Y %s
}
bind Menu <Motion> {
    tkMenuMotion %W %x %y %s
}
bind Menubutton <<Action-ButtonRelease>> {
    tkMbButtonUp %W
}
bind Menubutton <<Action-Motion>> {
    tkMbMotion %W down %X %Y
}
bind Menubutton <<Action>> {
    if {[string compare $tkPriv(inMenubutton) ""]} {
	tkMbPost $tkPriv(inMenubutton) %X %Y
    }
}
bind Menubutton <<Invoke>> {
    tkMbPost %W
    tkMenuFirstEntry [%W cget -menu]
}
bind Menubutton <Enter> {
    tkMbEnter %W
}
bind Menubutton <Leave> {
    tkMbLeave %W
}
bind Menubutton <Motion> {
    tkMbMotion %W up %X %Y
}
bind Radiobutton <<Action>> {
	tkCheckRadioInvoke %W
    }
bind Radiobutton <<Invoke>> {
    tkCheckRadioInvoke %W
}
bind Radiobutton <<Return>> {
	if {!$tk_strictMotif} {
	    tkCheckRadioInvoke %W
	}
    }
bind Radiobutton <Enter> {
	tkButtonEnter %W
    }
bind Radiobutton <Leave> {
    tkButtonLeave %W
}
bind Scale <<Action-ButtonRelease>> {
    tkCancelRepeat
    tkScaleEndDrag %W
    tkScaleActivate %W %x %y
}
bind Scale <<Action-Enter>> { }
bind Scale <<Action-Leave>> { }
bind Scale <<Action-Motion>> {
    tkScaleDrag %W %x %y
}
bind Scale <<Action>> {
    tkScaleButtonDown %W %x %y
}
bind Scale <<Adjust-ButtonRelease>> {}
bind Scale <<Adjust-Enter>> { }
bind Scale <<Adjust-Leave>> { }
bind Scale <<Adjust-Motion>> {
    tkScaleDrag %W %x %y
}
bind Scale <<Adjust>> {
    tkScaleButton2Down %W %x %y
}
bind Scale <<Down>> {
    tkScaleIncrement %W down little noRepeat
}
bind Scale <<End>> {
    %W set [%W cget -to]
}
bind Scale <<Home>> {
    %W set [%W cget -from]
}
bind Scale <<Left>> {
    tkScaleIncrement %W up little noRepeat
}
bind Scale <<MAdd>> {
    tkScaleControlPress %W %x %y
}
bind Scale <<MXPaste>> {
    tkCancelRepeat
    tkScaleEndDrag %W
    tkScaleActivate %W %x %y
}
bind Scale <<ParaDown>> {
    tkScaleIncrement %W down big noRepeat
}
bind Scale <<ParaUp>> {
    tkScaleIncrement %W up big noRepeat
}
bind Scale <<Right>> {
    tkScaleIncrement %W down little noRepeat
}
bind Scale <<Up>> {
    tkScaleIncrement %W up little noRepeat
}
bind Scale <<WordLeft>> {
    tkScaleIncrement %W up big noRepeat
}
bind Scale <<WordRight>> {
    tkScaleIncrement %W down big noRepeat
}
bind Scale <Enter> {
    if {$tk_strictMotif} {
	set tkPriv(activeBg) [%W cget -activebackground]
	%W config -activebackground [%W cget -background]
    }
    tkScaleActivate %W %x %y
}
bind Scale <Leave> {
    if {$tk_strictMotif} {
	%W config -activebackground $tkPriv(activeBg)
    }
    if {[string equal [%W cget -state] "active"]} {
	%W configure -state normal
    }
}
bind Scale <Motion> {
    tkScaleActivate %W %x %y
}
bind Scrollbar <<Action-ButtonRelease>> {
    tkScrollButtonUp %W %x %y
}
bind Scrollbar <<Action-Enter>> {
    # Prevents <Enter> binding from being invoked.
}
bind Scrollbar <<Action-Leave>> {
    # Prevents <Leave> binding from being invoked.
}
bind Scrollbar <<Action-Motion>> {
    tkScrollDrag %W %x %y
}
bind Scrollbar <<Action>> {
    tkScrollButtonDown %W %x %y
}
bind Scrollbar <<Adjust-Enter>> {
    # Prevents <Enter> binding from being invoked.
}
bind Scrollbar <<Adjust-Leave>> {
    # Prevents <Leave> binding from being invoked.
}
bind Scrollbar <<Adjust-Motion>> {
    tkScrollDrag %W %x %y
}
bind Scrollbar <<Adjust>> {
    tkScrollButton2Down %W %x %y
}
bind Scrollbar <<Down>> {
    tkScrollByUnits %W v 1
}
bind Scrollbar <<End>> {
    tkScrollToPos %W 1
}
bind Scrollbar <<Home>> {
    tkScrollToPos %W 0
}
bind Scrollbar <<Left>> {
    tkScrollByUnits %W h -1
}
bind Scrollbar <<MAdd>> {
    tkScrollTopBottom %W %x %y
}
bind Scrollbar <<MPosition>> {}
bind Scrollbar <<MXPaste>> {
    tkScrollButtonUp %W %x %y
}
bind Scrollbar <<PageDown>> {
    tkScrollByPages %W hv 1
}
bind Scrollbar <<PageUp>> {
    tkScrollByPages %W hv -1
}
bind Scrollbar <<ParaDown>> {
    tkScrollByPages %W v 1
}
bind Scrollbar <<ParaUp>> {
    tkScrollByPages %W v -1
}
bind Scrollbar <<Right>> {
    tkScrollByUnits %W h 1
}
bind Scrollbar <<Up>> {
    tkScrollByUnits %W v -1
}
bind Scrollbar <<WordLeft>> {
    tkScrollByPages %W h -1
}
bind Scrollbar <<WordRight>> {
    tkScrollByPages %W h 1
}
bind Scrollbar <Enter> {
    if {$tk_strictMotif} {
	set tkPriv(activeBg) [%W cget -activebackground]
	%W config -activebackground [%W cget -background]
    }
    %W activate [%W identify %x %y]
}
bind Scrollbar <Leave> {
    if {$tk_strictMotif && [info exists tkPriv(activeBg)]} {
	%W config -activebackground $tkPriv(activeBg)
    }
    %W activate {}
}
bind Scrollbar <Motion> {
    %W activate [%W identify %x %y]
}
bind Text <<Action-ButtonRelease>> {
    tkCancelRepeat
}
bind Text <<Action-Enter>> {
    tkCancelRepeat
}
bind Text <<Action-Leave>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkTextAutoScan %W
}
bind Text <<Action-Motion>> {
    set tkPriv(x) %x
    set tkPriv(y) %y
    tkTextSelectTo %W %x %y
}
bind Text <<Action>> {
    tkTextButton1 %W %x %y
    %W tag remove sel 0.0 end
}
bind Text <<Adjust-ButtonRelease>> {}
bind Text <<BackSpace>> {
    if {[string compare [%W tag nextrange sel 1.0 end] ""]} {
	%W delete sel.first sel.last
    } elseif {[%W compare insert != 1.0]} {
	%W delete insert-1c
	%W see insert
    }
}
bind Text <<Bottom>> {
    tkTextSetCursor %W {end - 1 char}
}
bind Text <<Clear>> {
    catch {%W delete sel.first sel.last}
}
bind Text <<Copy>> {
    tk_textCopy %W
}
bind Text <<Cut>> {
    tk_textCut %W
}
bind Text <<Delete>> {
    if {[string compare [%W tag nextrange sel 1.0 end] ""]} {
	%W delete sel.first sel.last
    } else {
	%W delete insert
	%W see insert
    }
}
bind Text <<DeleteEnd>> {
    if {!$tk_strictMotif} {
	if {[%W compare insert == {insert lineend}]} {
	    %W delete insert
	} else {
	    %W delete insert {insert lineend}
	}
    }
}
bind Text <<Down>> {
    tkTextSetCursor %W [tkTextUpDownLine %W 1]
}
bind Text <<End>> {
    tkTextSetCursor %W {insert lineend}
}
bind Text <<EndSelect>> {
    set tkPriv(selectMode) char
    tkTextKeyExtend %W insert
}
bind Text <<Escape>> {# nothing}
bind Text <<FocusNext>> {
    tkTextInsert %W \t
    focus %W
    break
}
bind Text <<Home>> {
    tkTextSetCursor %W {insert linestart}
}
bind Text <<Left>> {
    tkTextSetCursor %W insert-1c
}
bind Text <<MAdd>> {
    %W mark set insert @%x,%y
}
bind Text <<MExtend>> {
    tkTextResetAnchor %W @%x,%y
    set tkPriv(selectMode) char
    tkTextSelectTo %W %x %y
}
bind Text <<MExtendLine>> {
    set tkPriv(selectMode) line
    tkTextSelectTo %W %x %y
}
bind Text <<MExtendWord>> {
    set tkPriv(selectMode) word
    tkTextSelectTo %W %x %y 1
}
bind Text <<MIcursor>> {}
bind Text <<MSelectLine>> {
    set tkPriv(selectMode) line
    tkTextSelectTo %W %x %y
    catch {%W mark set insert sel.last}
    catch {%W mark set anchor sel.first}
}
bind Text <<MSelectWord>> {
    set tkPriv(selectMode) word
    tkTextSelectTo %W %x %y
    catch {%W mark set insert sel.last}
    catch {%W mark set anchor sel.first}
}
bind Text <<PageDown>> {
    tkTextSetCursor %W [tkTextScrollPages %W 1]
}
bind Text <<PageUp>> {
    tkTextSetCursor %W [tkTextScrollPages %W -1]
}
bind Text <<ParaDown>> {
    tkTextSetCursor %W [tkTextNextPara %W insert]
}
bind Text <<ParaUp>> {
    tkTextSetCursor %W [tkTextPrevPara %W insert]
}
bind Text <<Paste>> {
    tk_textPaste %W
}
bind Text <<Return>> {
    tkTextInsert %W \n
}
bind Text <<Right>> {
    tkTextSetCursor %W insert+1c
}
bind Text <<ScrollPageDown>> {
    %W xview scroll 1 page
}
bind Text <<ScrollPageUp>> {
    %W xview scroll -1 page
}
bind Text <<SelectAll>> {
    %W tag add sel 1.0 end
}
bind Text <<SelectBottom>> {
    tkTextKeySelect %W {end - 1 char}
}
bind Text <<SelectDown>> {
    tkTextKeySelect %W [tkTextUpDownLine %W 1]
}
bind Text <<SelectEnd>> {
    tkTextKeySelect %W {insert lineend}
}
bind Text <<SelectHome>> {
    tkTextKeySelect %W {insert linestart}
}
bind Text <<SelectLeft>> {
    tkTextKeySelect %W [%W index {insert - 1c}]
}
bind Text <<SelectNone>> {
    %W tag remove sel 1.0 end
}
bind Text <<SelectPageDown>> {
    tkTextKeySelect %W [tkTextScrollPages %W 1]
}
bind Text <<SelectPageUp>> {
    tkTextKeySelect %W [tkTextScrollPages %W -1]
}
bind Text <<SelectParaDown>> {
    tkTextKeySelect %W [tkTextNextPara %W insert]
}
bind Text <<SelectParaUp>> {
    tkTextKeySelect %W [tkTextPrevPara %W insert]
}
bind Text <<SelectRight>> {
    tkTextKeySelect %W [%W index {insert + 1c}]
}
bind Text <<SelectTop>> {
    tkTextKeySelect %W 1.0
}
bind Text <<SelectUp>> {
    tkTextKeySelect %W [tkTextUpDownLine %W -1]
}
bind Text <<SelectWordLeft>> {
    tkTextKeySelect %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
}
bind Text <<SelectWordRight>> {
    tkTextKeySelect %W [tkTextNextWord %W insert]
}
bind Text <<StartSelect>> {
    %W mark set anchor insert
}
bind Text <<TextFocusNext>> {
    focus [tk_focusNext %W]
}
bind Text <<TextFocusPrev>> {
    focus [tk_focusPrev %W]
}
bind Text <<Top>> {
    tkTextSetCursor %W 1.0
}
bind Text <<Transpose>> {
    if {!$tk_strictMotif} {
	tkTextTranspose %W
    }
}
bind Text <<Up>> {
    tkTextSetCursor %W [tkTextUpDownLine %W -1]
}
bind Text <<WordLeft>> {
    tkTextSetCursor %W [tkTextPrevPos %W insert tcl_startOfPreviousWord]
}
bind Text <<WordRight>> {
    tkTextSetCursor %W [tkTextNextWord %W insert]
}
bind Text <Alt-Key> {# nothing }
bind Text <Control-Key> {# nothing}
bind Text <Escape> {}
bind Text <Key-KP_Enter> {# nothing}
bind Text <Key> {
    tkTextInsert %W %A
}
bind Text <Meta-Key> {# nothing}
bind Text <Return> {}
bind Text <Shift-Key-Tab> {
    # Needed only to keep <Tab> binding from triggering;  doesn't
    # have to actually do anything.
    break
}
bind all <<FocusNext>> {tkTabToWindow [tk_focusNext %W]}
bind all <<FocusPrev>> {tkTabToWindow [tk_focusPrev %W]}
bind all <Alt-Key> {
	tkTraverseToMenu %W %A
    }
}
