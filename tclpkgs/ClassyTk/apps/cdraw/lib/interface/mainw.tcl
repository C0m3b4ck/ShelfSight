Classy::Toplevel subclass mainw
mainw method init args {
	super init
	# Create windows
	Classy::DynaTool $object.maintool  \
		-width 179 \
		-height 21 \
		-max 2 \
		-type MainTool
	grid $object.maintool -row 0 -column 0 -columnspan 3 -sticky new
	Classy::Canvas $object.canvas \
		-papersize A4 \
		-height 50 \
		-relief sunken \
		-scrollregion {0 0 595p 842p} \
		-width 50
	grid $object.canvas -row 2 -column 1 -sticky nesw
	scrollbar $object.scrollbar1
	
	scrollbar $object.scrollv
	grid $object.scrollv -row 2 -column 2 -sticky nesw
	scrollbar $object.scrollh \
		-orient horizontal
	grid $object.scrollh -row 3 -column 1 -sticky nesw
	Classy::DynaTool $object.dynatool1  \
		-orient vertical \
		-height 20 \
		-max 2 \
		-type SideBar
	grid $object.dynatool1 -row 2 -column 0 -rowspan 2 -sticky nesw
	Classy::DynaTool $object.extratool  \
		-type Properties
	grid $object.extratool -row 1 -column 0 -columnspan 3 -sticky nesw
	grid columnconfigure $object 1 -weight 1
	grid rowconfigure $object 2 -weight 1

	if {"$args" == "___Classy::Builder__create"} {return $object}
	# Parse this
	$object configure \
		-title [tk appname]
	$object.maintool configure \
		-cmdw [varsubst object {$object}]
	$object.canvas configure \
		-xscrollcommand "$object.scrollh set" \
		-yscrollcommand "$object.scrollv set"
	$object.scrollv configure \
		-command "$object.canvas yview"
	$object.scrollh configure \
		-command "$object.canvas xview"
	$object.dynatool1 configure \
		-cmdw [varsubst object {$object}]
	$object.extratool configure \
		-cmdw [varsubst object {$object}]
	Classy::DynaMenu attachmainmenu MainMenu $object
	# Configure initial arguments
	if {"$args" != ""} {eval $object configure $args}
# ClassyTk Finalise
private $object canvas current
set ::status($object.canvas,object) $object
array set current {
	zoom 100
	currentundo 1
	skeletonfonts 1
	skeletonredraw 0
	scalelock 1
}
set canvas $object.canvas
uplevel #0 [list private $object current]
focus $object.canvas
$object.extratool configure -type Properties
select_start $object element
set current(tool) element
Classy::rebind $object.canvas $object
Classy::DynaMenu cmdw MainMenu $object
clearpage $object
	set current(w) $object.canvas
	return $object
}