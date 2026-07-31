Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	Classy::Browser $object.browser  \
		-list {[concat .. [glob [pwd]/*]]} \
		-gettext gettext \
		-getdata getdata \
		-getimage getimage \
		-height 50 \
		-width 50
	grid $object.browser -row 2 -column 0 -sticky nesw
	frame $object.dir  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.dir -row 0 -column 0 -sticky nesw
	Classy::DynaTool $object.dir.tool  \
		-cmdw .try.dedit.work \
		-height 21 \
		-type DirTool
	grid $object.dir.tool -row 0 -column 0 -sticky nesw
	Classy::Entry $object.dir.entry \
		-label Dir \
		-default dir \
		-textvariable {[varsubst object {status($object.browser,dir)}]} \
		-width 4
	grid $object.dir.entry -row 0 -column 1 -sticky nesw
	grid columnconfigure $object.dir 1 -weight 1
	frame $object.file  \
		-borderwidth 0 \
		-height 10 \
		-width 10
	grid $object.file -row 1 -column 0 -sticky nesw
	Classy::Entry $object.file.entry \
		-label File \
		-textvariable {[varsubst object {status($object.browser,file)}]} \
		-width 4
	grid $object.file.entry -row 0 -column 1 -sticky nesw
	Classy::DynaTool $object.file.tool  \
		-cmdw .try.dedit.work \
		-height 17 \
		-type FileTool
	grid $object.file.tool -row 0 -column 0 -sticky nesw
	grid columnconfigure $object.file 1 -weight 1
	grid columnconfigure $object 0 -weight 1
	grid rowconfigure $object 2 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure  \
		-title {[tk appname]}
	bind $object.browser <<Action>> {filer_action %W %x %y}
	bind $object.browser <<Adjust>> {filer_adjust %W %x %y}
	bind $object.browser <<Drag>> {filer_drag %W %x %y %X %Y}
	bind $object.browser <<Drop>> {filer_drop w x y}
	bind $object.browser <<MExecute>> {filer_exec %W %x %y}
	bind $object.browser <<MExecuteAjust>> {filer_exec_adjust %W %x %y}
	$object.dir.entry configure \
		-command [varsubst object {setdir $object.browser}]
	$object.file.entry configure \
		-command [varsubst object {file_rename $object.browser}]
	Classy::DynaMenu attachmainmenu MainMenu $object.browser
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
setdir $object.browser [pwd]
	return $object
}

