Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	Classy::DynaTool $object.maintool  \
		-height 21 \
		-type MainTool
	grid $object.maintool -row 0 -column 0 -sticky new
	scrollbar $object.scrollbar2
	
	Classy::HTML $object.html
	grid $object.html -row 1 -column 0 -columnspan 2 -sticky nesw
	scrollbar $object.vbar
	grid $object.vbar -row 1 -column 2 -sticky nesw
	scrollbar $object.hbar \
		-orient horizontal
	grid $object.hbar -row 2 -column 0 -columnspan 2 -sticky nesw
	Classy::Entry $object.entry1 \
		-label URL \
		-combo 10 \
		-width 4
	grid $object.entry1 -row 0 -column 1 -columnspan 2 -sticky nesw
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 1 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-title [tk appname]
	$object.maintool configure \
		-cmdw [varsubst object {$object.html}]
	$object.html configure \
		-xscrollcommand "$object.hbar set" \
		-yscrollcommand "$object.vbar set"
	bind $object.html <Configure> {
		# only for html_library
		catch {
			%W tag configure hr -tabs %w
			%W tag configure last -spacing3 %h
		}
	}
	$object.vbar configure \
		-command "$object.html yview"
	$object.hbar configure \
		-command "$object.html xview"
	$object.entry1 configure \
		-command [varsubst object {$object.html geturl}]
	Classy::DynaMenu attachmainmenu MainMenu $object.html
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
	return $object
}

