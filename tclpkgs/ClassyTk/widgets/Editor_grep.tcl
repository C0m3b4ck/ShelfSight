Classy::Editor method _grepgoto {args} {
	private $object grep
	set w $object.grep
	set spec [$w.options.list get]
	set spec [lindex $spec 0]
	$object goto $spec $grep(pattern)
	Classy::update Classy::Editor-_grepgoto
	focus $w.options.list
}

Classy::Editor method _grepcancel {} {
	private $object grep
	set grep(cancel) 1
}

Classy::Editor method _grepdo {pattern files} {
	private $object grep
	set w $object.grep
	set grep(cancel) 0
	foreach file $files {
		$w.options.files configure -label "Searching $file"
		Classy::update Classy::Editor-_grepdo
		if $grep(cancel) {return}
		if [file isdir $file] {
			if $grep(recursive) {
				set temp [glob -nocomplain [file join $file *]]
				if [llength $temp] {$object _grepdo $pattern $temp}
			}
		} else {
			if [catch {set f [open $file]}] continue
			set num 1
			while {![eof $f]} {
				set line [gets $f]
				if [regexp -- $pattern $line] {
					$object.grep.options.list insert end "$file:$num:$line"
				}
				incr num
			}
			close $f
		}
	}
}

Classy::Editor method _grep {args} {
	private $object grep
	set w $object.grep
	$w.options.pattern configure -label "Searching Pattern"
	$w.options.list delete 0 end
	set files $grep(files)
	set pattern $grep(pattern)
	$object _grepdo $pattern $files
	$w.options.pattern configure -label "Pattern"
	$w.options.files configure -label "Files"
}

Classy::Editor method grep {} {
	private $object options grep
	set w $object.grep
	if ![info exists grep(files)] {
		set grep(files) [pwd]
		set grep(pattern) ^proc
		set grep(recursive) 1
		set grep(context) 0
	}
	if ![winfo exists $w] {
		Classy::Dialog $w -cache 1
		wm title $w Grep
		set what "\[$w.options.find get\] "
		$w add goto Goto [list $object _grepgoto] default
		$w add cancel Cancel [list $object _grepcancel]
		$w persistent add grep goto
		Classy::FileEntry $w.options.files -label Files -selectmode persistent -orient stacked \
			-textvariable [privatevar $object grep(files)] -command "$object _grep"
		Classy::Entry $w.options.pattern -label Pattern \
			-combo 20 \
			-textvariable [privatevar $object grep(pattern)] \
			-command [list $object _grep]
		Classy::ListBox $w.options.list -command [list $object _grepgoto]
		checkbutton $w.options.recursive -variable [privatevar $object grep(recursive)] -text "Recursive"
		Classy::NumEntry $w.options.context -label Context -textvariable [privatevar $object grep(context)]
		grid $w.options.recursive $w.options.context -sticky we
		grid $w.options.files -columns 2 -sticky we
		grid $w.options.pattern -columns 2 -sticky we
		grid $w.options.list -columns 2 -sticky nswe
		grid rowconfigure $w.options 3 -weight 1
		grid columnconfigure $w.options 0 -weight 1
	} else {
		$w place
		focus $w.options.pattern
	}
	focus $w.options.pattern
}
