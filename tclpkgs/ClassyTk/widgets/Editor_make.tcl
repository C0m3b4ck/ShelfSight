Classy::Editor method _makegoto {args} {
	private $object make
	set w $object.make
	set spec [$w.options.list get]
	set spec [lindex $spec 0]
	if ![regexp {^([^:]+):([0-9]+)} $spec temp file line] {return}
	set file [file join $make(dir) $file]
	$object goto $file:$line
	Classy::update Classy::Editor-_makegoto
	focus $w.options.list
}

Classy::Editor method _make {args} {
	private $object make
	set w $object.make
	$w.options.list delete 0 end
	set dir $make(dir)
	set cmd $make(cmd)
	$w.options.cmd configure -label "Making"
	Classy::update Classy::Editor-_make
	set keep [pwd]
	cd $dir
	set error [catch {eval exec $cmd} result]
	cd $keep
	set result [split $result \n]
	eval $object.make.options.list insert end $result
	$object.make.options.list insert end done
	$w.options.cmd configure -label "Make Command"
	focus $w.options.list
}

Classy::Editor method make {} {
	private $object make
	set w $object.make
	if ![info exists make(dir)] {
		set make(dir) [pwd]
		set make(cmd) make
	}
	if ![winfo exists $w] {
		Classy::Dialog $w -cache 1
		wm title $w make
		$w add goto Goto [list $object _makegoto] default
		$w add make Make [list $object _make]
		$w persistent add goto make
		Classy::FileEntry $w.options.dir -label Directory -selectmode browse -orient stacked \
			-textvariable [privatevar $object make(dir)] \
			-combo 20
		Classy::Entry $w.options.cmd -label "Make Command" \
			-combo 20 \
			-textvariable [privatevar $object make(cmd)] \
			-command [list $object _make]
		Classy::ListBox $w.options.list -command [list $object _makegoto]
		grid $w.options.dir -sticky we
		grid $w.options.cmd -sticky we
		grid $w.options.list -sticky nswe
		grid rowconfigure $w.options 2 -weight 1
		grid columnconfigure $w.options 0 -weight 1
	} else {
		$w place
	}
	focus $w.options.cmd
}


