Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	frame $object.tools  \
		-borderwidth 2 \
		-height 10 \
		-relief groove \
		-width 10
	grid $object.tools -row 0 -column 2 -sticky nesw
	button $object.tools.clock \
		-relief flat \
		-text {Jul 02 15:29:06} \
		-textvariable clock(value)
	grid $object.tools.clock -row 0 -column 2 -sticky nesw
	Classy::CmdWidget $object.tools.cmd \
		-prompt {% } \
		-height 5 \
		-width 10
	grid $object.tools.cmd -row 1 -column 0 -columnspan 3 -sticky nesw
	Classy::OptionMenu $object.tools.connect  \
		-text ccenter
	grid $object.tools.connect -row 0 -column 0 -sticky nesw
	$object.tools.connect set ccenter
	button $object.tools.button1 \
		-text L
	grid $object.tools.button1 -row 0 -column 1 -sticky nsw
	grid columnconfigure $object.tools 1 -weight 1
	grid rowconfigure $object.tools 1 -weight 1
	Classy::ScrolledFrame $object.progs  \
		-bd 0 \
		-borderwidth 0 \
		-height 1 \
		-width 1
	grid $object.progs -row 0 -column 0 -sticky nesw
		Classy::Paned $object.paned1
	grid $object.paned1 -row 0 -column 1 -sticky nesw
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 0 -weight 1

	# End windows
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-destroycommand "exit" \
		-title [tk appname]
	$object.tools.connect configure \
		-command [varsubst object {$object.tools.cmd connect [$object.tools.connect get]}] \
		-list [winfo interps]
	$object.tools.button1 configure \
		-command [varsubst object {set w [Classy::cmd]
$w.edit configure -prompt {[tk appname] % }
$w.edit connect [$object.tools.connect get]}]
	$object.paned1 configure \
		-window [varsubst object {$object.tools}]
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
$object.tools.cmd clearall
	return $object
}
