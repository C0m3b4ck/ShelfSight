Classy::Editor method _checkercancel {} {
	private $object checker
	set checker(cancel) 1
}

Classy::Editor method _checkergoto {args} {
	private $object checker
	set w $object.checker
	set spec [$w.options.list get]
	set spec [lindex $spec 0]
	$object goto $spec
	Classy::update Classy::Editor-_checkergoto
	focus $w.options.list
}

Classy::Editor method _checkerdo {files pattern cmd} {
	private $object checker
	set w $object.checker
	set checker(cancel) 0
	foreach file $files {
		if $checker(cancel) {return}
		if [file isdir $file] {
			if $checker(recursive) {
				set temp [glob -nocomplain [file join $file *]]
				if [llength $temp] {$object _checkerdo $temp $pattern $cmd}
			}
		} elseif {[string match $pattern $file]} {
			$w.options.files configure -label "Checking $file"
			Classy::update Classy::Editor-_checkerdo
			catch {exec $cmd $file} result
			set result [split $result \n]
			set result [list_select -regexp $result {:[0-9]}]
			eval $object.checker.options.list insert end $result
		}
	}
}

Classy::Editor method _checker {args} {
	private $object checker
	set w $object.checker
	$w.options.list delete 0 end
	set files $checker(files)
	set pattern $checker(pattern)
	set cmd $checker(cmd)
	$object _checkerdo $files $pattern $cmd
	$w.options.files configure -label "Files"
}

Classy::Editor method checker {} {
	private $object options checker
	set w $object.checker
	if ![info exists checker(files)] {
		set checker(files) [pwd]
		set checker(pattern) *.tcl
		set checker(recursive) 1
		set checker(cmd) procheck
	}
	if ![winfo exists $w] {
		Classy::Dialog $w -cache 1
		wm title $w checker
		set what "\[$w.options.find get\] "
		$w add goto Goto [list $object _checkergoto] default
		$w add check Check [list $object _checker]
		$w add cancel Cancel [list $object _checkercancel]
		$w persistent add checker goto
		Classy::FileEntry $w.options.files -label Files -selectmode persistent -orient stacked \
			-textvariable [privatevar $object checker(files)] -command "$object _checker"
		Classy::Entry $w.options.pattern -label "File Pattern" \
			-combo 20 \
			-textvariable [privatevar $object checker(pattern)] \
			-command [list $object _checker]
		Classy::Entry $w.options.checker -label "Checker Command" \
			-combo 20 \
			-textvariable [privatevar $object checker(cmd)]
		Classy::ListBox $w.options.list -command [list $object _checkergoto]
		checkbutton $w.options.recursive -variable [privatevar $object checker(recursive)] -text "Recursive"
		grid $w.options.checker -sticky we
		grid $w.options.recursive -sticky we
		grid $w.options.files -sticky we
		grid $w.options.pattern -sticky we
		grid $w.options.list -sticky nswe
		grid rowconfigure $w.options 4 -weight 1
		grid columnconfigure $w.options 0 -weight 1
	} else {
		$w place
		focus $w.options.pattern
	}
	focus $w.options.pattern
}

