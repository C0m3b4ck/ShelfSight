Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	Classy::DynaTool $object.maintool  \
		-width 179 \
		-type MainTool \
		-height 21
	grid $object.maintool -row 0 -column 0 -sticky new
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 1 -weight 1
	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-destroycommand "exit" \
		-title [tk appname]
	$object.maintool configure \
		-cmdw [varsubst object {$object}]
	Classy::DynaMenu attachmainmenu MainMenu $object
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

