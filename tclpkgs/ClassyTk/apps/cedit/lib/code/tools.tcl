proc end {w} {
	destroy $w
	if {"[winfo children .]" == ".classy__"} {
		exit
	}
}

proc savestate {} {
	global pwd
	set state ""
	foreach win [winfo children .] {
		if [regexp {^.classy__edit[0-9]+} $win] {
			lappend state [wm geometry $win] [$win.editor private reopenlist] [$win.editor private curfile]
		}
	}
	Classy::Default set app state_$pwd $state
	Classy::Default save app
}

proc edit args {
	if {"$args"==""} {set args "Newfile"}
	set w .classy__edit
	set num 1
	while {[winfo exists $w$num] == 1} {incr num}
	set w $w$num
	catch {destroy $w}
	toplevel $w -bd 0 -highlightthickness 0
	wm protocol $w WM_DELETE_WINDOW "end $w"
	Classy::Editor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{end $w\}"
	pack $w.editor -fill both -expand yes
	eval $w.editor load $args
	return $w
}

