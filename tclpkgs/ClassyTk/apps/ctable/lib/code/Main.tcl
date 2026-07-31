proc main args {
	auto_load Classy::TableEditor
	source [file join $Classy::appdir lib code tools.tcl]
	set state [Classy::Default get app state_$::pwd]
	if {("$state" == "")||("$args" != "")} {
		set num 1
		set w .classy__tableedit$num
		catch {destroy $w}
		toplevel $w -bd 0 -highlightthickness 0
		wm protocol $w WM_DELETE_WINDOW "end $w"
		Classy::TableEditor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{end $w\}"
		pack $w.editor -fill both -expand yes
		if {[llength $args]} {
			eval $w.editor load $args
		}
	} else {
		set num 1
		foreach {geom files curfile} $state {
			set w .classy__tableedit$num
			catch {destroy $w}
			toplevel $w -bd 0 -highlightthickness 0
			wm geometry $w $geom
			wm protocol $w WM_DELETE_WINDOW "end $w"
			Classy::TableEditor $w.editor -loadcommand "Classy::title $w" -closecommand "after idle \{end $w\}"
			pack $w.editor -fill both -expand yes
			eval $w.editor load $files
			$w.editor load $curfile
			incr num
		}
	}	
}

